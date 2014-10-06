---
layout: page
title: Ruby & Rails Development Environment with Vagrant
sidebar: false
---

## Goals

A development-ready environment includes the following tools:

* Ruby Version Manager (RVM)
* Ruby 1.9.3 and 2.1
* Git
* PostgreSQL 9+
* SublimeText Editor
* VirtualBox
* Vagrant
* Ubuntu Linux

## Setup Process

The entire setup process should take less than three hours.

### VirtualBox

VirtualBox is an application for running virtual machines. It's free and available for every major platform. You can [learn more about it](https://www.virtualbox.org/), or jump straight to the download page here:

https://www.virtualbox.org/wiki/Downloads

Look under "VirtualBox platform packages" for the binary distribution appropriate for your platform. Run the installer and follow the instructions.

### Vagrant

Vagrant is a system for easily managing and interactive with VirtualBox-based virtual machines. Using vagrant we can do everything from the command line and rarely if ever need to open the actual VirtualBox application. You can [learn more on the Vagrant website](http://vagrantup.com).

First, download the appropriate binary (matching your primary OS) from http://www.vagrantup.com/downloads.html and run the installer. The later steps here are based on the [Vagrant Getting Started Guide](http://docs.vagrantup.com/v2/getting-started/).

#### Setting Up Ubuntu

The easiest way to get going is to use an Ubuntu image preconfigured and vetted by the Vagrant project team. Drop into a terminal and **change to a directory** where you'll build your project (such a `~/projects/starting_rails` or `C:\projects\starting_rails`) and store the configuration for your virtual machine.

Then, from that directory:

{% terminal %}
$ vagrant init hashicorp/precise32
{% endterminal %}

That'll generate a `Vagrantfile`. Before starting the virtual machine, we want to setup a bridged port so we can later access a web server running in Vagrant from our host operating system.

Open that `Vagrantfile` in a text editor and uncomment/modify line 22 so it looks like this:

```
config.vm.network "forwarded_port", guest: 3000, host: 3000
```

Save the file and close your editor. Return to the terminal and start the VM:

{% terminal %}
$ vagrant up
{% endterminal %}

When you run `up` it'll try and boot that image, see that it's not available on the local system, then fetch an image of Ubuntu 12.04 "Precise Pangolin". Once downloaded and setup, it'll be started.

Other operating system "boxes" can be found at https://vagrantcloud.com/discover/featured and you can build your own.

#### Entering the Virtual Machine

You can now SSH into the running virtual machine:

{% terminal %}
$ vagrant ssh
{% endterminal %}

You're now inside the fully-functioning operating system.

#### Synched Folders

You can share files seamlessly between your host operating system and your virtual machine. This is useful if, for instance, you'd like to use a graphical editor in the host operating system, but run the code inside the VM.

The folder that you used to store the vagrant configuration is automatically shared with the virtual machine. So...

* Say you're working in the directory `~/projects/starting_rails`
* It currently contains the config file `~/projects/starting_rails/Vagrantfile`
* You can create a file `~/projects/starting_rails/README.md` using your host OS and any editor
* Within the VM's SSH session, you can interact with that file, like `cat /vagrant/README.md`

Check out http://docs.vagrantup.com/v2/synced-folders/ for more complex folder synching, but this setup will be good enough for now.

#### Local Editor

Because of the transparent folder sharing you have two options for editing code:

1. SSH into your virtual machine and use a text-based editor like Vim or Emacs
2. Run a graphical editor in the host operating system

If you go with option (2), we recommend [downloading SublimeText](http://www.sublimetext.com/) which is available for OS X, Windows, and Linux. It's quite popular in the Ruby community.

### Git

You'll of course need Git for source control. Install it within the SSH session:

{% terminal %}
$ sudo apt-get update
$ sudo apt-get install git
{% endterminal %}

And respond `y` to the prompt. You might notice that the `sudo` didn't ask for a password. Your Vagrant VM is setup to "trust" you. No one can login to the VM unless they're an authenticated user of your host operating system, so this is safe.

### PostgreSQL

#### Locale

Postgres uses information from the operating system to determine the language and encoding of databases. Let's set that default locale before install postgres :

{% terminal %}
$ sudo /usr/sbin/update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
{% endterminal %}

#### PostgreSQL installation

PostgreSQL is the database of choice in the Ruby community. Let's get it installed with apt:

{% terminal %}
$ sudo apt-get install postgresql libpq-dev
{% endterminal %}


#### Creating the Database Instance & Adding a User

Once installed, we need to create the database instance. Within the SSH session:

{% terminal %}
$ sudo mkdir -p /usr/local/pgsql/data
$ sudo chown postgres:postgres /usr/local/pgsql/data
$ sudo su postgres
$ /usr/lib/postgresql/9.1/bin/initdb -D /usr/local/pgsql/data
$ createuser vagrant
{% endterminal %}

Respond "Y" to `Shall the new role be a superuser?` Then you can exit the `su` subshell:

{% terminal %}
$ exit
{% endterminal %}

Now you're back to your Vagrant user session.

#### Add privilege for Vagrant to create database.

vagrant@vagrant-ubuntu-trusty-64:~$ psql  postgres
psql (9.3.5)
Type "help" for help.

postgres=> ALTER ROLE vagrant  CREATEDB;
postgres-> \q
vagrant@vagrant-ubuntu-trusty-64:~$

#### Verifying Install and Permissions

You should now be back to the normal `vagrant@precise32:~$` prompt. Let's create a database and connect to it:

{% terminal %}
$ createdb sample_db
$ psql sample_db
{% endterminal %}

You should see the following:

{% terminal %}
$ psql sample_db
psql (9.1.12)
Type "help" for help.

sample_db=# \q
{% endterminal %}

### RVM

There are several options for managing Ruby versions, but we'll use RVM with the standard "single user" method.

#### Initial Setup

From your SSH session, we first need to install the `curl` tool for fetching files, then can use a script provided by the RVM team for easy setup:

{% terminal %}
$ sudo apt-get install curl
$ \curl -sSL https://get.rvm.io | bash
{% endterminal %}

As it says in the post-install instructions, we need to load RVM into the current environment by running:

{% terminal %}
$ source /home/vagrant/.rvm/scripts/rvm
{% endterminal %}

Note that there will be no output from this command, but you can now see RVM:

{% terminal %}
$ which rvm
/home/vagrant/.rvm/bin/rvm
{% endterminal %}

#### Requirements

The RVM tool has an awesome tool for installing all the various compilers and packages you'll need to build Ruby and common libraries. Run it like this:

{% terminal %}
$ rvm requirements
{% endterminal %}

#### Ruby 1.9.3 and 2.1

You can see all the Rubies available through RVM with this command:

{% terminal %}
$ rvm list known
{% endterminal %}

Then install both Ruby 1.9.3 and 2.1:

{% terminal %}
$ rvm install 1.9.3
$ rvm install 2.1
{% endterminal %}

It'll take awhile to compile.

#### Default Ruby

You can set either as your default Ruby. For 2.1, run this:

{% terminal %}
$ rvm use 2.1 --default
{% endterminal %}

And verify it:

{% terminal %}
$ which ruby
/home/vagrant/.rvm/rubies/ruby-2.1.1/bin/ruby
$ ruby -v
ruby 2.1.1p76 (2014-02-24 revision 45161) [i686-linux]
{% endterminal %}

#### Bundler

Just about every project now uses Bundler, so let's install it:

{% terminal %}
$ gem install bundler
{% endterminal %}

#### JavaScript Runtime

Rails' Asset Pipeline needs a JavaScript runtime. There are several options, but let's install NodeJS:

{% terminal %}
$ sudo apt-get install nodejs
{% endterminal %}

## Verification

Let's clone and run a sample Rails application to make sure everything is setup correctly.

### Clone the Project

Within the SSH session:

{% terminal %}
$ cd /vagrant
$ git clone https://github.com/JumpstartLab/platform_validator.git
$ cd platform_validator
{% endterminal %}

### Rails Setup

Next we need to install dependencies and setup the database:

{% terminal %}
$ bundle
$ rake db:create db:migrate db:seed
{% endterminal %}

### Rails Console

Check that the console is working properly:

{% terminal %}
$ rails console
2.1.1 :001 > Person.count
   (0.3ms)  SELECT COUNT(*) FROM "people"
 => 6
2.1.1 :002 > Person.all
  Person Load (0.6ms)  SELECT "people".* FROM "people"
{% endterminal %}

### Run the Server

{% terminal %}
$ rails server
=> Booting Thin
=> Rails 4.0.4 application starting in development on http://0.0.0.0:3000
=> Run `rails server -h` for more startup options
=> Ctrl-C to shutdown server
Thin web server (v1.6.2 codename Doc Brown)
Maximum connections set to 1024
Listening on 0.0.0.0:3000, CTRL+C to stop
{% endterminal %}

Then, in your host operating system, open http://localhost:3000 in a browser. You should see the *Welcome abord* page -- you're done!

## Cloning

Once you've got a VM ready to go, you might want to back it up or copy it to other computers.

### Creating the Image

Start within the same folder as the `Vagrantfile` and:

{% terminal %}
$ vagrant package
{% endterminal %}

It'll shutdown the VM if it's running, then export a movable image named `package.box` which is about 650mb.

Move the file by any normal means (SCP, flash drive, network share, etc).

### Setup the Second Machine

Now on the machine where you want to run the VM you'll need to install VirtualBox and Vagrant using the same steps as above.

### Setup the Box

In a terminal from the same directory where the `package.box` file is, run the following:

{% terminal %}
$ vagrant box add package.box --name rails_box
{% endterminal %}

That will "download" the box file to the local Vagrant install's set of known boxes.

### Provision and Start the Box

Now move to the project directory where the `Vagrantfile` and your application code will live. Then:

{% terminal %}
$ vagrant init rails_box
$ vagrant up
{% endterminal %}

It'll clone the box then boot. Now you can `vagrant ssh` and you're ready to go!
