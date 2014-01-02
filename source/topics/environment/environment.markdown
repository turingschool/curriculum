---
layout: page
title: Environment Setup
section: Environment & Source Control
alias: [ /environment.html, /setup ]
---

Setting up your environment can be difficult when you're first starting with Ruby. We want to get the following installed:

* Git
* Ruby 2.0 and Ruby 1.9.3
* A text editor

The setup instructions are broken down by the following platforms: Mac; Linux; and Windows.

## Mac OS

Mac OS is the most popular platform for Ruby and Rails developers. To have a properly setup dev machine you want the following:

### XCode Command Line Tools

#### OS X 10.7.x (Lion) or OS X 10.8.x (Mountain Lion)

Installing ruby on Mac OS requires the Command Line Tools that XCode gives you
access to.

##### If you have XCode installed

* Open XCode and go to Preferences > Downloads > Install Command Line Tools.

##### If you don't have XCode installed

* [Create or Register](https://developer.apple.com/programs/register/) an Apple ID.
  Register with the same Apple ID you use for other Apple services, such as
  iTunes, iCloud, and the Apple Online Store.
* [Login](http://developer.apple.com/downloads/index.action) to the Apple
  Developer Portal.
* In the pane on the right, look for "command line tools" and choose the
* package appropriate to your version of OS X.
	** Mac OS X 10.7.x - Lion
	** Mac OS X 10.8.x - Mountain Lion
* Download this package
* When the download completes, you'll have a .dmg file. Double-click this
  file.
* Then double-click the .mpkg file that appears
* A dialog pops up. Accept the Terms.
* Accept the default install location (probably Macintosh HD) by clicking
  "install" or "continue"
* You'll be asked to enter your password, which is the password you use to log
  in to your account on the computer.
* When it has completed the installation, click "close".

You're good to go. You won't have to go looking for the program that got
installed, it's just going to be used by other things you'll be installing
later.

### Homebrew

[Homebrew](http://brew.sh) is a package management system that makes it easy to install hundreds of open source projects and compile them from source for maximum performance on your machine.

Install Homebrew.

* Open the Terminal.app program.
  You can search for it using Spotlight, or find it in
  Applications > Utilities > Terminal.app
* Go to [brew.sh](http://brew.sh/) and scroll until you see the heading
  "Install Homebrew"
* Paste the installation command into you terminal, and hit enter.
  It will tell you what it's going to do.
* Hit enter again to continue the installation process.
* It will ask you for your password.
  This is the password to log in to your account on the computer.

When it has completed the installation type "brew doctor" (without the
quotation marks) and it should tell you that everything is fine:

{% terminal %}
$ brew doctor
Your system is ready to brew.
{% endterminal %}

### GCC

You're going to need a C compiler in order to install Ruby. We can use
homebrew to get the official Apple gcc program that is distributed with XCode.

First we need to tell brew to add some extra formulae:

{% terminal %}
$ brew tap homebrew/dupes
{% endterminal %}

When that completes, type:

{% terminal %}
brew install apple-gcc42
{% endterminal %}

### Git

[Git](http://git-scm.com/) is the version control system of choice in the Ruby community.

The XCode command line tools installed git on your system, but at the time of
writing this tutorial, it installs an old version of git, 1.7.4.

Figure out where on your system git lives:

{% terminal %}
which git
{% endterminal %}

Most likely, this will say `/usr/bin/git`.

Find out which version of git is installed:

{% terminal %}
git --version
{% endterminal %}

If that says something about 1.7.x, then you'll want to install a newer
version:

{% terminal %}
$ brew install git
==> Downloading http://git-core.googlecode.com/files/git-1.8.3.4.tar.gz
########################################################### 100.0%
{% endterminal %}

Check the version and the location of the program again:

{% terminal %}
which git
git --version
{% endterminal %}

It will probably say exactly the same thing as it did before we installed git
using brew.

##### What happened?

Your computer has something called a PATH, which is basically a big list of
places that it will look for programs on your computer. For example, it might
have a list like this (except much longer):

* `/usr/bin`
* `/usr/local/bin`
* `~/bin`

When you type a command in the terminal, the computer goes to the first place,
`/usr/bin` and looks for a program with the name you typed. If it finds it,
fine, it will go ahead and run that program. If not, it will move to the next
location in the list and try again.

Right now, `/usr/bin` is before `/usr/local/bin` in your PATH, and Apple's
version (which is installed under `/usr/bin` is taking precedence over the one
we just installed (which is installed under `/usr/local/bin`.

We need to switch the order so the computer looks in `/usr/local/bin` first.

Go to your terminal and paste in the following (hit enter to run the command):

{% terminal %}
$ echo 'export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"' >> ~/.bash_profile
{% endterminal %}

##### What does all that mean?

`echo` is a command that just repeats whatever comes after it. For example:

{% terminal %}
$ echo "Hello, World!"
Hello, World!
{% endterminal %}

The `>>` means _append the output of the previous thing to the file that comes
after this_.

Here we're appending to `~/.bash_profile` which is a file that contains
configuration for your terminal. Every time you open a new terminal window,
that file gets read so that your terminal behaves the way you want it to.

##### Moving On

Now that we've changed the `~/.bash_profile` file, we need to update our
terminal session to read the new information. This is called _sourcing_ a
file:

{% terminal %}
source ~/.bash_profile
{% endterminal %}

To make sure that everything is the way you want it, run the `git --version`
and `which git` commands again:

{% terminal %}
which git
{% endterminal %}

{% terminal %}
git --version
{% endterminal %}

### [RVM](http://rvm.io)

RVM allows you to install and maintain multiple versions of Ruby.

More information about Ruby Version Mananger (RVM) can be found at [http://rvm.io](http://rvm.io)

To figure out if you have rvm installed, type the following in Terminal:

{% terminal %}
rvm --version
{% endterminal %}

It will either give you a version number, or an error message

#### If You Got a Version Number

You have RVM installed, and you just need to make sure you have a recent
version:

{% terminal %}
rvm get stable
{% endterminal %}

#### If You Got an Error Message

You probably got something that looked like this:

{% terminal %}
-bash: rvm: command not found
{% endterminal %}

You need to install rvm

{% terminal %}
$ \curl -L https://get.rvm.io | bash -s stable
{% endterminal %}

Look for the line in the output from the RVM installation that starts with

{% terminal %}
To start using RVM you need to run `source ...`
{% endterminal %}

Copy the command inside of the backticks (don't include the backticks), paste it into your terminal window, and hit enter.

Check if it got installed correctly by checking the version again.

{% terminal %}
rvm --version
{% endterminal %}

It should now give you a version number rather than an error message.

### Ruby

We're going to install two versions of Ruby: 2.0.0, which is the latest stable
release, and 1.9.3, which is the version that is most widely used.

To list all of the possible ruby versions that you can install, use the command:

{% terminal %}
rvm list known
{% endterminal %}

The output will be pretty long. Look at the very first section of the output,
which will look something like this:

{% terminal %}
# MRI Rubies
[ruby-]1.8.6[-p420]
[ruby-]1.8.7[-p374]
[ruby-]1.9.1[-p431]
[ruby-]1.9.2[-p320]
[ruby-]1.9.3[-p448]
[ruby-]2.0.0-p195
[ruby-]2.0.0[-p247]
[ruby-]2.0.0-head
ruby-head
{% endterminal %}

#### Ruby 2.0

We recommend getting the latest stable version of Ruby, which is version 2.0.

NOTE: rvm install 2.0.0-p247 looks like the latest stable patch version at the moment. It might depend on `brew install openssl`.

NOTE: All the square brackets denote things that are optional. In other words, if
you type `rvm install ruby-2.0.0-p247`, it is the same as typing `rvm install
2.0.0`. However, if you wanted to install a lower patch-level, like `-p195`,
then you would have to specify it explicitly, with `rvm install 2.0.0-p195`.

Go ahead and install version 2.0.0 -- it will probably take a while.

{% terminal %}
$ rvm install 2.0.0
{% endterminal %}

#### Ruby 1.9.3

We're also going to need 1.9.3.

The latest stable version of Ruby 1.9.3 at the moment is patch-level 448.

{% terminal %}
$ rvm install 1.9.3
{% endterminal %}

This will probably take a while.

#### Setting the Default Version

You can tell rvm which version you want to use by default, by typing:

{% terminal %}
rvm use --default 2.0.0
{% endterminal %}

If you want to switch to another version of ruby, type:

{% terminal %}
rvm use 1.9.3
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

<div class="opinion">
<p>If there is any way to avoid using Windows for your development environment, do it. For a free alternative, consider setting up a virtual machine with <a href="http://www.virtualbox.org">Virtual Box</a> and <a href="http://www.ubuntu.com/download/ubuntu/download">Ubuntu Linux</a>.</p>
</div>

### Text Editor

If you don't already have a favorite text editor, we recommend using [Sublime Text 2](http://www.sublimetext.com/2).

