---
layout: page
title: Monsterporioum - Refactoring to Services
sidebar: true
---

In this project you'll take an existing application and practice breaking logic and functionality into a cluster of smaller services.

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

In addition, we're practicing fundamental techniques like:

* Pushing logic down the stack
* Testing complex systems
* Managing deployment of multiple applications

### Schedule

0. Extracting Responsibilities
1. Fundamentals of Services
2. Extracting Email to a Service
3. Identifying Real-World Services
4. Extracting Ratings to a Service
5. Wrapup and Q&A
6. Next Steps

## Extracting Responsibilities

Essentially the process of creating services is about extracting logic. Let's practice that process in [Extracting Responsibilities]({% page_url extracting_responsibilities %}).

## Introducing Services

Before we dive into writing services, let's discuss a bit of the theory in [Introducing Services]({% page_url introducing_services %}).

## Extracting Notifications

Now that you have a feel for Redis, PubSub, and the theory around extracting services -- let's actually do it. Jump over to the [Extract Notification Service]({% page_url extract_notification_service %}) tutorial.

## Service Brainstorming

* Pair for 30 minutes on identifying potential targets
* In the full group, vote for the top two potential targets
* Spend 1 hour whiteboarding on each

## Extracting Ratings

Let's work with a more complex service that needs to read and write data. Jump over to the [Extract Ratings Service]({% page_url extract_ratings_service %}) tutorial.

## Development Practices

Finally, let's talk about some specific techniques that help the process of writing services in [Development Practices]({% page_url development_practices %}).

## Wrap-Up

### Next Steps

* Implementing Search with ElasticSearch
* Implementing Authentication
