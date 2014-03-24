---
layout: page
title: Systems Setup
section: Salesforce Elevate
sidebar: true
---

To get the most out of the workshop you should be working along with us. Before we get going, please go through the following setup steps.

## Accounts

### Heroku Account

You'll of course need a Heroku account. If you don't have one already, head over to http://heroku.com and click "Sign Up" [TODO: What does the button actually say?]

### Salesforce Developer Account

You probably have a Salesforce developer account already, but if not...

[TODO: Steps to register for SFDC account]

## Heroku Toolbelt

Install the Heroku Toolbelt following the instructions here: https://toolbelt.heroku.com/

## Git

We'll need Git to handle source control and facilitate pushing code to Heroku. You can find installer packages for any platform at http://git-scm.com/downloads or:

* On Linux, use apt: `sudo apt-get install git-core`
* On MacOS [use Homebrew](http://brew.sh) if it's installed: `brew install git`
* On Windows, [download the installer](http://git-scm.com/download/win)

## Java

You'll need the JDK installed. For this tutorial we're **using JDK 7** available from http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html

## Play

On top of Java, our sample app uses the Play Framework, an awesome way to build web applications in Java or Scala. 

Follow the instructions on the [Installing Play 2.0 page](http://www.playframework.com/documentation/2.0/Installing)

On a UNIX platform, like Linux or MacOS, you can get it going by:

* Creating a directory `/usr/local/play`
* Extracting/moving the Play archive into `/usr/local/play/play-2.0`
* Creating an alias to the `play` binary with `ln -s /usr/local/play/play-2.0/play /usr/local/bin`
* Verifying the install by running `play -v`

## Sample Application

We'll be working with a Java application using the Play framework. We're assuming that you've never used Play before -- that's ok!

From your terminal, clone the sample project from Github:

{% terminal %}
$ git clone https://github.com/JumpstartLab/play_sample
{% endterminal %}

The `cd` into that directory.

## Verify Functionality

[TODO: Verify that the sample app is ok since Josh had problems]
[TODO: Write the steps about how to fire up the app, run the evolution, etc]
