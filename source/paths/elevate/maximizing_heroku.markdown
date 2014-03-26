---
layout: page
title: Maximizing Heroku
section: Salesforce Elevate
sidebar: true
---

[TODO: Copyedit, Read-through from Schneems?]

You've gotten an application up and running, but how do you make sure it stays up and highly responsive?

## Scaling Web Processes

Even with threading, the traffic a single dyno can serve is limited. The easiest way to scale the number of concurrent requests your application can handle is to increase the number of dynos.

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

{% terminal %}
$  heroku ps
=== web (1X): `target/start -Dhttp.port=${PORT} ${JAVA_OPTS} -DapplyEvolutions.default=true -Ddb.default.driver=org.postgresql.Driver -Ddb.default.url=${DATABASE_URL}`
web.1: up 2014/03/24 19:53:41 (~ 25m ago)
{% endterminal %}

From that we know:

* `web (1X)` shows that we're using Heroku's smallest, cheapest dyno type
* `target/start` is the actual process that is executed on the dyno
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
=== web (2X): `target/start -Dhttp.port=${PORT} ${JAVA_OPTS} -DapplyEvolutions.default=true -Ddb.default.driver=org.postgresql.Driver -Ddb.default.url=${DATABASE_URL}`
web.1: up 2014/03/20 11:50:59 (~ 1m ago)
web.2: up 2014/03/20 11:51:45 (~ 38s ago)
web.3: up 2014/03/20 11:51:44 (~ 39s ago)
web.4: up 2014/03/20 11:51:45 (~ 38s ago)
web.5: up 2014/03/20 11:51:46 (~ 38s ago)
web.6: up 2014/03/20 11:51:45 (~ 39s ago)
web.7: up 2014/03/20 11:51:45 (~ 39s ago)
web.8: up 2014/03/20 11:51:47 (~ 37s ago)
{% endterminal %}

Now your dynos are twice as powerful, and there are eight times as many of them! Get back to the free settings with:

{% terminal %}
$ heroku ps:resize web=1X
Resizing and restarting the specified dynos... done
web dynos now 1X ($0.05/dyno-hour)
$ heroku ps:scale web=1
web dynos now 1X ($0.05/dyno-hour)
$ heroku ps
=== web (1X): `target/start -Dhttp.port=${PORT} ${JAVA_OPTS} -DapplyEvolutions.default=true -Ddb.default.driver=org.postgresql.Driver -Ddb.default.url=${DATABASE_URL}`
web.1: up 2014/03/20 11:55:08 (~ 57s ago)
{% endterminal %}

## Using the `Procfile`

Heroku's *Cedar* stack allows you a lot of flexibility through the `Procfile`. You can define and name one or more processes that your application should run when deployed.

### A Basic `Procfile`

Typically this starts with a `web` process. For a Ruby app, for instance, your `Procfile` might look like this:

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

You can makeup whatever process names are germane to your domain. Whatever name you used can be used from the web interface or CLI to scale dynos up and down.

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

Then we can query for the defined values again to verify it's there:

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

In Ruby, accessing environment variables is as easy as accessing the `ENV` constant, which references a hash:

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
scala> System.getenv("OAUTH_SHARED_SECRET")
res0: java.lang.String = helloworld
{% endterminal %}

### Considering Security

Environment variables are an appropriate place to store secure credentials, but you must keep in mind who has read access to them. *Any collaborator* on an application can query and set environment variables. If a user can deploy then they can see everything.

If that's a concern, then you can mitigate the issue by reducing deployment access. For instance, you could setup a Continuous Integration server which runs your tests and, if they pass, it deploys the code. The majority of developers wouldn't need access to the Heroku application itself, so there's less risk. 

### References

* [Configuration Variables](http://devcenter.heroku.com/articles/config-vars) on Heroku's DevCenter

## Installing an Add-on / Upgrading Your Database

One of Heroku's great strengths is the rich library of add-ons. There are dozen of options available at https://addons.heroku.com/ , giving you everything from data storage to video processing. Many of them can be installed/setup with little or no change to your application code.

Heroku offers [many different data storage options](https://addons.heroku.com/#data-stores), but most applications are centered around PostgreSQL. Let's look at how to upgrade to a production-tier Postgres instance using the add-ons system.

### PostgreSQL Levels

The basic PostgreSQL instance is good enough for development and to get your application running, but it is not very high performance *and* it only allows 10,000 total rows of data.

At the other end of the scale, you can spend $6,000/month on an instance with 68gb of dedicated RAM and support for a terrabyte of data. You can [see all the options in between here](https://addons.heroku.com/heroku-postgresql).

### Replacement vs Migration

Let's look at how to upgrade an application from the "Hobby Dev" to "Standard Yanari", the bottom level that Heroku considers "production scale."

There are different procedures for replacing the database with a new one versus migrating the existing data to a new instance. Let's look at the easier of the two, full replacement.

### Checking the Before-State

Before we start changing things around, let's look at the existing application configurations `DATABASE_URL` and `HEROKU_POSTGRESQL` keys:

{% terminal %}
heroku config
=== boiling-island-2815 Config Vars
DATABASE_URL:               postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
HEROKU_POSTGRESQL_JADE_URL: postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
{% endterminal %}

When we add a new database that `JADE` URL will stick around. This allows us to connect to the old database, in this case a free instance, if we wanted to access old data.

If, however, the old database were a paid plan, we'd keep getting charged until it's deprovisioned.

### Provisioning 

To add the new database instance we just need a single instruction:

{% terminal %}
$ heroku addons:add heroku-postgresql:standard-yanari
Adding heroku-postgresql:standard-yanari on boiling-island-2815... done, v9 ($50/mo)
Attached as HEROKU_POSTGRESQL_ROSE_URL
The database should be available in 3-5 minutes.
 ! The database will be empty. If upgrading, you can transfer
 ! data from another database with pgbackups:restore.
Use `heroku pg:wait` to track status.
Use `heroku addons:docs heroku-postgresql` to view documentation.
{% endterminal %}

As instructed, you can run `heroku pg:wait` which will hang until the new instance is ready.

{% terminal %}
$ heroku pg:wait
Waiting for database HEROKU_POSTGRESQL_ROSE_URL... available
{% endterminal %}

Now you're ready to actually use it.

### Configuring

Your application, either through the `Procfile` or code itself, should be relying on the `DATABASE_URL` environment variable. Therefore, using this database should be as easy as:

* Change the `DATABASE_URL` variable to the newly provisioned instance
* Restart the application
* Run any data migrations / evolutions

#### Change the `DATABASE_URL`

If you run `heroku config` again, you'll see the new database location defined:

{% terminal %}
$ heroku config
=== boiling-island-2815 Config Vars
DATABASE_URL:               postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
HEROKU_POSTGRESQL_JADE_URL: postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
HEROKU_POSTGRESQL_ROSE_URL: postgres://username:password@ec2-54-83-63-243.compute-1.amazonaws.com:5542/d4bibagdniev3f
{% endterminal %}

Then `unset` the `DATABASE_URL`...

{% terminal %}
$ heroku config:unset DATABASE_URL
Unsetting DATABASE_URL and restarting boiling-island-2815... done, v10
{% endterminal %}

And set it using the value of `HEROKU_POSTGRESQL_ROSE_URL` from above:

{% terminal %}
$ heroku config:set DATABASE_URL=postgres://username:password@ec2-54-83-63-243.compute-1.amazonaws.com:5542/d4bibagdniev3f
Setting config vars and restarting boiling-island-2815... done, v11
DATABASE_URL: postgres://username:password@ec2-54-83-63-243.compute-1.amazonaws.com:5542/d4bibagdniev3f
{% endterminal %}

#### Migrating / Evolving

At this point you've got a blank database. If you're deploying a Rails application, you'd want to run your migrations:

{% terminal %}
$ heroku run bundle exec rake db:migrate
{% endterminal %}

If you're running a Play application with auto-apply evolutions enabled, then they'll be run on the first request.

### Deprovisioning

**Please carefully think through what you're doing before following these instructions.** If you deprovision a database on Heroku you cannot get the data back.

That production-quality instance we just added upped our bill by $50/month. That far exceed the budget of a little sample application. Let's undo it:

* Change the `DATABASE_URL` back to the free instance
* Remove the Yanari instance

It's the reverse of what we did before:

{% terminal %}
$ heroku config:unset DATABASE_URL
$ heroku config:set DATABASE_URL=postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
$ heroku addons:remove heroku-postgresql:standard-yanari
{% endterminal %}

Where the URL in step two was our original `HEROKU_POSTGRESQL_JADE_URL`. 

The addon removal will ask you for a confirmation. **Consider** that a person who has access to your application could similarly *drop the production database*.

### References

* [Choosing the Right Heroku PostgreSQL Plan](https://devcenter.heroku.com/articles/heroku-postgres-plans#hobby-tier)
* [Creating and Managing Postgres Follower Database](https://devcenter.heroku.com/articles/heroku-postgres-follower-databases)

## Setting Up Custom Domains

Heroku's haiku-inspired generated URLs like *"boiling island"* are cute, but most of the time you'll want to use a custom domain you've purchased elsewhere. 

### Adding a Domain Name

Add the domain names like this:

{% terminal %}
$ heroku domains:add www.example.com
$ heroku domains:add example.com
{% endterminal %}

Note that, yes, you need both if you want both http://example.com and http://www.example.com to resolve to your application.

### DNS Configuration

Your DNS settings are likely controlled by the registrar you used to purchase the domain (like http://dnsimple.com or http://namecheap.com). You've configured Heroku to **listen** for requests to those domains, but you need to configure the DNS server to **send** the traffic to Heroku in the first place.

The exact settings and process will vary per registrar, but essentially you want to create a CNAME record pointing to your application's `herokuapp` URL, like `boiling-island-2815.herokuapp.com`.

### References

* [Custom Domains](https://devcenter.heroku.com/articles/custom-domains) on Heroku's DevCenter
