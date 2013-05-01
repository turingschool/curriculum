---
layout: page
title: Heroku Performance Workshop
---

## Registration

### In Person

If you're able to join us in person, please register at https://tito.io/jumpstart-lab/heroku-performance-workshop-railsconf-2013

### Live Stream

If you're joining us remotely we would appreciate you signing up here:

<form action="http://jumpstartlab.us1.list-manage.com/subscribe/post?u=8080b7a05247f0dee13a0a26f&amp;id=54a4b169a2" method="post" id="mc-embedded-subscribe-form" name="mc-embedded-subscribe-form" class="validate" target="_blank">
  <div class="mc-field-group">
    <input type="text" value="" name="EMAIL" class="required email" id="mce-EMAIL" title="Your Email Address" placeholder="Your email address">
    <input type="submit" value="Subscribe" name="Subscribe" id="mc-embedded-subscribe" />
  </div>
  <div id="mce-responses">
    <div class="response" id="mce-error-response" style="display:none"></div>
    <div class="response" id="mce-success-response" style="display:none"></div>
  </div>
</form>

We promise not to spam you up, but would like to be able to send you a follow-up after the session.

The actual URL for the live stream will be added here once it's available.

## Instructional Program

### Introduction (start-end)

Terence Lee and Jeff Casimir will give a quick introduction to the evening.

### Understanding the Heroku Platform

* How a request is served on Heroku
* What is a "dyno"?
* Why concurrent requests matter
* Ceder & Webbrick
* Understanding a Procfile
* Writing and deploying a Procfile

### Improving Queries

* You develop with insufficient data
* Query problems don't stand out
* Two key problems
  * Search Speed
  * N+1 Queries
* Search Speed
  * Full-table reads are slow
  * Primary keys, like `id`, are the main lookup mechanism
  * The database creates an index on the primary key automatically
  * But if you use `find_by_(X)` you need an index
  * If you use `where`, you need an index
  * Creating an index
  * Creating a compound index
* Solutions for N+1
  * There's no solution for N+1
  * Memory Cache
  * Counter Cache
  * Using `.includes`

### Using Caching

* Why caching works
* Understanding a key-value store
* Caching fragments
* Caching composed fragments
* The expiry problem
* Ignore rather than expire
* The implementation bits

## Performance Workshop

During this session you need to put the ideas we've discussed into practice.

### Getting Started

* Clone the repository
* Load sample data
* Run the performance suite

{% terminal %}
$ git clone https://github.com/jumpstartlab/store_demo
$ bundle
{% endterminal %}

Then follow the notes and instructions in the `README.markdown` to finish setup.

### Running the Tests

First, run the functional tests to make sure everything is working properly on your system:

{% terminal %}
$ bundle exec rake
{% endterminal %}

Then run the performance suite:

{% terminal %}
$ bundle exec rake performance:local
{% endterminal %}

The tests should pass and result in a total runtime number at the end.

### Improving the App

Let's see what we can do to implement the techniques discussed to drive that total suite time down.

### Measuring Results

The suite should, at first, take about [TODO: Start runtime].  

Then see if you can get the total time under:

* Bronze: [TODO: Bronze runtime]
* Silver: [TODO: Silver runtime]
* Gold: [TODO: Gold runtime]

## Sponsors

### Prize Sponsors

![Code Climate](/images/code-climate-logo.jpg)

Code Climate provides continuous code inspection for your Ruby app, letting you fix quality and security issues before they hit production. 

After each Git push, Code Climate analyzes your code to identify changes in quality and surface technical debt hotspots. Urgent notifications are sent immediately via Campfire chat, email or RSS so you can address potential quality issues as soon as they occur.

