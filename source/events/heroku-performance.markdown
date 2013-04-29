---
layout: page
title: Heroku Performance Workshop
---

On the evening of May 1st, Heroku and Jumpstart Lab invite you to join us for our Heroku Performance Workshop.

## Registration

The event will take place in-person at RailsConf right in the Oregon Convention Center. If you're not at RailsConf you can join us on the live stream!

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

### Improving Queries

### Using Caching

## Performance Workshop

During this session you need to put the ideas we've discussed into practice.

### Getting Started

* Clone the repository
* Load sample data
* Run the performance suite

{% terminal %}
$ git clone http://todo
$ bundle
$ [TODO: Load from pg_dump data]
$ rake performance
{% endterminal %}

If you're unable to load the dumped database or want to use another database system, you may do so then use the `rake db:seed` task to generate the data. But, be warned, the generation will take over 10 minutes.

## Sponsors

### Prize Sponsors

![Code Climate](/images/code-climate-logo.jpg)

Code Climate provides continuous code inspection for your Ruby app, letting you fix quality and security issues before they hit production. 

After each Git push, Code Climate analyzes your code to identify changes in quality and surface technical debt hotspots. Urgent notifications are sent immediately via Campfire chat, email or RSS so you can address potential quality issues as soon as they occur.

