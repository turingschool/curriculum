---
layout: page
title: Java + Salesforce + Heroku
section: Salesforce Elevate
sidebar: true
alias: [ /elevate ]
---

## Welcome

### Schedule

* 8:00 - Doors Open & Systems Setup
* 9:00 - Intros & Opening
* 9:10 - How Heroku Works
* 10:00 - Deploying Java Applications to Heroku
* 12:00 - Lunch
* 1:00 - Integrating Salesforce
* 2:30 - Heroku Platform
* 3:30 - Q&A
* 4:00 - Class Ends

### Systems Setup

To get the most out of the workshop you should be working along with us. Before we get going, please go through the following setup steps.

#### Accounts

(Heroku and Salesforce Dev accounts)

#### Git

We'll need Git to handle source control and facilitate pushing code to Heroku. You can find installer packages for any platform at http://git-scm.com/downloads or:

* On Linux, use apt: `sudo apt-get install git-core`
* On MacOS [use Homebrew](http://brew.sh) if it's installed: `brew install git`
* On Windows, [download the installer](http://git-scm.com/download/win)

#### Java

You'll need the JDK installed. For this tutorial we're using JDK 7 available from http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html

#### Play

Follow the instructions on the [Installing Play 2.0 page](http://www.playframework.com/documentation/2.0/Installing)

On a UNIX platform, like Linux or MacOS, you can get it going by:

* Creating a directory `/usr/local/play`
* Extracting/moving the Play archive into `/usr/local/play/play-2.0`
* Creating an alias to the `play` binary with `ln -s /usr/local/play/play-2.0/play /usr/local/bin`
* Verifying the install by running `play -v`

#### Sample Application

We'll be working with a Java application using the Play framework. We're assuming that you've never used Play before, that's ok!

From your terminal, clone the sample project from Github:

{% terminal %}
$ git clone https://github.com/JumpstartLab/play_sample
{% endterminal %}

#### Heroku Toolbelt

Install the Heroku Toolbelt following the instructions here: https://toolbelt.heroku.com/

#### Verify Functionality

( run the application locally and make sure it's ok! )

## How Heroku Works

Heroku is a cloud hosting platform focused on serving developers. Before you can get your application up and running we should discuss how the platform works.

Jump over to the [How Heroku Works]({% page_url how_heroku_works %}) tutorial.

## Deploying Java Applications on Heroku

### Using the Toolbelt

### Creating an Application

### Pushing via Git

### Checking Status

### Updating Your Application

### References

* [Deploying to Heroku](http://www.playframework.com/documentation/2.1.1/ProductionHeroku), Play Framework Documentation
* [Heroku Play Framework Support](https://devcenter.heroku.com/articles/play-support), Heroku DevCenter

## Integrating Salesforce

## Maximizing Heroku's Platform

You've gotten an application up and running, but how do you make sure it stays up and highly responsive?

### Scaling Web Processes

Even with threading, the traffic a single dyno can serve is limited. The easiest way to scale the number of concurrent requests you application can handle is to increase the number of dynos.

#### Through the GUI

Option one is to use the graphical interface on Heroku.com. You should:

* Login to heroku.com
* Click "Apps" in the top link bar
* Click the name of the application you want to manipulate
* Under "Dynos", slide the marker to the right
* Click "Apply Changes" (your account will really be debited by the minute)

#### From the CLI

Scaling through the GUI is cute, but it's not fast and difficult to script. Maybe, for instance, you find that your traffic spikes during certain hours and want to scale up your dynos *just for those hours*. You could write a script to manipulate the dynos from the command line.

Within your project directory you can check on your current dynos:

[TODO: Update with Java app info]

{% terminal %}
$ heroku ps
=== web (1X): `bundle exec puma -p $PORT`
web.1: up 2014/03/20 11:35:09 (~ 10m ago)
{% endterminal %}

From that we know:

* `web (1X)` shows that we're using Heroku's smallest, cheapest dyno type
* `bundle exec puma -p $PORT` is the actual process that is executed on the dyno
* `web.1` tells us that only a single dyno is running

From there you can do everything available in the GUI, such as changing the dyno type:

{% terminal %}
$ heroku ps:resize web=2X
Resizing and restarting the specified dynos... done
web dynos now 2X ($0.10/dyno-hour)
{% endterminal %}

And changing the number of dynos up to 8:

{% terminal %}
$ heroku ps:scale web=8
Scaling dynos... done, now running web at 8:2X.web dynos now 2X ($0.10/dyno-hour)
{% endterminal %}

And checking the results with `ps` again:

{% terminal %}
$ heroku ps
=== web (2X): `bundle exec puma -p $PORT`
web.1: up 2014/03/20 11:50:59 (~ 1m ago)
web.2: up 2014/03/20 11:51:45 (~ 38s ago)
web.3: up 2014/03/20 11:51:44 (~ 39s ago)
web.4: up 2014/03/20 11:51:45 (~ 38s ago)
web.5: up 2014/03/20 11:51:46 (~ 38s ago)
web.6: up 2014/03/20 11:51:45 (~ 39s ago)
web.7: up 2014/03/20 11:51:45 (~ 39s ago)
web.8: up 2014/03/20 11:51:47 (~ 37s ago)
{% endterminal %}

Now your dynos are twice as powerful and there are eight times as many of them! Get back to the free settings with:

{% terminal %}
$ heroku ps:resize web=1X
Resizing and restarting the specified dynos... done
web dynos now 1X ($0.05/dyno-hour)
$ heroku ps:scale web=1
web dynos now 1X ($0.05/dyno-hour)
$ heroku ps
=== web (1X): `bundle exec puma -p $PORT`
web.1: up 2014/03/20 11:55:08 (~ 57s ago)
{% endterminal %}

### Using the `Procfile`

### Running Background Processes

### Migrating Databases

### Collaborators and Other Configuration

### Understanding Add-Ons

### Measuring Application Performance

## Next Steps
