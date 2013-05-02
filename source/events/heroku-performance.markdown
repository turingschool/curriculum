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

### Introduction

Terence Lee and Jeff Casimir will give a quick introduction to the evening.

### Understanding the Heroku Platform

* How a request is served on Heroku
* What is a "dyno"?
* Why concurrent requests matter
* Ceder & Webrick
* Understanding a Procfile
* Writing and deploying a Procfile

#### A Standard Procfile

```plain
web: bundle exec rails server -p $PORT
```

#### A Puma Procfile

```plain
web: bundle exec rails server Puma -p $PORT
```

#### Using Foreman Locally

{% terminal %}
$ gem install foreman
$ foreman start
{% endterminal %}

### Improving Queries

* You develop with insufficient data
* Query problems don't stand out
* Two key problems
  * Search Speed
  * N+1 Queries

#### N + 1 Queries

```ruby
article = Article.find(5)
article.comments.count
article.tags
article.tags.each{ |tag| puts tag.articles.count }
```

* There's no global solution for N+1
* Memory Cache
* Counter Cache
* Using `.includes`

```ruby
article = Article.find(5)
article.tags.includes(:articles)
```

#### Query Speed

* Full-table reads are slow
* Primary keys, like `id`, are the main lookup mechanism
* The database creates an index on the primary key automatically
* But if you use `find_by_(X)` you need an index
* If you use `where`, you need an index
* Creating an index
* Creating a compound index

```ruby
class AddIndexes < ActiveRecord::Migration
  def change
    add_index :articles, :published
  end
end
```

#### Code Tutorial

http://tutorials.jumpstartlab.com/topics/performance/queries.html

### Using Caching

* Why caching works
* Understanding a key-value store
* Caching fragments

```
<% cache article do %>
  <%= link_to article.title, article_path(article) %>
  <span class='tag_list'><%= article.tag_list %></span>
<% end %>
```

* The expiry problem
* Ignore rather than expire
* Computing digests

#### Code Tutorial

http://tutorials.jumpstartlab.com/topics/performance/caching.html

## Performance Workshop

During this session you need to put the ideas we've discussed into practice.

### Getting Started

Clone the repository and install dependencies:

{% terminal %}
$ git clone https://github.com/jumpstartlab/store_demo
$ bundle
{% endterminal %}

Then follow the notes and instructions in the `README.markdown` to finish setup including loading the sample database.

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

In addition to Heroku and Jumpstart Lab, we have great prizes from our friends at:

<div style="max-width:300px" >
<img src='http://railscasts.com/assets/railscasts_logo-7101a7cd0a48292a0c07276981855edb.png'/>
</div>

RailsCasts is produced by Ryan Bates (rbates on Twitter and ryanb on GitHub) featuring tips and tricks with Ruby on Rails. The screencasts are short and focus on one technique so you can quickly move on to applying it to your own project. The topics target the intermediate Rails developer, but beginners and experts will get something out of it as well. 

<div style="max-width:300px" >
<img src='/images/code-climate-logo.jpg'/>
</div>

Code Climate provides continuous code inspection for your Ruby app, letting you fix quality and security issues before they hit production. 

After each Git push, Code Climate analyzes your code to identify changes in quality and surface technical debt hotspots. Urgent notifications are sent immediately via Campfire chat, email or RSS so you can address potential quality issues as soon as they occur.
