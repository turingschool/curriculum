---
layout: page
title: Extract Ratings Service
sidebar: true
---

Extracting the email into a service was relatively easy. Really, it wasn't much different than the way many apps implement background workers.

Now, let's look at a more complex architecture that, rather than just "doing" an action, is used to read and write domain data.

## Introduction

Each product in the store has multiple ratings. This functionality is perfect for extraction to a service because:

* it has relatively self-contained data. The only external data dependencies are a product ID and a user ID
* it doesn't have side effects / shared functionality with other parts of the application
* it's easy to reason about as a unit of functionality

## Validating Functionality

### Using Capybara 

### Using VCR to Mock Tests

## Reading Ratings

The easier part of the story is reading ratings from the service.

### Where Ratings (Currently) Come From

* Controller queries the model
* Model queries the database

### Pushing Logic Down to the Model

* Anything interesting from the controller that needs to get moved down?

### Substituting a PORO Proxy Model

* Write a simple PORO, called from the controller, that gets data from the ActiveRecord model

### Creating a Ratings Application

### Connecting to the Same Database

* Checking if they use Postgres so this is easy.

### Pulling Ratings from the DB

### Delivering JSON from the Service with Petroglyph

### Fetching JSON from the Primary App

### Working JSON into Domain Objects

### Removing the AR-Model from the Proxy Object

### Validating That It Works!

## Writing Ratings

### Using the Proxy to Write to ActiveRecord

### Implementing Writing in the Service

### Sending Proxy Data to the Service

### Verify That It Works!

## Un-Sharing the Database

### Creating a Database for the Service

### Reconfiguring the Service

### Verify That It Works!

## Asyncronous Writes

The system we've built so far is distributed but it's still synchronous. Given that there's some latency when the primary app calls out to the ratings app, we've actually slowed down our application.

### Use the Proxy to Create a Rating

* Pass the params down from the controller
* Turn the params into JSON and push onto the message queue

### Read the Message from the Service

* Write a script that subscribes to the channel

### "Double Write" the Rating

* Write a rating when it comes in.
* Still write it through the direct proxy access

### Remove Direct Writing from Proxy

### Verify that it works!

### Dealing with Validation

* Run some validation within the proxy object to check the Rating params.

## Asyncronous Reading Through JavaScript

### Implementing JavaScript-Executing Specs with Poltergeist

* How to install and setup Poltergeist with Capybara

### Duplicating Ratings

* Fetch the ratings from the server via JavaScript
* Insert them into the DOM so there are two whole sets of the ratings

### Remove Non-JavaScript Fetched Ratings

### Dealing with Latency

* Will the test fail because the JavaScript hasn't finished executing yet?
* Capybara will keep looking for 2 seconds, long enough for the JavaScript to complete: https://github.com/jnicklas/capybara#asynchronous-javascript-ajax-and-friends