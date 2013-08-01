---
layout: page
title: Creating a Gem
---

Let's talk about how to package Ruby code into a gem.

## Code Re-Use

In event manager we wrote some great code that helps us clean up zip codes and phone numbers. We find ourselves in a position in a new application where we wish we had that code.

## Creating a Gem

A gem is a ruby project that contains ruby code (the code you write) and a specification file ([gemspec](http://docs.rubygems.org/read/chapter/20)).

A gem specification is a special manifest file that contains:

* The name of the gem, the author, description, license, and links to resources, etc.
* a list of source files
* a list of test files
* a list of dependencies

The [Bundler](http://gembundler.com/) gem provides a command that allows us to quickly generate the structure of the gem. There are many [alternatives](https://www.ruby-toolbox.com/categories/gem_creation).

{% terminal %} 
$ bundle gem zipper
{% endterminal %}

## Composition of a Gemfile

* name
* version
* authors
* email
* description
* summary
* homepage
* license
* files
* executables
* test\_files
* require\_paths

## Migrating Your Code Into The Gem

To ensure we are not trampling on the work of others the code within a gem
should be placed within it's own namespace.

This does create some overhead in our previous code that uses the gem, but
it ensures that we do not destroy the precious ecosystem that Ruby provides.

## Packaging and Shipping Your Gem

* Reference gems by [name](http://gembundler.com/v1.2/gemfile.html)

{% terminal %} 
$ gem build zipper.gemspec
{% endterminal %}

* Installing the gem locally

{% terminal %} 
$ gem install --local zipper-0.0.1.gem
{% endterminal %}

* Pushing your gem to Rubygems

{% terminal %} 
$ gem push zipper-0.0.1.gem
{% endterminal %}

* Serving them locally

All installed gems, in your gemset, `gem list`, will be made available to
download.

## Using Gems from Git

* Reference gems by [git](http://gembundler.com/v1.2/git.html)

Bundler will look for a valid gemspec in the root directory of the project
and install the gem from 

## Using Gems by filepath

* Reference gems by [filepath](http://gembundler.com/v1.2/gemfile.html)