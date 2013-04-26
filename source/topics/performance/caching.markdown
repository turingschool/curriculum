---
layout: page
title: Caching in Rails
section: Performance
---

There are two hard things in computer science: naming things, cache
invalidation, and off-by-one errors. Let's talk about that second one.

Caching is difficult to get right, but Rails provides you with some excellent
tools to help make it easy. In this tutorial, we're going to cover how to add
caching to your Rails application to make it super snappy.

### Setup

{% include custom/sample_project_advanced.html %}

## Simple Data Caching

Computers compute. Sometimes, they do a lot of computing. Sometimes, they need
to do so much computing that it takes a really, really long time. Often, that's
not acceptable: we want our sites to be fast. So what to do?

The answer is a cache.

We're working with the blog application you may have used in previous
tutorials, but if you haven't, it's pretty straightforward. `Author`s write
`Article`s that have `Comment`s and `Tag`s. We're going to add some caching to
the admin dashboard to improve its performance.

### The problem

> "If you can not measure it, you can not improve it." - Lord Kelvin

When you have a web application, statistics on its usage are nice to have. They
can help you optimize conversions, plan new content based on what's been
popular on the past, and tons of other things.

Let's load up the site and check it out:

{% console %}
$ rails s
{% endconsole %}

If you open [http://localhost:3000](http://localhost:3000) in your browser,
you'll see something like this:

![dashboard](/images/caching/dashboard.png)

That part at the bottom is what we'll be improving upon. We collect a number
of statistics about the articles, comments, and the number of words in the sum
of them. This page renders pretty quickly at the moment, but as the number of
articles and comments goes up, it can get really slow. Let's change things so
that we can see this difference. Open up `db/seeds.rb` and up the numbers:

```
Author.generate_samples(100)
Tag.generate_samples(100)
Article.generate_samples(1000)
```

Then, re-build the database:

{% console %}
$ bundle exec rake db:drop db:migrate db:seed
$ rails s
{% endconsole %}

Now load up the site again, and it should feel... slow.

```
Rendered dashboard/show.html.erb within layouts/application (19.4ms)
Completed 200 OK in 4776ms (Views: 57.4ms | ActiveRecord: 3113.9ms)
```

Five seconds. Hit refresh. Another five seconds. This situation is
unacceptable, so let's fix it.

### The simplest thing: instance variable memoization

The easiest possible thing that we can do is to Just Use Ruby. Let's check
out the `DashboardController`, where the calculation is done:

```
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

All the logic, captured in the models. Nice. Let's check out
`Article.total_word_count`:

```
def self.total_word_count
  all.inject(0) {|total, a| total += a.word_count }
end
```

So we load up all the `Article`s, and loop through them. This works, but
of course will be super slow: we load up every Article on each request! We
can use memoization to improve this situation. Memoization is a technique where
a method is made faster by not repeating cacluations that were previously
done. In Ruby, this is most commonly accomplished through instance variables:

```
def self.total_word_count
  @total_word_count ||= all.inject(0) {|total, a| total += a.word_count }
end
```

Now, the first time we use `total_word_count`, it will save the answer into the
`@total_word_count` variable, and due to the `||=`, we won't re-perform the
calculation on subsequent calls. 

Go ahead and do the same thing for the other methods called in the
`DashboardController#index`.

Let's test this out: start up your server again with `rails s` and load the
page, then hit refresh:

```
Rendered dashboard/show.html.erb within layouts/application (17.6ms)
Completed 200 OK in 4311ms (Views: 48.3ms | ActiveRecord: 2843.4ms)

...

Rendered dashboard/show.html.erb within layouts/application (10.8ms)
Completed 200 OK in 43ms (Views: 19.8ms | ActiveRecord: 20.8ms)
```

Whoah! Here's my diff:

```
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

Not so fast. The first page load still takes four seconds. And it'll take four
seconds every time we restart our server, as well. That's often not good
enough. And since our cached value never expires, it will also be wrong as soon
as we add a new article or comment. What we need are two things:

1. A way to persist our cached value across restarts of the server.
2. An 'expiration strategy' to update the value in the cache when things change.

### Better: Rails.cache

Luckily, people smarter than you or I have thought about this problem. There
are multiple bits of software called 'key/value stores' that can tackle this
exact sitaution. From the name, you can infer that a key/value store... stores
keys and values. You've already used keys and values in Ruby, with `Hash`es.
So basically, a key/value store is like a giant, persistant Ruby `Hash`. In
this section, we'll explore Redis, which is an excellent key/value store.

<div class="note">
<p>You need to follow the <a href='installing_redis.html'>instructions for installing and configuring Redis</a> to follow this part of the tutorial.</p>
</div>

There are multiple key/value stores, and so Rails provides an interface to use
any one you want. Just remember the Rails API, and you can use Redis,
Memcached, or another store that you may fancy.

The API is quite simple. Here's how you'd save a value in a Ruby `Hash`:

{% irb %}
irb > cache = {}
=> {}
irb > cache[:count] = 5
=> 5
irb > cache[:count]
=> 5
{% endirb %}

Easy, right? Well, with Rails, you just do this:

{% irb %}
irb > Rails.cache.write("count", 5)
=> true
irb > Rails.cache.read("count")
=> 5
{% endirb %}

Simple! If you check out the Redis console, you can see the value has been
stored into Redis:

{% console %}
$ redis-cli
redis 127.0.0.1:6379> select 1
OK
redis 127.0.0.1:6379[1]> keys *
1) "ns:count"
{% endconsole %}

That `"ns:count"` there shows we have a `count` key in the `ns` namespace.

Now, we could use this to save things in our Rails application, but first, I
want to show you a better syntax that you can use. If you were to implement
it right now, I bet you'd do something like this:

```
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
the answer. What's the matter with this?

In a word: `#fetch`.

Ruby has a really convenient method on `Hash` called `#fetch`. Here, let me
show you how it works:

{% irb %}
irb > cache = {}
=> {}
irb > cache.fetch("count") { 5 }
=> 5
{% endirb %}

Neat! The block we pass into `#fetch` gives us a value to return if there's
no key in the hash. One bad part about `#fetch`, though:

{% irb %}
irb > cache["count"]
=> nil
{% endirb %}

It doesn't actually save the value into our `Hash`. Bummer. However, `Rails.cache` not only implements `#fetch`, but also stores the value into the cache:

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

```
  def self.total_word_count
    Rails.cache.fetch("comment_total_word_count") do
      all.inject(0) {|total, a| total += a.word_count }
    end
  end
```

Look at that! Way nicer. We don't need to repeat the key, we don't need to
check the value, and it's all nice and clear. Easy!

One small note: you may notice that we've added `comment\_` to the front of our
key. This is because we have a `total_word_count` for both `Article`s and
`Comment`s, and if they shared a key, we'd get the wrong answer.

There's one other tricky bit with the cache. Check out the `#most\_popular`
method:

```
def self.most_popular
  @most_popular ||= all.sort_by{|a| a.comments.count }.last
end
```

This stored a `Article` object in our cache. That won't work. You should try to
only store primitive objects into the cache. So, we have to do this:

```
  def self.most_popular
    id = Rails.cache.fetch("article_most_popular") do
      all.sort_by{|a| a.comments.count }.last.id
    end

    Article.find(id)
  end
```

Go ahead and implement these tactics for all three of our methods that need
caching.  When you hit the server, the _very first_ page load should be slow,
and then all the rest should be fast. Restart your server, and it should still
be fast. Great!

However, that first page load is still slow. Not cool. And if we add a new
`Article` or `Comment`, it doesn't update. Bummer. Luckily, these two problems
have the same solution.

### Cache expiration

We need a strategy to recalculate our cached values. The simplest one is to
invalidate our cache whenever the data changes. This method is really easy, and
really simple:

```
module InvalidatesCache
  extend ActiveSupport::Concern

  included do
    after_create :invalidate_cache
    after_update :invalidate_cache

    def invalidate_cache
      Rails.cache.clear
    end
  end
end

class Article
  include InvalidatesCache
end

class Comment
  include InvalidatesCache
end
```

Now, when we make a new `Article` or `Comment` (or update it), the cache gets
blown away. Check it out:

{% irb %}
irb > Article.create title: "new article", body: "This is a body", author_id: 1
=> #<Article id: 1001, title: "new article", body: "This is a body", created_at: "2013-04-26 20:04:49", updated_at: "2013-04-26 20:04:49", author_id: 1>
irb > Rails.cache.read("article_most_popular")
=> nil
{% endirb %}

Obviously, this is a bit heavy-handed: This now means that the first request
after _each_ update or creation will be super slow, but at least we're now
correct. Also, we're blowing away the _entire_ cache every time, if we were
caching other values, this would get rid of them too.

So, to do this right:

1. We need the list of keys that we need to invalidate.
2. We need to only remove those keys when we update the correct models.

On top of that, this still means that we have one slow request per creation or
update. So, to fix that, instead of removing the cache, we need to update it
with the new value. To do that:

1. We need to keep track of which calculation goes with which key, and upate
   accordingly.
2. We need to know which calculations depend on each other. For example, the
   total words calculation relies on both `Article`s and `Comments`, but the
   most popular article calculation only worries about `Article`s.

Caching is hard.

If you're an experienced Rails dev, you might already be crafting a DSL in your
mind and typing `bundle gem awesome\_cache` into your terminal. Stop! There's
actually a better way!

## Key-based cache expiration


## More Resources

* [Memoization](http://en.wikipedia.org/wiki/Memoization)
