---
layout: page
title: Maximizing Heroku
section: Salesforce Elevate
sidebar: true
---

You've gotten an application up and running, but how do you make sure it stays up and highly responsive?

## Scaling Web Processes

Even with threading, the traffic a single dyno can serve is limited. The easiest way to scale the number of concurrent requests you application can handle is to increase the number of dynos.

### Through the GUI

Option one is to use the graphical interface on Heroku.com. You should:

* Login to heroku.com
* Click "Apps" in the top link bar
* Click the name of the application you want to manipulate
* Under "Dynos", slide the marker to the right
* Click "Apply Changes" (your account will really be debited by the minute)

### From the CLI

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

## Using the `Procfile`

## Running Background Processes

## Migrating Databases

## Collaborators and Other Configuration

## Understanding Add-Ons

## Measuring Application Performance
