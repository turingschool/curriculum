---
layout: page
title: Workers & Services
---

## Workers and Services

We'll follow up on yesterday's session and then work through a sample implementation from scratch.

### Setup for optional session

* Pull the latest of SimpleFeed and SimpleFeedClient
* Run `bundle` in both apps
* Start redis if it isn't already running: `redis-server /usr/local/etc/redis.conf`
* Start `guard`

### Workers Areas of Focus from Yesterday

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
