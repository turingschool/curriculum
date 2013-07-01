---
layout: page
title: Advanced Tools
section: Environment & Source Control
---

### Sample Project

{% include custom/sample_project_advanced.html %}

### Ruby Debugger

The Ruby debugger is a separate gem which requires installation, usually through your Gemfile. Note that the debugger relies on native extensions, so you need to have the Ruby headers and compilation tools setup on your system.

#### Ruby 1.8.7

Add the dependency to your development gems in the `Gemfile`:

```ruby
group :development do
  gem 'ruby-debug'
end
```

Or install it from the terminal with `gem install ruby-debug`

#### Ruby 1.9.X

Assuming you're using Bundler, add the dependency to your development gems in the `Gemfile`:

```ruby
group :development do
  gem 'debugger'
end
```

Or install it from the terminal with `gem install debugger`

If you leave off the `19` you would instead get the package for use with 1.8.7 and it is incompatible with 1.9.

### Redis

#### Ubuntu

There are a few options to install Redis on Ubuntu. The first and easiest is to use `apt`:

{% terminal %}
$ sudo apt-get install redis-server
{% endterminal %}

This will set up `redis-server` to startup with the OS, but it may be a slightly dated version.

To get the latest stable version you can download from `http://redis.io/download` and install using their directions. 

#### MacOS

Presuming you have Homebrew installed, you can install the Redis recipe:

{% terminal %}
$ brew install redis
{% endterminal %}

#### Windows

There is no official Redis server version for Windows. There is a third-party port of the original service which can be used for development but may not offer 100% compatibility:

https://github.com/dmajkic/redis/

### GhostScript

#### OS X

Use homebrew and install it with `brew install ghostscript`.

#### Linux

Install it with `apt-get install ps2pdf`. If you get an error that `ps2pdf` package can not be found, try typing `ps2pdf` to see if it is already installed as part of the OS.

#### Windows

Download and run the installer from http://www.ghostscript.com/download/gsdnld.html

### Other Gems

Gems you may want to utilize in various advanced tutorial sections include:

* `perftools.rb`
* `rack-perftools_profiler`
* `bullet`
* `newrelic_rpm`
* `kaminari`

Install them all with this instruction from the terminal:

{% terminal %}
$ gem install perftools.rb rack-perftools_profiler bullet newrelic_rpm kaminari --no-rdoc --no-ri
{% endterminal %}
