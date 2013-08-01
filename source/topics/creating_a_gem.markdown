---
layout: page
title: Creating a Gem
---

Let's talk about how to package Ruby code into a gem.

## Introduction

### What is a Gem?

A gem is an archive that contains ruby code (the code you write) and a specification file ([gemspec](http://docs.rubygems.org/read/chapter/20)).

### Gemspec

A gem specification is a special manifest file that contains:

* The name of the gem, the author, description, license, and links to resources, etc.
* a list of source files
* a list of test files
* a list of dependencies

## Creating a Gem

### A Skeleton from Bundler

The [Bundler](http://gembundler.com/) gem provides a command that allows us to quickly generate the structure of the gem. There are many [alternatives](https://www.ruby-toolbox.com/categories/gem_creation) and you could do it manually.

For example, if we want to create a gem named `zipper` we can run:

{% terminal %} 
$ bundle gem zipper
{% endterminal %}

### Completing the `Gemfile`

Open the generated `Gemfile` and you can complete the `name`, `version`, `authors`, `email`, `homepage`, `summary`, and `description` easily enough. 

The `rubyforge_project` is unused in the age of Github.

### Listing Files

The `gemspec` lists the files that are included in the gem itself. This can be an annoyance in that every time you add a file to the gem you have to add it to the `.gemspec` too.

Instead, it's become common to cheat. The `.gemspec` is Ruby, so we can use a bit of trickery to shell out, use git to list the files, and dynamically build them into an array for the spec:

```
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
``` 

### Dependencies

Your application should specify any other gems that it depends on in development or production/usage.

#### Usage Runtime Dependency

If there's a gem that you gem depends on to be used by a normal user, it's a runtime dependency. These are added like so:

```
s.add_dependency 'activesupport', '~> 3.2'
```

You want to write these version specifications carefully. 

#### Dependency Version Specification

Just like a `Gemfile` in a Rails application, you need to think about what versions will be sufficient for the needed functionality. 

Get too specific about which version you want, and your gem might be incompatible with another gem that depends on a different version of the same dependency.

Be too general, and the user's system might use a much older or much newer version of the dependency gem, which might break your usage.

In general, you should use the `~>` comparator which means "accept any version of this gem which matches the version number or has a greater smallest digit".

For instance, '~> 3.2' would match versions `3.2`, `3.3`, or `3.12`. But it wouldn't match `3.1` or `4.1`.

The second number, the minor version, is usually safe to rely on for not breaking backwards compatibility.

But, if you wanted to rely on a specific minor version, you could specify the patch level. '~> 3.2.0' would match versions `3.2.0`, `3.2.1`, or `3.2.12`. But it wouldn't match `3.1` or `3.3`.

#### Development Dependencies

Often there are gems that are needed for working on the gem itself, but not necessary for normal users. These should be specified as development dependencies:

```
s.add_development_dependency 'rspec', '~> 2.12'
```

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