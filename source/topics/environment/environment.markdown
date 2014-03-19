---
layout: page
title: Environment Setup
section: Environment & Source Control
alias: [ /environment.html, /setup ]
---

Setting up your environment can be difficult when you're first starting with Ruby. We want to get the following installed:

* Git
* Ruby 2.1
* A text editor

The setup instructions are broken down by the following platforms: Mac, Linux, and Windows.

## Mac OS

Mac OS is the most popular platform for Ruby and Rails developers. These instructions assume you're on the latest version of MacOS, 10.9. If you're using an older version, refer to [these additional notes]({% page_url environment_older_macos %}).

To have a properly setup dev machine you want the following:

1. XCode
2. Homebrew
3. Git
4. RVM / Ruby

### XCode & Command Line Tools

1. Install XCode from the Apple App Store
2. Open the application after installing and agree to the SLA terms
3. Open `terminal` and run `xcode-select --install`, enter your user password

You should be good to go!

### Homebrew

[Homebrew](http://brew.sh) is a package management system that makes it easy to install hundreds of open source projects and compile them from source for maximum performance on your machine.

* Open the Terminal (You can search for it using Spotlight, or find it in
  `Applications > Utilities > Terminal`)
* Run the homebrew installation script by copy/pasting `ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"` and pressing enter
* It will ask you for your password.
  This is the password to log in to your account on the computer.

#### Verifying Homebrew

When it has completed the installation run `brew doctor` and it should tell you that everything is fine:

{% terminal %}
$ brew doctor
Your system is ready to brew.
{% endterminal %}

### Git

[Git](http://git-scm.com/) is the version control system of choice in the Ruby community. XCode installed an older version of Git for you, but let's update it.

{% terminal %}
$ brew install git
==> Downloading http://git-core.googlecode.com/files/git-1.8.3.4.tar.gz
########################################################### 100.0%
{% endterminal %}

### [RVM](http://rvm.io)

RVM allows you to install and maintain multiple versions of Ruby. More information about Ruby Version Mananger (RVM) can be found at [http://rvm.io](http://rvm.io).

#### Installation

Similar to Homebrew, RVM provides a script to get everything installed. Run this in your Terminal:

{% terminal %}
$ \curl -L https://get.rvm.io | bash -s stable
{% endterminal %}

#### Loading / Post-Install

Look for the line in the output from the RVM installation that starts with

{% terminal %}
To start using RVM you need to run `source ...`
{% endterminal %}

Copy the command inside of the backticks (don't include the backticks), paste it into your terminal window, and hit enter.

Check if it got installed correctly by checking the version.

{% terminal %}
rvm --version
{% endterminal %}

It should give you a version number rather than an error message.

### Ruby

We're going to install Ruby 2.1. If you need another version it'll be same procedure, just replace "2.1" in the instructions with whichever version you want.

#### What's Available?

To list all of the possible ruby versions that you can install, use the command:

{% terminal %}
rvm list known
{% endterminal %}

#### Ruby 2.0

We recommend getting the latest stable version of Ruby, which is version 2.1. Install it with:

{% terminal %}
$ rvm install 2.1
{% endterminal %}

#### Requirements

There are *several* additional libraries that gems will often rely on. RVM makes installing those easy, too. Run this command:

{% terminal %}
$ rvm requirements
{% endterminal %}

It'll figure out what needs to be installed and install it.

#### Setting the Default Version

You can tell rvm which Ruby version you want to use by default:

{% terminal %}
rvm use 2.1 --default
{% endterminal %}

### Text Editor

If you don't already have a favorite text editor, we recommend using [Sublime Text 2](http://www.sublimetext.com/2).

## Linux

If Mac OS isn't a possibility, then your next best bet is Linux. Among distributions, Ubuntu has the best support for Ruby and Rails development. You'll need:

* Git (`sudo apt-get install git-core`)
* RVM (<http://ryanbigg.com/2010/12/ubuntu-ruby-rvm-rails-and-you/>)

You want to avoid managing Ruby, RubyGems, etc. through your package management solution (`apt`). The packages available usually lag months behind the real source code repositories, and it is going to cause you massive headaches.

Instead, setup RVM and handle everything through there (as we'll discuss in the next section).

If you're going to be doing Rails work, then you should also install Node.js. You can get it from your distribution's package manager. If you're using Ubuntu, like above:

`sudo apt-get install nodejs`

### Text Editor

If you don't already have a favorite text editor, we recommend using [Sublime Text 2](http://www.sublimetext.com/2).

## Windows

Getting started on the Windows platform is actually very easy. Engine Yard (<http://engineyard.com>) has put together the RailsInstaller (<http://railsinstaller.org/>), a single package installer with all the tools you need to get working. Make sure that, during the setup, you check the box to configure your environment variables. You can stop after step 2, once you've entered your email and name in the DOS prompt.

Beyond initial setup, though, there is going to be pain. As you add in more Gems and other dependencies you'll find that many of them utilize _native extensions_, code written in C for better performance. Unless the authors have put energy into being cross-platform, you'll run into issues.

Instead, we recommend using VirtualBox and Vagrant to run a Linux virtual machine within your Windows host operating system.

Check out our [Vagrant Setup]({% page_url vagrant_setup %}) tutorial for a full walk-through.
