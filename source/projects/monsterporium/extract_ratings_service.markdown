---
layout: page
title: Extract Ratings Service
sidebar: true
---

Extracting the email into a service was relatively easy. Really, it wasn't much different than the way many apps implement background workers.

Now, let's look at a more complex architecture that rather than just "doing" an action, is used to read and write domain data.

### Introduction

Each product in the application has multiple ratings. This functionality is perfect for extraction to a service because:

* it has relatively self-contained data. The only external data dependencies are a product ID and a user ID
* it doesn't have side effects / shared functionality with other parts of the application
* it's easy to reason about as a unit of functionality

### Validating Functionality

#### Using Capybara 

#### Using VCR to Mock Tests

### Reading Ratings

The easier part of the story is reading ratings from the service.

#### Where Ratings (Currently) Come From

#### Pushing Logic Down to the Model

#### Substituting a PORO Proxy Model

* Write a simple PORO, called from the controller, that just gets data from the ActiveRecord model

#### Creating a Ratings Application

#### Connecting to the Same Database

#### Pulling Ratings from the DB

#### Delivering JSON from the Service with  Petroglyph

#### Fetching JSON from the Primary App

#### Working JSON into Domain Objects

#### Removing the AR-Model from the Proxy Object

#### Validating That It Works!

### Writing Ratings

#### Using the Proxy to Write to ActiveRecord

#### Implementing Writing in the Service

#### Sending Proxy Data to the Service

#### Verify That It Works!

### Un-Sharing the Database

#### Creating a Database for the Service

#### Reconfiguring the Service

#### Verify That It Works!

### Asyncronous Writes

#### Add a Message from the Proxy

#### Read the Message from the Service

* Write a script that subscribes to the channel

#### "Double Write" the Rating

* Write a rating when it comes in.
* Still write it through the direct proxy access

#### Remove Direct Writing from Proxy

#### Verify that it works!

### Asyncronous Reading Through JavaScript

* Testing at the JS-powered level with Poltergeist
* Accessing data on the server
* Manipulating the DOM
* Masking Latency
