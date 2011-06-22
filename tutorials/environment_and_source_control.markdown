---
layout: tutorial
title: Writing Better Views
outline:
  Platforms
  RVM
  Bundler
  Common Git Practices
  Heroku Configuration / Setup
---

Setting up your environment can be difficult when you're first starting with Ruby and Rails. To make matters worse, there is a lot of outdated and just wrong documentation out there on the web.

Here's a concise guide to the current best practices.

## Outline by Platform

The ideal setup is going to vary by platform.

### MacOS

MacOS is the most popular platform for Ruby and Rails developers. I strongly recommend that you get on MacOS if there is any possible way to make it happen. To have a properly setup dev machine you want to have:

* XCode 4 (http://itunes.apple.com/us/app/xcode/id422352214?mt=12)
* Homebrew (http://mxcl.github.com/homebrew/)
* Git (`brew install git` after Homebrew is installed)
* RVM (https://rvm.beginrescueend.com/)

XCode is necessary to have all the development headers and compilers available on your system. Homebrew is a package management system that makes it super easy to install hundreds of open source projects and compile them from source for maximum performance on your machine. Git is, of course, the version control system of choice in Ruby-land. Finally, RVM will be discussed more in the next section.

### Linux

If MacOS isn't a possibility, then your next best bet is Linux. Among distributions, Ubuntu has the best support for Ruby and Rails development. You'll need:

* Git (`sudo apt-get install git-core`)
* RVM (https://rvm.beginrescueend.com/)

You want to avoid managing Ruby, RubyGems, etc through your package management solution (`apt`). The packages available usually lag months behind the real source code repositories, and it is going to cause you massive headaches.

Instead, setup RVM and handle everything through there.

### Windows

Getting started on the Windows platform is actually very easy. Engine Yard (http://engineyard.com) has put together the RailsInstaller (http://railsinstaller.org/), a single package installer with all the tools you need to get working.

Beyond initial setup, though, there is going to be pain. As you add in more Gems and other dependencies you'll find that many of them utilize _native extensions_, code written in C for better performance. This C code likely will not compile under Windows, so the gem maintainer may have a second version of the gem without the extensions. You're losing performance, but more importantly you're using code that most of the community is *not* using. You're going to run into bugs that few other users see and will experience odd interactions between libraries.

If there is any way to avoid using Windows for your development environment, do it. For a free alternative, consider setting up a virtual machine with Virtual Box (http://www.virtualbox.org/) and Ubuntu Linux (http://www.ubuntu.com/download/ubuntu/download).

## RVM

RVM, or Ruby Version Manager, has revolutionized how we install and manage Ruby. Given the rapid pace of development in our community, it is common that a developer will need to have access to both Ruby 1.8.7 for older projects and Ruby 1.9.2 for newer ones. They might also mix in alternative Ruby interpreters like JRuby or Rubinius. Installing and maintaining all these by hand is extremely difficult.

Enter RVM. The RVM system actually contains no Ruby code -- it's a collection of terminal scripts that can make managing multiple versions of Ruby transparent and easy. Even if you are only using one version of Ruby today, you'll still gain great benefits from RVM. Let me put it this way: if you're on a Unix-based system and not using RVM, *you are doing it wrong.*

### Quick Setup

Generally RVM can be setup in three steps.

1. Install from source:
    bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)
2. Add this line to your `~/.bash_profile`
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
3. Re-process your profile
    source ~/.bash_profile
    
Validate RVM is installed by running `rvm info` and you should see lots of information about your environment.    
    
### Installing Rubies

Once you have access to the RVM system you're ready to install Ruby. To see what versions of Ruby are available you can run `rvm list known` in a terminal.

For these tutorials we'll be using Ruby 1.9.2, install it with the following commands. Note that *$* is my terminal prompt:

    $ rvm install 1.9.2
    
Then tell RVM to make it our default Ruby:

    $ rvm use 1.9.2 --default
    
Test it by displaying the Ruby version and you should see something like this:

    $ ruby -v
    ruby 1.9.2p136 (2010-12-25 revision 30365) [x86_64-darwin10.7.0]
    
