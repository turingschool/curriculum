---
layout: page
title: Workers and Services
---

## Workers and Services

There are some common weaknesses in the implementation of background jobs. Let's look at an example from one of your projects, do some refactoring, and push out the reliance on Rails.

### Setup

* Clone [https://github.com/jcasimir/example_feed_engine](https://github.com/jcasimir/example_feed_engine)
* Run `bundle`
* `rake db:migrate db:test:prepare`
* Start redis if it isn't already running: `redis-server /usr/local/etc/redis.conf`
* Run `rake` and you should get 86 green, 5 yellow
* Start `guard`

#### Areas of Focus

* We have some basic Ruby refactorings to pursue
  * Single Responsibility: methods, classes
* `perform` is just an entry point
* Getting away from Rails dependency
  * Query/submit through the API
  * Practice dream-driven development
* Running/testing in isolation
  * Queue with the data you need
  * Running isolation tests
  * Running jobs as an isolated app
