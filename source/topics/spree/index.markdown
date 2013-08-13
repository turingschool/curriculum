---
layout: page
title: Building Applications with Spree
---

## Getting Around Your Spree Application

Spree gives you all these great features but it is not clear where the features
come from an initial project. To build new features for Spree it is essential
to understand how to navigate the Spree source code.

* Getting Comfortable With Bundler commands: **show** and **open**

### Discussion

* Bundler fundamentals (Gemfile and Gemfile.lock)
* Bundler's **update** vs **install**

## Debugging Your Spree Application

Now that you are able to get around the source it is time to use Ruby's
debugging tools to help you bridge your mental understanding of the code and
the actual way the code is working

* Debugger

## Adding to the Admin Experience

The Spree admin page suits most purposes but we have some ideas that we want
to override or replace to the existing experience. First we will examine the
current layout and examine how we can append additional features.

The current admin experience offers us the ability to list the current users
in the system. When we view this page we only have a list of email addresses
of our users. It is hard to tell from this who are the admins of our system.

To view if a user is an admin we need to access the details of each user. It
would nice if we could include a simple flag or highlight if the user is an
admin from the index page. This will allow us to at a glance see the admins
within our system.

* Overriding View Templates
* Ruby Objects

### Discussion:

* Open Classes
* Monkeypatching
* `class_eval` and `instance_eval`

## Refining our Additions

The Spree admin experience looks great with the addition that we have made.
Now it is time to refine the experience and extract it into an extension.

* Deface

## Spree Extension Format

With our changes complete and refined it is time to package the entire
experience into an extension which we can share with others and bring into our
future Spree projects that may require it.

### Discussion

* Gems and Gemspec
* Bundler with paths and git repositories
* Engines vs Plain Old Gems

## Creating a Theme System

The first spree extension that we created added very little to the current
experience. We relied on the existing infrastructure with very few changes.
Now we want to create an extension that will require us to add additional
controllers and views.

* Controllers and Views
* Rails Console

### Discssion

* Best Practices for Models, Views, and Controllers

## Resources

* [Ruby Styleguide](https://github.com/styleguide/ruby)
* [Rails Guides](http://guides.rubyonrails.org/v3.2.13/)
* [Rails API](http://api.rubyonrails.org/v3.2.13/)

### Spree on JRuby

Spree runs with JRuby but with some serious warts. A running server is available
as a [branch](https://github.com/JumpstartLab/SpreeStore/tree/jruby) of the
Spree Store project.

The server will run but issues remain with the gem
[Deface](https://github.com/spree/deface) and how it renders the content from
the overrides.

### Spree on Rails 4

Spree is currently working towards supporting
[Rails 4](https://github.com/spree/spree/tree/rails4).