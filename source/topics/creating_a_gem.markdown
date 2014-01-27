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

### Completing the `.gemspec`

Open the generated `zipper.gemspec` and you can complete the `name`, `version`, `authors`, `email`, `homepage`, `summary`, and `description` easily enough. 

The `rubyforge_project` is unused in the age of GitHub.

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

Now it's time to actually move your code into the gem. 

### The Base File

The convention is to create a file like `lib/zipper.rb` where `zipper` is replaced by the name of your gem. That file:

* requires other Ruby files in the gem
* handles any setup tasks

### Real Code

From there, let's say you have a class named "Foo" and a class named "Bar". The files should be `lib/zipper/foo.rb` and `lib/zipper/bar.rb`.

#### Namespacing Your Classes

When users require our gem we want to be reasonably sure that our classed don't cause namespace collisions with classes in their application. To avoid this problem, we use Ruby modules as name spaces.

Say that my `Foo` class was originally:

```
class Foo
end
```

Then I want to wrap it in a namespace matching my gem's name:

```
module Zipper
  class Foo
  end
end
```

Where `Zipper` should be the actual name of your gem.

## Packaging and Shipping Your Gem

Once the code is in place and your specs are passing, it's time to actually build the gem archive:

{% terminal %} 
$ gem build zipper.gemspec
{% endterminal %}

### Installing Locally

You can then install the gem locally so it's available to all your apps:

{% terminal %} 
$ gem install --local zipper-0.0.1.gem
{% endterminal %}

### Pushing to Rubygems

Ready to be famous? Then push your code to Rubygems:

{% terminal %} 
$ gem push zipper-0.0.1.gem
{% endterminal %}
