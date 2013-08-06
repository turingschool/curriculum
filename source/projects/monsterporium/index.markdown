---
layout: page
title: Monsterporioum - Refactoring to Services
sidebar: true
---

In this series of projects you'll take an existing application and practice breaking logic and functionality into a cluster of smaller services.

## Course Plan

### Learning Goals

When you complete this course, you should be able to:

1. evaluate functionality to determine suitability for a service
2. implement message posting to a service along-side existing functionality
3. consume queued messages and act on them
4. validate functionality end-to-end
5. remove now-redundant functionality from the primary app
6. access data across services using appropriate abstraction
7. write data to a service using a REST API

In addition, we'll practice fundamental techniques like:

* Pushing logic down the stack
* Testing complex systems
* Refactoring under test

### Schedule

0. Extracting Responsibilities
1. Fundamentals of Services
2. Extracting Email to a Service
3. Identifying Real-World Services
4. Extracting Ratings to a Service
5. Wrapup and Q&A
6. Next Steps

## Extracting Responsibilities

The process of creating services is about extracting logic. Let's practice that process in [Extracting Responsibilities]({% page_url extracting_responsibilities %}).

## Introducing Services

Before we dive into writing services, let's discuss a bit of the theory in [Introducing Services]({% page_url introducing_services %}).

## Extracting Notifications

Now that you have a feel for Redis, PubSub, and the theory of extracting services -- let's actually do it. Jump over to the [Extract Notification Service]({% page_url extract_notification_service %}) tutorial.

## Practicing with Services

It's one thing to be led by the hand through the extraction of a service. In this segment, we turn the responsibility over to you. 

Jump over to the [Practicing with Services]({% page_url practicing_services %}) tutorial.

## Extracting Ratings

Let's work with a more complex service that needs to read and write data. Jump over to the [Extract Ratings Service]({% page_url extract_ratings_service %}) tutorial.

## Development Practices

Finally, let's talk about some specific techniques that help the process of writing services in [Development Practices]({% page_url development_practices %}).

## Wrap-Up

Finally, it's time for the big Q&A and working on some of your own code.

## Addendum

Once you're comfortable with what we've done here, a few challenges to further challenge your skills:

### Implementing Search

Search is an excellent service to extract because you're probably relying on an external search system already (like ElasticSearch, Solr, etc). Extracting search typically means building a few components:

* A component that's responsible for sending any new content into the indexer
* A component that actually runs queries against the index
* A component that wraps those results into domain objects for the primary app

### Implementing Authentication

Authentication across services is tricky.

* First, build a service whose whole job is to deal with user login (username, password, etc) and sets a session ID in the user's cookie
* Build a component which can, given a cookie, validate it against that service
* Once the user is logged in, forward them to the primary application with a signed parameter that creates a session in the primary app. This necessitates a shared secret between the primary and auth applications
* On future requests, just work from that record/cookie in the primary app
