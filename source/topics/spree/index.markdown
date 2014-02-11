---
layout: page
title: Building Applications with Spree
sidebar: true
---

Spree is an awesome platform for building and running an online store or system of stores. Out of the box you get functionality that can cover 80%+ of use cases.

### Customizing Spree

But maybe you're in that 20% and you want to customize things. If you've ever customized software written by someone else, you know that this is **inherently** a very difficult process. If you didn't build it, you're unlikely to agree with all the design decisions. There'll be names that don't make sense to you. There are "obvious" nuances missed and opportunities for the platform to be better.

That's true of Spree just as it is any other platform. **But**, Spree has some great strengths:

* open source, so you can see *exactly* how things work without manuals or tech support phone calls
* a broad and active community of developers who help each other out
* a growing library of existing extensions and customizations
* several years of development and usage

### Learning Goals

In this series of tutorials we'll:

* Learn how Spree is constructed and where the code lives
* Practice navigating the Spree source to find the bits we're interested in
* Practice techniques for debugging Spree applications
* Practice extending Spree with new features
* Learn why and practice how to test-drive Spree applications and features

Let's get started!

## Navigating Spree

First off, let's talk about what it means to build a Spree application, where the code lives, and how we explore it.

Jump over to the [Navigating Spree]({% page_url navigating_spree %}) tutorial.

## Debugging Spree Applications

Now that you are able to get around the source it is time to use Ruby's
debugging tools to help you bridge your mental understanding of the code and
the actual way the code is working.

Jump over to the [Debugging Spree]({% page_url debugging_spree %}) tutorial.

## Customizing Spree

Let's work through the process of adding functionality to Spree itself. Jump over to the [Adding to the Admin Experience]({% page_url adding_to_the_admin_experience %}) tutorial.

## Refining Customizations

In the first tutorial, we took a rather brute-force approach to creating a feature. Let's revisit those changes and clean things up in the the [Refining Customizations]({% page_url refining_our_additions %}) tutorial.

## Packaging Extensions

With our changes complete and refined it is time to package the entire
experience into an extension which we can share with others and bring into our
future Spree projects that may require it. Jump over to the [Packaging Spree Extensions]({% page_url packaging_extensions %}) tutorial.

## Creating a Theme Extension

The first spree extension that we created added very little to the current
experience. We relied on the existing infrastructure with very few changes.
Now we'll create an extension that will require us to add additional
controllers and views. Jump over to the [Creating a Theme System]({% page_url creating_a_theme_system %}) tutorial.

## Small Topics

### Ruby & Rails Style

Writing Ruby that other developers want to work with is difficult. Writing Rails applications that can grow and scale is hard too. Here are a few references to help you along the way:

* [Ruby Styleguide](https://github.com/styleguide/ruby)
* [Rails Guides](http://guides.rubyonrails.org/v3.2.13/)
* [Rails API](http://api.rubyonrails.org/v3.2.13/)

### Using Rake

Rake is a powerful tool for automating parts of your workflow. Check out our [Automated Tasks with Cron and Rake tutorial]({% page_url automation %}).

### Testing and RSpec

Building Spree applications that can grow reliably means writing a robust automated test suite. If you're just getting started with RSpec and testing, check out:

* [RSpec and BDD]({% page_url rspec_and_bdd %})
* [RSpec Practices]({% page_url rspec_practices %})

### Spree on JRuby

Spree runs with JRuby but with some serious warts. A running server is available
as a [branch](https://github.com/JumpstartLab/SpreeStore/tree/jruby) of the
Spree Store project.

The server will run but issues remain with the gem
[Deface](https://github.com/spree/deface) and how it renders the content from
the overrides.

At this time, Spree is effectively incompatible with JRuby.

### Spree on Rails 4

Spree is running on Rails 4 and Ruby 2.1, there is work started to support the [Rails 4.1 beta](https://github.com/spree/spree/tree/rails-4.1.0) here.
