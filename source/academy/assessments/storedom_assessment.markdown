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
* The facilitator may change the spec or ask additional questions to assess your understandings/skills
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
* Fork the starter repo on GitHub: [https://github.com/JumpstartLab/storedom](https://github.com/JumpstartLab/storedom)
* Clone your fork to your computer
* Add our upstream: `git remote add upstream git@github.com:JumpstartLab/storedom.git`
* Run `bundle` to install dependencies
* Run `rake db:seed` to generate the started data
* Setup any external tooling you want (your IDE, `guard`, etc)

## Feature Description

During your assessment, your facilitator will ask you to implement one or more of the features described below.

### 1. Deactivating Items

Our store is growing and some items are no longer available for purchase. Make the following changes to the application:

* Add a column to the database marking the item as active/inactive
* Use the Rails Console to mark all but 10 items inactive
* Modify the controller to only display active items on the items listing page

#### Extensions

* If the user adds `?show_inactive=true`, display both inactive and active items.
* Add a button to "activate" items on that page which utilizes a custom `activate` action for that individual item.

### 2. Order Status

All orders are not the same. Let's add a `status` to help keep things organized:

* Add a status to orders which can be any of the following: `submitted`, `paid`, `rejected`, `complete`
* Validate that only those statuses can be used
* Display the orders on `/orders` grouped by their status
* Add the ability to update the status of an order

### 3. Administration

Users shouldn't be able to see all the orders on the system. Let's start creating an Admin interface.

* Move the `show` and `index` actions from `OrdersController` and modify the routes so that they're reached by a URL like `/admin/orders` and `/admin/orders/1`
* Add a security check that, in order to access any action that controller, you must be an Admin
* Consider any request that has a parameter `?admin=true` to be an admin

#### Extensions

* Implement a legitimate login solution of any complexity

### 4. Refactoring Seeding

Currently the `seeds.rb` is one large file with multiple responsibilities.

* Split each of the generate methods out into it's own class
* Make those classes use a signature like `Seed::Item.generate(500)` to create records
* Add testing along the way
* Eliminate the `Seed` class

### 5. Creating an API

Storedom does not have an API.

Create an API that:

* serves JSON
* is versioned
* is tested
* has a public endpoint to get all the items
* has a public endpoint to get a specific item
* has a protected endpoint to create items (using `?admin=true` as a proxy for authentication)
* has a protected endpoint to get the data for a specific order (`?admin=true`)

#### Extensions:

Write a wrapper gem for Storedom's API that allows you to easily:

* Fetch all items
* Fetch all orders
* Fetch a single order
* Create an order

#### Extensions

* Once the features are complete, add VCR so the tests pass without Storedom actually running.

### 6. Adding Stats

Which are the most popular items?

* Add a column to the items to track how many times they've been ordered
* Reprocess all existing orders to populate that column
* When the user requests `/items?sorted_by=popularity`, display them in order of descending number of purchases
* When an order is created, make sure it automatically updates the item's order count

## Evaluation Criteria

Subjective evaluation will be made on your work/process according to the following criteria:

#### 1. Ruby Syntax & API

* 4: Developer is able to write Ruby demonstrating a broad/deep understanding of available language features
* 3: Developer is able to write Ruby structures with a minimum of API reference, debugging, or support
* 2: Developer is able to write Ruby structures, but needs some support with method names/concepts or debugging syntax
* 1: Developer is generally able to write Ruby, but spends significant time debugging syntax or looking up elementary methods/concepts
* 0: Developer struggles with basic Ruby syntax

#### 2. Ruby Style

* 4: Developer writes code that is exceptionally clear and well-factored
* 3: Developer solves problems with a balance between conciseness and clarity and often extracts logical components
* 2: Developer writes effective code, but does not breakout logical components
* 1: Developer writes code with unnecessary variables, operations, or steps which do not increase clarity
* 0: Developer writes code that is difficult to understand

#### 3. Rails Syntax & API

* 4: Developer is able to implement and improve the requested features
* 3: Developer is able to implement the requested features with some support
* 2: Developer needs guidance about what needs to be done to realize the features, but is able to perform the actual implementation
* 1: Developer demonstrates shallow knowlege about what Rails provides or how requests work
* 0: Developer struggles to utilize/build basic Rails features

#### 4. Rails Style

* 4: Developer is able to craft Rails features that make smart use of Ruby, follow the principles of MVC, and push business logic down where it belongs
* 3: Developer generally writes clean Rails features that make smart use of Ruby, with some struggles in pushing logic down the stack
* 2: Developer struggles with some concepts of MVC
* 1: Developer struggles with MVC and pushing logic down the stack
* 0: Developer shows little or no understanding of how to craft Rails applications

#### 4. Testing

* 4: Developer excels at taking small steps and using the tests for *both* design and verification
* 3: Developer writes tests that are effective validation of functionality, but don't drive the design
* 2: Developer uses tests to guide development, but implements more functionality than the tests cover
* 1: Developer is able to write tests, but they're written after or in the middle of implementation
* 0: Developer does not use tests to guide development

#### 5. Problem Solving

* 4: Developer is able to create and implement strategies, and actively reassess/revise them
* 3: Developer is able to both create and implement problem solving strategies
* 2: Developer needs help with some details, but is able to build a strategy
* 1: Developer understands the big-picture, but struggles to put together a strategy
* 0: Developer struggles to come up with a cohesive problem-solving approach

#### 6. Collaboration

* 4: Developer *actively seeks* collaboration both before implementing, while in motion, and when stuck
* 3: Developer lays out their thinking *before* attacking a problem and integrates feedback through the process
* 2: Developer asks detailed questions when progress slows or stops
* 1: Developer is able to integrate unsolicited feedback but does not really collaborate
* 0: Developer needs more than two reminders to "think out loud" or struggles to articulate their process 
