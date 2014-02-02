---
layout: page
title: Monsterporium - Refactoring to Services
sidebar: true
---

In this series of tutorials you'll take an existing application and practice breaking logic and functionality into a cluster of smaller services.

## Course Plan

### Learning Goals

When you complete this course, you should be able to:

1. Evaluate functionality to determine suitability for a service
2. Implement message posting to a service along-side existing functionality
3. Consume queued messages and act on them
4. Validate functionality end-to-end
5. Remove now-redundant functionality from primary app
6. Access data across services using appropriate abstraction
7. Write data to a service using a REST API

In addition, you'll practice fundamental techniques like:

* Pushing logic down the stack
* Testing complex systems
* Refactoring under test

### Schedule

1. Introducing Services
2. Practicing Services
3. Asynchronous Messaging
4. Extracting Notifications
5. Extracting Ratings
6. Next Steps

## Refactoring to Services

### Introducing Services

Before we dive into writing services, let's discuss a bit of the theory including:

* Fractal Design
* The Proxy Approach
* The Smart-Client Approach

Go to [Introducing Services](http://tutorials.jumpstartlab.com/projects/monsterporium/introducing_services.html).

### Practicing with Services

Extracting services can seem like a big, unweildy, and confusing ordeal. To
give you a gentle start, we're going to give you an itty-bitty specification
for a service to practice on.

Jump over to the [Practicing with Services](http://tutorials.jumpstartlab.com/projects/monsterporium/practicing_services.html) tutorial to wrap your head around the idea of services before diving into the larger tutorials.

### Asynchronous Messaging

One key pattern that you'll see over and over again when dealing with
services is the publish-subscribe messaging pattern (PubSub). This allows you
to have one message sender (publisher) and many message receivers
(subscribers), like in a chatroom.

Jump over to the [Asynchronous Messaging](http://tutorials.jumpstartlab.com/topics/asynchronous_messaging_with_pubsub.html) tutorial to get a feel for how PubSub
works.

### Extracting Notifications

Now that you have a feel for Redis, PubSub, and the theory of extracting services -- let's actually do it. In this tutorial you'll practice:

* Writing characterization tests to validate existing functionality
* Inserting a shim layer to pull logic away from the primary application
* Introducing a message queue
* Implementing an external Ruby script
* Removing functionality from the primary application
* Validating the results

Jump over to the [Extract Notification Service](http://tutorials.jumpstartlab.com/projects/monsterporium/extract_notification_service.html) tutorial.

### Extracting Ratings

The notifications service was able to just push messages without interacting with the service directly. Let's work with a more complex service that needs to both read and write data.

* Writing characterization tests to validate existing functionality
* Inserting a shim layer to pull logic away from the primary application
* Reimplementing the logic as a Sinatra service
* Removing functionality from the primary application
* Validating the full-stack functionality

Jump over to the [Extract Ratings Service](http://tutorials.jumpstartlab.com/projects/monsterporium/extract_ratings_service.html) tutorial.

## Next Steps

Finally, it's time to work on some of your own code.

### Addendum: Implementing Search

Search is an excellent service to extract because you're probably relying on an external search system already (like ElasticSearch, Solr, etc). Extracting search typically means building a few components:

* A component that's responsible for sending any new content into the indexer
* A component that actually runs queries against the index
* A component that wraps those results into domain objects for the primary app
