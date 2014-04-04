---
layout: page
title: Getting Started with Sinatra
sidebar: true
---

Sinatra is an incredibly small library for writing web applications in Ruby. Here's the minimum you need to get rolling.

## Setup

Assuming you already have Ruby and Bundler installed, let's get Sinatra setup.

### File/Folder Structure

Let's start our project with the minimum and build up from there. We need:

* a project folder
* a `Gemfile`
* an `app.rb` file

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

### The Root Path

```ruby
class MySinatraApp < Sinatra::Base
  get '/' do
  end
end
```

Inside of this class we call the method named `get`, giving it a parameter
`/` and a block of code. The string parameter to `get` is the URL pattern to
match.

Our Sinatra application knows that it is running on
[http://localhost:4567](http://localhost:4567), so we only need to define the
part of the url that comes after that.

In this case we passed `'/'`, which will match when someone visits the
homepage, also known as the *root* of the application.

#### Tell the application how to respond

```ruby
class MySinatraApp < Sinatra::Base
  get '/' do
    'Hello, world!'
  end
end
```

The block of code that we pass to the `get` method between the `do`
and the `end` is the code that Sinatra is going to run when someone requests
the root page.

The response to the request is a string, in this case `'Hello, World!'`, which
is sent to the browser and displayed.

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
  article = Ariticle.find_by_id(id)
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
  article = Ariticle.find_by_id(id)
  article.to_json
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

It's not practical to render all your content out as strings right in the endpoint definitions. Instead we usually use templates.

#### Creating a View Template

Within your project folder, create a folder named `views`.

In that folder, create a file named `index.erb` with the following contents:

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

#### Rendering the Template

Back in your `app.rb`, change your `get` method like this:

```ruby
get '/' do
  erb :index
end
```

Flip over to your browser, refresh, and...still see `Hello, World`???

#### Passing Data to the Template

get '/:id/edit' do |id|
  idea = Idea.find(id.to_i)
  erb :edit, locals: {id: id}
end
