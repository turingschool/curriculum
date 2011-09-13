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

( I haven't done this in forever, so...? )

### Marking Fragments

( Mark a section in a view template for caching )

### Storing to Cache

( Is there anything to say here? )

### Loading from Cache

( Fetch it from cache )

### Expiring / Refreshing the Cache

( How does this happen? )

## Page Caching

( Argument for/against -- huge performance increase if your data can be a bit stale )

### Customizing Cached Pages

( It would be awesome to show an example of caching a page completely then using JavaScript and a second request to fetch the current username and replace placeholder text in the header with the current user)

( Anything else to say about page caching? )

## References

* http://jodosha.github.com/redis-store/
* http://guides.rubyonrails.org/caching_with_rails.html
* http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
