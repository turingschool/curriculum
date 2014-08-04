---
layout: page
title: SinatraCMS
---

## Key Skills

In this assessment we're looking to see how you:

* Apply TDD at multiple levels to develop Sinatra applications
* Work with data in a SQL database
* Understand the components of Sinatra and how they fit together
* Use view templates to present data

## Expectations

* Work on the exercise defined below for 37 minutes with your facilitator
* The facilitator may change the spec or ask additional questions to assess your understandings/skills
* As you work, you may:
  * Ask questions of your facilitator
  * Reference external public resources (ie: Google, Ruby API, etc)
  * Use the tooling most comfortable to you (Editor/IDE, testing framework, support tools like Guard, etc)
* As you work, you should not:
  * Copy code snippets other than those present in this description
  * Seek live support from individuals other than your facilitator

## Getting Started

Before your session begins, clone the repo from GitHub and install dependencies:

``` shell
$ git clone https://github.com/turingschool/sinatra_cms
$ cd sinatra_cms
$ bundle
```

## Fundamental Exercises

Use TDD to continue building features on to the existing CMS.

### Existing Features

When you clone the app a user is able to:

* create a new page
* display a single page

You'll find feature and unit tests for this functionality. As you add new features,
your functionality should follow the same testing patterns.

### Challenge 1: List Pages

Open `test/features/page_index_test.rb` and you'll find the
pseudocode for a feature test.

1. Implement the rest of the test using Capybara
2. Write unit tests as you move down the stack to help guide your progress
3. Implement the features
4. Use a view template to render the results

### Challenge 2: Delete a Page

Open `test/features/page_delete_test.rb` and you'll find the
pseudocode for a feature test.

1. Implement the rest of the test using Capybara
2. Write unit tests as you move down the stack to help guide your progress
3. Implement the feature
4. Update the view templates to make use of the feature

### Challenge 3: Edit a Page

Open `test/features/page_edit_test.rb` and you'll find the
pseudocode for a feature test.

1. Implement the rest of the test using Capybara
2. Write unit tests as you move down the stack to help guide your progress
3. Implement the features
4. Write a view template for the form
5. Extract out a partial that's used by both the new and edit forms

## Evaluation

Subjective evaluation will be made on your work/process according to the following criteria:

### 1. Satisfactory Progress

* 4: Developer is able to skillfully move through their work at the pace of an
experienced developer.
* 3: Developer is able to smoothly move through work and make progress at the
rate of a junior developer
* 2: Developer hits slowdowns, but moves with the speed of an apprentice developer.
* 1: Developer struggles to make progress.

### 2. Ruby Syntax, API, and Enumerations

* 4: Developer is able to comfortably use multiple Ruby techniques to solve a problem
* 3: Developer is able to write Ruby with a minimum of reference or debugging
* 2: Developer is able to write Ruby with some debugging of fundamental concepts
* 1: Developer is generally able to write Ruby, but gets stuck on or needs help
with fundamental concepts

#### 3. Problem Solving Process

* 4: Developer iterates to solutions that balance conciseness with clarity
* 3: Developer solves problems, but doesn't refine their solutions
* 2: Developer struggles to solve problems without direct guidance
* 1: Developer is unable to solve problems without direct guidance

#### 4. Testing

* 4: Developer is able to test at multiple layers of abstraction to drive
development
* 3: Developer writes strong feature or unit tests, but does not balance them
* 2: Developer can write both feature and unit tests with some guidance
* 1: Developer struggles to write meaningful tests at any level

#### 5. Workflow

* 4: Developer is a master of their tools, efficiently moving between phases of development
* 3: Developer demonstrates comfort with their tools, makes some use of keyboard
shortcuts, and excellent use of their screen.
* 2: Developer smoothly moves between tools, but is dependent on mouse-driven
interaction or fails to utilize their whole screen.
* 1: Developer gets work done, but wastes significant time due to workflow issues

#### 6. Collaboration

* 4: Developer *actively seeks* collaboration both before implementing, while in motion, and when stuck
* 3: Developer lays out their thinking *before* attacking a problem and integrates feedback through the process
* 2: Developer asks detailed questions when progress slows or stops
* 1: Developer is able to integrate unsolicited feedback but does not really collaborate
* 0: Developer needs more than two reminders to "think out loud" or struggles to articulate their process
