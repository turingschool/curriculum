---
layout: page
title: Service-Oriented Architecture
sidebar: true
---

The goal of this project is to build a cluster of applications that speak to each other, but provide a unified interface to the user.

## Evaluation Criteria

The evaluation of the project is broken into three areas of focus:

1. Technical Evaluation
2. Client Satisfaction
3. Learning & Progress

### Technical Evaluation

As we look through your project we're assessing these five areas of focus:

* A) Services - breaking functionality into small services
* B) Encapsulation - hiding the service dependencies
* C) Rails MVC - well architected MVC that pushes logic down the stack
* D) Test Driven Development - testing at multiple levels

In each area we'll render an evaluation of:

* 4 - Exceeded expectations, went above and beyond what you were *supposed* to do
* 3 - Met expectations
* 2 - Below expectations, made an attempt but really didn't hit the goal
* 1 - Far below expectations, no effort or no effective effort

#### A. Services

* 4 - Project uses multiple services, each isolated from one another, along with wrapper gems to communicate
* 3 - Project uses multiple services to distribute workload
* 2 - Project uses one service for some piece of the functionality
* 1 - Project does utilize any internal services

#### B. Encapsulation

* 4 - Service connections are abstracted into gems that could be reused
* 3 - Service connections are condensed into single classes that abstract the details
* 2 - Some attempt is made to abstract the services from each other, but it is leaky
* 1 - Each service has highly detailed knowledge of the others, meaning the code is highly coupled

#### C. Rails MVC

* 4 - Application consistently encapsulates business logic at the model level with only HTTP and routing concerns in the controller
* 3 - Application makes efforts to push logic down from controllers into the models and processor objects
* 2 - Application has too much responsibility/code in the controllers
* 1 - Application has pervasive logic in the views and too much responsibility/code in the controllers

#### D. Test-Driven Development

* 4 - The code demonstrates high test coverage (>80%), tests at the feature and unit levels, and allows services to be tested in isolation
* 3 - The code demonstrates high test coverage (>80%), tests at feature and unit levels, but needs all services to be running concurrently
* 2 - The code demonstrates high test coverage (>80%), but does not adequately balance feature and unit tests
* 1 - The code does not have 80% test coverage

### Client Satisfaction

First and foremost, the application needs to do what it is supposed to do.

#### A. Deployment

Is it properly deployed and ready for customers?

* 4 - VPS deployment with NGINX/Apache, PostgreSQL, and proper startup after machine reboot
* 3 - VPS deployment with NGINX/Apache and PostgreSQL
* 2 - VPS deployment with no NGINX/Apache
* 1 - Not deployed

#### B. Features

Does it have the expected features?

* 4 - There are more features than we planned
* 3 - All planned features were delivered
* 2 - Some features were sacrificed to meet the deadline
* 1 - Major features are missing

#### C. Interface

Does it have a highly usable interface?

* 4 - The application is pleasant, logical, and easy to use
* 3 - The application has many strong pages/interactions, but a few holes in lesser-used functionality
* 2 - The application shows effort in the interface, but the result is not effective
* 1 - The application is confusing or difficult to use

#### D. Concept

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