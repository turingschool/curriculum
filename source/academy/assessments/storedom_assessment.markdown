---
layout: page
title: Storedom Assessment
---

In this assessment you will:

* Use test-driven development
* Demonstrate mastery of all parts of the Rails stack
* Demonstrate mastery of Ruby throughout the process

## Expectations

* Work on the exercise described below for 45 minutes with your facilitator
* The facilitator will assign you a challenge similar but not identical to those
in the test suite. The facilitator may change the expectations or ask additional
questions to assess your understandings/skills
* As you work, you *should*:
  * Think out loud so your facilitator can understand your process
  * Ask questions of your facilitator
  * Reference external public resources (ie: Google, Ruby API, etc)
  * Use the tooling most comfortable to you (Editor/IDE, testing framework, support tools like Guard, etc)
* As you work, you *should not*:
  * Copy code snippets other than those present in this description
  * Seek live support from individuals other than your facilitator
* After you complete the exercise, please use discretion with your classmates to allow them an authentic evaluation experience

## Preparation

Before the session starts:

* Have the [display driver installed](http://www.displaylink.com/support/mac_downloads.php)
* Clone the repo on GitHub: [https://github.com/turingschool-examples/storedom](https://github.com/turingschool-examples/storedom)
* Run `bundle` to install dependencies
* Run `rake db:create db:migrate db:seed`
* Setup any external tooling you want (your IDE, `guard`, etc)

## Third Module Assessment Expectations

Your facilitator will assign a feature similar to these:

### 1. Deactivating Items

Our store is growing and some items are no longer available for purchase. Make the following changes to the application:

* Add a column to the database marking the item as active/inactive
* Use the Rails Console to mark all but 10 items inactive
* Modify the controller to only display active items on the items listing page
* If the user adds `?show_inactive=true`, display both inactive and active items.
* Add a button to "activate" items on that page which utilizes a custom `activate` action for that individual item.

### 2. Order Status

All orders are not the same. Let's add a `status` to help keep things organized:

* Add a status to orders which can be any of the following: `submitted`, `paid`, `rejected`, `complete`
* Validate that only those statuses can be used
* Display the orders on `/orders` grouped by their status
* Add the ability to update the status of an order

## Fourth Module Assessment Expectations

Your facilitator will assign you the task of building a tested feature like the
following:

* Create a versioned JSON API allowing you to read data from and write data
to the application
* Implement OAuth login and use the returned data to create a persisted local user
* Build a "Customers who bought X also purchased..." feature and the ability to
sort items in the store by various criteria
* Improve the performance of the application using key-based caching, database
indicies, and simplifying database queries

## Evaluation Criteria

Subjective evaluation will be made on your work/process according to the following criteria:

### 1. Satisfactory Progress

* 4: Developer is able to skillfully move through their work at the pace of an
experienced developer.
* 3: Developer is able to smoothly move through work and make progress at the
rate of a junior developer
* 2: Developer hits slowdowns, but moves with the speed of an apprentice developer.
* 1: Developer struggles to make progress.

### 2. Ruby Syntax & Style

* 4: Developer is able to write Ruby demonstrating a broad/deep understanding of available language features. Code that is exceptionally clear and well-factored.
* 3: Developer is able to write Ruby structures with a minimum of API reference, debugging, or support while balancing conciseness & clarity
* 2: Developer is able to write Ruby structures, but needs some support with method names/concepts or debugging syntax
* 1: Developer is generally able to write Ruby, but spends significant time debugging syntax or looking up elementary methods/concepts
* 0: Developer struggles with basic Ruby syntax

### 3. Rails Syntax & API

* 4: Developer is able to implement and improve the requested features
* 3: Developer is able to implement the requested features with some support
* 2: Developer needs guidance about what needs to be done to realize the features, but is able to perform the actual implementation
* 1: Developer demonstrates shallow knowlege about what Rails provides or how requests work
* 0: Developer struggles to utilize/build basic Rails features

### 4. Rails Style

* 4: Developer is able to craft Rails features that make smart use of Ruby, follow the principles of MVC, and push business logic down where it belongs
* 3: Developer generally writes clean Rails features that make smart use of Ruby, with some struggles in pushing logic down the stack
* 2: Developer struggles with some concepts of MVC
* 1: Developer struggles with MVC and pushing logic down the stack
* 0: Developer shows little or no understanding of how to craft Rails applications

### 5. Testing

* 4: Developer excels at taking small steps and using the tests for *both* design and verification
* 3: Developer writes tests that are effective validation of functionality, but don't drive the design
* 2: Developer uses tests to guide development, but implements more functionality than the tests cover
* 1: Developer is able to write tests, but they're written after or in the middle of implementation
* 0: Developer does not use tests to guide development

### 6. Problem Solving

* 4: Developer is able to create and implement strategies, and actively reassess/revise them
* 3: Developer is able to both create and implement problem solving strategies
* 2: Developer needs help with some details, but is able to build a strategy
* 1: Developer understands the big-picture, but struggles to put together a strategy
* 0: Developer struggles to come up with a cohesive problem-solving approach

### 7. Collaboration

* 4: Developer *actively seeks* collaboration both before implementing, while in motion, and when stuck
* 3: Developer lays out their thinking *before* attacking a problem and integrates feedback through the process
* 2: Developer asks detailed questions when progress slows or stops
* 1: Developer is able to integrate unsolicited feedback but does not really collaborate
* 0: Developer needs more than two reminders to "think out loud" or struggles to articulate their process
