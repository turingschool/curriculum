---
layout: page
title: Systems Setup
section: Salesforce Elevate
sidebar: true
---

To get the most out of the workshop you should be working along with us. Before we get going, please go through the following setup steps.

## Accounts

### Heroku Account

You'll of course need a Heroku account. If you don't have one already, head over to https://id.heroku.com/signup and create one.

### Salesforce Developer Account

You probably have a Salesforce developer account already, but if not create one now: https://events.developerforce.com/signup

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

On top of Java, our sample app uses the Play Framework, a great way to build modern web applications in Java or Scala. 

Download the [binary archive version of Play 2.0 here](http://download.playframework.org/releases/play-2.0.zip).

We need this executable to be in your path. On a UNIX platform, like Linux or MacOS, you can get it going by:

* Creating a directory `/usr/local/play`
* Extracting/moving the Play archive into `/usr/local/play/play-2.0`
* Creating an alias to the `play` binary with `ln -s /usr/local/play/play-2.0/play /usr/local/bin`
* Verifying the install by running `play help`

Having downloaded the binary archive to my `~/Downloads` folder, here's the process for MacOS:

{% terminal %}
$ mkdir -p /usr/local/play
$ tar -zxvf ~/Downloads/play-2.0.zip -C /usr/local/play
x play-2.0/
x play-2.0/documentation/
x play-2.0/documentation/api/
...
x play-2.0/repository/local/jaxen/jaxen/1.1.3/jars/jaxen.jar.sha1
x play-2.0/repository/local/jaxen/jaxen/1.1.3/jars/jaxen.jar.md5
x play-2.0/repository/local/jaxen/jaxen/1.1.3/jars/jaxen.jar
$ ln -s /usr/local/play/play-2.0/play /usr/local/bin
$ which play
/usr/local/bin/play
$ play help
       _            _ 
 _ __ | | __ _ _  _| |
| '_ \| |/ _' | || |_|
|  __/|_|\____|\__ (_)
|_|            |__/ 
             
play! 2.0, http://www.playframework.org

...
{% endterminal %}

## Sample Application

We'll be working with a Java application using the Play framework. We're assuming that you've never used Play before -- that's ok!

In your terminal, move to a folder where you want to store the project. Then clone the project from Github:

{% terminal %}
$ git clone https://github.com/JumpstartLab/play_sample
$ cd play_sample
{% endterminal %}

## Verify Functionality

Play applications are very easy to get running locally if Java and Play are in the right places. Try this:

{% terminal %}
$ play
 play
Getting org.scala-tools.sbt sbt_2.9.1 0.11.2 ...
:: retrieving :: org.scala-tools.sbt#boot-app
  confs: [default]
  37 artifacts copied, 0 already retrieved (7324kB/183ms)
[info] Loading project definition from /Users/jcasimir/Dropbox/Projects/play_demo_1/project
[info] Set current project to computer-database-jpa (in build file:/Users/jcasimir/Dropbox/Projects/play_demo_1/)
       _            _ 
 _ __ | | __ _ _  _| |
| '_ \| |/ _' | || |_|
|  __/|_|\____|\__ (_)
|_|            |__/ 
             
play! 2.0, http://www.playframework.org

> Type "help play" or "license" for more information.
> Type "exit" or use Ctrl+D to leave this console.

[computer-database-jpa] $ 
{% endterminal %}

Then you have a console running with the application loaded up. Type `run` and hit enter. It'll prepare more dependencies then output this:

{% terminal %}
--- (Running the application from SBT, auto-reloading is enabled) ---

[info] play - Listening for HTTP on port 9000...

(Server started, use Ctrl+D to stop and go back to the console...)
{% endterminal %}

### In the Browser

Now the application should be running locally. Open your web browser and visit [http://localhost:9000](http://localhost:9000)

#### Running Evolutions

Play applications use "Evolutions" to change the state of the database. You should see a big error page complaining that there are Evolutions which need to be run. Click the `Apply this script now!` button to run them.

#### Working Application

Now you should see the application, which lists 574 historical computers. You're ready to go!
