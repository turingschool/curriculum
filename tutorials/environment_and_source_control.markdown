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
2. Add these lines to your `~/.bash_profile`
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
    [[ -r $rvm_path/scripts/completion ]] && . $rvm_path/scripts/completion
3. Re-process your profile
    source ~/.bash_profile
    
Validate RVM is installed by running `rvm info` and you should see lots of information about your environment.    

### Setup Global Gems

You can setup RVM to add certain gems to all versions of Ruby and all gemsets. Use restraint here, but I believe all Ruby apps should use Bundler (http://gembundler.com/) for dependency management. Create a file `~/.rvm/gemsets/global.gems` and just add this line:

    bundler
    
Bundler will now be setup for new Rubies and added to new gemsets.
    
### Installing Rubies

Once you have access to the RVM system you're ready to install Ruby. To see what versions of Ruby are available you can run `rvm list known` in a terminal.

For these tutorials we'll be using Ruby 1.9.2, install it with the following commands. Note that *$* is my terminal prompt:

    $ rvm install 1.9.2
    
Then tell RVM to make it our default Ruby:

    $ rvm use 1.9.2 --default
    
Test it by displaying the Ruby version and you should see something like this:

    $ ruby -v
    ruby 1.9.2p136 (2010-12-25 revision 30365) [x86_64-darwin10.7.0]

When you're using RVM you don't need to do anything special, just run `ruby` and `gem` like normal. One thing to note, though: RVM installs Ruby into the user space, so you *do not need to use sudo, ever.*

## Bundler

The Ruby ecosystem has tens of thousands of Gem libraries we can utilize in our programs. A typical Rails application might rely on fifty libraries. In the days of Rails 2 managing these dependencies was a real challenge, especially when coordinating multiple machines and developers.

The Bundler system (http://gembundler.com/) makes most of that challenge go away. In our project we create a `Gemfile` which specifies our dependencies and gem source. Using that file, Bundler can resolve the complex interactions of library dependencies and install/utilize gems as needed.

### A Basic Gemfile

A very simple Gemfile might look like this:

```ruby
source :rubygems
gem 'rails'
gem 'rake'
```

From a terminal in the project directory we can process this Gemfile and setup the dependencies with one command:

```bash
bundle
```

Bundler will attempt to utilize gems already installed on the system to meet the dependencies, and if any additional are needed they'll be fetched from RubyGems (http://rubygems.org/).

### Versioning Dependencies

Most Ruby libraries move fast, some move incredibly slowly. While there are established Version Policies (http://docs.rubygems.org/read/chapter/7) for RubyGems, their implemention is spotty at best. Using the above Gemfile, our application would today pull down Rails version 3.0.8 and Rake 0.9.0. 

Six months from now, though, it might pull down Rails version 3.2.0. Will that break our application? Probably. So we should lock our gems down to specific versions. Adding exact versions to my above Gemfile would look like this:

```ruby
source :rubygems
gem 'rails', '3.0.8'
gem 'rake', '0.9.0'
```

#### Flexible Versioning

But what about bug and security fixes? I can build against Rails 3.0.8, but if a security issue is found they'll release a 3.0.9. The third number is called the "patch level", and when it increments it is supposed to be completely backwards compatible. 3.0.9 should introduce no issues for an app built agains 3.0.8. This rule generally holds true.

But patch levels are released every few weeks. This can make keeping the Gemfile up to date a real pain. We can add some flexibility to our dependencies with the "squiggle-rocket" operator:

```ruby
source :rubygems
gem 'rails', '~>3.0.8'
gem 'rake', '~>0.9.0'
```

Now Bundler will use Rails version 3.0.8, 3.0.9, or any later patch level (3.0.*). It will *not*, however, use 3.1.0. This is usually the ideal behavior. Upgrading the "minor" version, from 3.0 to 3.1, is likely to necessitate changes in your application.

#### Managing Edge Code

Often you'll be developing a gem while you're developing an application that uses it. Or, sometimes you'll need to use the absolute bleeding edge code for a Gem before it's released on RubyGems. In that case, Bundler can resolve dependencies directly from Git or GitHub:

```ruby
source :rubygems
gem 'rails', :git => "https://github.com/rails/rails.git"
gem 'rake', '~>0.9.0'
```

Building an application using git-based dependencies is *an extremely bad idea* unless you control the repository. Unless you have a lot of time to waste and enjoy frustration, never build against edge rails as I've shown here.

## Development and Release Strategy with Git

The Git Version Control System has taken over most of the Ruby world. Simply put, if you're going to develop with Ruby you have to learn Git.

### Getting Started

A full Git tutorial is beyond scope here, but there are many great resources out there already:

* ProGit by Scott Chacon available free online: http://progit.org/book/
* Help.GitHub: http://help.github.com/
* PeepCode's Git Video: http://peepcode.com/products/git

### Managing Development and Releases

Beyond the tool itself, you need a strategy for managing a Git repository. In general:

* Do not develop any code on the `master` branch, only merge in other branches
* Start a branch for every feature
* Merge and prune branches when the feature is done
* Do not check in code unless the tests are passing

While those guidelines can get you started, you should consider a robust release management process outlined in extensive detail here: http://nvie.com/posts/a-successful-git-branching-model/

If that sounds appealing, then you can run the process using GitFlow (https://github.com/nvie/gitflow/). There is a great introduction tutorial to using GitFlow put together by Dave Bock at CodeSherpas here: http://codesherpas.com/screencasts/on_the_path_gitflow.mov

### GitHub

Git is great, but GitHub is totally amazing. If there is any way for you to use GitHub, do it. If you're developing open source, then the free public repositories are fine. If you need some privacy, individual and organization accounts provide private repositories for a few dollars a month. And if you need more comprehensive security, consider GitHub:FI (http://fi.github.com/) which you can run on your server inside your firewall. 

GitHub supports code review, collaboration, and organization tools that are completely game changing.

## Heroku Setup