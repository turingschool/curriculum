---
layout: page
title: Exploring Spree Applications
section: Building Applications with Spree
---

Spree gives you all these great features but it is not clear where the features
come from an initial project. To build new features for Spree it is essential
to understand how to navigate the Spree source code.

### Installation

With a fairly [barebones](https://github.com/JumpstartLab/SpreeStore)
Spree application you would be surprised how little code is in that project.

Let's install all of the project's dependencies and start the rails server.

```bash
git clone git@github.com:JumpstartLab/SpreeStore.git
bundle install
rake db:migrate
rake db:seed
rake spree_sample:load
rails server
```

### Visit the Root Page

Let's visit the application's root page and disect the request and the
associated logs to help us figure out to start exploring the Spree source code.

* Visit `http://localhost:3000`

* View the terminal results

```
Started GET "/" for 127.0.0.1 at 2013-08-08 19:02:28 -0500
Processing by Spree::HomeController#index as HTML
...
```

So we know that the root of our application is being processed by the `index`
action of the `Spree::HomeController`. A quick review of our existing source
code we see we have not defined that route or even that controller. Where
did this functionality come from?

### Disecting the Root Page Results

Let's start by examining our routes file and look for an associated controller.

* Open the `config/routes.rb`:

A traditional Rails application defines a
[root route](http://guides.rubyonrails.org/routing.html#using-root) within
the `config/routes.rb` file. When we look at our current application there is
no root present, however there is a Rails Engine setup at the root of the
application.

```
mount Spree::Core::Engine, :at => '/'
```

So instead of a root action Spree defines an engine that is mounted at the
root of our application. So our application has no routes and no controller
defined. So we need to start exploring the Spree source code to find out
more details about the engine.

### Exploring the Spree Engine

So our application contains no Spree source code. Where is the spree source?
So how do we gain access to the Spree source?

The [Bundler](http://bundler.io/) application allows us to manage our
dependencies. We used it to install all of the necessary components. It can
also help us find and open the source.

Let's first view the location of the source and then open the source code:

* Run `bundle show spree`

```
/Users/USERNAME/.rvm/gems/ruby-2.0.0-p195@GEMSETNAME/gems/spree-2.0.3
```

The result of the *bundle show* command will show us the file location of
the **spree** gem. We can use that file path to open within our editor.

However, before we do that lets use a different Bundler command which will
allows us to more quickly open the contents of the gem.

* Run `bundle open spree`

When we execute this command the first time it will inform us that we need
to set our EDITOR or BUNDLER_EDITOR.

* Setup [Sublime](http://www.sublimetext.com/docs/2/osx_command_line.html)
  to be launchable from the terminal.

This allows you to run the command `subl FILENAME` to open a file in sublime.

* Run `export BUNDLER_EDITOR=subl`

This will set your bundler editor for current terminal sessions.

* Run `bundle open spree`

Sublime should open with the contents of the Spree gem.

### Your source is in Another Gem

Looking through the [Spree](http://rubygems.org/gems/spree) gem that was opened
you will not find the `Spree::Core::Engine` or `Spree::HomeController`.

That is because the spree gem is a meta-gem. Which means it contains little or
no source code but has several dependencies on other gems.

* Open `lib/spree.rb`:

The source contains several require lines which require additional gems:

```
require 'spree_core'
require 'spree_api'
require 'spree_backend'
require 'spree_frontend'
require 'spree_sample'
```

### Opening Another Gem

So the source we are looking for does not exist within the **spree** gem but
it probably exists in one of its dependencies.

Using `bundle open GEMNAME` to open up:

* spree_core
* spree_backend
* spree_frontend

Within each of these projects search for the following files:

* `config/routes.rb`
* `app/controllers/home_controller.rb`

### Opening All the Gems

Another alternative to opening each and every gem in various editor windows is
to open all of your gems. This may be overkill, but can make it easier sometimes
to search through all of the source quickly and easily.

* Run `bundle show spree`

```
/Users/USERNAME/.rvm/gems/ruby-2.0.0-p195@GEMSET/gems/spree-2.0.3
```

The path in the output contains the specific information that includes the
Spree gem. Remove the spree gem from the path and you have a path to all
the gems within the gemset.

* Run `subl /Users/USERNAME/.rvm/gems/ruby-2.0.0-p195@GEMSET/gems`

Sublime will open an editor that now allows you search across all the gems
within your gemset. This may be an overly large list of gems but sometimes
having access to more than one gem at a time is easier to manage particularly
if you want to browse the source.

### An Easier Time Exploring With RubyMine

RubyMine makes the entire process of navigating the source code and associated
gems much easier as all the installed gems are provided in the list of external
libraries.

* Set the correct Ruby Version and Gemset in project options.

* Press `Cmd+N` to search for a class and search for `HomeController`.
