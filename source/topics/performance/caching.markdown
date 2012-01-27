---
layout: page
title: Caching with Redis
section: Performance
---

Caching is an important concept in improving the performance of an application.  There are various levels/types of caching:

1. Caching page content - the HTML that is generated and sent to the browser
 * Page Caching - caching the entire response of an individual page
 * Fragment Caching - caching a subset of the page
2. Data caching - data used in the controller or views

### Setup

{% include custom/sample_project_advanced.html %}

## Redis

Redis is a high performance, in-memory key-value data store, and it can be saved to disk in order to offer persistence.

### Install

#### Ubuntu

There are a few options to install Redis on Ubuntu. The first and easiest is to use `apt`:

```plain
sudo apt-get install redis-server
```

This will set up `redis-server` to startup with the OS, but it may be a slightly dated version.

To get the latest stable version you can download from `http://redis.io/download` and install using their directions. 

#### MacOS

Presuming you have Homebrew installed, you can install the Redis recipe:

```
brew install redis
```

#### Windows

There is no official Redis server version for Windows. There is a third-party port of the original service which can be used for development but may not offer 100% compatibility:

https://github.com/dmajkic/redis/

## `redis-store`

Redis-Store hooks into Rails's caching layer in order to provide Redis as the backend caching mechanism.

### Install

Instal `redis-store` by adding `gem 'redis-store'` to the `Gemfile` and running `bundle`.

### Redis Options

The options to configure how `redis-store` connects to Redis are as follows with the default values:

* `host`: IP address or DNS of the host to connect to [default: `localhost`]
* `port`: port Redis is listening on [default: `6379`]
* `db`: which Redis database to `select` after connecting [default: `0`]
* `namespace`: string to prefix redis keys [default: `nil`]
* `password`: authentication password for Redis [default: `nil`]

A hash with the above keys or a string may be specified to connect.  The format of the string looks like:

```text
redis://:secret@localhost:6379/1/namespace
```

`:secret@` and `/1/namespace` are optional fragments of this string, but note that if you want to specify a namespace the DB number must also be provided.

#### Typical Configuration

To run experiments in this tutorial, use the following configuration in  `config/environments/development.rb`:

```ruby
AppName::Application.configure do
  ...
  config.cache_store = :redis_store, "redis://localhost:6379/1/ns"
  ...
end
```

## Direct Data Caching

Storing and retrieving data directly from the cache is quite simple.  `Rails.cache` is the object to interface with, using the `read` and `write` methods on it:

```irb
> Rails.cache.write("testcache", "some value")
# => "OK"

> Rails.cache.read("testcache")
# => "some value"
```

The data could also be viewed from the Redis console:

```
redis-cli> select 1
redis-cli> keys *
1) "ns:testcache"
```

## Fragment Caching

Fragment caching is used to cache a portion of the HTML that is generated in a page.  An example would be a header used on every page of the site.  The data would be calculated once and the HTML fragment stored to avoid firing the calculation every request.

Whenever the data is changed the cache would be invalidated and regenerated.

### Marking Fragments

Within a view template, the segment of the page to be cached is surrounded in a `cache` block:

```erb
<% cache('articles_count') do %>
  There are <%= Article.count %> articles on our site.
<% end %>
```

### Storing to Cache

After restarting the server and hitting the page the logs now mention checking for the `articles_count` fragment:

```text
Started GET "/articles" for 127.0.0.1 at 2011-09-14 00:56:56 -0400
...
Exist fragment? views/articles_count (34.8ms)
Read fragment views/articles_count (0.2ms)
Rendered articles/index.html.erb within layouts/application (173.0ms)
Completed 200 OK in 399ms (Views: 177.5ms | ActiveRecord: 2.4ms)
```

Since the fragment was not found, it was generated on the fly and stored into the cache. The Redis store now has the fragment included:

```text
redis-cli> keys *
1) "ns:views/articles_count"
redis-cli> get ns:views/articles_count
"\x04\o: ActiveSupport::Cache::Entry\:\x10@compressedF:\x10@expires_in0:\x10@created_atf\x181315976116.44449\x00r\x86:\x0b@valueI\"-      There are 3 articles in our site.\\x06:\x06ET"
```

### Loading from Cache

Any subsequent page load will now read the fragment. If the user creates a new `Article`, the cached article count would be incorrect until the fragment is expired and recalculated.

### Expiring / Refreshing the Cache

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

## Page Caching

One level up from _Fragment Caching_ is _Page Caching_, which will cache the entire page instead of a portion of the page.  Unlike Fragment Caching, the page's HTML is stored on the filesystem (in `Rails.public_path` by default) even if an alternative `cache_store` like Redis-Store is being used.

Page caching offers a great performance boost, since future requests to the page don't even touch the Rails stack. The web server simply returns the HTML from the cache folder.  However, this does come with a few downsides:

1. The cache file will continue to be served until it is expired, so pages which have data that changes frequently will likely not be a candidate for page caching.
2. The same file is served regardless of the parameters in the request.  `/articles?page=1` would be written to the filesystem with the name `articles.html`, so a request for `/articles?page=2` would continue to serve `articles.html` with the content for page 1 even if the content should be different.

### Experimenting with Page Caching

Page Caching is initiated by adding `caches_page :action_name` in the controller class.  

<div class="note">
<p>In the development environment controller caching is turned off by default. To turn it on for experimenting, the <code>config.action_controller.perform_caching</code> value needs to be set to <code>true</code> in <code>config/environments/development.rb</code> and the server restarted.</p>
</div>

The following changes would be made in order to cache our articles page:

```ruby
 # config/environments/development.rb
 config.action_controller.perform_caching = true

 # app/controllers/articles_controller.rb
 caches_page :index
```

Now when the articles page is visited for the first time the logs will report that the cache was written:

```text
Rendered articles/index.html.erb within layouts/application (143.8ms)
Write page /path/to/application/public/articles.html (0.5ms)
Completed 200 OK in 441ms (Views: 178.6ms | ActiveRecord: 3.5ms)
```

The location of the cache file can be seen in the 2nd line of the above log output.  Subsequent requests to `/articles` will not cause any additional logging, since the web server is now returning `articles.html` without touching Rails.

#### Expiring Pages

To expire a cached page, we use the `expire_page` method and give it the  template to expire. For example, when we add or delete an `Article`, we could call:

```ruby
expire_page :action => :index
```

Then the next request for `/articles` will regenerate the cached index.

## References

* Redis-Store Gem: http://jodosha.github.com/redis-store/
* Rails Guide on Caching: http://guides.rubyonrails.org/caching_with_rails.html
* Rails API for Caching: http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html

