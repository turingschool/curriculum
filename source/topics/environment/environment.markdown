---
layout: page
title: Environment Setup
section: Environment & Source Control
sidebar: true
alias: [ /environment.html, /setup ]
---

Setting up your environment can be difficult when you're first starting with Ruby. We want to get the following installed:

* Git
* Ruby 2.1
* PostgreSQL
* A text editor

The setup instructions are broken down by platform: Mac, Linux, and Windows.

### Text Editor

If you don't already have a favorite text editor, we recommend using [Atom](https://atom.io/).

## Mac OS

Mac OS is the most popular platform for Ruby and Rails developers.
These instructions assume you're on the latest version of MacOS, 10.9.
If you're using an older version, refer to [these additional notes]({% page_url environment_older_macos %}).

### Terminal

The terminal is a textual interface to your computer.
You can move around folders (called directories) and run programs within it.
For example, when you run `pry` or `ruby`, you are running that program from the terminal.

If this is all new for you, see [Terminal and Editor](http://tutorials.jumpstartlab.com/academy/workshops/terminal_and_editor.html)

You can use the existing terminal, or my favourite: [iTerm2](http://iterm2.com/).
To launch the terminal, go to Spotlight and type "Terminal" or "iTerm" and then run it.
The following commands expect a terminal.

### XCode & Command Line Tools

XCode is a huge suite of development tools published by Apple. You'll want to install it before attempting to install anything else.

1. Install XCode from the Apple App Store
2. Open the application after installing and agree to the SLA terms
3. Open `terminal` and run `xcode-select --install`, enter your user password

You should be good to go!

### Homebrew

[Homebrew](http://brew.sh) is a package management system that makes it easy to install hundreds of open source projects and compile them from source for maximum performance on your machine.

Open the Terminal (You can search for it using Spotlight, or find it in `Applications > Utilities > Terminal`), then run the homebrew installation script:

{% terminal %}
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
{% endterminal %}

It will ask you for your password. This is the password to log in to your account on the computer, it needs this because it installs its packages in a place that all users of this computer can access.

#### Verifying Homebrew

When it has completed the installation run `brew doctor` and it should tell you that everything is fine:

{% terminal %}
$ brew doctor
Your system is ready to brew.
{% endterminal %}

If it says something like **"Warning: /usr/bin occurs before /usr/local/bin"**, then you need to edit a variable called your PATH.
The PATH variable is how your shell finds programs you are trying to run. For example, when we just ran `$ brew doctor`, how did it
know where to find the brew program? It looked through a list of directories until it found `brew`. The list is stored in the `$PATH`.
You can see the list with `$ echo "$PATH"`, which should print out a long string of directories, delimited by colons.
You can make this more human-friendly by translating colons into newlines like this: `$ echo "$PATH" | tr : "\n"`.
The program you are trying to run may show up at multiple places in these directories. For example, if you said `which -a git`,
it might tell you that there is a git in "/usr/bin/git" and also in "/usr/local/bin/git". Since the shell will execute the first
one that it finds, we need to make sure that the one we want (the homebrew one, in /usr/local/bin) is the one it finds,
which means that "/usr/local/bin" needs to be earlier in the path.

We can place it earlier in the path by editing the configuration file for our shell:

{% terminal %}
$ atom ~/.bash_profile
{% endterminal %}

At the top of this file, type `export PATH="/usr/local/bin:$PATH"` which will add "/usr/local/bin", homebrew's install location,
to the beginning of the path.

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
$ curl -L https://get.rvm.io | bash -s stable
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

To list all of the possible Ruby versions that you can install, use the command:

{% terminal %}
rvm list known
{% endterminal %}

#### Ruby 2.1

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
$ rvm use 2.1 --default
{% endterminal %}

### PostgreSQL

Postgres is the database of choice for most Rails projects.

#### Installation

Homebrew has Postgres for you. From your terminal:

{% terminal %}
$ brew install postgresql
{% endterminal %}

#### If You Want Postgres to Always Run

This can be nice if you work with Postgres frequently, or just don't want to have to deal with turning it on again:

{% terminal %}
ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
{% endterminal %}

#### If You Want To Manually Start And Stop Postgres

If you don't want Postgres to run all the time, you can start and stop it as you need it, with these commands:

{% terminal %}
$ pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
{% endterminal %}


$ pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
server starting

$ pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log status
pg_ctl: server is running (PID: 1933)
/usr/local/Cellar/postgresql/9.3.4/bin/postgres "-D" "/usr/local/var/postgres"

$ pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log stop
waiting for server to shut down.... done
server stopped
{% endterminal %}

If you prefer to do this, you might consider making a shell script to automate these.

#### Verifying Install and Permissions

Let's create a database and connect to it:

{% terminal %}
$ createdb sample_db
$ psql sample_db
{% endterminal %}

You should see the following (note: use `\q` to exit):

{% terminal %}
$ psql sample_db
psql (9.3.3)
Type "help" for help.

sample_db=# \q
{% endterminal %}

If you got that, then Postgres is good to go.

## Linux

If Mac OS isn't a possibility, then your next best bet is Linux. Among distributions, Ubuntu has the best support for Ruby and Rails development.

Check out our tutorial for [setting up a Vagrant/Linux virtual machine]({% page_url vagrant_setup %}). Just skip the bits about Vagrant, all the other Linux-centric setup is the same.

## Windows

Getting started on the Windows platform is actually very easy. Engine Yard (<http://engineyard.com>) has put together the RailsInstaller (<http://railsinstaller.org/>), a single package installer with all the tools you need to get working. Make sure that, during the setup, you check the box to configure your environment variables. You can stop after step 2, once you've entered your email and name in the DOS prompt.

Beyond initial setup, though, there is going to be pain. As you add in more Gems and other dependencies you'll find that many of them utilize _native extensions_, code written in C for better performance. Unless the authors have put energy into being cross-platform, you'll run into issues.

Instead, we recommend using VirtualBox and Vagrant to run a Linux virtual machine within your Windows host operating system.

Check out our [Vagrant Setup]({% page_url vagrant_setup %}) tutorial for a full walk-through.
