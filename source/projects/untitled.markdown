---
layout: page
title: Untitled
sidebar: true
---

In this project you'll use Ruby on Rails to build an online commerce platform to facilitate online ordering.

## Introduction

### Learning Goals

* Use TDD to drive all layers of Rails development including unit, integration, and user acceptance tests
* Design a system of models which use one-to-one, one-to-many, and many-to-many relationships
* Practice mixing HTML, CSS, and Rails templates to create an inviting and usable User Interface
* Differentiate responsibilities between components of the Rails stack
* Build a logical user-flow that moves across multiple controllers and models

### Restrictions

Project implementation may **not** use:

* Any external library for authentication except `bcrypt`
* A pre-existing, externally created CSS/HTML design/template (however, you may use [Bootstrap](http://getbootstrap.com/), [Zurb Foundation](http://foundation.zurb.com/), etc.)

### Getting Started

1. One team member creates a repository with the name of your online ordering platform
2. Add the other team members as collaborators
3. Add your project to Waffle.io 
4. Configure [Hound](https://houndci.com/) for style guide violations
5. Use [waffle.io](http://waffle.io) to write and track user stories

## Base Expectations

You will build an online ordering platform. Customers should be able to place orders and view placed order details. The site owner should be able to manage products and categories in addition to processing and completing orders. 

## Process

(insert here)

## Extensions

The extensions listed below are a non-exhaustive list of extension ideas. 

### What's Good Here?

On any item I can, as an Unauthenticated User:

* See the posted reviews including:
  * title, body, and a star rating 0-5
  * the display name of the reviewer
* See an average of the ratings broken down to half-stars

On items I've purchased, as an Authenticated User I can:

* Add a rating including:
  * Star rating 0-5
  * Title
  * Body text
* Edit a review I've previously submitted until 15 minutes after I first submitted it

### The Machine Knows What You Like

Implement simple recommendations including:

* The ability to easily see your last order and add the same items to the current order
* After an item is added to and order, recommend three items other customers have ordered with this item. If there aren't three other things that've been ordered, fill in with the most popular overall items
* Combinations of several items (ex: an appetizer, main dish, and dessert) with a small discount over ordering them individually

### Where Is It?

Implement full-text search for both the consumer and administrator:

#### Consumer

* Search for items in the whole site
* Search through "My Orders" for matches in the item name or description

#### Administrator

Search orders using a builder-style interface (like Google's "Advanced Search") allowing them to specify any of these:

* Status (drop-down)
* Order total (drop-down for `>`, `<`, `=` and a text field for dollar-with-cents)
* Order date  (drop-down for `>`, `<`, `=` and a text field for a date)
* Email address of purchaser

### Transaction Processor

Implement a "checkout" procedure using Stripe, Paypal or another service to handle credit card transactions in a "sandboxed" developer environment.

When the card is processed, update the order to "paid" and send a confirmation email to the user. Emails should _only_ be sent when the app is in `production` mode. Don't spam people while you're getting it working.

### Phone Confirmation

As a restaurant I have a registered contact phone number. When an order is placed online the system calls me with an interaction like this:

* "Hi, this is **StoreName*** calling with an online order. Press 1 to accept, 3 to reject". They press "1"
* "The customer name is John Schmoe."
* "The customer will pickup the order at 5:45PM"
* "The order includes: shrimp wontons, chicken pad thai large, and green tea ice cream small. There are a total of 3 items."
* "Press 1 to confirm the order, 2 to repeat, or 3 to cancel."
* The result of the call updates the order in the database and sends an email to the customer.

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
* 2: Project needs significantly more attention to the User Experience, but works
* 1: Project is difficult or unpleasant to use

### 7. Workflow

* 4: Excellent use of branches, pull requests, and a project management tool.
* 3: Good use of branches, pull requests, and a project-management tool. 
* 2: Sporadic use of branches, pull requests, and/or project-management tool. 
* 1: Little use of branches, pull requests, and/or a project-management tool.