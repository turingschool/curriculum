---
layout: page
title: FeedEngine
---

The goal of this project is to practice consuming web service APIs as well as publishing an API of your own. You will create a data aggregator service that pulls data and activity from other applications and publishes it through both a web interface and an API.

## Project Structure

### Learning Goals

* Learn to consume data from various third-party APIs
* Make aggregated data available through an API
* Build and use a Ruby Gem wrapping your own API
* Coordinate with project stakeholders to produce quality code and product.
* Continue to emphasize performance, UI, and overall user experience.
* Continue using TDD to drive all layers of Rails development.

### Teams and Process

Teams consist of four to five developers.

### Getting Started

This is a greenfield project. Choose one team member to create a repository, set up your teammates as collaborators, and get started. 

In addition, setup a Pivotal Tracker instance for the project. Invite all of the following to your Tracker project: jeff@jumpstartlab.com, susannah@jumpstartlab.com, jorge@jumpstartlab.com, katrina@jumpstartlab.com

### Team Workflow

You should review and follow the [project workflow patterns for Tracker & Github]({% page_url projects/workflow %}).

### Planning & Requirements

The authoritative project requirements will be created and maintained in collaboration with your client through Pivotal Tracker. This means that the requirements for your team will differ significantly from others groups.

## Application Concepts

You're expected to complete the following functional and non-functional requirements, which describe an application and accompanying gem that function as a user activity feed, API consumer, and API producer.

You will also need to build an excellent user experience. Your stakeholders will emphasize usability when reviewing and accepting stories during the show and tell sessions. If a feature is not highly useable, then it's not customer-ready and can't be accepted.

Each group will work on one of the [custom project concepts]({% page_url feed_engine_concepts.html %}) selected at the beginning of the project.

## Technical Requirements

### Caching and Data Querying

Take advantage of caching and performance techniques including:

* data caching
* fragment caching / Russian-Doll Caching
* query consolidation
* database optimizations (query count, using indicies, joins)

### Background Workers

Make extensive use of background workers including:

* Sending or receiving email
* Querying third-party APIs
* Processing bulk data

### Providing an API & Gem

The full functionality of your application should be available through an API. That API should come with a wrapper gem that makes it easy to work with.

The background workers **may not** connect to your application database directly or load the Rails environment for your app. They must go through your API gem to read from and write to feeds.

### Provisioning & Using a VPS

For this project you need to deploy on a VPS instance which you have built from the ground up. That'll include installing Ruby, Rails, Apache/NGINX, PostgreSQL, Redis, etc along with reasonable security.

## Evaluation Criteria

The evaluation of the project is broken into three areas of focus:

1. Client Satisfaction
2. Code Critique
3. Learning & Progress

### Client Satisfaction

First and foremost, the application needs to do what it is supposed to do.

1. Does the application deliver on the concept? 
2. Is it ready for customers to start signing up?
3. Does it portray a professional, premium brand?
4. Is it reliable? Does it recover from user and system errors?

### Code Critique by Instructors

Beyond delivering features, they have to be built correctly.

1. Does the code demonstrate mastery of the MVC model, pushing logic down to the model layer, keeping views simple, and controllers slim?
2. Are background workers employed well? Can they support a quickly growing user base?
3. Does the test suite support the application's architecture? Is it robust enough to ensure functionality, but flexible enough to allow change?
4. Does the application implement a comprehensive API? Does the wrapper gem provide easy access to that API?
5. Does the application use effective techniques to improve performance (database-level, caching, etc)?

### Learning & Progress

Working software is great, but this is still about learning.

1. Did the team make effective use of Pivotal Tracker to guide development?
2. Did the team find and use strategies for working together efficiently?
3. Did each member of the team seek challenge and push themselves?
4. Did each team member demonstrate growth and progress during the project?
