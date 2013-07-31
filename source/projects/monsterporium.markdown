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

0. Extracting Responsibilities
1. Fundamentals of Services
2. Extracting Email to a Service
3. Identifying Real-World Services
4. Extracting Ratings to a Service
5. Wrapup and Q&A
6. Next Steps

## Extracting Responsibilities

Let's start today as we will every day: by programming. In this session, our goals are to:

* Get your mind ready for programming
* Explore the fundamental premise of extracting logic out into related objects

### Setup

Please:

* Get together with another developer to pair program
* Clone the [Robot Simulator](https://github.com/JumpstartLab/code_retreat) exercise

### Initial Implementation

Spend the next 30 minutes trying to get the tests to pass with your pair. 

If you'd like an extra challenge, implement your solution with **no if statements**.

### Discuss

Were you able to get it finished? Probably not. Let's quickly talk about a few techniques that were useful.

### Refactor

What does "North" have to do with the concept of a Robot? Nothing.

Return to your code with your pair and, for the next 15 minutes, attempt to:

* Create a `Plane` class which a robot instance is connected to
* Extract all the "knowledge" about cardinal directions to the plane
* Think about what it'd be like to implement a plane with diagonal directions (N, NE, E, SE, S, SW, W, NW). The tests would have to be rewritten, but would your `Robot` be able to handle `Plane` changing?

### Recap

* How did extracting `Plane` affect the complexity of `Robot`?
* What does that mean about the **churn** of Robot over time?
* Could your Robot now exist in 3D space?
* What about Ruby makes this pattern easy?

## Introducing Services

Now let's start to talk about services. In this section, our goals are to:

* Lay the foundation for services
* Understand how services fit with MVC
* Understand both the **proxy** and **smart client** approaches to services
* Understand the basic role and functionality of a pub/sub messaging channel

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

### Identifying a Service

A good candidate for extraction to a service...

* Has limited and known interactions with other parts of the domain logic
* Are a conceptual piece of value rather than a just a piece of functionality
* Could potentially be reused in a different application

Poor candidates for service extraction...

* Need access to large pieces of data from the primary application
* Are reading and writing primary application data

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

### How Pub/Sub Messaging Works

Let's hop over to another short tutorial to experiment with Redis:

http://tutorials.jumpstartlab.com/topics/asynchronous_messaging_with_pubsub.html

## Extracting Notifications

### Introduction

#### Goals

#### The Monsterporium

* Description of the project, what it has, what it does, etc

#### Where Email Notifications Come From

* Showing what process(es) in the app generate emails

#### High-Level Overview of Where We're Going

* Whiteboard-level description of how it'll work when we're done.

### Characterizing Functionality

* Writing a semi-auto test harness to check that emails are actually sent.

### Pushing Logic Down the Stack

* Get the mailer logic down to the model level
* Pull that code out to a class in LIB
* Call that Lib code from the model
* Validate that it still works

### Working with the Pub/Sub Channel

* Integrate Redis into the app
* When an email needs to be sent, send a message to Redis
* Leave the existing functionality in place
* Implement Mailcatcher to see the email
* Show that the message, since we weren't subscribed yet, is gone
* Start a simple listener in IRB or Rails Console that just prints out the message

### Implementing a Listener

( Not sure where Pony fits in )

#### Creating the File

#### Subscribing to the Channel

#### Dumping Messages to a Log File

#### Running with `rails runner`

* If necessary -- or is it just with `ruby`?

#### Sending the Email

#### Validating Functionality

### Removing Code from the Primary App

#### Encapsulating the Message Posting

* Create a class that does the actual message publishing to Redis

#### Deactivating and Removing the Delivery Code

#### Validating Functionality

## Service Brainstorming

* Pair for 30 minutes on identifying potential targets.
* In the full group, vote for the top two potential targets.
* Spend 1 hour on each, whiteboarding.

## Extracting Ratings

Ratings

- reading
- writing
- reading through JS

### Validating Functionality

#### Using Capybara 

#### Using VCR to Mock Tests

### Rendering JSON

#### Using Petroglyph

### Accessing the Service Through JavaScript

* Accessing data on a server
* Manipulating the DOM
* Masking Latency

## Development Practices

### Writing a Gem

### Deploying Services

### Alternative Messaging Systems/Styles

### Git Practices

### Code Climate

## Wrap-Up

### Next Steps

* Implementing Search with ElasticSearch
* Implementing Authentication
