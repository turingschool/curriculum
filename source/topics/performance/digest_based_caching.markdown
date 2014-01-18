---
layout: page
title: Digest-Based Caching
section: Performance
sidebar: true
---

Expiring caches is hard. What if you could just ignore antiquated data? Enter key-based cache expiration.

1. The cache is append-only. What this means is that we never change the values stored in the cache, but instead create new key/value pairs.
2. The key is calculated based on the object being cached. When the object changes, the key changes. The old key/value pair is irrelevant.
3. Will you run out of memory? Ideal key/value stores for this technique automatically evict older entries when memory is needed.
4. You can nest objects, and that ties their keys (and therefore, their values) together.Caching a post and its comments, then when a new comment is the post's cache gets invalidated (or rather creates a different key, making the old data irrelevant).

## Tooling Setup

In other performance tutorials we've used Redis. But Redis does not auto-expire keys. When its memory fills up new writes will start failing.

Instead let's use memcache.

### The Sample Project

{% include custom/sample_project_advanced.html %}

We need a lot of sample data. Open up `db/seeds.rb` and increase the number of objects generated:

```ruby
Author.generate_samples(20)
Tag.generate_samples(20)
Article.generate_samples(100)
```

Then, re-build the database and start the server:

{% terminal %}
$ bundle exec rake db:drop db:migrate db:seed
$ rails s
{% endterminal %}

### Installing Memcache

If you're on OS X with Homebrew it's easy:

{% terminal %}
$ brew install memcached
{% endterminal %}

After installation, you'll want to start Memcache:
 
{% terminal %}
$ ln -sfv /usr/local/opt/memcached/*.plist ~/Library/LaunchAgents
$ launchctl load ~/Library/LaunchAgents/homebrew.mxcl.memcached.plist
{% endterminal %}

### Installing Dalli

[Dalli](https://github.com/mperham/dalli) is the preferred Ruby client for interacting with Memcached. Add it to your application's `Gemfile`:

```ruby
gem 'dalli'
```

Then `bundle`.

### Configuring Rails to Use Dalli

Presuming that you're experimenting in development, open `config/environments/development.rb` and add this line:

```ruby
config.cache_store = :dalli_store
config.action_controller.perform_caching = true
```

Make sure that if you already had `cache_store` configured from another tutorial that this line *replaces* it.

### Verifying It All

With those change in place, fire up a Rails console and try it out:

{% irb %}
> Rails.cache.write("counter", 5)
 => true 
> Rails.cache.read("counter")
 => 5 
{% endirb %}

Want some proof from memcached itself? There isn't a great console/interface built in. But you can use telnet to verify that the key is there:

{% terminal %}
$ telnet localhost 11211
Trying ::1...
Connected to localhost.
Escape character is '^]'.
> get counter
VALUE counter 1 4
i

END
> get counter_doesnt_exist
END
> quit
{% endterminal %}

Note that the `>` above don't actually appear, they're just used here to point out the commands entered.

## Getting Started with Cache Digests

We'll use the `cache_digests` library to generate cache keys based on input data.

### Checking Out All Articles

Let's try it with the 'all articles' page first. Start up your
server and hit `http://localhost:3000/articles` in your browser.

```text
Rendered articles/index.html.erb within layouts/application (19306.7ms)
Completed 200 OK in 19449ms (Views: 6716.8ms | ActiveRecord: 12731.3ms)
```

Brutal! We have to load a thousand articles, a hundred tags, and count all
the comments... mega slow.

### How Cache Digest Works

The `cache_digests` library uses MD5 hashing to generate cache keys. If any bit of the input to the the hash operation changes, then the hash output will change. Since that hash result changes the cache key being searched for changes. The old value will be cleaned up by `memcached` when memory is needed.

`cache_digests` can hash both the templates and the data, so if you change either then a new cache key is generated.

### Adding `cache_digests` to a Rails App

In Rails 4, there's nothing to do. It's built in.

Our sample application is in Rails 3. Add the `cache_digests` gem to the Gemfile, then `bundle`.

### Add Caching to the View Template

We need to mark segments of the view template for caching. Modify
`app/views/articles/index.html.erb` to use a `cache` block when it renders each article:

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

Now, each article block will have a cache based on the `Article` instance. If we
modify an article, only that article's digest (and thus key) will change.

### Results from the Browser

Open up your browser, hit `http://localhost:3000/articles`, then look at the server log. You'll see something like this:

```text
Rendered articles/index.html.erb within layouts/application (29488.8ms)
Completed 200 OK in 29660ms (Views: 16398.4ms | ActiveRecord: 13261.1ms)
```

Then refresh the page and return to the log for results like this:

```text
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

### Comment Problems

On that index page each article displays the number of comments.

* Open one of the articles in a separate tab
* Notice the number of comments on the index
* Add a comment using the other tab
* Reload the index and the comments count **didn't** change

Why? The cache fragments are based on the article. We added a comment record to the database, but we didn't change the article itself.

### Touching Objects

We can have new comments affect the `updated_at` timestamp of the parent article. In `comment.rb` add `:touch` :

```ruby
class Comment < ActiveRecord::Base
  belongs_to :article, :touch => true
end
```

Go add another comment in the article show tab, refresh the article index, and you should see the correct comment count. The generated key changed because the article `updated_at` changed.

### One Sad User, Most Are Happy

We still have that bad first page load. But when we change an article or add a comment, just one digest key will change. The rest of the article digests will remain the same so their existing cached fragments will be used.

## Caching a Single Article

### Starting with the `show` Template

Let's try the technique on the show page for an `Article`. Find an article with
a lot of comments, or just add a bunch of comments to one in the console. For this example we'll work with the article with ID #799,
so I opened up `http://localhost:3000/articles/799` in my browser. It has 15
comments:

```text
Rendered articles/show.html.erb within layouts/application (353.3ms)
Completed 200 OK in 392ms (Views: 366.1ms | ActiveRecord: 18.3ms)
```

392ms isn't horrible, but it's not ok. Let's examine the 
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

### Adding Caching

We need to tell Rails two things:

1. Cache all of this based on the `Article`
2. Cache the nested child comments individually

First wrap a cache call around the whole template:

```html+erb
<% cache @article do %>
  <h1><%= @article.title %></h1>
  <h4>Published <%= @article.created_at %></h4>
  <p class='tag_list'><em>Tagged:</em> <%= @article.tag_list %></p>

...everything else...

<% end %>
```

Refresh the page twice to make sure the cache gets loaded up.

![before caching](/images/caching/before_cache.png)

```text
Read fragment views/articles/799-20130426174937/33c6b50a8951af1b50232cdb6f7ffb60 (0.3ms)
Rendered articles/show.html.erb within layouts/application (0.6ms)
Completed 200 OK in 17ms (Views: 16.5ms | ActiveRecord: 0.1ms)
```

### Add a Comment

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

See that 'Read fragment' and 'write fragment'? Because of our `:touch`,
when the comment was created, it updated the timestamp on the article. The updated article generated a different digest key than the old one, so the cache load missed. Rails ran the template itself and cached the results for later use.

## Nested Cache Elements

### Thinking About `updated_at`

There's one problem with this technique, though. Adding the comment touched the parent article, which meant changing the `updated_at`. The view template was outputting that `updated_at` to represent when the content of the article itself was updated, which  didn't really happen. You might not care this time, but for some applications, this isn't
great. 

There's another way. We can nest the cache blocks within the template, then `:touch` isn't needed down in the models. 

**Remove** all the `touch` bits from the models. Return to the article in the browser and add another comment:

![stale cache](/images/caching/stale_cache.png)

Oh no! It still says 16 total comments, and this troll-y comment I left before
is the 'newest' one. But I added another! Where'd it go?

Well, because our `updated_at` wasn't modified for `@article`, the digest generated the same old cache key.

### Listing Cache Dependencies

We can see the nested dependencies with this rake task:

{% terminal %}
$ bundle exec rake cache_digests:nested_dependencies TEMPLATE=articles/show
[

]
{% endterminal %}

Nothing yet. 

### Extracting a Partial

Find the part of the view template that renders the comments using `@article.comments.each`. Cut the segment inside of the each block out to a partial:

```html+erb
<%= render partial: 'comments/comment', collection: @article.comments %>
```

and in `app/views/comments/_comment.html.erb`:

```html+erb
<div class='comment'>
  <p>
    <em><%= comment.author_name %></em>
    said <%= distance_of_time_in_words(comment.article.created_at, comment.created_at) %> later:
  </p>
  <p><%= comment.body %></p>
</div>
```

If you're seeing the comments repeating over and over again after refreshing the show page, make sure you've deleted the each block that previously surrounded the portion you cut out.

### Reevaluating Dependencies

Let's examine those dependencies again:

{% terminal %}
$ bundle exec rake cache_digests:nested_dependencies TEMPLATE=articles/show
[
  "comments/comment"
]
{% endterminal %}

Rails will now know that we rely on this partial. When it caches the whole template, it'll cache each rendering of the partial individually. If any of the comments changes, its key will change making the old fragment/key obsolete. The whole page, which is dependent on this fragment, will also generate a different key.

Hit refresh, and you should see all posted comments.

## More Resources

* [Heroku's Guide to Memcached](https://devcenter.heroku.com/articles/advanced-memcache)
* [Cache Digest gem on GitHub](https://github.com/rails/cache_digests)
* [How Key-based Cache Expiration Works](http://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works)
* [cache_digests gem](https://github.com/rails/cache_digests)
* [The 'caching' branch of blogger_advanced](https://github.com/jumpstartlab/blogger_advanced/tree/caching)
