---
layout: page
title: Asynchronous Messaging with Redis and Pub/Sub
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
* Traditional messaging patterns
* The PubSub (Publish and Subscribe) pattern
* Asynchronous, or "fire and forget"

## Experiments

With that base understanding in place, let's do some experiments with Redis and PubSub.

### Start Redis-CLI

In one terminal window, start the Redis Command Line Interface (CLI) and being monitoring interactions:

{% terminal %}
$ redis-cli
redis 127.0.0.1:6379> MONITOR
{% endterminal %}

### Start IRB Session "A"

In another terminal window, start an IRB session:

{% irb %}
$ require 'redis'
$ redis = Redis.new
{% endirb %}

### Start IRB Session "B"

Open a third tab in Terminal, start another IRB session, and subscribe to the channel named `my_channel`:

{% irb %}
$ require 'redis'
$ redis = Redis.new
$ redis.subscribe("my_channel") do |event|
  event.message do |channel, body|
    puts "I heard [#{body}] on channel [#{channel}]"
  end
end
{% endirb %}

Observe that...

* In the redis-CLI window, you see a subscriber added

### Publish in IRB Session A

Back in the first IRB session, publish a message:

{% irb %}
$ redis.publish("my_channel", "the message")
{% endirb %}

Observe that...

* In the redis-CLI window you see that a message was posted
* In IRB Session B you get the output `I heard [the message] on [my_channel]`

### Start IRB Session "C"

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

Check that...

* You see the second subscriber in the redis-cli window

### Broadcast to the Channel

Again, back in the first IRB session, publish another message:

{% irb %}
$ redis.publish("my_channel", "Is this thing on?")
{% endirb %}

Check that...

* The second IRB window outputs `I heard...`
* The third IRB window outputs `I think...`

## Pub/Sub Take Aways

* Async means the sender is done almost instantly
* Pub/Sub is setup so subscribing is "cheap"
* Published messages should be simple -- like strings or JSON, not complex serialized objects
