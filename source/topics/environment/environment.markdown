---
layout: page
title: Environment Setup
section: Environment & Source Control
---

Setting up your environment can be difficult when you're first starting with Ruby and Rails. To make matters worse, there is a lot of outdated and wrong documentation out there on the web.

Here's a concise guide to the current best practices.

### Goals

Generally speaking, we want to get the following installed:

* Ruby 1.9.2
* Rails 3.2.0
* Git

### Mac OS

Mac OS is the most popular platform for Ruby and Rails developers. To have a properly setup dev machine you want the following:

* XCode 4
  * XCode is necessary to have all the development headers and compilers available on your system
  * If you have an OS X installation disc, the XCode Installer package appears in the disc's Optional Installs folder
  * Double-click the .mpkg file to open the installer and begin the installation process
  * Otherwise, download it from the App Store:  http://itunes.apple.com/us/app/xcode/id422352214?mt=12
* Homebrew
  * Homebrew is a package management system that makes it super easy to install hundreds of open source projects and compile them from source for maximum performance on your machine. 
  * Find download and installation instructions at http://mxcl.github.com/homebrew/
* Git
  * Git is the version control system of choice in the Ruby community
  * Once Homebrew is installed, run `brew install git`
* RVM
  * With Homebrew and Git in place, check out the download and installation instructions at https://rvm.beginrescueend.com/

<div class="note">
<p>If downloading XCode will take you too long, you can try using the unofficial GCC compilers available here: <a href="https://github.com/kennethreitz/osx-gcc-installer">https://github.com/kennethreitz/osx-gcc-installer</a></p>
</div>

### Linux

If Mac OS isn't a possibility, then your next best bet is Linux. Among distributions, Ubuntu has the best support for Ruby and Rails development. You'll need:

* Git (`sudo apt-get install git-core`)
* RVM (<http://ryanbigg.com/2010/12/ubuntu-ruby-rvm-rails-and-you/>)

You want to avoid managing Ruby, RubyGems, etc. through your package management solution (`apt`). The packages available usually lag months behind the real source code repositories, and it is going to cause you massive headaches.

Instead, setup RVM and handle everything through there (as we'll discuss in the next section).

### Windows

Getting started on the Windows platform is actually very easy. Engine Yard (<http://engineyard.com>) has put together the RailsInstaller (<http://railsinstaller.org/>), a single package installer with all the tools you need to get working. Make sure that, during the setup, you check the box to configure your environment variables.

Beyond initial setup, though, there is going to be pain. As you add in more Gems and other dependencies you'll find that many of them utilize _native extensions_, code written in C for better performance. Unless the authors have put energy into being cross-platform, you'll run into issues.

<div class="opinion">
<p>If there is any way to avoid using Windows for your development environment, do it. For a free alternative, consider setting up a virtual machine with <a href="http://www.virtualbox.org">Virtual Box</a> and <a href="http://www.ubuntu.com/download/ubuntu/download">Ubuntu Linux</a>.</p>
</div>