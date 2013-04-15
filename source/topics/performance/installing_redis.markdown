---
layout: page
title: Installing Redis
section: Performance
---

## Redis

Redis is a high performance, in-memory key-value data store which can be persisted to disk.

### Install

#### MacOS

Presuming you have Homebrew installed, you can install the Redis recipe:

{% terminal %}
$ brew install redis
$ redis-server /usr/local/etc/redis.conf
{% endterminal %}

#### Ubuntu

There are a few options to install Redis on Ubuntu. The first and easiest is to use `apt`:

{% terminal %}
$ sudo apt-get install redis-server
{% endterminal %}

This will set up `redis-server` to startup with the OS, but it may be a slightly dated version.

To get the latest stable version you can download from `http://redis.io/download` and install using their directions. 

#### Windows

There is no official Redis server version for Windows. There is a third-party port of the original service which can be used for development but may not offer 100% compatibility:

https://github.com/dmajkic/redis/

## `redis-rails`

Redis-Rails hooks into Rails's caching layer in order to provide Redis as the backend caching mechanism.

### Install

Install `redis-rails` by adding `gem 'redis-rails'` to the `Gemfile` and running `bundle`.

### Typical Configuration

To run experiments in these tutorials, use the following configuration in  `config/environments/development.rb`:

```ruby
AppName::Application.configure do
  ...
  config.cache_store = :redis_store, "redis://localhost:6379/1/ns"
  ...
end
```

### Caching in Development?

If you want to turn on caching in development (while testing / learning about Redis), in the same `config/environments/development.rb` file:

```ruby
AppName::Application.configure do
  ...
  config.cache_store = :redis_store, "redis://localhost:6379/1/ns"
  config.action_controller.perform_caching = true
  ...
end
```

### Configuration Options

The options to configure how `redis-rails` connects to Redis are as follows with the default values:

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
