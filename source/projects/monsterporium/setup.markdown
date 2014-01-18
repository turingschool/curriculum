---
layout: page
title: Setup for Services
---

## Ruby

We're assuming that you [already have Ruby 1.9.3 or 2.0]({% page_url environment %}) ready to go.

## Clone the Monsterporium

You can see the [store_demo repository on GitHub](https://github.com/jumpstartlab/store_demo) and clone it like this:

{% terminal %}
$ git clone git@github.com:JumpstartLab/store_demo.git
{% endterminal %}

Make sure you are in the project directory:

{% terminal %}
$ cd store_demo
{% endterminal %}

Create a branch for this tutorial.

{% terminal %}
$ git checkout -b extract-notifications
{% endterminal %}

Then get ready to go:

{% terminal %}
$ bundle
$ rake db:migrate db:seed db:test:prepare
$ rake
{% endterminal %}

## Install Redis

You'll need Redis installed and running on your system. On OS X with homebrew, it's as easy as:

{% terminal %}
$ brew install redis
{% endterminal %}

Then test it by starting up the redis command line interface:

{% terminal %}
$ redis-cli
redis 127.0.0.1:6379> exit
{% endterminal %}

### Redis Gem

Install the Redis gem from Rubygems:

{% terminal %}
$ gem install redis
{% endterminal %}

Then test it from IRB:

{% terminal %}
$ irb
001 > require 'redis'
 => true
002 > r = Redis.new
 => #<Redis client v3.0.4 for redis://127.0.0.1:6379/0>
003 > r.set("hello", "world")
 => "OK"
004 > r.get("hello")
 => "world"
005 > exit
{% endterminal %}