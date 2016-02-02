---
layout: page
title: TrafficSpy
---

## Abstract

In this project you'll use Ruby, Sinatra, and ActiveRecord to build a web traffic tracking and analysis tool.

Your application will receive data over HTTP from a simulation engine. The simulator will construct and transmit HTTP requests which include tracking data.

Imagine that I run a commercial website and embed JavaScript code which gets activated each time a page is viewed on my site. That JavaScript captures information about the visitor and the page they're viewing then, in the background, submits that data to *your* TrafficSpy application.

Your application parses and stores that data.

Later, I visit your site and can view data about my traffic through a HTML interface.

## Learning Goals

* Understand how web traffic works
* Dig into HTTP concepts including headers, referrers, and payload
* Design a normalized SQL-based database structure
* Use ActiveRecord to interface with the database from Ruby
* Practice fundamental database storage and retrieval
* Understand and practice HTTP verbs including GET, PUT, and POST
* Practice using fundamental HTML and CSS to create a usable web interface

## Getting Started

### Clone the Project

1. One team member forks the skeleton repository at [https://github.com/turingschool-examples/traffic-spy-skeleton](https://github.com/turingschool-examples/traffic-spy-skeleton)
2. Add the other team members as collaborators

### Requirements

The project must use:

* [Sinatra](http://www.sinatrarb.com/)
* [PostgreSQL](http://www.postgresql.org/)
* [ActiveRecord](http://guides.rubyonrails.org/active_record_basics.html)

You'll want to set up the [DatabaseCleaner](https://github.com/DatabaseCleaner/database_cleaner) gem in order to have a clean database each time you run tests. Follow the instructions for setting up the gem. Due to a bug in the most recent version of the gem, you'll need to use this line when you set the strategy in your test helper file:

```ruby
  DatabaseCleaner.strategy = :truncation, {except: %w[public.schema_migrations]}
```

Want to read more about the bug? Click [here](https://github.com/DatabaseCleaner/database_cleaner/issues/317).

You will also probably want to set up a [rake task to run your tests](http://ruby-doc.org/stdlib-2.0/libdoc/rake/rdoc/Rake/TestTask.html).

See the "Resources" section at the bottom of this page for additional helpful documentation.

Before starting, make sure you have the [Postgres App](http://postgresapp.com/) installed.

### Restrictions

The project may not use:

* `Rails`

## Base Expectations:

### Iteration 0

The core idea behind TrafficSpy is that your application will store and analyze data from a clients website about visitors to their site. For iteration 0 let's begin by storing some of that data, and for now we'll assume our TrafficSpy application is analyzing data for only one client.

To store data with ActiveRecord/Postresql we need to create migrations and a model for a particular resource. In this example we have a PayloadRequest resource, so we need a ```PayloadRequest``` model, and a migration that will create a ```PayloadRequest``` table with the necessary attributes.

Our payload looks like this:

```
payload = {
  "url":"http://jumpstartlab.com/blog",
  "requestedAt":"2013-02-16 21:38:28 -0700",
  "respondedIn":37,
  "referredBy":"http://jumpstartlab.com",
  "requestType":"GET",
  "parameters":[],
  "eventName": "socialLogin",
  "userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
  "resolutionWidth":"1920",
  "resolutionHeight":"1280",
  "ip":"63.29.38.211"
}
```

Currently, our client only cares about some of the information within the payload. They want to track data about the ```url```, ```requestedAt```, ```respondedIn```, ```referredBy```, and ```requestType```.

* Create a migration that creates a ```PayloadRequest``` table that has a column for each of the previously mentioned attributes.

Now that we have a database table for the ```PayloadRequest``` we start with our model.

Let's create a new file within our model directory - `payload_request.rb`. Don't forget to inherit from `ActiveRecord::Base`. The start of the file should look something like this:

```ruby
class PayloadRequest < ActiveRecord::Base

end

```

If we didn't inherit from active record base we wouldn't get a the nice query methods and database interaction methods that are o so nice.

Now that we have a PayloadRequest model started, finish it off by creating validations for the PayloadRequest attributes.

* All the attributes must be present in the request.

### Iteration 1

Now that we have our basic database design in place, we can see that it isn't quite normalized. Our ```PayloadRequest``` violates normal form. Extract the data necessary to normalize the database so far. Do this by creating migrations, models and establishing appropriate relationships between models.

### Iteration 2

Our database design is looking better. Now, let's start to manipulate some of that data we're storing.

We want to analyze the ```PayloadRequests``` for the following stats:

* Average Response time for our clients app across all requests
* Max Response time across all requests
* Min Response time across all requests
* Most frequent request type
* List of all HTTP verbs used
* Most popular URL
* Least popular URL

### Iteration 3

Now that we've set up a basic app that can store data from a client, let's expand the features so we can accept PayloadRequests from multiple clients.

We already have a ```PayloadRequest``` model and database table, and we know that a ```PayloadRequest``` will belong to a ```Client```, and a ```Client``` will have many ```PayloadRequests```. That means we need to figure out a way to store ```Client``` data and somehow relate that to our ```PayloadRequest``` data.

A Client has two attributes, an ```identifier```, and a ```rootUrl```.

Create 2 migrations:
* Create the ```Client``` table with the respective attributes
* Create a migration to add a reference to the ```Client``` on the ```PayloadRequest``` table. This migration will establish the one-to-many relationship that ```PayloadRequest```s and ```Client```s have.

Now that we have a place to store out client data, make sure you go into the models and establish the relationships between ```PayloadRequest```, and ```Client```, and you set up appropriate validations for the ```Client```.
