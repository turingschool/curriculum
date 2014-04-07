---
layout: page
title: Getting Started with Sinatra
sidebar: true
---

Sinatra is an incredibly small library for writing web applications in Ruby. Here's the minimum you need to get rolling.

## Setup

Assuming you already have Ruby and Bundler installed, let's get Sinatra setup.

### File/Folder Structure

We need:

* a project folder
* a `Gemfile`
* an `app.rb` file
* a `config.rb` file

### `Gemfile`

We're going to depend on one external gem in our `Gemfile`:

```ruby
source 'https://rubygems.org'

gem 'sinatra', require: 'sinatra/base'
```

Save that and, from your project directory, run `bundle` to install the
dependencies.

### `app.rb`

In the `app.rb` we'll start writing the web application.

```ruby
class MySinatraApp < Sinatra::Base
  get '/' do
    "Hello, World!"
  end
end
```

Save the file.

### `config.ru`

The `app.rb` defines the web application, but we'll use a different file to actually run it. Create `config.ru` with these contents:

```ruby
require 'bundler'
Bundler.require

require './app'

run MySinatraApp
```

### Starting the Server

From your project directory, start the server:

{% terminal %}
$ rackup -p 4567
{% endterminal %}

Access [http://localhost:4567](http://localhost:4567) in your web browser.
You should see `Hello, World` then pat yourself on the back for developing a
web application.

## Defining Endpoints

In Sinatra we define endpoints that are a combination of HTTP verb and request path.

```ruby
class MySinatraApp < Sinatra::Base
  get '/' do
    'Hello, world!'
  end
end
```

In defining the endpoint we...

* call Sinatra's `get` method
* pass it a URL pattern to match, in this case `/`, the "root"
* pass it a block to run (`do`/`end`) when that endpoint is accessed
* send the return value of that block as the respose to the user

## Automatic Reloading

By default, your Sinatra app is loaded only once. If you make changes you'll need to stop and restart your server. That's no fun.

Try changing your `'Hello, world!'` to `'Good morning, world!'`, refresh the browser, and verify that it *doesn't* show the new output.

### Setup `sinatra-contrib`

The easiest way to get automatic reloading is to use the `sinatra/reloader` portion of the `sinatra-contrib` gem.

#### In the `Gemfile`

Add `sinatra-contrib` to your `Gemfile`:

```ruby
gem 'sinatra-contrib', require: 'sinatra/reloader'
```

Then run `bundle` from your terminal to install the gem.

#### In the `app.rb`

And add this to your application. You already have the `class` line, put these
three right below it:

```ruby
class MySinatraApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end
```

#### Restart the Server

Kill your server process (`CTRL-C`) and restart it using `rackup`:

{% terminal %}
$ rackup -p 4567
== WEBrick on http://127.0.0.1:4567/
[2013-02-26 17:41:28] INFO  WEBrick 1.3.1
[2013-02-26 17:41:28] INFO  ruby 1.9.3 (2013-02-06) [x86_64-darwin11.4.2]
[2013-02-26 17:41:28] INFO  WEBrick::HTTPServer#start: pid=9648 port=4567
{% endterminal %}

#### Test It

Refresh the browser and see "Good morning, world!". Change the message in your `app.rb`, refresh the browser again, and see it update.

## Parameters

Let's look at how to get parameter data out of the request URL. Within your route you can add markers that look like Ruby symbols. Imagining you wanted URLs like `/articles/16` you could define the endpoint like this:

```ruby
get '/article/:id' do
  article = Article.find_by_id(id)
  article.body
end
```

Sinatra will supply local variables to the block named after the markers in the URL pattern.

## Rendering JSON

If you're just prototyping, it might make sense to just output JSON rather than worry about HTML and view templates.

### Setup the Gem

Add this to the `Gemfile`:

```ruby
gem 'json'
```

Then run `bundle` in the terminal. Now that the gem is in the bundle it'll automatically be required by `Bundler.require`.

### Render JSON

JSON is really just a String. Using the sample endpoint from above...

```ruby
get '/article/:id' do
  Article.find_by_id(id).to_json
end
```

You'll just get out something like `"#<Article:0x007fbe8182e230>"`. Not useful.

### Defining JSON Attributes

Within your model, in this example `Article`, define a `to_json` method the outputs the attributes you want to expose and calls `to_json` on the collection:

```
class Article
  def to_json
    [:title => self.title, :body => self.body].to_json
  end
end
```

Then refresh your browser and you should see that attribute data.

## Rendering Templates

When you want to output HTML it's not practical to render strings right in the endpoint definitions. Instead we use templates.

### Creating a View Template

Within your project folder, create a folder named `views`. Then in that folder, create a file named `index.erb` with the following contents:

```erb
<html>
  <head>
    <title>MySinatraApp</title>
  </head>
  <body>
    <h1>Hello World, View Template Edition</h1>
  </body>
</html>
```

Go to your browser and refresh the root page. You should see no change, still
just `Hello, World`.

### Rendering the Template

Back in your `app.rb`, change your `get` method to render the ERB template:

```ruby
get '/' do
  erb :index
end
```

Flip over to your browser, refresh, and you should see `Hello World, View Template Edition`.

### Passing Data to the Template

But maybe you want to pass data to the view template.

#### Modifying the Endpoint

In the endpoint definition we need to specify what data should be passed to the template. Let's embed the current time:

```ruby
get '/' do
  erb :index, locals: {now: Time.now}
end
```

#### Modifying the View Template

Then we can add an H3 to the view template:

```erb
<body>
  <h1>Hello World, View Template Edition</h1>
  <h3>It's <%= now %></h3>
</body>
```

ERB allows you to embed Ruby within your template. The two styles to know are:

* `<%= your_code %>` is used to output the result of `your_code`
* `<% your_code %>` runs `your_code`, but does not render anything
