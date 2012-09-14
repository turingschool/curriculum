---
layout: page
title: Instructions, Challenges to Tackle
---

## Instructions & Challenges

### Instructions

* Clone [`git://github.com/JumpstartLab/simple_feed_client.git`](`git://github.com/JumpstartLab/simple_feed_client.git`)
* Tests
  `bundle exec rspec`
* Startup    
  `bundle exec irb`
  `Bundler.require`
* Authentication
  * Username: j3
  * Password: hungry

### Challenges to Tackle

1. Configurability
  * Point the client towards the heroku server
  * Make the target URL configurable
2. Testing Existing `get_feed`
  * Check that the status is 200
  * Check the body
    * Parse it with JSON 
    * Check that it's a hash
3. Abstract the Response
  * Create a `Feed` object
  * Rework `get_feed` to initialize and return the `Feed` object
4. Child Objects
  * Query the feed for its items
  * Create specific types of feed items and return the mixed collection