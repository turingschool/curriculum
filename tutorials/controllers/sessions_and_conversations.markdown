# Sessions and Conversations

HTTP is a stateless protocol. Sessions allow us to chain multiple requests together into a conversation between client and server.

Sessions should be an option of last resort. If there's no where else that the data can possibly go to achieve the desired functionality, only then should it be stored in the session. Sessions can be vulnerable to security threats from third parties, malicious users, and can cause scaling problems.

That doesn't mean we can't use sessions, but we should only use them where necessary.

## Adding, Accessing, and Removing Data

Rails gives us access to the current session through the `session` helper method. Much like the `params` method, the `session` method returns us an object that we can think of as a hash. In reality it is an instance of `ActionDispatch::Session::AbstractStore::SessionHash`.

### Adding

We can add information to the session just like a regular hash:

```ruby
def new
  @order = current_user.orders.create
  session[:order] = @order.to_param
end
```

The session can store any kind of string data, but you're best served by keeping it as small as possible for both speed and security. Instead of storing whole objects, store the ID of that object, then do a lookup as necessary.

### Reading

Then, in the current or later requests, you can access that data:

```ruby
def add_to_cart
  @order = current_user.orders.find(session[:order])
  @order << Product.find(params[:id])
end
```

Note that we only fetch an order ID from the session, then run a scoped query against the database. We rely on `current_user.orders` to scope the search to just orders attached to this user. You should be skeptical of data coming out of a session and assume that a user can, one way or another, modify the data. Scoping queries like this can insulate you from serious security issues.

### Deleting

Just like a hash, values can be cleared by setting them to `nil` or calling `delete` with the key:

```ruby
session[:order] = nil
# or
session.delete(:order)
```

#### Reset

If you want to erase the entire session, call `reset_session`:

```ruby
def new
  reset_session
  @order = current_user.orders.create
  session[:order] = @order.to_param
end
```

## Storage Options

Where you store the session data has implications for performance and security.

### User Cookies

The default storage mechanism is the browser's cookie.

* Advantages
  * No server storage
  * No extra queries server-side
  * No setup effort
* Disadvantages
  * User access / viewable, possible tampering
  * 4kb Size Limit
  * Tied to a single physical client machine
  * Sent with each request (increasing total bandwidth)

There is no configuration necessary to use cookies, they're setup and "on" by default.

### Database Storage with `ActiveRecordStore`

Some sites choose to use database storage to move the bulk of the data server-side:

* Advantages
  * Size limited only by database
  * Less prone to user modification
  * Only uses a cookie to track session id client side
  * Less data transferred to/from client
* Disadvantages
  * Causes an extra database query on every request
  * Can inflate database disk/memory usage
  * Need to be pruned via monitor process

#### Setup

First, create a migration to build the database table. From your command prompt:

```
rails generate session_migration
rake db:migrate
```

Then open `config/initializers/session_store.rb` and change the line like this:

```ruby
MyApp::Application.config.session_store :cookie_store, :key => '_myapp_session'
```

To this:

```ruby
MyApp::Application.config.session_store :active_record_store
```

Restart the server if it's running. No other changes in the app are necessary.

### In-Memory Storage with Redis and `redis-store`

The best option for scalable session storage is to use Redis (http://redis.io/). Redis is an extremely fast in-memory data store which can be used for direct data storage, caching, and session storage. It is becoming an essential component of any major Rails application.

The `redis-store` library provides a Ruby interface to each of these jobs, including `Rack::Session::Redis` which implements the session storage interface that Rails expects. Compared to the other options for session storage:

* Advantages
  * Size limited only by Redis
  * Less prone to user modification
  * Only uses a cookie to track session id client side
  * Less data transferred to/from client
  * Extremely fast querying and storing of data  
* Disadvantages
  * Necessitates extra process / setup
  * Need to be pruned via monitor process

#### Setup

Setup and start the Redis server. Add a dependency on the `redis-store` gem to your `Gemfile` then run `bundle`.

Open `config/initializers/session_store.rb` and change the line like this:

```ruby
MyApp::Application.config.session_store :cookie_store, :key => '_myapp_session'
```

To this:

```ruby
MyApp::Application.config.session_store Rack::Session::Redis
```

Restart the server and you're ready to go!

## Reference

* Rails Guide on Security (& Sessions): http://guides.rubyonrails.org/security.html#sessions
* Rails Guide on Configuring Rails Applications: http://guides.rubyonrails.org/configuring.html
* Redis: http://redis.io/
* `redis-store`: https://github.com/jodosha/redis-store and http://jodosha.github.com/redis-store/