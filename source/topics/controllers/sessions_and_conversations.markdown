---
layout: page
title: Sessions and Conversations
section: Controllers
---

HTTP is a stateless protocol. Sessions allow us to chain multiple requests together into a conversation between client and server.

Sessions should be an option of last resort. If there's nowhere else that the data can possibly go to achieve the desired functionality, only then should it be stored in the session. Sessions can be vulnerable to security threats from third parties, malicious users, and can cause scaling problems.

We should only use them where necessary.

## Adding, Accessing, and Removing Data

Rails gives us access to the current session through the `session` helper method. Much like the `params` method, the `session` method returns us an object that we can think of as a hash. In reality it is an instance of `ActionDispatch::Session::AbstractStore::SessionHash`.

### Adding Data

We can add information to the session just like a regular hash:

```ruby
def new
  @order = current_user.orders.create
  session[:order] = @order.to_param
end
```

The session can store any kind of string data, but you're best served by keeping it as small as possible for both speed and security. Instead of storing whole objects, store the ID of an object and then do a lookup on the server side, as necessary.

### Reading Data

In the current or later requests you can access that data:

```ruby
def add_to_cart
  @order = current_user.orders.find(session[:order])
  @order << Product.find(params[:id])
end
```

Note that we only fetch an order ID from the session, and then run a scoped query against the database. We rely on `current_user.orders` to scope the search to just orders attached to this user. 

You should be skeptical of the data coming out of a session and assume that a user can, in one way or another, modify the data. Scoping queries like this can insulate you from serious security issues.

### Deleting Data

Just like a hash, values can be cleared by setting them to `nil` or calling `delete` with the key:

```ruby
session[:order] = nil
# or
session.delete(:order)
```

### Reset

If you want to erase the entire session, call `reset_session`:

```ruby
def new
  reset_session
  @order = current_user.orders.create
  session[:order] = @order.to_param
end
```

## Storage Options

Where you store the session data has implications for both performance and security.

### User Cookies

The default storage mechanism is the browser's cookie.

* Advantages
  * No server storage
  * No extra queries server-side
  * No setup effort
* Disadvantages
  * User access / visibility, possible tampering
  * 4kb Size Limit
  * Sent with each request (increasing total bandwidth)

There is no configuration necessary to use cookie storage, they are set up and turned on by default.

### Database Storage with `ActiveRecordStore`

Some sites choose to use database storage to move the bulk of the data server-side:

* Advantages
  * Size limited only by database
  * Less prone to user tampering
  * Only uses a cookie to track session id
  * Less data transferred to/from client
* Disadvantages
  * Causes an extra database query on every request
  * Can inflate database disk/memory usage
  * Need to be pruned via monitor process

#### Setup

First, you will need to intall the 'activerecord-session_store' gem to your Gemfile:

```ruby
gem 'activerecord-session_store'
```

Then run 'bundle' from your command prompt.

{% terminal %}
bundle
{% endterminal %}

Next, create a migration to build the database table. From your command prompt:

{% terminal %}
$ rails generate session_migration
$ rake db:migrate
{% endterminal %}

Then open `config/initializers/session_store.rb` and change the line like this:

```ruby
MyApp::Application.config.session_store :cookie_store, key: '_myapp_session'
```

To this:

```ruby
MyApp::Application.config.session_store :active_record_store
```

Restart the server if it is running. No other changes in the app are necessary.

### In-Memory Storage with Redis and `redis-store`

The best option for scalable server-side session storage is to use Redis (http://redis.io/). Redis is an extremely fast in-memory data store which can be used for direct data storage, caching, and session storage. It is becoming an essential component of any major Rails application.

The `redis-store` library provides a Ruby interface to each of these jobs. Specifically, `Rack::Session::Redis` implements the session storage interface that Rails expects. 

* Advantages
  * Size limited only by Redis
  * Little danger of user tampering
  * Only uses a cookie to track session id client side
  * Little data transferred to/from client
  * Extremely fast querying and storing of data  
* Disadvantages
  * Necessitates extra process / setup
  * Need to be pruned via monitor process

#### Setup

Setup and start the Redis server. Add a dependency on the `redis-store` gem to your `Gemfile` and run `bundle`.

Open `config/initializers/session_store.rb` and change the line like this:

```ruby
MyApp::Application.config.session_store :cookie_store, key: '_myapp_session'
```

To this:

```ruby
MyApp::Application.config.session_store Rack::Session::Redis
```

Restart the server and you're ready to go!

## Exercises

{% include custom/sample_project.html %}

1. Output the entire session by calling `debug session.inspect` from the application layout.
2. Write a `before_filter` in `ApplicationController` named `set_last_action` and trigger it on every action in the application. In the action, store the current time into a session key named `last_action`. Look for the value in your debug output.
3. Write an `after_filter` in `ApplicationController`, triggered on every action, that _appends_ the timestamp in `last_action` to the current `flash[:notice]`. Remove the `debug session.inspect` from your layout and observe the timestamp in the flash of each action.
4. Follow the steps in the text to implement database-backed sessions. Restart your server and verify the filters still work as expected. *CHALLENGE*: using a database inspection tool, look at the sessions table and find how the session is serialized. What data format is that? What security threat does this pose?

## Reference

* Rails Guide on Security (& Sessions): http://guides.rubyonrails.org/security.html#sessions
* Rails Guide on Configuring Rails Applications: http://guides.rubyonrails.org/configuring.html
* Redis: http://redis.io/
* `redis-store`: https://github.com/jodosha/redis-store and http://jodosha.github.com/redis-store/
