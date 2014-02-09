---
layout: page
title: Asynchronous Messaging with Redis and PubSub
sidebar: true
---

## Getting Started with Redis PubSub

* How messaging works
* Request-Response Pattern
* Asynchronous Messaging
* PubSub Messaging Pattern

### How Messaging Works

A message pattern is a network-oriented architecture that describes how two different parts of a system connect and communicate with each other.

### Request-Response Pattern

When you are browsing the Internet, the most common messaging pattern is the request-reply pattern.

When you visit a website, for example, your browser sends a request to a server, and the server responds with the data that your browser will render on your screen. Since this happens at the moment the user sends the request, this is a synchronous request.

### Asynchronous Messaging

This works well when the user is the one who starts the request, but what if something happened in the server, like receiving an email, and you don't know anything about it? Using the request-reply pattern synchronously will mean that unless the user sends a new request, like hitting a "refresh" button, he won't be able the get his email.

The asynchronous request-response messaging pattern provides a potential solution. This type of pattern lets us to put the request in a queue allowing us to say how often we would like to send a request to the server. Therefore, we can check the server every once in a while to see whether there is new data, like a new email, and get it from the server.

### PubSub Messaging Pattern

But what if you have are in a chatroom and several users are talking to each other at the same time? If you use the asynchronous request-response pattern, your users will only get the new messages once in a while, derailing the entire conversation.

The PubSub messaging pattern solves this by having one publisher (i.e. the chat service) and many subscribers (i.e. the chatroom participants). This pattern lets the publisher to send one message to one or more clients that are subscribed to that publisher.

This means that everytime something changes in the chat service, the server will send a message to all the participants at once allowing real-time conversations.

## Experiments

With that base understanding in place, let's do some experiments with Redis and PubSub.

### Getting Started

Before jumping ahead, make sure you have Redis installed. Redis is a key-value store that allow us entry and retrieve data very fast. If you don't have it, you can install it using homebrew:

{% terminal %}
$ brew install redis
{% endterminal %}

Also, don't forget to install the Redis gem. This will let us talk to the Redis database using Ruby. You can install the gem by doing this:

{% terminal %}
$ gem install redis
{% endterminal %}

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

Observe that in the redis-CLI terminal window, you see a subscriber added.

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

Make sure that you see the second subscriber in the redis-cli terminal window.

### Broadcast to the Channel

Again, back in the first IRB session, publish another message:

{% irb %}
$ redis.publish("my_channel", "Is this thing on?")
{% endirb %}

Observe that...

* The second IRB window outputs `I heard...`
* The third IRB window outputs `I think...`

## Pub/Sub Take Aways

* Asynchronous, or async, means the sender is done almost instantly when it sends the message by putting it in a queue.
* PubSub subscribing is "cheap". You can have one sender and numerous subscribers without affecting the publisher.
* Published messages should be simple -- like strings or JSON, not complex serialized objects.
