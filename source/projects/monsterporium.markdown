---
layout: page
title: Monsterporioum
sidebar: true
---

In this project you'll take an existing application and practice breaking logic and functionality into a cluster of smaller services.

## High-Level Goals

At a high-level, we're studying:

* How a services architecture works
* What parts of an application can become services
* How services affect our development processes

In addition, we're practicing fundamental techniques like:

* Pushing logic down the stack
* Testing of complex systems
* Managing deployment of multiple applications

## Planning Topics

### Learning Goals

0. Developer is able to evaluate functionality to determine suitability for a service
0. Developer is able to implement message posting to a service along-side existing functionality
0. Developre can consume queued messages and act on them
0. Developer can validate functionality end-to-end
0. Developer can remove now-redundant functionality from primary app
0. Developer can access data across services using appropriate abstraction.
0. Developer can write data to a service using a REST API

### Overall Course Structure

0. Background (1/2-1 day)
0. Quick (1-2 days)
0. Real-World: Identify potential services
0. Full (2-3 days)
0. Wrap (1 day)
0. Leave-Behind?

#### Background

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

### Conceptual

* Services as a part of MVC
* Fractal design
* Services vs Mini-apps = web services
* What can be a web service?
* How is functionality extracted?
  * Duplicate, Validate, Delete
* Responsibilities
* What does end-to-end testing look like?

### SOA Benefits

* lower churn
* connect for free / low cost
* redundancy
* easier to reason about
* scaling
* reuse
* uncoupled deployment
* reimplement / experiments

### SOA Sacrifices

* deployment / ops
* versioning
* testing
* http requests
* duplication (creating POROs)

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
