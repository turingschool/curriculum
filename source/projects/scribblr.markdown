---
layout: page
title: "Scribblr: A JavaScript Blogging App"
sidebar: true
language: ruby
topics: rails
---

In this project we will create a simple blog using JavaScript for portions of the front-end. We'll cover:

* Rails Asset Pipeline
* JavaScript Unit Testing with Konacha
* JavaScript Integration Testing with Capybara

This project assumes you have a small amount of experience with Rails, and will primarily focus on the JavaScript.

## 0. Initial Setup

### Rails

First off, we need a Rails project. We're going to work with Rails 4, which as of the writing of this material is currently on RC1, which is a prerelease. You will need at least Ruby 1.9.3, and Ruby 2.0.0 is recommended.

Install Rails 4's RC1 with this command:

{% terminal %}
$ gem install rails -v 4.0.0.rc1
{% endterminal %}

Next, setup our initial project. It's going to be a JavaScript heavy Blog, so let's give it a cool name, like Scribblr:

{% terminal %}
$ rails new scribblr
$ cd scribblr
{% endterminal %}

Now let's boot up the Rails server:

{% terminal %}
$ rails server
=> Booting WEBrick
=> Rails 4.0.0.rc1 application starting in development on http://0.0.0.0:3000
=> Run `rails server -h` for more startup options
=> Ctrl-C to shutdown server
[2013-06-01 14:00:12] INFO  WEBrick 1.3.1
[2013-06-01 14:00:12] INFO  ruby 2.0.0 (2013-05-14) [x86_64-darwin12.3.0]
[2013-06-01 14:00:12] INFO  WEBrick::HTTPServer#start: pid=51959 port=3000
{% endterminal %}

Note that on the last line our server is running on port 3000. Visit [localhost:3000](http://localhost:3000) and you should see Rails's welcome screen.

## 1. Post Scaffold

* scaffold generator for posts
* migrate db
* bootstrap layout generator
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
