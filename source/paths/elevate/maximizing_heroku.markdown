---
layout: page
title: Maximizing Heroku
section: Salesforce Elevate
sidebar: true
---

[TODO: Copyediting]
[TODO: Read-through from Schneems?]

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

[TODO: More details about what happens in a Procfile]

Heroku's Celadon Cedar stack affords much more flexibility about what kinds of processes can be run on Heroku. A typical
web app configuration using `delayed_job` and `thin` is below:

```bash
worker: bundle exec rake jobs:work
web: bundle exec thin start -p $PORT -e $RACK_ENV
```

Read more about Procfile configuration [here](http://devcenter.heroku.com/articles/procfile).

### Running Background/Worker Processes

[TODO: Explain how background processes work and effect billing]
[TODO: Is there a little background worker we could implement in the app and fire up?]

For performance reasons, most web applications end up offloading work to worker processes that operate asynchronously, outside the context of a web request. This usually involves setting up a queueing system such as [delayed_job](http://devcenter.heroku.com/articles/delayed-job]) or [Resque](https://github.com/defunkt/resque). 

delayed_job is the more documented, simpler approach since you can use your existing relational database. Follow [Heroku's setup instructions](http://devcenter.heroku.com/articles/delayed-job) to get this running.

Note that if you are creating an app using Heroku's Cedar stack, you will need to add a worker process to the app's [Procfile](http://devcenter.heroku.com/articles/procfile), described below.

## Configuration

[TODO: Explain how the systems configuration can be used, manipulated, why it should be used for secure credentials]

As your app grows it will need various pieces of configuration data to run. Some of this data will be too sensitive or change too frequently for you to be able to store it in source control. Heroku allows you to store configuration variables so that your app can configure itself in production mode. 

All apps start out with a default set of variables, which you can view with the command `heroku config`. Pay special attention to `RACK_ENV` (which determines the environment your app boots into) and `DATABASE_URL` which points at your app's database.

Read more about [Heroku configuration variables](http://devcenter.heroku.com/articles/config-vars).

## Setting Up Custom Domains

You can run your app for free at a [custom domain](http://devcenter.heroku.com/articles/custom-domains) name by running:

{% terminal %}
$ heroku addons:add custom_domains:basic
{% endterminal %}

Add the domain names like this:

{% terminal %}
$ heroku domains:add www.example.com
$ heroku domains:add example.com
{% endterminal %}

You must configure a CNAME for your domains to point to Heroku in order for this to work, as explained in detail in the [Heroku Custom Domains](http://devcenter.heroku.com/articles/custom-domains) documentation.

## Using Cron

[TODO: Review/copyedit CRON segment]

Heroku will run short-duration daily and hourly batch jobs for you using the [Cron add-on](http://addons.heroku.com/cron). 

You need to add a rake task named "cron" to your app in `lib/tasks/cron.rake`. 

```ruby
desc "run cron jobs"
task cron: :environment do
  if Time.now.hour % 3 == 0
    puts "do something every three hours"
  end

  if Time.now.hour == 0
    puts "do something at midnight"
  end
end
```

<div class="opinion">
<p>The most modular, easily-testable way to manage recurring tasks like this is to create a separate Cron task as described by Nick
Quaranto in <a href="http://robots.thoughtbot.com/post/7271137884/testing-cron-on-heroku">Testing Cron on Heroku</a>.</p>
</div>

With this task in place, just setup the add-on:

{% terminal %}
# daily cron is free
$ heroku addons:add cron:daily

# hourly cron costs $3/month
$ heroku addons:add cron:hourly
{% endterminal %}

## Migrating Databases

[TODO: Explain how databases are migrated up to higher tiers]

## Understanding Add-Ons

[TODO: Intro about add-ons and why they're so cool]

### Measuring Application Performance

[TODO: Install NewRelic, gather some data, observe it]
