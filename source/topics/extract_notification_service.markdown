---
layout: page
title: Extract Notification Service
sidebar: true
---

## Dependencies

Install redis:

{% terminal %}
$ brew install redis
{% endterminal %}

Install the redis gem:

{% terminal %}
$ gem install redis
{% endterminal %}

Clone the [store_demo repository](https://github.com/jumpstartlab/store_demo).

### Background

Tight coupling: controllers communicate with mailers by sending objects.

### Test Coverage

Run the tests to check that they're passing. Then deliberately change something in the controllers where the Mailers are triggered. Rerun the tests. What fails?

We need better tests.

We'll use `mailcatcher`.

`gem install mailcatcher` # do not put in gemfile

```ruby
# confi/environments/development.rb
# confi/environments/test.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = { :address => "127.0.0.1", :port => 1025 }
```

Unfortunately, ActionMailer overrides the delivery_method inside the tests, so we need to override the override. Add this as the first line of both the mailer specs:

```ruby
ActionMailer::Base.delivery_method = :smtp
```

Then delete the expectation. We'll be checking these semi-manually.

Run the tests, open [mailcatcher](http://localhost:1080), eyeball the tests.

### End-to-End Email Test

Which controller actions send emails?

Are these tested in the controller tests? How about the feature tests?

Deal with one call to a mailer at a time:

* `raise "something"` before the `Mailer.something().deliver` in the controller
* run the controller specs
* if nothing fails, run the feature specs

If we can test the integration at the controller level, that's preferable, since those tests are faster.

Make sure that at least one test is sending email to mailcatcher for each of the calls to the mailers.

Clear mailcatcher, and run the full test suite one time.
Count how many emails end up in mailcatcher.

### Refactor the Mailers

The welcome mailer currently takes a user object.

* What information does it actually need?

Change the spec to send a hash with just that information.
Change the welcome mailer to work with that information.
Change the controller to pass the correct information to the mailer.

Now do the same for the order confirmation email.

Make sure both the mailer tests and the controller tests send the right emails to mailcatcher.

### Configure Redis

Include the `redis` gem in the Gemfile, and bundle install.

Create a directory `config/redis`. We'll add two configuration files:

```plain
# config/redis/development.conf
daemonize yes
port 6382
logfile ./log/redis_development.log
dbfilename ./db/development.rdb
```

```plain
# config/redis/test.conf
daemonize yes
port 6383
logfile ./log/redis_test.log
dbfilename ./db/test.rdb
```

We need to get Rails to start redis. Create an init file in `config/initializers/redis.rb`:

```ruby
file = File.join("config", "redis", "#{Rails.env}.conf")
path = Rails.root.join(file)
config = File.read(path)

`redis-server #{path}`

running = `ps aux | grep [r]edis-server.*#{file}`

if running.empty?
  raise "Could not start redis"
end

port = config[/port.(\d+)/, 1]
$redis = Redis.new(:port => port)
```

0. Add semi-automated end-to-end testing with mailcatcher
0. add redis to the primary app
0. shunt existing notifications through redis
0. build the separate ruby service (pony, cron job)
0. make it consume the redis events, write to a log
0. trigger actual notification in service, comment out in primary app
0. delete obsolete code in primary app

## Jeff's Outline

### Introduction

#### Goals

#### The Monsterporium

* Description of the project, what it has, what it does, etc

#### Where Email Notifications Come From

* Showing what process(es) in the app generate emails

#### High-Level Overview of Where We're Going

* Whiteboard-level description of how it'll work when we're done.

### Characterizing Functionality

* Writing a semi-auto test harness to check that emails are actually sent.

### Pushing Logic Down the Stack

* Get the mailer logic down to the model level
* Pull that code out to a class in LIB
* Call that Lib code from the model
* Validate that it still works

### Working with the Pub/Sub Channel

* Integrate Redis into the app
* When an email needs to be sent, send a message to Redis
* Leave the existing functionality in place
* Implement Mailcatcher to see the email
* Show that the message, since we weren't subscribed yet, is gone
* Start a simple listener in IRB or Rails Console that just prints out the message

### Implementing a Listener

( Not sure where Pony fits in )

#### Creating the File

#### Subscribing to the Channel

#### Dumping Messages to a Log File

#### Running with `rails runner`

* If necessary -- or is it just with `ruby`?

#### Sending the Email

#### Validating Functionality

### Removing Code from the Primary App

#### Encapsulating the Message Posting

* Create a class that does the actual message publishing to Redis

#### Deactivating and Removing the Delivery Code

#### Validating Functionality