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

* Create a migration that creates a ```PayloadRequest``` table that has a column for each of the attributes.

Now that we have a database table for the ```PayloadRequest``` we start with our model.

Let's create a new file within our model directory - `payload_request.rb`. Don't forget to inherit from `ActiveRecord::Base`. The start of the file should look something like this:

```ruby
class PayloadRequest < ActiveRecord::Base

end

```

If we didn't inherit from active record base we wouldn't get a the nice query methods and database interaction methods that are o so nice.

Now that we have a PayloadRequest model started, finish it off by creating validations for the PayloadRequest attributes.

* All the attributes must be present in the request.

You can use ActiveRecord's [validations feature](http://guides.rubyonrails.org/active_record_validations.html).


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
* List of URLs listed form most requested to least requested
* Web browser breakdown across all requests(userAgent)
* OS breakdown across all requests(userAgent)
* Screen Resolutions across all requests (resolutionWidth x resolutionHeight)


Our clients also find it valuable to have stats on specific URLs. For a specific URL, let's find the following Stats:

* Max Response time
* Min Response time
* A list of response times across all requests listed from longest response time to shortest response time.
* Average Response time for this URL
* HTTP Verb(s) associated used to it this URL
* Three most popular referrers
* Three most popular user agents

### Iteration 3

Now that we've set up a basic app that can store data from a client, let's expand the features so we can accept PayloadRequests from multiple clients.

We already have a ```PayloadRequest``` model and database table, and we know that a ```PayloadRequest``` will belong to a ```Client```, and a ```Client``` will have many ```PayloadRequests```. That means we need to figure out a way to store ```Client``` data and somehow relate that to our ```PayloadRequest``` data.

A Client has two attributes, an ```identifier```, and a ```rootUrl```.

Create 2 migrations:
* Create the ```Client``` table with the respective attributes
* Create a migration to add a reference to the ```Client``` on the ```PayloadRequest``` table. This migration will establish the one-to-many relationship that ```PayloadRequest```s and ```Client```s have.

Now that we have a place to store out client data, make sure you go into the models and establish the relationships between ```PayloadRequest```, and ```Client```, and you set up appropriate validations for the ```Client```.

### Iteration 4

Now let's get into the nitty gritty that is the internet. Currently our app works by feeding it data directly, but that's not how we plan for it to be used in the real world. We want our app to be accessible via the internet.

First, let's have clients register their application by submitting a post request to the following address:

```
http://yourapplication:port/sources
```
The parameter that we will require a client to pass will be:

* identifier
* rootUrl

We can send a request with this specific information via the Terminal and the ```curl``` command. Check out how to use the ```curl``` command via your Terminal by typing ```man curl```. This will bring up the manual for ```curl```.

We will send a request like this:

```
$ curl -i -d 'identifier=jumpstartlab&rootUrl=http://jumpstartlab.com'  http://localhost:9393/sources
```

Wondering what `-i` and `-d` mean? Check the manual.


A post to ```http://yourapplication:port/sources``` will require one of three possible responses from our application.

* 1. Missing Parameters - 400 Bad Request

If missing any of the required parameters return status `400 Bad Request` with
a descriptive error message.

Wondering how to send back a status code from a Sinatra app? Check out the [Sinatra docs](http://www.sinatrarb.com/intro.html).

* 2. Identifier Already Exists - 403 Forbidden

If that identifier already exists return status `403 Forbidden` with a
descriptive error message.

* 3. Success - 200 OK

When the request contains all the required parameters return status `200 OK`
with the following data for the client:

```
{"identifier":"jumpstartlab"}
```

* identifier - the unique identifier for the application that has been created for the client.

### Iteration 5

After completing iteration 4, we can now register Clients and their applications. However, there is still no way to get their data into our application. Let's change this by adding an endpoint for Clients to post their payload data.

A registered application will send `POST` requests to the following URL:

```
http://yourapplication:port/sources/IDENTIFIER/data
```

IDENTIFIER, in this URL, is the unique identifier for the client.

If you recall from iterations 0 and 1 we've already structured our app to accept payload data. If everything was set up correctly we should need to change much if anything for this to work with the payload being sent over HTTP.

Everything sent of HTTP by nature is a string. That makes JSON structure perfect for sending data over HTTP. We will send our payload request as a parameter called 'payload' which contains the payload as JSON data.

Here is an example of sending a payload to our application:

```
curl -i -d 'payload={"url":"http://jumpstartlab.com/blog","requestedAt":"2013-02-16 21:38:28 -0700","respondedIn":37,"referredBy":"http://jumpstartlab.com","requestType":"GET","parameters":[],"eventName":"socialLogin","userAgent":"Mozilla/5.0 (Macintosh%3B Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17","resolutionWidth":"1920","resolutionHeight":"1280","ip":"63.29.38.211"}' http://localhost:9393/sources/jumpstartlab/data
```

Find the Ruby JSON docs [here](http://www.ruby-doc.org/stdlib-2.0/libdoc/json/rdoc/JSON.html).

Our application should process the request with one of the 4 following outcomes.

* 1. __Missing Payload__ - 400 Bad Request
  * If the payload is missing, return status `400 Bad Request` with a descriptive error message.
* 2. __Already Received Request__ - 403 Forbidden
  * If the request payload has already been received return status `403 Forbidden` with a descriptive error message.
* 3. __Application Not Registered__ - 403 Forbidden
  * When data is submitted to an application URL that does not exist, return a `403 Forbidden` with a descriptive error message.
* 4. __Success__ - 200 OK
  * When the request contains a unique payload return status `200 OK`.

### Iteration 6

Now that we have a site up and a an endpoints for our clients to register their applications and submit payload data for their applications, our client's want a place to go to view the statistic we have generated for their applications.

We'll want and endpoint for a client to see their aggregate site data:

```
http://yourapplication:port/sources/IDENTIFIER
```

When the IDENTIFIER exists and a Client goes to their endpoint they should be able to view statistics for:

* Average Response time across all requests
* Max Response time across all requests
* Min Response time across all requests
* Most frequent request type
* List of all HTTP verbs used
* List of URLs listed form most requested to least requested
* Web browser breakdown across all requests
* OS breakdown across all requests
* Screen Resolutions across all requests (resolutionWidth x resolutionHeight)

When an identifier does not exist return a page that displays the following:

* Message that the identifier does not exist

When an identifier does exist, but no payload data has been submitted for the source.

* Message that no payload data has been received for this source

### Iteration 7

We also have stats we generated that are specific to a Clients URLs. Let's create a view that will show our URL specific stats.

The URL we will create for this will be:

```
http://yourapplication:port/sources/IDENTIFIER/urls/RELATIVEPATH

Examples:

http://yourapplication:port/sources/jumpstartlab/urls/blog
http://yourapplication:port/sources/jumpstartlab/urls/article/1
http://yourapplication:port/sources/jumpstartlab/urls/about
```

First - let's set up our client's specific statistics to have the URLs link to their respective URL specific page.

on the page that is found at this endpoint:

```
http://yourapplication:port/sources/IDENTIFIER
```

make sure you have: Hyperlinks of each url to view url specific data.


If the url for the identifier __DOES__ exist let's display the url specific stats in this view:

* Max Response time
* Min Response time
* A list of response times across all requests listed from longest response time to shortest response time.
* Average Response time for this URL
* HTTP Verb(s) associated used to it this URL
* Three most popular referrers
* Three most popular user agents

If the url for the identifier __DOES NOT__ exist:

* Display a message that the url has not been requested
