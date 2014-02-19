---
layout: page
title: Navigating Spree
---

Any large piece of software is difficult to understand. But there's been significant effort put into Spree to break it into bite-sized pieces that are easier to comprehend.

## On Gems and Bundler

Let's discuss a few key points that you should understand about how Spree is constructed:

### Background on Ruby Gems

* Where Rubygems started
* What is a gem, exactly?
* The rise of Gemcutter (aka rubygems.org)
* Rails and dependencies
* Pre-bundler "Solutions"

### Bundler Principles

* Multiplying dependencies
* Dependency version issues
* Complex dependency graph
* System reproduceability

### Bundler Details

* Writing the `Gemfile`
  * Source
  * From Rubygems
  * From the Local System
  * From Git
* Generating the `Gemfile.lock`
* Dependencies and source control
* `bundle` or `bundle install`
* `bundle update [gem]` versus `bundle update`

### Bundler Help

* `bundle list`
* `bundle show`
* `bundle open`

## Spree Gems

Let's talk in a bit more detail about the Spree gems themselves.

### `spree` - The Meta-Gem

* Just requires the other gems

### `spree_core`

* The place for data models shared across components
* Mailers
* Business logic

### `spree_backend`

* Admin views
* Admin controllers
* Relies on `spree_core` for models

### `spree_frontend`

* User-facing views
* User-centric controllers

### `spree_api`

* Controllers to handle API request
* Views to generate JSON data with RABL
* Models/business logic in `spree_core`

### `spree_cmd`

* Provides command-line tools for installing spree and generating extensions.

### `spree_sample`

* Provides a rake task to load your store with some dummy data to work with.
* Run it with `spree_sample:load`

## How to Use Spree

* Build your own Rails application
* Install Spree as an engine (via the gem and command-line tools)
* Install any extensions
* Add any overrides to *your* appliction tree
