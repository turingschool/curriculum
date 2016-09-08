title: Measuring Application Performance
output: measuring_application_performance.html
controls: true
theme: JumpstartLab/cleaver-theme

--

# Measuring Performance

You want to make sure you application runs well and delivers a great experience for you users. One of the best choices for monitoring an application running on Heroku is NewRelic.

--

## Introduction

To get that data to NewRelic you:

* Install the add-on
* Download and install their monitor package into your application
* Setup your unique account key
* Re-deploy your application

--

### Install the Addon

NewRelic has several plan types depending on your needs, but we'll use the free *Stark* plan. From your project directory:

```
$ heroku addons:add newrelic:stark
```
--

Then, as it suggests, you can open the Dev Center documentation about NewRelic:

```
$ heroku addons:docs newrelic
```
--

### Install the Monitor

NewRelic offers monitor packages for Java, Ruby, Python, Node.js, and Clojure.

Detailed instructions to install the agent can be found [in the Dev Center](https://Dev Center.heroku.com/articles/newrelic#java-configuration).

--

We've already included the agent in the sample application, which involved:

* Downloading the latest Java agent version from http://download.newrelic.com/newrelic/java-agent/newrelic-agent/
* Extracting it into the project directory

--

#### Load the Monitor

For Java applications we can load the monitor when the application starts by modifying the `JAVA_OPTS` environment variable.

--

Remember that you can list out your existing environment variables with `heroku config`:

```
$ heroku config
=== boiling-island-2815 Config Vars
NEW_RELIC_LICENSE_KEY: a57d802cdb7891d33bc7bc5eeeff6af94c67b020
NEW_RELIC_LOG:         stdout
DATABASE_URL:               postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
HEROKU_POSTGRESQL_JADE_URL: postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
JAVA_OPTS:                  -Xmx384m -Xss512k -XX:+UseCompressedOops
PATH:                       .jdk/bin:.sbt_home/bin:/usr/local/bin:/usr/bin:/bin
REPO:                       /app/.sbt_home/.ivy2/cache
SBT_OPTS:                   -Xmx384m -Xss512k -XX:+UseCompressedOops
```

--

We need to add `-javaagent:newrelic/newrelic.jar` to the end of JAVA_OPTS like this:

```
$ heroku config:add JAVA_OPTS='-Xmx384m -Xss512k -XX:+UseCompressedOops -javaagent:newrelic/newrelic.jar'
```
Now when our dyno restarts it'll load the monitor.

--

### Restarting Manually

If you had added the monitor yourself, you'd want to commit to Git and push to Heroku.

But since the files were already in place for the sample app, we can just force a restart to pickup the new environment variables:

```
$ heroku restart
```
--

### Generate Data

Run `heroku open` to open your production application in your browser. Click around through a few different screens to generate a bit of data.

--

### View Results in NewRelic

You can view NewRelic from within your Heroku dashboard:

* Visit https://dashboard.heroku.com/apps
* Click your application
* Under the *Add-ons* heading, click `New Relic`
* You'll be taken to the NewRelic interface and automatically logged in

--

There you should see the data from the last few minutes of your production activity.

In the future, you could also run the following from your command line: `heroku addons:open newrelic`

--

## What You've Learned

* Heroku's add-on system makes it easy to install third-party tools like NewRelic
* NewRelic can be used to monitor the health of your application
