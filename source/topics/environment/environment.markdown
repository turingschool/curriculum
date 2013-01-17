---
layout: page
title: Environment Setup
section: Environment & Source Control
alias: [ /environment.html, /setup ]
---

Setting up your environment can be difficult when you're first starting with Ruby. We want to get the following installed:

* Git
* Ruby 1.9.3
* A text editor

The setup instructions are broken down by the following platforms: Mac; Linux; and Windows.

## Mac OS

Mac OS is the most popular platform for Ruby and Rails developers. To have a properly setup dev machine you want the following:

### Command Line Tools for XCode
* [Create or Register](https://developer.apple.com/programs/register/) an Apple ID.

Register with the same Apple ID you use for other Apple services, such as iTunes, iCloud, and the Apple Online Store.

* [Login](http://developer.apple.com/downloads) to the Apple Developer Portal.
* Search for "Command Line Tools (OS X Lion) for Xcode" or "Command Line Tools (OS X Mountain Lion) for Xcode".
* Download and install the package.

### [Homebrew](http://mxcl.github.com/homebrew/)

Homebrew is a package management system that makes it super easy to install hundreds of open source projects and compile them from source for maximum performance on your machine.

{% terminal %}
$ ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
==> This script will install:
/usr/local/bin/brew
/usr/local/Library/...
/usr/local/share/man/man1/brew.1
Press ENTER to continue or any other key to abort
{% endterminal %}

### [Git](http://git-scm.com/)

Git is the version control system of choice in the Ruby community.

{% terminal %}
$ brew install git
==> Downloading http://git-core.googlecode.com/files/git-1.8.1.1.tar.gz
########################################################### 100.0%
{% endterminal %}


### [RVM](http://rvm.io)

RVM allows you to install and maintain multiple versions of Ruby. More information about Ruby Version Mananger (RVM) can be found at http://rvm.io

{% terminal %}
$ bash -s stable < <(curl -L http://bit.ly/r52UYO)
$ source ~/.bash_profile
$ rvm install 1.9.3 --with-gcc=clang
$ rvm use 1.9.3 --default
{% endterminal %}

### Text Editor

* [Vim](http://www.vim.org/)
* [Sublime Text 2](http://www.sublimetext.com/2)
* [Textmate](http://macromates.com/)
* [RubyMine IDE](http://www.jetbrains.com/ruby/)
* [Redcar](http://redcareditor.com/)

## Linux

If Mac OS isn't a possibility, then your next best bet is Linux. Among distributions, Ubuntu has the best support for Ruby and Rails development. You'll need:

* Git (`sudo apt-get install git-core`)
* RVM (<http://ryanbigg.com/2010/12/ubuntu-ruby-rvm-rails-and-you/>)

You want to avoid managing Ruby, RubyGems, etc. through your package management solution (`apt`). The packages available usually lag months behind the real source code repositories, and it is going to cause you massive headaches.

Instead, setup RVM and handle everything through there (as we'll discuss in the next section).

If you're going to be doing Rails work, then you should also install Node.js. You can get it from your distribution's package manager. If you're using Ubuntu, like above:

`sudo apt-get install node`

### Text Editor

* [Vim](http://www.vim.org/)
* [Sublime Text 2](http://www.sublimetext.com/2)
* [RubyMine IDE](http://www.jetbrains.com/ruby/)
* [Redcar](http://redcareditor.com/) 

## Windows

Getting started on the Windows platform is actually very easy. Engine Yard (<http://engineyard.com>) has put together the RailsInstaller (<http://railsinstaller.org/>), a single package installer with all the tools you need to get working. Make sure that, during the setup, you check the box to configure your environment variables. You can stop after step 2, once you've entered your email and name in the DOS prompt.

Beyond initial setup, though, there is going to be pain. As you add in more Gems and other dependencies you'll find that many of them utilize _native extensions_, code written in C for better performance. Unless the authors have put energy into being cross-platform, you'll run into issues.

<div class="opinion">
<p>If there is any way to avoid using Windows for your development environment, do it. For a free alternative, consider setting up a virtual machine with <a href="http://www.virtualbox.org">Virtual Box</a> and <a href="http://www.ubuntu.com/download/ubuntu/download">Ubuntu Linux</a>.</p>
</div>

### Text Editor

* [Notepad++](http://notepad-plus-plus.org/)
* [Sublime Text 2](http://www.sublimetext.com/2)
* [BBEdit](http://www.barebones.com/products/bbedit/index.html?utm_source=df&utm_medium=banner&utm_campaign=bbedit)
* [RubyMine IDE](http://www.jetbrains.com/ruby/)
* [Redcar](http://redcareditor.com/) 
