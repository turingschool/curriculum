---
layout: page
title: Key-Based Cache Expiration
section: Performance
---

## Key-Based Cache Expiration

Expiring caches is hard. What if you could just never expire keys? Enter key-based cache expiration.

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
