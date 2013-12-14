---
layout: page
title: Caching Data
section: Performance
---

There are two hard things in computer science: naming things, cache
invalidation, and off-by-one errors. Let's talk about that second one.

Caching is difficult to get right, but Rails provides you with some excellent
tools to help make it easy. In this tutorial, we'll look at how to pre-calculate data so requests utilizing that data can respond quickly.

## Setup

{% include custom/sample_project_advanced.html %}

## Simple Data Caching

### Terminology

Computers compute. Sometimes, they do a lot of computing. Sometimes, they need
to do so much computing that it takes a really, really long time. But we want our sites to be fast. What do we do?

The answer is a **cache**. A cache is a temporary storage place. In software, the cache is typically used to store data you want fast access to, but the cache is not the primary storage place. 

The **database** is meant to be your durable, long-run data storage. You should use a cache in such a way that if it gets totally deleted you haven't lost any data of value. 

An empty cache is **"cold"** and as we calculate and store data values we're **"warming"** it. If we try and load a piece of data from the cache and it's not that, that's a **"cache miss"**. If the data *is* there when we want it, that's a **"cache hit"**.

When our underlying database data changes and the cache entries need to be removed we're **invalidating** them.

### The problem

We're working with the blog application you may have used in previous
tutorials, but if you haven't, it's pretty straightforward. `Author`s write
`Article`s that have `Comment`s and `Tag`s. We're going to add some caching to
the admin dashboard to improve its performance.

> "If you can not measure it, you can not improve it." - Lord Kelvin

When you have a web application, statistics on its usage are important. They
can help you optimize conversions, plan new content based on what's been
popular on the past, and tons of other things.

Let's load up the site and check it out:

{% terminal %}
$ rails s
{% endterminal %}

If you open [http://localhost:3000](http://localhost:3000) in your browser,
you'll see something like this:

![dashboard](/images/caching/dashboard.png)

That part at the bottom is what we'll be improving upon. We collect a number
of statistics about the articles, comments, and the number of words in the sum
of them. This page renders pretty quickly at the moment, but as the number of
articles and comments goes up, it can get really slow. 

Let's change things so that we can see this difference. Open up `db/seeds.rb` and increase the number of objects generated:

```ruby
Author.generate_samples(100)
Tag.generate_samples(100)
Article.generate_samples(1000)
```

Then, re-build the database:

{% terminal %}
$ bundle exec rake db:drop db:migrate db:seed
$ rails s
{% endterminal %}

Now load up the site again, and it should feel...slow.

```text
Rendered dashboard/show.html.erb within layouts/application (19.4ms)
Completed 200 OK in 4776ms (Views: 57.4ms | ActiveRecord: 3113.9ms)
```

Five seconds. Hit refresh. Another five seconds. This situation is
unacceptable, so let's fix it.

## An Experimental Approach: Class Instance Variables

The easiest possible thing that we can do is to *Just Use Ruby*. 

### Finding the Slowness

Let's check out the `DashboardController`, where the calculation is done:

```ruby
class DashboardController < ApplicationController
  def show
    @articles = Article.for_dashboard
    @article_count = Article.count
    @article_word_count = Article.total_word_count
    @most_popular_article = Article.most_popular

    @comments = Comment.for_dashboard
    @comment_count = Comment.count
    @comment_word_count = Comment.total_word_count
  end
end
```

All the logic is pressed down to the models. Let's then check out
`Article.total_word_count`:

```ruby
def self.total_word_count
  all.inject(0) {|total, a| total += a.word_count }
end
```

We load up all the articles and loop through them calling `word_count` on each. This works, but will be super slow. We re-run the calculation on each new request! 

### Memoization

We can use memoization to improve this situation. Memoization is a technique where
a method is made faster by not repeating cacluations that were previously
done. In Ruby, this is most commonly accomplished through instance variables. For instance, with the `total_word_count` method we can add an instance variable in front of the calculation:

```ruby
def self.total_word_count
  @total_word_count ||= all.inject(0) {|total, a| total += a.word_count }
end
```

#### How Memoization Works

Now, the first time we use `total_word_count`, it will save the answer into the
`@total_word_count` variable. On subsequent calls the `||=` will return the previously-calculated data instead of re-performing the calculation.

Note that since the instance variable is created inside a `self.` class method, it is stored on with the class itself. Remember that classes in Ruby are instances of the `Class` class. If you were creating a *normal* instance variable in an `Article` instance method it would only be attached to that instance of `Article` which gets wiped away between requests.

But the class is **not** re-loaded between requests. Thus the class instance variable will still be there for the subsequent requests.

#### Memoizing Other Methods

Go ahead and use the same technique for the other methods called from the
`DashboardController#show`.

#### Testing the Results

Start up your server again with `rails s` and load the dashboard page. You should see output in your server log similar to this:

```text
Rendered dashboard/show.html.erb within layouts/application (17.6ms)
Completed 200 OK in 4311ms (Views: 48.3ms | ActiveRecord: 2843.4ms)
```

Then hit refresh in your browser and observe something like this:

```text
Rendered dashboard/show.html.erb within layouts/application (10.8ms)
Completed 200 OK in 43ms (Views: 19.8ms | ActiveRecord: 20.8ms)
```

Whoah! Here's a diff of all changes made in this experiment:

```diff
diff --git a/app/models/article.rb b/app/models/article.rb
index 4967d0f..2e679a9 100644
--- a/app/models/article.rb
+++ b/app/models/article.rb
@@ -28,7 +28,7 @@ class Article < ActiveRecord::Base
   end

   def self.most_popular
-    all.sort_by{|a| a.comments.count }.last
+    @most_popular ||= all.sort_by{|a| a.comments.count }.last
   end

   def self.random
@@ -57,7 +57,7 @@ class Article < ActiveRecord::Base
   end

   def self.total_word_count
-    all.inject(0) {|total, a| total += a.word_count }
+    @total_word_count ||= all.inject(0) {|total, a| total += a.word_count }
   end

   def self.generate_samples(quantity = 1000)
diff --git a/app/models/comment.rb b/app/models/comment.rb
index feafe3f..47f9350 100644
--- a/app/models/comment.rb
+++ b/app/models/comment.rb
@@ -12,6 +12,6 @@ class Comment < ActiveRecord::Base
   end

   def self.total_word_count
-    all.inject(0) {|total, a| total += a.word_count }
+    @total_word_count ||= all.inject(0) {|total, a| total += a.word_count }
   end
 end
```

Just three lines changed, adding three variables, and we went from 4,000 ms to
43 ms! So we're done, right?

#### Memoization Means Problems

Not so fast. The first page load still takes four seconds. And it'll take four
seconds every time we restart our server, as well. That's often not good
enough. 

More importantly, our cached values never expire! When we add a new article or comment the old data will still be memoized. The dashboard will never change! We could chase around our code and find every place that changes an article or a comment and tell it to clear the cached values. But you'll miss one (or more) as the application grows and your cache won't work properly.

We need a better strategy.

## Using `Rails.cache`

There are software tools called 'key/value stores' that can tackle this
exact sitaution. From the name, you can infer that a key/value store... stores
keys and values. 

You know how to use hashes in Ruby. Think of a key/value store as a big-hash-as-a-server. It's persistent and can be shared by multiple processes or applications.

### Starting with Redis

There are multiple key/value stores, and so Rails provides an interface to use
any one you want. Just remember the Rails API, and you can use Redis,
Memcached, or another store that you may fancy.

Let's explore Redis which is an excellent key/value store.

<div class="note">
<p>You need to follow the <a href='installing_redis.html'>instructions for installing and configuring Redis</a> to follow this part of the tutorial.</p>
</div>

### Keys & Values in Ruby

First let's look at a simple Ruby `Hash`:

{% irb %}
irb > cache = {}
=> {}
irb > cache[:count] = 5
=> 5
irb > cache[:count]
=> 5
{% endirb %}

Easy, right? 

### `Rails.cache`

From the Rails console:

{% irb %}
irb > Rails.cache.write("count", 5)
=> "OK"
irb > Rails.cache.read("count")
=> 5
{% endirb %}

Your data is stored in the cache.

### Redis Console

You can connect to Redis directly to inspect keys and values:

{% terminal %}
$ redis-cli
redis 127.0.0.1:6379> select 1
OK
redis 127.0.0.1:6379[1]> keys *
1) "ns:count"
{% endterminal %}

That `"ns:count"` there shows we have a `count` key in the `ns` namespace.

### Using `fetch`

If you were to implement it right now, you'd probably do something like this:

```ruby
  def self.total_word_count
    count = Rails.cache.read("total_comment_word_count")

    unless count
      count = all.inject(0) {|total, a| total += a.word_count }
      Rails.cache.write("total_comment_word_count", count)
    end
    
    count
  end
```

Check to see if we have it cached, if not, calculate and store it, then return
the answer. It'll work.

But the `#fetch` method will make your life much easier. It's a method available on any `Hash` in Ruby:

{% irb %}
irb > sample = {}
=> {}
irb > sample.fetch("count") { 5 }
=> 5
{% endirb %}

We created the `sample` hash with no keys, so asking for `sample["count"]` would normally return `nil`. But with `#fetch` you can pass a block which provides a default value. Since the `"count"` key was not found, `5` was returned.

**But**, it doesn't store that value. So if you now ask for the key again the normal way:

{% irb %}
irb > cache["count"]
=> nil
{% endirb %}

It doesn't actually save the value into our `Hash`. Bummer. 

### Rails Cache & `#fetch`

However, `Rails.cache` is not a normal Ruby hash. It's a specialized class which not only implements `#fetch`, but also stores the value:

{% irb %}
irb > Rails.cache.clear
=> 1
irb > Rails.cache.read("count")
=> nil
irb > Rails.cache.fetch("count") { 5 }
=> 5
irb > Rails.cache.read("count")
=> 5
{% endirb %}

Awesome! Now, we can write our method in a much simpler way:

```ruby
  def self.total_word_count
    Rails.cache.fetch("comment_total_word_count") do
      all.inject(0) {|total, a| total += a.word_count }
    end
  end
```

#### Keys Must Be Unique

One small note: you may notice that we've added `comment_` to the front of our
key. This is because we have a `total_word_count` for both articles and
comments. The keys in a hash much be unique.

#### Cache Data Must Be Simple

Check out the `#most_popular` method with memoization:

```ruby
def self.most_popular
  @most_popular ||= all.sort_by{|a| a.comments.count }.last
end
```

This stored a `Article` object in `@most_popular`. 

Your data cache (Redis) is not Ruby. It doesn't know about `Article` objects. It only deals with strings, integers, and a few other simple data types. You can try to *serialize* your `Article` instance into a string and *deserialize* it later, but you're going to have a bad time. Serialization causes lots of new problems.

Only store those simple data types into the cache. For `most_popular`, you can store just the `id` of the most popular article in the cache. Then, when the method is called, find the `id` and execute a single database query to get the actual article.

```ruby
def self.most_popular
  id = Rails.cache.fetch("article_most_popular") do
    all.sort_by{|a| a.comments.count }.last.id
  end

  Article.find(id)
end
```

#### Implement It

Go ahead and implement these tactics for all three of our methods that need
caching.  When you hit the server, the _very first_ page load will be slow,
 then all the rest should be fast. Restart your server, and it should still
be fast. Your cache is now *warm*. 

However, that first page load is still slow. Not cool. And if we add a new
`Article` or `Comment`, it doesn't update the data because our cache hasn't been expired.

## Explicit Cache Expiration

When do we need to recalculate the data? Whenever a comment or article is added, removed, or changed. 

### Using Rails Callbacks

Let's take advantage of Rails' callbacks system to invalidate our cache when those objects are changed.

#### Creating `InvalidatesCache`

Create a file `app/models/invalidates_cache.rb` with these contents:

```ruby
module InvalidatesCache
  extend ActiveSupport::Concern

  included do
    after_create :invalidate_cache
    after_update :invalidate_cache
    after_destroy :invalidate_cache

    def invalidate_cache
      Rails.cache.clear
    end
  end
end
```

This module makes use of the `included` method from `ActiveSupport::Concern`. All the code between the `do` and `end` will be executed in the context of the including class, just as if you'd written these lines in the model class itself.

#### Using `InvalidatesCache`

Open your `Article` and `Comment` models and add the following inside the class definition. Typically includes are done at the top of the class, so it'd look like...

```
class Article < ActiveRecord::Base
  include InvalidatesCache
  # The rest of the existing code...
end
```

Now, when we make a new `Article` or `Comment` (or update it), the entire cache gets
blown away. 

#### Observing the Behavior

Experiment with it in the Rails console:

{% irb %}
irb > Article.create title: "new article", body: "This is a body", author_id: 1
=> #<Article id: 1001, title: "new article", body: "This is a body", created_at: "2013-04-26 20:04:49", updated_at: "2013-04-26 20:04:49", author_id: 1>
irb > Rails.cache.read("article_most_popular")
=> nil
{% endirb %}

Blowing away the entire cache is quite expensive because now it's totally *cold*. Every subsequent request that uses cached data will *miss* until it's all recalculated and stored.

#### Fine-Grained Expiration

To do this right we need to know exactly which keys should be invalidated when a record changes. We need to keep track of which calculation goes with which key, and update them accordingly. 

We also need to know which calculations depend on each other. For example, the total words calculation relies on both articles and comments, but the most popular article calculation only relies on articles.

Caching is hard.

## Key-based cache expiration

What if I told you that Rails could handle all these details for you? Enter
key-based cache expiration. Here's the lowdown.

1. The cache is append-only. What this means is that we never change the value
   of the cache, but change the _key_ instead. You'll see why this matters
   in a moment.
2. The key is calculated based on the object who the cache is based on. So,
   when the object changes, the key changes. That's why it's append-only: when
   it needs to be expired, we get a different key.
3. You might be thinking, "If we never delete things, won't we just run out of
   memory?" Many key/value stores that are used as caches automatically evict
   older entries, and so we just don't care, we let the store handle that. They
   do this based on a 'least recently used' algorithm.
4. You can nest objects, and that ties their keys (and therefore, their values)
   together. So if I'm caching `Post`s and thier `Comment`s, and I nest
   `Comment`s inside of `Posts`, then when I get a new `Comment`, the `Post`'s
   cache gets invalidated.

That's it! Let's try it with the 'all articles' page first. Start up your
server and hit `http://localhost:3000/articles` in your browser.

```text
Rendered articles/index.html.erb within layouts/application (19306.7ms)
Completed 200 OK in 19449ms (Views: 6716.8ms | ActiveRecord: 12731.3ms)
```

Brutal! We have to load a thousand articles, a hundred tags, and count all
the comments... mega slow.

To begin, we have to add the `cache_digests` gem to our Gemfile, then
`bundle`:

{% terminal %}
$ echo "gem 'cache_digests'" >> Gemfile
$ bundle
{% endterminal %}

If we were in Rails 4, we wouldn't need to do this.

Anyway, the first thing we need to do is modify our associations to `touch`
their parent objects. For example, in `app/models/article.rb`:

```ruby
belongs_to :author, :touch => true
```

This is needed on the `belongs_to` side of associations, as children don't
need to be updated when their parent is. The `Article`, `Comment`, and
`Tagging` models all need to be updated.

Next, we need to enable caching in development by modifying
`config/environments/development.rb`:

```ruby
config.action_controller.perform_caching = true
```

Normally, this would be false, but since we're experimenting with caching, we
want it on.

Then, we need to actually add caching to our view. Modify
`app/views/articles/index.html.erb` to use a `cache` block:

```html+erb
<% cache article do %>
  <%= link_to article.title, article_path(article) %>
  <span class='tag_list'><%= article.tag_list %></span>
  <span class='actions'>
    <%= edit_icon(article) %>
    <%= delete_icon(article) %>
  </span>
  <%= pluralize article.comments.count, "Comment" %>
<% end %>
```

Now, each of these blocks will have a cache based on their object, and if we
modify one of them, only its cache will be invalidated. Try it out: open up
your browser, hit `http://localhost:3000`, and then refresh. As before, the
first hit should be slow, but after that, it should be snappy.

```text
Rendered articles/index.html.erb within layouts/application (29488.8ms)
Completed 200 OK in 29660ms (Views: 16398.4ms | ActiveRecord: 13261.1ms)

...

Rendered articles/index.html.erb within layouts/application (582.2ms)
Completed 200 OK in 599ms (Views: 579.5ms | ActiveRecord: 18.7ms)
```
Before the final output, you should have seen a bunch of these:

```text
Read fragment views/articles/995-20130426175152/68d8223fc7ff88a529e72542807fd454 (0.2ms)
Read fragment views/articles/996-20130426175152/68d8223fc7ff88a529e72542807fd454 (0.1ms)
Read fragment views/articles/997-20130426175153/68d8223fc7ff88a529e72542807fd454 (0.2ms)
Read fragment views/articles/998-20130426175154/68d8223fc7ff88a529e72542807fd454 (0.1ms)
```

If we examine Redis, we can see all of the keys in there, too:

{% terminal %}
$ redis-cli
redis 127.0.0.1:6379> select 1
OK
redis 127.0.0.1:6379[1]> keys *
1) "ns:views/articles/302-20130426174621/68d8223fc7ff88a529e72542807fd454"
2) "ns:views/articles/131-20130426174541/68d8223fc7ff88a529e72542807fd454"
3) "ns:views/articles/304-20130426174621/68d8223fc7ff88a529e72542807fd454"
4) "ns:views/articles/102-20130426174536/68d8223fc7ff88a529e72542807fd454"
5) "ns:views/articles/234-20130426174604/68d8223fc7ff88a529e72542807fd454"
6) "ns:views/articles/104-20130426174536/68d8223fc7ff88a529e72542807fd454"
...
999) "ns:views/articles/468-20130426174709/68d8223fc7ff88a529e72542807fd454"
1000) "ns:views/articles/90-20130426174533/68d8223fc7ff88a529e72542807fd454"
1001) "ns:views/articles/795-20130426174934/68d8223fc7ff88a529e72542807fd454"
{% endterminal %}

Nice! We still have that bad first page load, but rather than blow away the
entire cache, it only blows away the portion of the cache, so that's a nice
improvement. Let's try it out on the show page for an `Article`. Find one with
a lot of comments, or just add a bunch of comments to one in IRB. Mine is #799,
so I opened up `http://localhost:3000/articles/799` in my browser. It has 15
comments:

```text
Rendered articles/show.html.erb within layouts/application (353.3ms)
Completed 200 OK in 392ms (Views: 366.1ms | ActiveRecord: 18.3ms)
```

Not to shabby. Let's examine the show view, it's in
`app/views/articles/show.html.erb`:

```html+erb
<h1><%= @article.title %></h1>
<h4>Published <%= @article.created_at %></h4>
<p class='tag_list'><em>Tagged:</em> <%= @article.tag_list %></p>

<p><%= @article.body %></p>


<div class='article_actions'>
  <%= edit_icon(@article, "Edit") %>
  <%= delete_icon(@article, "Delete") %>
  <%= link_to "Back to All Articles", articles_path  %>
</div>

<h3><%= pluralize @article.comments.count, "Comment" %></h3>

<% @article.comments.each do |comment| %>
  <div class='comment'>
    <p>
      <em><%= comment.author_name %></em>
      said <%= distance_of_time_in_words(@article.created_at, comment.created_at) %> later:
    </p>
    <p><%= comment.body %></p>
  </div>
<% end %>

<h4>Add Your Comment</h4>
<%= form_for(@article.comments.new) do |f| %>
    <p>
        <%= f.label :author_name %><br/>
        <%= f.text_field :author_name %>
    </p>
    <p>
        <%= f.label :body %><br/>
        <%= f.text_area :body %>
    </p>
    <%= f.hidden_field :article_id%>
    <%= f.submit "Save" %>
<% end %>
```

We need to tell Rails two things:

1. We want to cache all of this based on the `Article`.
2. We want to nest in a cache for the `Comment`s.

The first part is easy:

```html+erb
<% cache @article do %>
  <h1><%= @article.title %></h1>
  <h4>Published <%= @article.created_at %></h4>
  <p class='tag_list'><em>Tagged:</em> <%= @article.tag_list %></p>
...
```

If you refresh the page a few times, you'll see the cache warm up and things
will get snappy.

![before caching](/images/caching/before_cache.png)

```text
Read fragment views/articles/799-20130426174937/33c6b50a8951af1b50232cdb6f7ffb60 (0.3ms)
Rendered articles/show.html.erb within layouts/application (0.6ms)
Completed 200 OK in 17ms (Views: 16.5ms | ActiveRecord: 0.1ms)
```

Nice. Let's try adding a comment by using a form at the bottom.
Fill it out...

![comment](/images/caching/comment.png)

and hit submit...

![after caching](/images/caching/after_cache.png)

```text
Read fragment views/articles/799-20130427002754/33c6b50a8951af1b50232cdb6f7ffb60 (0.3ms)
  Tag Load (10.5ms)  SELECT "tags".* FROM "tags" INNER JOIN "taggings" ON "tags"."id" = "taggings"."tag_id" WHERE "taggings"."article_id" = 799
   (3.7ms)  SELECT COUNT(*) FROM "comments" WHERE "comments"."article_id" = 799
  Comment Load (3.6ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = 799
Write fragment views/articles/799-20130427002754/33c6b50a8951af1b50232cdb6f7ffb60 (0.4ms)
  Rendered articles/show.html.erb within layouts/application (30.7ms)
Completed 200 OK in 45ms (Views: 25.9ms | ActiveRecord: 17.9ms)
```

Nice! See that 'Read fragment' and 'write fragment'? Because of our `:touch`,
when the `Comment` was created, it updated the timestamp on the `Article`,
which updated the cache.

There's one big problem with this, though. Since we've modified our `Article`'s
`updated_at`, it now shows that it was last modified now. That didn't really
happen. You might not care this time, but for some applications, this isn't
great. Wouldn't there be a better way?

Turns out there is! We can just nest the cache blocks and then `:touch` isn't
needed. Let's remove them from the models, and then try adding another comment:

![stale cache](/images/caching/stale_cache.png)

Oh no! It still says 16 total comments, and this troll-y comment I left before
is the 'newest' one. But I added another! Where'd it go?

Well, because our `updated_at` wasn't modified for `@article`, we used the
old cache and didn't update to the new one. Bummer. So what to do? We can
see the nested dependencies with this rake task:

{% terminal %}
$ bundle exec rake cache_digests:nested_dependencies TEMPLATE=articles/show
[

]
{% endterminal %}

Nothing. Let's fix that. Change the view template a bit:

```html+erb
<%= render partial: 'comments/comment', collection: @article.comments %>
```

and make a new partial (in `app/views/comments/_comment.html.erb`):

```html+erb
<div class='comment'>
  <p>
    <em><%= comment.author_name %></em>
    said <%= distance_of_time_in_words(comment.article.created_at, comment.created_at) %> later:
  </p>
  <p><%= comment.body %></p>
</div>
```

Let's examine those dependencies again:

{% terminal %}
$ bundle exec rake cache_digests:nested_dependencies TEMPLATE=articles/show
[
  "comments/comment"
]
{% endterminal %}

Great, so now Rails will know that we rely on this partial as well. Rails will
cache each one individually, as well as tie them to the greater view. Awesome.

Hit refresh, and you should see 17 (or whatever number you had +1) comments.
Awesome.

### One last problem

In the case of our dashboard, we can't simply use `cache_digests` because
the objects are simple numbers, not objects with an `updated_at`. Fixing
this problem is currently left as an advanced exercise. 

## More Resources

* [Memoization](http://en.wikipedia.org/wiki/Memoization)
* [How Key-based Cache Expiration Works](http://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works)
* [cache_digests gem](https://github.com/rails/cache_digests)
* [The 'caching' branch of blogger_advanced](https://github.com/jumpstartlab/blogger_advanced/tree/caching).
  Commits roughly correspond to sections of this tutorial.
