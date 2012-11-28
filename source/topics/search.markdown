---
layout: page
title: Implementing Search with WebSolr
section: Small Topics
---

The best options for application search engines run on Java. Solr, by the Apache foundation, has emerged as a favorite among the Rails community.

Managing a second application running in a different language and virtual machine can be a headache. WebSolr, http://websolr.com/, emerged as an easy way to outsource the running of your search engine. Though it runs as an external service, it is completely transparent to your user and, generally, transparent to the developer.

Let's look at making use of it from a Rails application.

## Sunspot

The Sunspot gem, http://outoftime.github.com/sunspot/, is the most comprehensive Ruby interface to Solr-powered search engines.

### Install

To install Sunspot and it's dependencies, add `sunspot_rails` to your `Gemfile` and run bundle.

#### `sunspot_solr`

You can *optionally* setup a local Solr instance with an embedded JRuby server by installing the `sunspot_solr` gem. To get the latest beta version, install with this command:

{% terminal %}
$ gem install sunspot_solr -v 1.3.0.rc3 --pre
{% endterminal %}


Then start the server with `sunspot-solr start`.

<div class="note">
  <p>At the time of this writing, I had trouble getting `sunspot_solr` to run correctly.</p>
</div>

#### Local Solr Install

Solr is available as a package in Homebrew for OS X (`brew install solr`) or Ubuntu's apt (`apt-get install solr`).

#### Heroku Setup

To setup your Heroku application to make use of WebSolr, run this command from your project directory:

{% terminal %}
$ heroku addons:add websolr
{% endterminal %}

<div class="note">
  <p>The bottom level WebSolr package is a $20/month add-on.</p>
</div>

### Configuration

There are two options for telling your application and the Sunspot library how to find the Solr server.

#### Environment Variable

Sunspot will look for and use a `WEBSOLR_URL` environment variable in available.

When you use the WebSolr add-on, this is automatically managed for you.

#### Configuration File

If you want to setup the configuration information in the application, generate a config file by running:

{% terminal %}
$ rails generate sunspot_rails:install
{% endterminal %}

That will create a `config/sunspot.yml` where you can set the host and port.

### Indexing

Once you have Solr running and Sunspot setup, you need to tell it how to index your model data.

In the model, call the `searchable` method and pass a block. In the block, we call methods specifying the type and name of attributes to index. For instance:

```ruby
class Article < ActiveRecord::Base
  searchable do
    text    :title
    text    :body
    time    :published_at
  end
end
```

Then Sunspot will index each of these three fields in Solr.

#### Available Methods and Settings

The following indexing methods are available:

* `text`: breaks the data into individual keywords
* `string`: index the data as a single string.
* `time`: datetime fields
* `integer`: numeric fields, especially foreign keys

#### Setting Priorities

If you index multiple fields, like the title and the body here, then it's likely some components are more important that others. 

For instance, you might want to promote matches in the title more highly than matches in the body. You can add the `default_boost` parameter, like this:

```
searchable do
  text :title, default_boost: 2
  text :body
end
```

#### Updating the Index

By default, Sunspot will update the index whenever an object is created, saved, or destroyed. 

This is easy, but in production it can slow your application down because it happens during the request/response cycle. Instead, it'd be better to push the index updating to an asynchronous worker process.

Sunspot has a built in capability to use background workers, triggered by adding calling `handle_asynchronously :solr_index`:

```ruby
class Article < ActiveRecord::Base
  searchable do
    text    :title
    text    :body
  end
  handle_asynchronously :solr_index
end
```

The only catch is that this relies on the Heroku default background job queue: `delayed_job`. If you're using Resque, instead, try the following code written by the author of Sunspot: https://gist.github.com/659188

### Searching

You've setup the server and indexed the data, now you can actually run queries. Use the `search` class method and pass in a block.

A basic search might look like this:

```ruby
search_result = Article.search { keywords 'hello' }
```

The block passed to search can be more specific, too:

```ruby
search_result = Article.search do
  fulltext 'hello world'
  with(:published_at).less_than Time.now
  order_by :published_at, :desc
end
```

There are many more options and techniques that can be used to refine the search results, for information on them check out the Sunspot gem API.

### Search Results

Once you execute a search you have access to both the matched objects and metadata about the search itself.

#### `.results`

Call the `.results` method to get back the ordered set of search results:

```ruby
search_result = Article.search { keywords 'hello' }
@articles = search_result.results
```

These are just your normal domain objects with no metadata.

#### `.hits`

If you're interested in the metadata, use the `.hits` method. The Sunspot wiki has two great examples of ways you could use the metadata along with the matched objects, adapted below.

We can use the `each_hit_with_result` method to iterate through the match data and the matched objects. Call the `.score` method for the numeric quality-of-match indicator, here's how we might output it in the results: 

```erb
<div class="results">
  <% @search.each_hit_with_result do |hit, article| -%>
    <div class="result">
      <h2><%= article.title %></h2>
      <div class="score"><%= hit.score %></div>
      <p><%= article.body %></p>
    </div>
  <% end -%>
</div>
```

Or, you could highlight the fragment of the object which matched the search:

```erb
<div class="results">
  <% @search.each_hit_with_result do |hit, article| -%>
    <div class="result">
      <h2><%= article.title %></h2>
      <p class="summary"><%= hit.highlight(:body).format { |fragment| content_tag(:em, fragment) } %></p>
    </div>
  <% end -%>
</div>
```

## References

* Heroku DevCenter on Websolr: http://devcenter.heroku.com/articles/websolr
* SunSpot quickstart: https://github.com/sunspot/sunspot/wiki/Adding-Sunspot-search-to-Rails-in-5-minutes-or-less
* Working with Sunspot Results: https://github.com/sunspot/sunspot/wiki/Working-with-search
* WebSolr Add-On Service Levels: http://addons.heroku.com/websolr
