# Caching

( Premise of Caching )

Caching is an important concept in improving the performance of an application.  There are various levels/types of caching:

1. Caching page content - the HTML that is generated and sent to the browser
 * Page Caching - caching the entire response of an individual page
 * Fragment Caching - caching a subset of the page
2. Data caching - data used in the controller or views

Redis is a high performance, in-memory key-value data store, and it can be saved to disk in order to offer persistence.

## `redis-store`

Redis-Store hooks into Rails's caching layer in order to provide `Redis` as the backend caching mechanism.

### Install

( Add to Gemfile, bundle)
Installing `redis-store` is as easy as adding `gem 'redis-store` to the Gemfile and running `bundle`.

### Redis Options

The options to configure how `redis-store` connects to Redis are as follows (the default values are shown after the option key):

* `host` (*localhost*): IP address or DNS of the host to connect to
* `port` (*6379*): port Redis is listening on
* `db` (*0*): which Redis database to `select` after connecting
* `namespace` (*nil*): string to prefix redis keys with
* `password` (*nil*): authentication password for Redis

A hash with the above keys or a string may be specified to connect.  The format of the string looks like:

```text
redis://:secret@localhost:6379/1/namespace
```

`:secret@` and `/1/namespace` are optional fragments of this string, but note that if you want to specify a namespace the DB number must also be provided.

Let's configure Redis-Store in our development environment by adding the following to `config/environments/development.rb`:

```ruby
AppName::Application.configure do
  ...
  config.cache_store = :redis_store, "redis://localhost:6379/1/ns" # or specify a hash like { :db => 1, :namespace => 'ns' }
  ...
end
```

## Direct Data Caching

Storing and retrieving data directly from the cache is quite simple.  `Rails.cache` is the object to interface with, using the `read` and `write` methods on it:

```text
ruby> Rails.cache.write("testcache", "some value")
 => "OK"

ruby> Rails.cache.read("testcache")
 => "some value"

redis-cli> select 1
redis-cli> keys *
1) "ns:testcache"
```

## Fragment Caching

Fragment caching is used to cache a portion of the HTML that is generated in a page.  An example would be a header that displays the total number of articles that is displayed in the header of every page on the site.  The count of the number of articles would be calculated once and the HTML fragment displaying the articles count would be cached so that query would not need to be executed everytime.

Whenever an article is added or removed the articles count would change and the fragment cache would need to be invalidated so it is regenerated with the correct number on the next request.

### Marking Fragments

Within a view the segment of the page to be cached is surrounded in a `cache` block:

```ruby
 # application header layout
...
<% cache('articles_count') do %>
  There are <%= Article.count %> articles in our site.
<% end %>
...
```

### Storing to Cache

After restarting the server and hitting the page the logs now mention checking for the `total_users` fragment:

```text
Started GET "/articles" for 127.0.0.1 at 2011-09-14 00:56:56 -0400
...
Exist fragment? views/articles_count (34.8ms)
Read fragment views/articles_count (0.2ms)
Rendered articles/index.html.erb within layouts/application (173.0ms)
Completed 200 OK in 399ms (Views: 177.5ms | ActiveRecord: 2.4ms)
```

The Redis store now has the fragment cache included:

```text
redis-cli> keys *
1) "ns:views/articles_count"
redis-cli> get ns:views/articles_count
"\x04\o: ActiveSupport::Cache::Entry\:\x10@compressedF:\x10@expires_in0:\x10@created_atf\x181315976116.44449\x00r\x86:\x0b@valueI\"-      There are 3 articles in our site.\\x06:\x06ET"
```

### Loading from Cache

Any subsequent page load will now read the fragment when rendering the header layout.  This means that if this was the only change made and the user now creates a new Article the article count displayed in the header would be incorrect since the count is being read from the cache.

### Expiring / Refreshing the Cache

In order to force the page to generate the HTML with the correct articles count the cache fragment needs to be expired.  To manually expire the cache in the `Articles` controller `expires_cache` needs to be added after the article is created or destroyed:

```ruby
def create
  a = Article.new(params[:article])
  a.save
  expire_fragment("articles_count")
  ...
end

def destroy
  article = Article.find(params[:id])
  article.destroy
  expire_fragment("articles_count")
  ...
end
```

Another mechanism to expire caches is to use a Cache Sweeper which will act as an observer to monitor when changes to a model should result in cache expiration.  Refer to the [Cache Sweepers](http://guides.rubyonrails.org/caching_with_rails.html#sweepers) section in the Rails Guides for more information.

## Page Caching

( Argument for/against -- huge performance increase if your data can be a bit stale )

### Customizing Cached Pages

( It would be awesome to show an example of caching a page completely then using JavaScript and a second request to fetch the current username and replace placeholder text in the header with the current user)

( Anything else to say about page caching? )

## References

* http://jodosha.github.com/redis-store/
* http://guides.rubyonrails.org/caching_with_rails.html
* http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
