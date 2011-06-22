---
layout: tutorial
title: Writing Better Views
outline:
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

