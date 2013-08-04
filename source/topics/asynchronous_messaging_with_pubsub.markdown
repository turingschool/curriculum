---
layout: page
title: Asynchronous Messaging with Pub/Sub
sidebar: true
---

## Dependencies

Install redis:

{% terminal %}
$ brew install redis
{% endterminal %}

Install the redis gem:

{% terminal %}
$ gem install redis
{% endterminal %}



## Getting Started with Redis Pub/Sub

* How messaging works
* Publish and Subscribe
* Why it's asynchronous

### Experiments

In one terminal window, start the Redis Command Line Interface (CLI) and begin monitoring interactions:

{% terminal %}
$ redis-cli
redis 127.0.0.1:6379> MONITOR
{% endterminal %}

In another terminal window, start an IRB session:

{% irb %}
$ require 'redis'
$ redis = Redis.new
{% endirb %}

Now open a second IRB session in a third terminal window:

{% irb %}
$ require 'redis'
$ redis = Redis.new
$ redis.subscribe("my_channel") do |event|
  event.message do |channel, body|
    puts "I heard [#{body}] on channel [#{channel}]"
  end
end
{% endirb %}

Back in the first IRB session, publish a message:

{% irb %}
$ redis.publish("my_channel", "the message")
{% endirb %}

Observe that...

* In the redis-CLI window, you see a subscriber added and a message posted
* In the second IRB session, you get the output `I heard [the message] on [my_channel]`

Now, leaving all the existing windows open, open a third IRB session in a final terminal window:

{% irb %}
$ require 'redis'
$ redis = Redis.new
$ redis.subscribe("my_channel") do |event|
    event.message do |channel, body|
      puts "I think [#{body}] sounds great!"
    end
  end
{% endirb %}

Again, back in the first IRB session, publish another message:

{% irb %}
$ redis.publish("my_channel", "Is this thing on?")
{% endirb %}

Check that...

* You see the second subscriber in the monitor window
* The second IRB window outputs `I heard...`
* The third IRB window outputs `I think...`

### Pub/Sub Review

* Async means faster first response
* Pub/Sub is setup so subscribing is "cheap"
* Published messages should be simple -- like strings or JSON, not complex serialized objects
