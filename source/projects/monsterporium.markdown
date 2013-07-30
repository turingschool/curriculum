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
