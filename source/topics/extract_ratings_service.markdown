---
layout: page
title: Extract Ratings Service
sidebar: true
---

This tutorial blah blah blah assumes finished Extract Notifications Service (link). It's open source, please pull request and all that.

Extracting the email into a service was relatively easy. Really, it wasn't much different than the way many apps implement background workers.

Now, let's look at a more complex architecture that, rather than just "doing" an action, is used to read and write domain data.

## Introduction

Each product in the store has multiple ratings. This functionality is perfect for extraction to a service because:

* it has relatively self-contained data. The only external data dependencies are a product ID and a user ID
* it doesn't have side effects / shared functionality with other parts of the application
* it's easy to reason about as a unit of functionality

## Validating Functionality

The existing ratings do not have unit tests or controller tests. There are some feature specs, but they're incomplete.

### Using Capybara

In `spec/features/user_rates_products_spec.rb` add tests to cover the functionality.

We need:

GET /account/ratings

-[ ] a unique list of products ordered
-[ ] if they've rated it: show rating
-[ ] else link to add rating
-[x] create a rating
-[x] update
-[x] create fails (incorrect params)
-[x] edit fails (incorrect params)
-[ ] edit fails (window of opportunity closed)

Also, we need a test for displaying the ratings on the products page.
`spec/features/public_user_views_products_spec.rb`

GET /products/:id
-[ ] view all the ratings for a product

### Ignoring Bugs

The current implementation has a number of issues, but we'll just ignore them.

## Reading Ratings

The easier part of the story is reading ratings from the service.

### Where Ratings (Currently) Come From

* Controller queries the model
* Model queries the database

### Loosening the Coupling

#### Hiding data that will go away

When the ratings move into the remote service, it will not make sense to expose the primary key of the database. Users should only ever have a single rating for a given product, so we can use the combination of user id and product id to access the ratings.

In order to make this possible, we'll refactor the primary app so it doesn't rely on the rating id.

* add hidden fields to the form
* change the routes for edit/update to use the user_id
* change the dom id for the raty stars thing.
  if we're showing all the user's ratings, use the product id,
  if we're showing all the product's ratings, use the user id

#### Introducing a simple rating proxy

* a simple ruby class that will be a local stand-in for the rating object

#### Introducing an Adapter

* an adapter that will talk to the remote service

But first, use it to talk to the database

### Creating a Ratings Application

#### Wiring together the stand-alone application

Wire together test and lib directories
Wire up activerecord
Implement rollback for tests
Wire up sinatra lib/api.rb
 - handle not_found
 - handle 500 errors
Create config/environment file
Add single API endpoint
* GET    api/v1/users/:id/ratings
Set content type to json
Delete wiring tests
Use Petroglyph (no id, created_at->rated_at)

### Consuming the JSON in the primary app

But... does it work? We don't have any data in the stand-alone app

#### Adding a POST endpoint

#### Using VCR to Mock Tests

#### Writing a migration script

Duplicate the seeds from the primary app to the secondary app using the POST endpoint.

* POST   api/v1/products/:id/ratings

### Writing Ratings from the Adapter

#### Creating ratings

Save both places.

#### Editing ratings

* GET    api/v1/products/:id/ratings/:user_id
* PUT    api/v1/products/:id/ratings/:user_id

Save both places.

### Displaying all ratings for a product

* GET    api/v1/products/:id/ratings

#### We won't delete them, but it's usually good to support the full complement of RESTful endpoints.

* DELETE api/v1/products/:id/ratings/:user_id

### Stop writing to the local ratings

### Delete obsolete data

### Protecting user's data

Implement shared secret, protect write endpoints

## Asyncronous Writes

The system we've built so far is distributed but it's still synchronous. Given that there's some latency when the primary app calls out to the ratings app, we've actually slowed down our application.

### Deleting obsolete code

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

