---
layout: page
title: Bundler
section: Environment & Source Control
---

The Ruby ecosystem has tens of thousands of Gem libraries we can utilize in our programs. A typical Rails application might rely on 50 libraries. In the days of Rails 2 managing these dependencies was a real challenge, especially when coordinating multiple machines and developers.

As the core team built Rails 3, they addressed this problem by creating Bundler (<http://gembundler.com/>). In our project we create a `Gemfile` which specifies our gem dependencies and source(s). Using that file, Bundler can resolve the complex interactions of library dependencies and install/utilize gems as needed.

## A Basic `Gemfile`

A very simple `Gemfile` might look like this:

```ruby
source :rubygems
gem 'rails'
gem 'rake'
```

From the terminal, in the project directory, we can process this `Gemfile` and setup the dependencies with one command:

{% terminal %}
$ bundle install
{% endterminal %}


Since `install` is the default `bundle` command you can omit it, like so:

{% terminal %}
$ bundle
{% endterminal %}


Bundler will attempt to utilize gems already installed on the system to meet the dependencies, fetching additional gems from the "source" (in our example [RubyGems](http://rubygems.org/)) as needed.

<div class="note">
<p>Once in awhile you'll want to run <code>bundle</code> when you're offline. To tell Bundler to <em>only</em> use locally installed gems, add the <code>local</code> flag like this: <code>bundle --local</code>.</p>  
</div>

## Versioning Dependencies

Most Ruby libraries move fast, some move incredibly slowly. While there are established Version Policies (<http://docs.rubygems.org/read/chapter/7>) for RubyGems, their implementation is spotty at best. Using the above `Gemfile`, our application would (at the time of this writing) pull down Rails version 3.0.10 and Rake 0.9.2. 

Six months from now, though, it might pull down Rails version 3.2.0. Will that break our application? *Probably*. So we should lock our gems down to specific versions. Adding exact versions to the above `Gemfile` would look like this:

```ruby
source :rubygems
gem 'rails', '3.0.10'
gem 'rake', '0.9.2'
```

### Flexible Versioning

But what about bug and security fixes? I can build against Rails 3.0.10, but if a security issue is found they'll release a 3.0.11. The third number is called the "patch level", and when it increments it should be completely backwards compatible. 3.0.11 should introduce _no issues_ for an app built against 3.0.10. This rule _generally_ holds true.

But patch levels are released every few weeks. This can make keeping the `Gemfile` up to date a real pain. We can add some flexibility to our dependencies with the "squiggle-rocket" operator:

```ruby
source :rubygems
gem 'rails', '~>3.0.10'
gem 'rake', '~>0.9.2'
```

Now Bundler will use Rails version `3.0.10`, `3.0.11`, or any patch level in the `3.0.*` series. It will *not*, however, use `3.1.0`. 

This is usually the ideal behavior. Upgrading the "minor" version, from `3.0` to `3.1`, is likely to necessitate changes in your application.

### Managing Edge Code

Often you'll be developing a gem while you're developing an application that uses it. Or, sometimes you'll need to use the absolute bleeding edge code for a Gem before it's released on RubyGems. In that case, Bundler can resolve dependencies directly from Git or GitHub:

```ruby
source :rubygems
gem 'rails', git: "https://github.com/rails/rails.git"
gem 'rake', '~>0.9.2'
```

Building an application using git-based dependencies is *an extremely bad idea* unless you control the repository. The easiest way to do that is fork the repository on GitHub, then reference your fork in your `Gemfile`.  You can keep your fork up to date by adding the original repository as an upstream remote (<https://github.com/MarkUsProject/Markus/wiki/Gitkeepingpace>).

Unless you have a lot of time to waste and enjoy frustration, *never* build against "Edge Rails" as shown here.

## Using `bundle exec`

Many gems provide command-line executables, like `rake` and `rails`. 

### Old vs. New

When you run `rake` at the command line, for instance, your system searches its `PATH` for a matching executable. If you had both Rake versions `0.8.7` and `0.9.2` installed, which one would it use? Rubygems will cause the system to use the newest installed version.

But your application might be written with `0.8.7`. There isn't a way, using the normal command line, to force Rubygems to use the older version.

### Running in Your Bundle

Bundler provides a command line function `bundle exec`. When you run `bundle exec`, Bundler will:

* sandbox execution so your system gems are not accessible
* load the gems specified in your `Gemfile`
* then run whatever command you add after the `exec`

So, for example:

{% terminal %}
$ bundle exec rake db:migrate
{% endterminal %}

Would force usage of the version of Rake specified in your project's `Gemfile`, regardless of what other versions are installed in the system gems.

### Recommendations

Once your project has a `Gemfile`, it is a good practice to prefix every command line instruction with `bundle exec`. So you might do operations like:

* `bundle exec rake db:migrate`
* `bundle exec rails generate model Article`
* `bundle exec rspec spec`

It's a pain to type `bundle exec` all the time, so some developers will create an alias in the OS to `be`, allowing `be rake db:migrate`, etc.

<div class="note">
  <p>On MacOS or Linux you could create such an alias by opening your <code>.bashrc</code> or <code>.bash_profile</code> and adding this line:</p>
  <p><code>alias be="bundle exec $1"</code></p>
</div>
