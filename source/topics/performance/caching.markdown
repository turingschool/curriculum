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

{% irb %}
$ Rails.cache.write("testcache", "some value")
# => "OK"
$ Rails.cache.read("testcache")
# => "some value"
{% endirb %}


## Key-based cache expiration


## More Resources

* [Memoization](http://en.wikipedia.org/wiki/Memoization)
