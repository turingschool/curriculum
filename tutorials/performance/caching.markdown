# Caching

( Premise of Caching )
( We'll use Redis as the cache server )

## `redis-store`

( Basic Intro for Redis-Store)

### Install

( Add to Gemfile, bundle)

### Redis Options

( Show defaults ) 
( Example of specifying IP, port, etc)

## Direct Data Caching

( Store and fetch individual values from cache )
( Maybe EX is a counter or something )

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