---
layout: page
title: Monsterporium - Development Practices
sidebar: true
---

With all that extraction out of the way, let's talk about a few workflow practices and tools that are useful when working with services.

### Writing a Gem

Ideally the team that is responsible for writing/maintaining a service is also responsible for building the wrapper or proxy gem. Let's look at how to take our existing proxy classes and [roll them into a new gem]({% page_url creating_a_gem %}).

### Deploying Services

There's a counter-intuitive trick to deploying services: there is nothing to it.

One of the beauties of systems architectures is that you **very rarely** want or need to deploy all the applications at once.

Let's talk about [how to deploy an application with Capistrano]({% page_url deploying_with_capistrano %}) and just setup one Cap recipe for each application.

### Alternative Messaging Systems/Styles

PubSub with Redis is our favorite system for async messaging, but there are many other options including:

* [RabbitMQ](http://www.rabbitmq.com/)
* [ZeroMQ](http://zeromq.org/)

### Code Climate

We strongly recommend that any project worth working on get setup on [Code Climate](https://codeclimate.com/), an awesome tool for analyzing the quality of the code in an application and how that quality is changing over time.