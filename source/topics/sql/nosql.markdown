---
layout: page
title: NoSQL Integration
---

A year ago everywhere you went people were talking about NoSQL in our community. It's cooled down a bit now, but the result of that excitement is that you have many options at your disposal.

## MongoDB

MongoDB has emerged as the most popular document database in the Rails community. There are concerns about the data integrity and the "eventually consistent" nature of the data distribution, but there are many projects using the database with great success.

### Adapters

You have two options for using Mongo from Ruby/Rails: MongoMapper and Mongoid.

#### MongoMapper

MongoMapper, driven primarilly by John Nunemaker, attempts to bring some of the niceties of `ActiveRecord` into the Mongo world. This library is popular and is usually the choice for people making their first leap into MongoDB.

More information is at http://mongomapper.com/

#### Mongoid

Mongoid is, according to statistics, the slightly more popular choice. It still mimics some functionality of `ActiveRecord`, but does so in a slightly cleaner way than MongoMapper. The development team is larger and, personally, I trust the Computer Science skills of the people behind it a bit more. Between the two, Mongoid would be my clear choice.

More info at http://mongoid.org/

## Key-Value Stores

The big area for growth right now in the "NoSQL" world are key-value stores.

### Memcached

Memcache is kinda the old guard in this realm. It's simple and it works. If you want to store key-value data in RAM it's reliable and easy to setup. There are client libraries for just about every language and platform.

### Redis

The new hotness is Redis. It does the job that Memcached did and adds a lot of functionality.

For instance, you can perform atomic operations. On memcache, you might fetch a value, increment it, then save the result. With Redis, you can just issue a single instruction to increment the counter.

It also implements simple data structures including hashes, lists, and sorted sets.

We're still figuring out the right ways to take advantage of Redis, but some popular options include:

* With the [Resque](https://github.com/defunkt/resque) library for coordinating background jobs
* With [Redis-Store](https://github.com/jodosha/redis-store) for storing translations, sessions, and caching pages/page fragments
* Manipulating native Redis objects with [redis-rb](https://github.com/ezmobius/redis-rb)
