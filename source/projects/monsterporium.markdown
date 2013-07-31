---
layout: page
title: Monsterporioum
sidebar: true
---

In this project you'll take an existing application and practice breaking logic and functionality into a cluster of smaller services.

## Course Plan

### High-Level Goals

At a high-level, we're studying:

* How a services architecture works
* What parts of an application can become services
* How services affect our development processes

In addition, we're practicing fundamental techniques like:

* Pushing logic down the stack
* Testing of complex systems
* Managing deployment of multiple applications

### Learning Goals

When you complete this course, you should be able to:

1. evaluate functionality to determine suitability for a service
2. implement message posting to a service along-side existing functionality
3. consume queued messages and act on them
4. validate functionality end-to-end
5. remove now-redundant functionality from primary app
6. access data across services using appropriate abstraction.
7. write data to a service using a REST API

### Schedule

1. Fundamentals of Services
2. Extracting Email to a Service
3. Identifying Real-World Services
4. Extracting Ratings to a Service
5. Wrapup and Q&A
6. Next Steps

## Planning Topics

#### Quick

Notifications.

Prep: add notification count to admin in primary app

0. add redis to the primary app
0. shunt existing notifications through redis
0. Add semi-automated end-to-end testing with mailcatcher
0. build the separate ruby service (pony, cron job)
0. make it consume the redis events, write to a log
0. trigger actual notification in service, comment out in primary app
0. delete obsolete code in primary app
0. Add sinatra api: return count of dispatched emails
0. Create proxy to talk to API
0. Display proxied number in admin view

#### Real World: Identify Potential Services

Pair for 30 minutes on identifying potential targets.

In the full group, vote for the top two potential targets.

Spend 1 hour on each, whiteboarding.

#### Full

Ratings

- reading
- writing
- reading through JS

#### Wrap

#### Leave-Behind

Search.



### Process

* BDD
  * Black-box testing
  * Characterization tests
  * Tracking the growth/shrink of views
* Red/Green/Refactor
* Deployment
* Pushing logic down the stack

### Technical

* Creating a gem
* JSON
* Authentication
* REST
* VCR
* Petroglyph
* Redis
  * Pub/Sub
  * Async
  * Alternatives
* ElasticSearch
* Capybara + Poltergeist
* JavaScript
  * Accessing data on a server
  * Manipulating the DOM
  * Masking Latency

### Prep

* Watch Chris Kelly’s talk
* Setup for using localhost, ex lvh.me?

### Etc

* CodeClimate
* Git practices

## Introducing Services

### Fractal Design

* SOLID and SRP
* Apply it several layers of abstraction
  * Line of code
  * Method
  * Class
  * **Application**

### Definitions and Concepts

* A **Service**, strictly speaking is A but for our purposes, it's B
* A **Message** is how one application communicates with another
* A **Message Service** is the channel which accepts and delivers a message
* **Pub/Sub** is a messaging architecture which allows multiple subscribers to listen to a single publisher

### Services within MVC

#### The Proxy Approach

* Starting with a traditional MVC layout
* The model is responsible for domain logic and data access
* Services are data and domain logic
* As such, they should be encapsulated down at the model layer
* The controller and view shouldn't know that the service exists

#### The Smart Client Approach

* The primary app doesn't have to know everything
* It's acting as a middleman
* We can take advantage of smart JavaScript clients
* Treat the client as the proxy
* Directly access the services and manipulate the DOM
* Completely remove the service from the primary app's MVC

### How Messaging Works

* Install Redis
* Create a publisher
* Create a subscriber
* Publish a message
* See it
* Create another subscriber
* Publish a message
* See it

### Identifying a Service

A good candidate for extraction to a service...

* Has limited and known interactions with other parts of the domain logic
* Are a conceptual piece of value rather than a just a piece of functionality
* Could potentially be reused in a different application

Poor candidates for service extraction...

* Need access to large pieces of data from the primary application
* Are reading and writing primary application data
* ???

### The Pros and Cons

#### Pros

* lower churn
* connect for free / low cost
* redundancy
* easier to reason about
* scaling
* reuse
* uncoupled deployment
* reimplement / experiments

#### Cons

* deployment / ops
* versioning
* testing
* http requests
* duplication (creating POROs)

### The Process of Building a Service

Duplicate, Validate, Delete:

1. Implement message creation
2. Build the service to consume those messages
3. Validate the functionality of the service in parallel with the primary application
4. Remove functionality from the primary application
