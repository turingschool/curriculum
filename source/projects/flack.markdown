---
layout: page
title: Flack
sidebar: true
---

# Flack - Service-Oriented-Chat

In this project we'll be building a chat application that users can
interact with through the browser.

At minimum, the application is expected to:

* Have a clear and pleasant interface
* Allow users to sign up and authenticate
* Deliver messages in real-time between multiple clients
* Support multiple rooms or conversations
* Persist messages on the server so they can be viewed later

## Application Themes

In addition to the basic chat features, each application is expected to
provide additional value through integration with a thematic service.
Your team will be expected to collaborate with the clients (a.k.a
instuctors) to identify a useful theme and design ways to integrate it
with your chat application.

Some ideas might include:

1. A github-themed chat which allows users to receive updates from and
  interact with repositories
2. A presentation/slideshow chat which allows presenters to host rooms
  for giving presentations and receiving audience feedback
3. A customer-support chat system that allows users to be matched with
  available support reps on an ad-hoc basis
4. A music-player chat where users can queue and listen to songs via an
  online music service (or the same concept for video)
5. A project-management chat system that helps teams manage projects by
  integrating with a project management system like Waffle or Trello
6. An ed-tech chat that helps teachers manage classrooms by recording
  information such as attendence or grades

Your team is welcome to use any of these ideas or come up with your own
in conjunction with your client. Whatever concept you choose, the focus
will be on working with your client to plan an iterative development
cycle that satisfies basic chat features first and then layers in
integrated functionality as the project progresses.

## Evaluation Criteria

The evaluation of the project is broken into three areas of focus:

1. Technical Evaluation
2. Client Satisfaction
3. Learning & Progress

### Technical Objectives

As we look through your project we're assessing these five areas of focus:

* A) Services - breaking functionality into small services
* B) Encapsulation - hiding the service dependencies
* C) Rails MVC - well architected MVC that pushes logic down the stack
* D) Test Driven Development - testing at multiple levels

#### A. Services

* 4 - Project uses multiple services, each isolated from one another, along with wrapper libraries to communicate
* 3 - Project uses multiple services to distribute workload
* 2 - Project uses one service for some piece of the functionality
* 1 - Project does utilize any internal services

#### B. Encapsulation

* 4 - Service connections are abstracted into reuseable libraries
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

### Project Management and Process

"Software projects don't fail for technical reasons." An important
aspect of this project will be managing your team's development process
and delivering functional software at every iteration.

### A. Project Management process

* 4 - The team demonstrates disciplined use of project management tools that is reflected in the application's source code
* 3 - The team uses project management tools for conceptual
planning, but development is still somewhat ad-hoc and disorganized
* 2 - The team makes inconsistent use of management tools
* 1 - Management and development are both ad-hoc and disorganized

### B. Project Management process

* 4 - The team executes disciplined project sprints, delivering
functional projects at each step
* 3 - The team plans project sprints effectively, but one or two sprints
end with a non-functional product
* 2 - The team plans project sprints, but sprints often end with
incomplete features
* 1 - The team performs one sprint -- to the finish.
