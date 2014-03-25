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

Heroku's *Cedar* stack allows you a lot of flexibility through the `Procfile`. You can define and name one or more processes that your application should run when deployed.

### A Basic `Procfile`

Typically this starts with a `web` process. For a Ruby app, for instance, you `Procfile` might look like this:

```plain
web: bundle exec thin start -p $PORT -e $RACK_ENV
```

* The `web` part defines the name of the process type
* The part to the right of the `:` is what you'd run from a UNIX terminal to execute the process
* Environment variables can be used (like `$PORT` and `$RACK_ENV` here)

### A Java/Play Example

A `web` process for a Play application is a bit more complicated:

```plain
web: target/start -Dhttp.port=${PORT} ${JAVA_OPTS} -DapplyEvolutions.default=true -Ddb.default.driver=org.postgresql.Driver -Ddb.default.url=${DATABASE_URL}
```

It...

* Uses the name `web`
* Runs the executable `target/start`
* Passes several options from the environment variables (`PORT`, `JAVA_OPTS`, `DATABASE_URL`)
* Automatically runs the database "evolutions" if needed

### Defining Multiple Processes

If you want to run multiple dynos each running the same application, like eight instances of your `web` process, then you're already done.

Commonly, however, you'll want to run multiple different processes. An application, for instance, might want to have 16 dynos running the `web` process to respond to web requests, then four dynos running as background workers sending email or doing other jobs.

You can define multiple process types in the `Procfile`:

```plain
web: bundle exec thin start -p $PORT -e $RACK_ENV
worker: bundle exec rake jobs:work
```

You can makeup whatever process names are germain to your domain. Whatever name you used can be used from the web interface or CLI to scale dynos up and down.

[TODO: Is there a little background worker we could implement in the app and fire up?]

### References

* [Procfile configuration options](http://devcenter.heroku.com/articles/procfile) on Heroku's DevCenter

## Configuration

Web applications typically rely on some pieces of data that either can't or shouldn't be stored in the source code. This might include:

* Resource locations, like the IP address of the database
* Security credentials, like OAuth tokens
* Execution environment markers, like *"production"* and *"development"*

These bits of data can be stored on Heroku and made available as environment variables.

### Querying the Config

All apps start out with a default set of variables. From within a Heroku project's directory on your local system, run `heroku config`. The below example is from a Java Play application with some pieces removed for security:

{% terminal %}
$ heroku config
=== boiling-island-2815 Config Vars
DATABASE_URL:               postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
HEROKU_POSTGRESQL_JADE_URL: postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
JAVA_OPTS:                  -Xmx384m -Xss512k -XX:+UseCompressedOops
PATH:                       .jdk/bin:.sbt_home/bin:/usr/local/bin:/usr/bin:/bin
REPO:                       /app/.sbt_home/.ivy2/cache
SBT_OPTS:                   -Xmx384m -Xss512k -XX:+UseCompressedOops
{% endterminal %}

Note, particularly, the `DATABASE_URL` which is the location of the PostgreSQL database provisioned for this application.

### Adding a Value

Say we now want to store a key named `OAUTH_SHARED_SECRET` on the server. We use `heroku config:add`:

{% terminal %}
$ heroku config:add OAUTH_SHARED_SECRET="helloworld"
Setting config vars and restarting boiling-island-2815... done, v8
OAUTH_SHARED_SECRET: helloworld
{% endterminal %}

Then can query for the defined values again to verify it's there:

{% terminal %}
$ heroku config
=== boiling-island-2815 Config Vars
DATABASE_URL:               postgres://zvxdqpyretrsgk:DNKuFujjxCLKoCV3qQFyH7kz_E@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
HEROKU_POSTGRESQL_JADE_URL: postgres://zvxdqpyretrsgk:DNKuFujjxCLKoCV3qQFyH7kz_E@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
JAVA_OPTS:                  -Xmx384m -Xss512k -XX:+UseCompressedOops
OAUTH_SHARED_SECRET:        helloworld
PATH:                       .jdk/bin:.sbt_home/bin:/usr/local/bin:/usr/bin:/bin
REPO:                       /app/.sbt_home/.ivy2/cache
SBT_OPTS:                   -Xmx384m -Xss512k -XX:+UseCompressedOops
{% endterminal %}

### Accessing Values in Code

Defining those pieces of data is only useful if you can access them from your code.

#### Ruby

In Ruby, accessing environment variables is as easy as accessing the `ENV` constant which references a hash:

{% terminal %}
$ heroku run irb
Running `irb` attached to terminal... up, run.2128
irb(main):001:0> ENV['OAUTH_SHARED_SECRET']
=> "helloworld"
irb(main):002:0> 
{% endterminal %}

#### Java

{% terminal %}
$ heroku run sbt play console
Running `sbt play console` attached to terminal... up, run.2176
Picked up JAVA_TOOL_OPTIONS:  -Djava.rmi.server.useCodebaseOnly=true
Getting org.scala-tools.sbt sbt_2.9.1 0.11.2 ...
...
> System.getenv("OAUTH_SHARED_SECRET")
=> "helloworld"
{% endterminal %}

[TODO: Check that this actually works]

### Considering Security

Environment variables are an appropriate place to store secure credentials, but you must keep in mind who has read access to them. *Any collaborator* on an application can query and set environment variables. If a user can deploy then then can see everything.

If that's a concern, then you can mitigate the issue by reducing deployment access. For instance, you could setup a Continuous Integration server which runs your tests and, if they pass, it deploys the code. The majority of developers wouldn't need access to the Heroku application itself, so there's less risk. 

### References

* [Configuration Variables](http://devcenter.heroku.com/articles/config-vars) on Heroku's DevCenter

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
