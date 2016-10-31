---
layout: page
title: Little Shop of Orders
sidebar: true
---

# Little Shop of Orders

In this project you'll use Ruby on Rails to build an online commerce platform to facilitate online ordering.

## Introduction

### Learning Goals

* Use TDD to drive all layers of Rails development including unit and integration tests
* Design a system of models which use one-to-one, one-to-many, and many-to-many relationships
* Practice mixing HTML, CSS, and templates to create an inviting and usable User Interface
* Differentiate responsibilities between components of the Rails stack
* Build a logical user-flow that moves across multiple controllers and models
* Practice an agile workflow and improve communication skills working within a team

### Restrictions

Project implementation may **not** use:

* Any external library for authentication except `bcrypt`

### Getting Started

1. One team member creates a repository with the name of your online ordering platform
2. Add the other team members and your instructor(s) as collaborators
3. Add your project to Waffle.io
4. Configure [Hound](https://houndci.com/) for style guide violations
5. Use [waffle.io](http://waffle.io) to write and track user stories
6. By the end of the first evening of the project, your group needs to send the following to your anchor:
  * Github repository
  * Link to app on heroku
  * Link to Waffle
  * App Name
  * App Description
  * Link to completed [DTR](https://gist.github.com/case-eee/91be629f380606c1498a9c3c0e5fc7ed)
  * List of possible extentions

## Base Expectations

You will build an online ordering platform. Customers should be able to place orders and view placed order details. The site owner should be able to manage products and categories in addition to processing and completing orders.

## Process

Each team will have an assigned project manager that will be the primary point of contact between the product owner (instructor) and the rest of the team.

Most initial stories will be provided by the product owner. You will be asked to write your own stories over the course of the project and they should follow the same format as the ones that are provided to you.

You should not write code or migrations until a story calls for it.

Teams will meet with the product owner regularly and demo completed stories. The product owner will request additional features at each meeting and those stories should be completed prior to your next meeting. Project scope and requirements can change at the discretion of the product owner so following an agile approach is really important.

It is expected that teams will have meaningful discussions and code reviews using comments on Github. Your instructors will be looking for this. Commits should also have meaningful messages. If you have commits that say things like "Fixing hound complaints.", you will likely be asked to [squash](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html) those commits. Rebasing should be done _before_ the branch is merged into master or you will run into problems.

The master branch of your project should always remain in a state where it can be demoed and deployed... yes, even days that you don't have any _planned_ meetings.

Everyone will provide feedback for group members at the end of the project.

## Extensions

The extensions listed below are a non-exhaustive list of extension ideas.

* product reviews
* product recommendations based on past orders
* product and category search
* credit card processing with Stripe or Paypal
* phone or text message order confirmation

## Evaluation Process

For the evaluation we'll work through the expectations above and look at the
following criteria:

### 1. Feature Completeness

* 4: All features are correctly implemented along with two extensions
* 3: All features defined in the assignment are correctly implemented
* 2: There are one or two features missing or incorrectly implemented
* 1: There are bugs/crashes in the features present

### 2. Views

* 4: Views show logical refactoring into layout(s), partials and helpers, with no logic present
* 3: Views make use of layout(s), partials and helpers, but some logic leaks through
* 2: Views don't make use of partials or show weak understanding of `render`
* 1: Views are poorly organized

### 3. Controllers

* 4: Controllers show significant effort to push logic down the stack
* 3: Controllers are generally well organized with three or fewer particularly ugly parts
* 2: There are four to seven ugly controller methods that should have been refactored
* 1: There are more than seven unsatisfactory controller methods

### 4. Models

* 4: Models show excellent organization, refactoring, and appropriate use of Rails features
* 3: Models show an effort to push logic down the stack, but need more internal refactoring
* 2: Models are somewhat messy and/or make poor use of Rails features
* 1: Models show weak use of Ruby and weak structure

### 5. Testing

* 4: Project has a running test suite that exercises the application at multiple levels
* 3: Project has a running test suite that tests and multiple levels but fails to cover some features
* 2: Project has sporadic use of tests and multiple levels
* 1: Project did not really attempt to use TDD

### 6. Usability

* 4: Project is highly usable and ready to deploy to customers
* 3: Project is highly usable, but needs more polish before it'd be customer-ready
* 2: Project needs more attention to the User Experience, but works
* 1: Project is difficult or unpleasant to use, or needs significantly more attention to user experience

### 7. Workflow

* 4: Excellent use of branches, pull requests, and a project management tool.
* 3: Good use of branches, pull requests, and a project-management tool.
* 2: Sporadic use of branches, pull requests, and/or project-management tool.
* 1: Little use of branches, pull requests, and/or a project-management tool.
