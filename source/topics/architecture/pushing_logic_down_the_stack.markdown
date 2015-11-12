---
layout: page
title: Pushing Logic Down the Stack
---

## High Level

In an MVC application the Controller has a lot of jobs, which means that over
time it tends to attract code. The goal is to build high-quality applications that
push logic down the stack towards the models.

### Learning Goals

Through this discussion you should develop a stronger understanding of:

* What does and doesn't belong in a controller?
* Why are controllers difficult to reason about and test?
* How can we relocate appropriate logic to the model layer?
* How can we use non-ActiveRecord objects ("POROs") to help organize and
simplify code?

### Example Project

It's best to show these kinds of problems with an actual student codebase. For this
exercise we've selected Oregon Sale project, an implementation of the Store Engine
project.

__Dependencies__

Before you continue, make sure you have the necessary dependencies:

1. Ruby 2.1.1 `rvm install 2.1.1` if you don't have it
2. Update homebrew `brew update` 
3. LibV8 -- `brew install v8`
4. PhantomJS -- `brew install phantomjs`

Clone, bundle, prep the database, and run the tests:

{% terminal %}
$ git clone git@github.com:turingschool/oregon_sale.git
$ cd oregon_sale
$ bundle
$ rake db:create db:migrate db:seed
$ bundle exec rake spec
{% endterminal %}

The tests should pass with one pending spec.

## The Rules

When attempting to push logic down the stack, keep the following ideas/questions
in mind:

* Anything related to HTTP and parameters stays in the controller
* Any complexity involving data, like filtering or ordering, belongs in the model
* Let the model keep the data to itself. The controller shouldn't have to know
about the intricacies of the data types and database oddities
* Ask "could this possibly be reused in our [mobile|desktop] app?" If yes, then
it probably belongs in the model.
* *Use* a method in the controller before you write it in the model. Think through
what data the model will need and pick a name that flows well.
* You can create Plain-Old Ruby Objects ("POROs") when you want a model that
isn't backed by a database.

## In Practice

This project, like most Rails projects, has many opportunities for pushing logic
down the stack. Let's look at several refactorings all together, in small groups,
and individually.

### 1. All Together

As a group let's look at the following:

* Easy: `ProductsController#show`, `LineItemsController#destroy`
* Medium: `UsersController#create`
* Hard: `HomeController#show`

### 2. In Small Groups

Next break into small groups and complete the following:

* Easy: `LineItemsController#increase`
* Medium: `OrdersController#new`
* Hard: `OrdersController#create`

### 3. Individually

Finally, on your own:

* Easy: `ProductsController#retire`, `ProductsController#show`
* Medium: `LineItemsController#decrease`
* Hard: `SearchController#user_search` (and all of its various helper methods)
