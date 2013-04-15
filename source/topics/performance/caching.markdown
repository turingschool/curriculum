---
layout: page
title: Caching with Redis
section: Performance
---

## Background

What if there were a global hash? A place where any of your processes could store data and it could be found by any process at a later time. It would could even have a network interface/server, so the global store could run on its own machine and your application servers could be on totally different machines.

That's the basic concept of using a key-value cache. It's one massive hash where you can store and fetch data.

What would you store in there? Simply put: data. But to be a bit more specific:

* Small chunks of data like integers and strings
* Lists
* Large pre-rendered strings

### Uses for Cached Data

You use a cache to make things faster. The data stored in there should not be "exclusive" or "durable". If the cache were complete erased, all of the data could be reloaded or recalculated elsewhere.

The cache is an intermediary storage. It's incredibly fast, so you use it to store and later find data that's expensive/slow to fetch or calculate.

### Setup

{% include custom/sample_project_advanced.html %}

<div class="note">
<p>You need to follow the <a href='installing_redis.html'>instructions for installing and configuring Redis</a> to follow this tutorial.</p>
</div>

## Direct Data Caching

### Theory

Imagine you have an expensive calculation, like finding the total number of words across all articles in your blog. If you want to display that number on the site, you'll have to 

* fetch all the articles from the database
* split them all into words
* count the words in each article
* sum the counts

Once you have hundreds of article, this will be *crazy slow*. Even if you use the technique of memoization (like `@word_count = ...`), that will still be very slow the first time it's run _on each request_.

If you had a cache, though, you could store the count as an integer. When you want to display it, just fetch it from the cache. When you add or edit an article, run the word count calculation and store it in the cache. Now every request that displays that data is faster.

#### Advantages

* Ultra-fast data storage, manipulation, and retrieval

#### Disadvantages

* It can be a bit tricky to keep your data correct/consistent as things change in your database
* To really maximize the potential, you need to learn the Redis API to understand all the data operations possible

### Practice

Storing and retrieving data directly from the cache is quite simple.  `Rails.cache` is the object to interface with, using the `read` and `write` methods on it:

{% irb %}
$ Rails.cache.write("testcache", "some value")
# => "OK"
$ Rails.cache.read("testcache")
# => "some value"
{% endirb %}

The data could also be viewed from the Redis console:

{% terminal %}
$ redis-cli
redis-cli> select 1
redis-cli> keys *
1) "ns:testcache"
{% endterminal %}

#### Redis Data Operations

To understand what's possible, you should browse and begin learning [the Redis API](http://redis.io/commands) and you can try experimenting with it in-browser at the [Try Redis](http://try.redis.io/) page. 

## Fragment Caching

### Theory

You probably don't give much thought to rendering view templates (`.erb` or `.haml` files), but it's one of the slower parts of the request-response cycle because:

* Doing the string interpolation to mix HTML and data is kind of slow
* View templates often disguise quite a bit of looping when using partials, generating hundreds of lines of output
* Often templates kick off delayed `ActiveRecord` queries or create new queries, having to dive down to the database

Fragment caching attempts to save some of this cost by storing large chunks of HTML.

#### An Example

Imagine you're writing an online store. On your products page you've got a partial for product with ID `22`. In that partial you render the title, an image tag, the short description, the current price, and a percentage savings off the "retail price". It might take 0.01 seconds to render that partial.

Then once your store grows and has 20 products on a page, all of a sudden 20 times 0.01 is 0.2 seconds, which starts to degrade the user experience.

But does it really need to be dynamic? Isn't the partial rendered for a certain product the same across many users? The only time it'd change is when the product itself changes. If you're store is successful, that partial might get rendered a million times between product changes.

#### Advantages

If you use fragment caching:

* Rails attempts to find the pre-rendered content in the cache and display it
* If it's not found, the partial is rendered normally
* The partial is stored into the cache for later requests
* When the product is changed you have to invalidate (or delete) the cache

On a listing of 20 products, you might have each product rendered as its own cache entry. Fetching twenty fragments from the cache and composing them into one view template will be much faster, probably 100x faster, than rendering the partials directly.

#### Disadvantages

* You need to create an algorithm for naming keys that won't trample on each other. For instance, you might store the example's fragments as `'product_index_id_22'`
* You need to know when to invalidate the fragment, which is probably whenever the rendered elements change any of their stored data (like the product title or in-stock status changes)
* There's often the "one sad user" phenomenon: the first user/request to the page will not find anything in the cache and they'll have degraded performance

### Practice

Fragment caching is used to cache a portion of the HTML that is generated in a page.  An example would be a header used on every page of the site.  The data would be calculated once and the HTML fragment stored to avoid firing the calculation every request.

Whenever the data is changed the cache would be invalidated and regenerated.

#### Marking Fragments

Within a view template, the segment of the page to be cached is surrounded in a `cache` block:

```erb
<% cache('articles_count') do %>
  There are <%= Article.count %> articles on our site.
<% end %>
```

#### Storing to Cache

After restarting the server and hitting the page the logs now mention checking for the `articles_count` fragment:

{% terminal %}
Started GET "/articles" for 127.0.0.1 at 2011-09-14 00:56:56 -0400
...
Exist fragment? views/articles_count (34.8ms)
Read fragment views/articles_count (0.2ms)
Rendered articles/index.html.erb within layouts/application (173.0ms)
Completed 200 OK in 399ms (Views: 177.5ms | ActiveRecord: 2.4ms)
{% endterminal %}

Since the fragment was not found, it was generated on the fly and stored into the cache. The Redis store now has the fragment included:

{% terminal %}
redis-cli> keys *
1) "ns:views/articles_count"
redis-cli> get ns:views/articles_count
"\x04\o: ActiveSupport::Cache::Entry\:\x10@compressedF:\x10@expires_in0:\x10@created_atf\x181315976116.44449\x00r\x86:\x0b@valueI\"-      There are 3 articles in our site.\\x06:\x06ET"
{% endterminal %}

#### Loading from Cache

Any subsequent page load will now read the fragment. If the user creates a new `Article`, the cached article count would be incorrect until the fragment is expired and recalculated.

#### Expiring / Refreshing the Cache

To manually expire the cache in the `ArticleController` actions, call the method `expire_fragment` after the `Article` is created or destroyed:

```ruby
def create
  a = Article.new(params[:article])
  a.save
  expire_fragment("articles_count")
  #...
end

def destroy
  article = Article.find(params[:id])
  article.destroy
  expire_fragment("articles_count")
  #...
end
```

#### Using Sweepers

Another mechanism to expire caches is to use a Cache Sweeper which will act as an observer to monitor when changes to a model should result in cache expiration.  Refer to the [Cache Sweepers](http://guides.rubyonrails.org/caching_with_rails.html#sweepers) section in the Rails Guides for more information.

Note that sweepers (and observers) have been removed from Rails 4 and extracted [into a gem](https://github.com/rails/rails-observers).

#### Auto-Expiring Caches

Rails also provides a mechanism to auto-expire caches when a model is updated.

In `articles/show.html.erb`, surround the file with:

```ruby
<% cache @article do %>
  <h1><%= @article.title %></h1>
  # ...
<% end %>
```

Now when you hit the page with a cached fragment, the logs will output 
something like:

{% terminal %}
Started GET "/articles/1" for 127.0.0.1 at 2012-05-25 20:15:51 -0400
Processing by ArticlesController#show as HTML
  Parameters: {"id"=>"1"}
  Article Load (0.1ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = ? LIMIT 1  [["id", "1"]]
Read fragment views/articles/1-20120526001550 (0.1ms)
{% endterminal %}

What's happening behind the scenes is a cache named `articles/1-20120526001550` is created.
Models have a method `cache_key`, which returns a string containing the model id 
and `updated_at` timestamp. When a model changes, the fragment's `updated_at` timestamp
won't match and the cache will re-generate. 

#### Using `touch`

Auto-expiring caches are a handy feature, but if you add a comment you'll
notice that the article's comment data remains the same.  That's because the 
article's `updated_at` column wasn't updated when a comment was created. 
Luckily, ActiveModel provides us with a way to change associated models with 
`touch`. In your `Comment` model, add `touch` to the article's association:

```ruby
class Comment < ActiveRecord::Base
  belongs_to :article, touch: true
  # ...
end
```

Now when a comment is created or updated, the associated article's `updated_at`
column will change and the cache fragment will be re-generated.

## Page Caching

### Theory

Fragment caching is cool, but if you really want to survive massive traffic, you'll need page caching.

Continue thinking about running an online store. You send out a news letter about your new spring collection. Hopefully your users click-through and check it out.

That page they view will (hopefully) see massive traffic. But it's the same page for each user. If you're going through and fetching data, composing view templates, and even fetching a bunch of fragments from the cache, you're wasting time!

Instead you deploy page caching. When you cache a page you take the *entire* HTML response and store it in your cache. When the next request comes in for that path, the cached HTML is returned.

This is the fastest possible response because it doesn't do any string interpolation and there no trips to the database. It actually doesn't even activate a controller action. It's just straight HTML sent back to the user with almost no participation by your application.

Then, when your backend data changes (like a product gets sold out or a title changes), you invalidate the cache and re-render the page.

#### Advantages

* Highest-possible performance
* Unlike Fragment Caching, the page's HTML is stored on the file system (in `Rails.public_path` by default) so no external tools like Redis is necessary

#### Disadvantages

* The cache file will continue to be served until it is expired, so pages which have data that changes frequently will likely not be a candidate for page caching
* Small tweaks to a page (like displaying the current username up in the top navigation) can make page caching tricky or impossible
* The same file is served regardless of the parameters in the request.  `/articles?page=1` would be written to the file system with the name `articles.html`, so a request for `/articles?page=2` would continue to serve `articles.html` with the content for page 1 even if the content should be different.

### Practice

Page Caching is initiated by adding `caches_page :action_name` in the controller class.  

<div class="note">
<p>In the development environment controller caching is turned off by default. To turn it on for experimenting, the <code>config.action_controller.perform_caching</code> value needs to be set to <code>true</code> in <code>config/environments/development.rb</code> and the server restarted.</p>
</div>

#### Caching the Page

The following changes would be made in order to cache our articles page:

```ruby
 # config/environments/development.rb
 config.action_controller.perform_caching = true

 # app/controllers/articles_controller.rb
 caches_page :index
```

Now when the articles page is visited for the first time the logs will report that the cache was written:

{% terminal %}
Rendered articles/index.html.erb within layouts/application (143.8ms)
Write page /path/to/application/public/articles.html (0.5ms)
Completed 200 OK in 441ms (Views: 178.6ms | ActiveRecord: 3.5ms)
{% endterminal %}

The location of the cache file can be seen in the 2nd line of the above log output.  Subsequent requests to `/articles` will not cause any additional logging, since the web server is now returning `articles.html` without touching Rails.

#### Expiring Pages

To expire a cached page, we use the `expire_page` method and give it the template to expire. For example, when we add or delete an `Article`, we could (in the controller action) call:

```ruby
expire_page action: :index
```

The next request for `/articles` will regenerate the cached index.

## References

* Redis-Store Gem: http://jodosha.github.com/redis-store/
* Rails Guide on Caching: http://guides.rubyonrails.org/caching_with_rails.html
* Rails API for Caching: http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
* Using Redis as an i18n backend for speed/ease: http://railscasts.com/episodes/256-i18n-backends
* Redis Quick-Start (with CLI): http://redis.io/topics/quickstart
