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

0. Extracting Responsibilities
1. Fundamentals of Services
2. Extracting Email to a Service
3. Identifying Real-World Services
4. Extracting Ratings to a Service
5. Wrap-up and Q&A
6. Next Steps

## Refactoring to Services

### Extracting Responsibilities

The process of creating services is about extracting logic. When working with a complex Rails application, it can be hard to see where the boundaries between objects should lie.

Let's get started with a short project in pure Ruby to explore how extracting responsibilities into objects can simplify our design.

Jump over to [Extracting Responsibilities]({% page_url extracting_responsibilities %}).

### Introducing Services

Before we dive into writing services, let's discuss a bit of the theory including:

* Fractal Design
* The Proxy Approach
* The Smart-Client Approach

Go to [Introducing Services]({% page_url introducing_services %}).

### Extracting Notifications

Now that you have a feel for Redis, PubSub, and the theory of extracting services -- let's actually do it. In this tutorial you'll practice:

* Writing characterization tests to validate existing functionality
* Inserting a shim layer to pull logic away from the primary application
* Introducing a message queue
* Implementing an external Ruby script
* Removing functionality from the primary application
* Validating the results

Jump over to the [Extract Notification Service]({% page_url extract_notification_service %}) tutorial.

### Practicing with Services

It's one thing to be led by the hand through the extraction of a service. In this segment, we turn the responsibility over to you. Let's experiment with extracting a service from your primary work.

Jump over to the [Practicing with Services]({% page_url practicing_services %}) tutorial.

### Extracting Ratings

The notifications service was able to just push messages without interacting with the service directly. Let's work with a more complex service that needs to both read and write data. 

* Writing characterization tests to validate existing functionality
* Inserting a shim layer to pull logic away from the primary application
* Reimplementing the logic as a Sinatra service
* Removing functionality from the primary application
* Validating the full-stack functionality

Jump over to the [Extract Ratings Service]({% page_url extract_ratings_service %}) tutorial.

### Implementing Authentication

Finally we'll kick it up a notch on the complexity scale and extract all authentication / user management to an external servies. To pull it off you will:

* Use Rails to implement an authentication service
* Gather/shim user dependencies in the primary app
* Pull those responsibilities out into a wrapper gem
* Connect the primary app to the authentication app through the gem
* Make shared information available between the apps to eliminate tampering / forgery

Go to the [Extracting Authentication](#) tutorial.

## Wrap-Up

Finally, it's time for the big Q&A and working on some of your own code.

### Addendum: Implementing Search

Search is an excellent service to extract because you're probably relying on an external search system already (like ElasticSearch, Solr, etc). Extracting search typically means building a few components:

* A component that's responsible for sending any new content into the indexer
* A component that actually runs queries against the index
* A component that wraps those results into domain objects for the primary app
