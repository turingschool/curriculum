---
layout: page
title: "JavaScript Blogger"
sidebar: true
language: ruby
topics: rails
---

In this project we will create a simple blog using JavaScript for portions of the front-end, the Asset Pipeline, and JavaScript unit and acceptance testing.

This project assumes you have a small amount of experience with Rails, and will primarily focus on the JavaScript.

## 0. Initial Setup

* trim out gems we don't need
* add twitter-bootstrap-rails
* run the server, yay it works

## 1. Post Scaffold

* bootstrap layout generator
* scaffold generator for posts
* migrate db
* bootstrap resource themer
* add a root url
* make some posts

## 2. Asset Pipeline

* talk about app/assets, vendor/assets, and assets from gems
* compile assets, look at compiled output
* add some lines to application.js, compile, look at compiled file
* clobber assets
* run dev server
* inspect js tags in head in dev mode
* stop server, compile assets, run in production mode
* inspect tags in head in production

## 3-X. Incorporate autosaving widget

* mostly use Jim's tutorial
* extract some functions so they can be tested later

## 4. Konacha

* add gem
* bring in assets
* setup an "assert true" test to ensure it's working
* browser run mode for debugging? Console?

## 5. Unit test the autosaver

* test the extracted functions
* extract autotest into OO, guided by our tests, TDD style

## 6. Acceptance (Integration) testing

* setup capybara
* create plain integration test (visit root, see Posts)
* write an editing test

## 7. Formatting

* Write acceptance test for formatting, a few simple markdown checks
* Add markdown server-side
* Write acceptance test for live preview
* Drop to unit test for a preview function
* write glue jquery for preview
