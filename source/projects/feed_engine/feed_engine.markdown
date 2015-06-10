---
layout: page
title: FeedEngine
sidebar: true
---

The goal of this project is to practice consuming web service APIs as well as publishing an API of your own. You will create a data aggregator service that pulls data and activity from other applications and publishes it through both a web interface and an API.

## Project Structure

### Learning Goals

* Learn to consume data from various third-party APIs
* Make aggregated data available through an API
* Building a client-side application in Ember that consumes your API
* Build and use a Ruby Gem wrapping your own API
* Continue to emphasize performance, UI, and overall user experience
* Continue using TDD to drive all layers of development
* Coordinate with project stakeholders to produce quality code and product

You will build this project in three phases:

1. Client-side Ember application using fixtures and mocks
2. Server-side Rails application, which provide an API for your client-side application
3. Connecting the client-side and server-side applications

### Getting Started

This is a greenfield project. Choose one team member to create a repository, set up your teammates as collaborators, and get started. Use a project management tool of your choice.

You should make two repositories: one for your Ember application and one for your Rails applications.

### Planning & Requirements

The authoritative project requirements will be created and maintained in collaboration with your client through meetings and your project management tool. This means that the requirements for your team will differ significantly from other groups.

You must use Hound and Skylight in your projects.

## Application Concepts

Each group will work on one of the [custom project concepts][concepts] selected at the beginning of the project.

[concepts]: http://tutorials.jumpstartlab.com/projects/feed_engine/feed_engine_concepts.html

## Technical Requirements

### Caching and Data Querying

Take advantage of caching and performance techniques including:

* data caching
* query consolidation
* database optimizations (query count, using indicies, joins)

### Background Workers

Make *extensive* use of background workers including:

* Sending or receiving email
* Querying and fetching data from third-party APIs
* Processing bulk data

### Providing an API & Gem

The main functionality of your application should be available through an API. That API should come with a wrapper gem that makes it easy to work with.

The background workers **may not** connect to your application database directly or load the Rails environment for your app. They must go through your API gem to read from and write to feeds.

### Provisioning & Using a VPS

(This step is optional. You can use a VPS or push to Heroku.)

For this project you need to deploy on a VPS instance which you have built from the ground up. That'll include installing Ruby, Rails, Apache/NGINX, PostgreSQL, Redis, etc along with reasonable security.

## Evaluation Criteria

The evaluation of the project is broken into three areas of focus:

1. Technical Evaluation
2. Client Satisfaction
3. Learning & Progress

### Technical Evaluation

As we look through your project we're assessing these areas of focus:

* APIs - consuming and providing
* Interface - light view templates, logical and clean UX
* Background Workers - doing work asyncronously through the API
* Test Driven Development - testing at multiple levels
* Process - test driven development, using Pivotal Tracker

In each area we'll render an evaluation of:

* 4 - Exceeded expectations, went above and beyond what you were *supposed* to do
* 3 - Met expectations
* 2 - Below expectations, made an attempt but really didn't hit the goal
* 1 - Far below expectations, no effort or no effective effort

#### Server-Side Application and APIs

* 4 - Project wraps/isolates external APIs, tests API interaction without actual connectivity dependencies, provides a tested API, and provides a tested wrapper gem
* 3 - Project wraps/isolates external APIs, provides an API, and provides an effective wrapper gem, but does not test them effectively
* 2 - Project has an internal API and gem, but external APIs are scattered across the application *OR* external APIs are consolidated but the internal API isn't built/tested/wrapped
* 1 - Project does not offer its own API and wrapper gem

#### Client-Side Application

* 4 - Your application has exceptionally well-factored code with little or now duplication and all components separated out into logical components.
* 3 - Your application is thoughtfully put together with some duplication and no major bugs.
* 2 - Your application has a significant amount of duplication and one or major bugs.
* 1 - Your client-side application does not function.

#### Background Workers

* 4 - All API/data interaction goes through background workers
* 3 - Workers are used to fetch external data and post it to the application, but some call are made in the request cycle
* 2 - Workers are implemented for only a few pieces of responsibility (ex: email)
* 1 - Workers do not exist / are not handling any work

#### Test-Driven Development

* 4 - The code demonstrates high test coverage (>80%), tests at the feature and unit levels, and does not rely on external services.
* 3 - The code demonstrates high test coverage (>80%), tests at feature and unit levels, but relies on external services
* 2 - The code demonstrates high test coverage (>80%), but does not adequately balance feature and unit tests
* 1 - The code does not have 80% test coverage

#### Technical Processes

* 4 - The team effectively used tracker and delivered *multiple* iterations into production
* 3 - The team effectively used tracker but only delivered one real iteration into production
* 2 - The team made effective use of tracker but did not get the application into production
* 1 - The team did not make effective use of tracker

#### Workflow

* 4 - Your team conducts code review, comments pull requests, on and addresses all line comments in pull requests
* 3 - Your team generally conducts pull requests, but some PRs are merged in without discussion or review. There are some unaddressed line comments in pull requests.
* 2 - Your team generally conducts pull requests, but some PRs are merged in without discussion or review. There are some unaddressed line comments in pull requests.
* 1 - Your team frequently pushes to master or to merges pull requests with no discussion.

### Client Satisfaction

First and foremost, the application needs to do what it is supposed to do.

#### Code Quality

Is it properly deployed and ready for customers?

* 4 - VPS deployment with NGINX/Apache, PostgreSQL, and proper startup after machine reboot
* 3 - VPS deployment with NGINX/Apache and PostgreSQL
* 2 - VPS deployment with no NGINX/Apache
* 1 - Not deployed

#### Features

Does it have the expected features?

* 4 - There are more features than we planned
* 3 - All planned features were delivered
* 2 - Some features were sacrificed to meet the deadline
* 1 - Major features are missing and/or the application is not deployed to production

#### Interface

Does it have a highly usable interface?

* 4 - The application is pleasant, logical, and easy to use
* 3 - The application has many strong pages/interactions, but a few holes in lesser-used functionality
* 2 - The application shows effort in the interface, but the result is not effective
* 1 - The application is confusing or difficult to use

#### Concept

Does the application deliver on the concept?

* 4 - Exceeded expectations, this application is great
* 3 - Met expectations, the application is a solid first version
* 2 - Below expectations, this is at-best a prototype
* 1 - Far below expectations, this doesn't demonstrate the value of the concept

### Learning & Progress

Working software is great, but this is still about learning. Let's discuss the progress and outcomes as a client + group.

1. Did the team make effective use of Pivotal Tracker to guide development?
2. Did the team find and use strategies for working together efficiently?
3. Did each member of the team seek challenge and push themselves?
4. Did each team member demonstrate growth and progress during the project?