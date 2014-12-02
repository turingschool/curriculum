---
layout: page
title: HTTP Caching: Rack::Cache, Varnish and CDNs
section: Performance
---

We've seen a variety of caching techniques so far in our Rails projects
— from page/action caching to data and fragment caching. These techniques give us some flexibility to cache data at different levels of granularity, but so far they have all relied on a data store (often redis or memcached) which our application uses to store and retrieve chunks of cached data.

HTTP Caching is another caching technique which relies on some of the built-in features of the HTTP spec itself rather than on a cache data store which we control from our application. With HTTP caching we use cache headers to indicate whether a given resource is cacheable and if so, for how long. The benefit of this approach is that our application is only responsible for including cache information in the response. The storage mechanism is left flexible — it could be a proxy cache like varnish or Rack::Cache, a web browser's local cache, a CDN — or some combination of these.

The HTTP spec has some fairly sophisticated caching semantics built into it. Used well the proper combination of caching headers and HTTP response codes can drastically cut down on the amount of data being transferred by a server. In this tutorial, we'll look at using Rack::Cache and some of Rails' built-in HTTP caching features to store and re-render stale content on subsequent requests


### HTTP Caching Basics

Before we get started implementing Rack::Cache on our project, let's talk about some HTTP caching fundamentals and terminology.

In a nutshell, the goal of HTTP caching is to avoid transferring data over the network if it has not been changed since the last time it was retrieved. For our purposes, this data will most often be an HTML page (or possibly a JSON API response). Things that could cause the data to change might be updates to underlying database records which are represented in the page.

The job of our server, then, is to keep track of the data necessary to say whether a resource has changed or not. The client is responsible for sending some related timestamps and headers which allow the server to say if the client's most recent copy is up to date or not.

__Cache-Control__ - Server-provided header containing cache info. Should include `max-age=`, which will tell clients how long they are allowed to cache the attached data. Eg `Cache-Control: max-age=300`. Other Cache-Control headers include `no-store`, `public`, `private`, `no-cache`, `must-revalidate`, `proxy-revalidate`. `private` cached data is valid for only the specific user; effectively limited to browser caches.

__Validators__ - Server-side mechanism for determining if a client's data is recent enough or not. We will often use model `updated_at` timestamps for these.

__Last-Modified__ - Server-provided header showing what time a resource was last updated. Stored by client and used on subsequent requests to determine whether server needs to render a full response or not (a time-based validator).

__Etags__ - A digest representing the content in a response. Stored by client and used on subsequent requests to determine whether server needs to render a full response or not (a content-based validator).

__If-None-Match__ - HTTP validation header from client. Contains the Etag of the last known response for the requested resource. Server will validate against current content and respond with 304 if it's still a match.

__If-Modified-Since__ - HTTP validation header from client. Contains the `Last-Modified` timestamp of last known response. Server will validate against current timestamp and respond with 304 if it's still a match.

__Status Codes: 304 Not Modified__ - HTTP response code associated with content which has not changed since it was last retrieved. Allows server to tell client their previous response is still valid without re-generating the entire response body.


### Rack::Cache

Rack::Cache is rack middleware which provides a lightweight, local HTTP proxy cache. It's not as configurable as a more sophisticated proxy server like Varnish and does not have the distribution advantages of a CDN, but it is very easy to set up and is supported out of the box with Rails. Let's look at adding it to the example storedom project.

Start by cloning, bundling, etc:

```
git clone https://github.com/turingschool-examples/storedom.git http-caching-workshop
cd http-caching-workshop
bundle
be rake db:drop db:create db:setup
rails s
```

Recall from the [Load Testing tutorial](http://tutorials.jumpstartlab.com/topics/performance/load_testing.html) that we can use the Apache Bench (`ab`) utility to quickly load test a server. Let's see how the index action of our base storedom app currently performs:

```
ab -n 1000 -c 100 http://localhost:3000/items

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.9      0       4
Processing:  1767 11344 1884.9  11583   14319
Waiting:     1762 11338 1883.9  11579   14319
Total:       1771 11345 1884.2  11583   14319

Percentage of the requests served within a certain time (ms)
  50%  11583
  66%  11933
  75%  12081
  80%  12243
  90%  12705
  95%  13691
  98%  14003
  99%  14182
 100%  14319 (longest request)
```

Not the best, considering that the content on this page is basically static. Our problem is that rendering the action involves a relatively expensive DB query (loading all items), and we are performing it on every request even when the data is unchanged. Let's see if we can improve its performance by implementing Rack::Cache.

__Step 1: Enable Caching in Development Mode__

By default Rails disables caching in development. Since we want to test our cache in dev, let's re-enable it by changing this line in our `config/development.rb`:

```
  config.action_controller.perform_caching = true
```

__Step 2: Add Rack::Cache middleware to the app__

Middleware are configured in `config/application.rb`. Add this configuration to the file:

```
    config.middleware.use Rack::Cache,
      :verbose => true,
      :metastore   => 'file:/tmp/cache/rack/meta',
      :entitystore => 'file:/tmp/cache/rack/body'
```

The `metastore` and `entitystore` entries here tell the cache where to store its data. `verbose` mode means to log info about what is being cached. To verify it worked, you can run `rake middleware` and make sure that `Rack::Cache` appears in the list.

__Step 2: Add Stale Checks in Items#index__

Next we need to add some checks in our controller to determine if the content is stale or not. Rails provides several methods on `ActionController` for manipulating the HTTP cache headers. These are defined in the `ActionController::ConditionalGet` module ([http://api.rubyonrails.org/classes/ActionController/ConditionalGet.html](http://api.rubyonrails.org/classes/ActionController/ConditionalGet.html))

`expires_in` - set expires_in header for current response

`fresh_when` - conditionally renders a 304 if the content is still fresh based on supplied etag, last_modified, and public data.

`stale?` - Used to branch conditionally on staleness/freshness - useful if you are handling multiple request formats in a single controller.

We can use this in our index action to conditionally return a 304 if our data is still fresh. This begs the question, however — how do we know if the data is fresh or not? In our case, the index action is just rendering a list of items, defined by the query `Item.all`. It seems reasonable, then, that the last updated time of the entire list would be the most recent updated timestamp of all the items.

We can find this with `Item.maximum(:updated_at)`.

Let's use `fresh_when` with this attribute in our controller:

```
  def index
    @items = Item.all
    fresh_when(:last_modified => Item.maximum(:updated_at), :public => true)
  end
```

Now let's try the endpoint with curl:

```
curl -I localhost:3000/items
HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Last-Modified: Mon, 01 Dec 2014 22:41:23 GMT
Content-Type: text/html; charset=utf-8
Cache-Control: public
X-Request-Id: e6d22a5d-948b-41b6-bd8f-60e19f3597a5
X-Runtime: 0.106738
Server: WEBrick/1.3.1 (Ruby/2.1.1/2014-02-24)
Date: Mon, 01 Dec 2014 23:40:58 GMT
Content-Length: 0
Connection: Keep-Alive
```

Still getting an HTTP 200, but now we can see the response includes a `Last-Modified` header. We can send this on a subsequent request to allow the server to "validate" against that timestamp and optionally send us a 304 if the response has not changed.


```
curl -I localhost:3000/items --header 'If-Modified-Since: Mon, 01 Dec 2014 22:41:23 GMT'
HTTP/1.1 304 Not Modified
X-Frame-Options: SAMEORIGIN
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Last-Modified: Mon, 01 Dec 2014 22:41:23 GMT
Cache-Control: public
X-Request-Id: 5a264e5f-88cb-4b57-9337-1716cd6a3747
X-Runtime: 0.007498
Server: WEBrick/1.3.1 (Ruby/2.1.1/2014-02-24)
Date: Mon, 01 Dec 2014 23:42:30 GMT
Connection: Keep-Alive
Set-Cookie: request_method=HEAD; path=/
```

Not bad. Let's look at one more thing in our controller. Our action currently looks like this:


```
 def index
   @items = Item.all
   fresh_when(:last_modified => Item.maximum(:updated_at), :public => true)
 end
```

Notice anything fishy? We're loading `@items` on every request, even if we end up sending a 304 because the client has up-to-date information. The point of HTTP caching is to make our 304 responses as close to "free", so we should avoid unnecessary queries like this.

Restructure the controller and the `items/index.html.erb` template to lazily load items so that we only incur that query cost for requests that need to be rendered.

Once we have that done, restart the server to allow Rack::Cache to boot up. Then let's try again with apache bench:

__(Keep in mind your timestamps will be different depending on when your data was migrated and when you are working through the tutorial)__

```
ab -n 1000 -c 100 -H 'If-Modified-Since: Mon, 01 Dec 2014 22:41:23 GMT' http://localhost:3000/items

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   1.1      0       5
Processing:    71  766 102.9    785     976
Waiting:       71  765 102.9    785     976
Total:         75  766 102.2    785     978

Percentage of the requests served within a certain time (ms)
  50%    785
  66%    790
  75%    793
  80%    795
  90%    880
  95%    885
  98%    887
  99%    914
 100%    978 (longest request)  
```

Much better -- we're now hitting one fast db query (find the most recently updated time for an item) every request instead of a big query to fetch all items.

However we can see from our server logs that we're still getting through to the Application on each request, which shouldn't be happening. For example:

```
Started GET "/items" for 127.0.0.1 at 2014-12-01 16:23:46 -0700
Processing by ItemsController#index as */*
   (0.3ms)  SELECT MAX("items"."updated_at") AS max_id FROM "items"
Completed 304 Not Modified in 1ms (ActiveRecord: 0.3ms)
```

The goal of an HTTP cache is to sit between an application server and an end-user, and completely intercept and respond to requests for which it has valid cached data.

Our server is validating the requests properly based on the `If-Modified-Since` headers coming from the client, but we still haven't set an "expires at" value for our HTTP Cache-Control header. The default value is 0, so Rack::Cache is refusing to serve cached data (it is attempting to validate every time).

Let's fix this by adding an `expires_in` setting in our action:

```
  def index
    expires_in 1.minutes, :public => true
    fresh_when(:last_modified => Item.maximum(:updated_at), :public => true)
  end
```

Try the `ab` command again and we should see some cache hits in the server log. Additionally, we can now drop the `If-Modified-Since` headers we were sending from `ab`, since Rack::Cache will actually handle these (it communicates the headers to the Rails server so that we don't have to):

```
ab -n 1000 -c 100 http://localhost:3000/items

....

Started GET "/items" for 127.0.0.1 at 2014-12-01 16:53:59 -0700
cache: [GET /items] fresh
```

Now wait one minute and try again. The `expires_in` time has elapsed, the cached data is no longer valid, and we should see Rack::Cache re-validate against the server again. Something like:

```
Started HEAD "/items" for 127.0.0.1 at 2014-12-01 16:55:20 -0700
Processing by ItemsController#index as */*
   (0.3ms)  SELECT MAX("items"."updated_at") AS max_id FROM "items"
Completed 304 Not Modified in 1ms (ActiveRecord: 0.3ms)
cache: [HEAD /items] stale, valid, store
```

The "stale, valid, store" indicates that Rack::Cache received a request for stale data, validated against the server, and stored the new response in its cache, ready for the next request. Then all responses should be cached again for another minute.

#### Independent Work

Let's experiment further with Rack::Cache

* Invalidate the response by updating one of the items from console (causing its updated_at timestamp to change). Verify that requests sent with the previous `If-Modified-Since` headers no longer receive a 304. A request with the new `Last-Modified` value provided by the server should now 304.

* Add HTTP Caching to the Items#show endpoint. What is the proper last-modified timestamp for a single item?

* Do some reasearch on Varnish and CDNs like Akamai. What are the differences between Rack::Cache and these tools? What might be some of the advantages and disadvantages of each.


#### More Reading

http://railscasts.com/episodes/321-http-caching

http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html

http://rtomayko.github.io/rack-cache/

http://tomayko.com/writings/things-caches-do