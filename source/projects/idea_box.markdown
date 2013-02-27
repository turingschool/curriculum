---
layout: page
title: IdeaBox
---

Every developer has more ideas than time. As David Allen likes to say "the human brain is for creating ideas, not remembering them." Let's build a system to record your good, bad, and aweful ideas.

And let's use it as an excuse to learn about Sinatra and Sequel.

## I0: Getting Started

### Envioronment Setup

For this project you need to have setup:

* Ruby 1.9.3
* SQLite (built in to Mac OS X)
* Ruby's Bundler gem

### File/Folder Structure

Let's start our project with the minimum and build up from there. We need:

* a project folder
* a `Gemfile`
* an `application.rb` file

### `Gemfile`

We're going to depend initiall on three external gems in our `Gemfile`:

```ruby
source 'https://rubygems.org'

gem 'sinatra'
gem 'sequel'
gem 'sqlite3'
```

Save that and, from your project directory, run `bundle` to install the dependencies.

### `application.rb`

In the `application.rb` we'll start writing the meat of our application. Over time we'll factor parts out to their own files. Let's start with this:

```ruby
Bundler.require

get '/' do
  "Hello, World!"
end
```

Save the file.

### Starting the Server

From your project directory, start the server:

{% terminal %}
$ bundle exec ruby application.rb
[2013-02-26 16:31:44] INFO  WEBrick 1.3.1
[2013-02-26 16:31:44] INFO  ruby 1.9.3 (2013-02-06) [x86_64-darwin11.4.2]
== Sinatra/1.3.5 has taken the stage on 4567 for development with backup from WEBrick
[2013-02-26 16:31:44] INFO  WEBrick::HTTPServer#start: pid=9394 port=4567
{% endterminal %}

In the third line of output note that the server is, by default, running on port `4567`.

Pull up the root page by accessing `http://localhost:4567/` in your web browser. You should see `Hello, World` then pat yourself on the back for developing a web application.

### What Just Happened?

* In the `application.rb` you called the `get` method which is defined by Sinatra. 
* You pass `get` a string parameter which is the URL pattern to match. 
* In this case, we passed `'/'`. That tells Sinatra to run the passed block, between the `do` and `end` whenever someone requests the root page (like `http://localhost:4567/`).

Now you're ready to start building the application.

## I1: Recording Ideas

For the early iterations we're going to ignore authentication and authorization. Just imagine that our users are going to run this app on their local machine behind a firewall.

When they visit the root URL, we should...

* Display a text field where they can record a new idea with a "SAVE" button
* Show a list of their existing ideas

Let's build that functionality now.

### View Templating Basics

Our current "application" is just rendering a string. It doesn't have HTML tags or any of the content that a real web page needs. While we could write the HTML we want to render right there in `application.rb`, it would get unmaintainable quickly.

#### Creating a View Template

Within your project folder, create a folder named `views`.

In that folder, create a file named `index.erb` with the following contents:

```erb
<html>
  <head>
    <title>IdeaBox</title>
  </head>
  <body>
    <h1>Hello World, View Template Edition</h1>
  </body>
</html>
```

Go to your browser and refresh the root page. You should see no change, still just `Hello, World`.

#### Rendering the Template

Back in your `application.rb`, change your `get` method like this:

```ruby
get '/' do
  erb :index
end
```

Flip over to your browser, refresh, and...still see `Hello, World`???

#### Manual Reloading

If you've developed anything in Rails before, you've been spoiled by automatic reloading. In Ruby it's actually pretty complex to dynamically undefine and redefine classes when files change. In Sinatra, this functionality is **not** built in by default.

Go to your server terminal session and hit `CTRL-C` to stop the process. Restart the server (`bundle exec ruby application.rb`), flip over to your browser, and refresh the page. Now you should see the "View Template Edition" header.

#### Automatic Reloading

The easiest way to get automatic reloading is to use the `shotgun` gem.

First, add `shotgun` to your `Gemfile`:

```ruby
gem 'shotgun'
```

Then run `bundle` from your terminal to install the gem.

Kill your server process (`CTRL-C`) and restart it using `shotgun`:

{% terminal %}
$ bundle exec shotgun application.rb
== Shotgun/WEBrick on http://127.0.0.1:9393/
[2013-02-26 17:41:28] INFO  WEBrick 1.3.1
[2013-02-26 17:41:28] INFO  ruby 1.9.3 (2013-02-06) [x86_64-darwin11.4.2]
[2013-02-26 17:41:28] INFO  WEBrick::HTTPServer#start: pid=9648 port=9393
{% endterminal %}

Note that `shotgun`, by default, starts the server on port `9393`. Flip over to your browser and change the URL to `http://localhost:9393`.

Go to your `index.erb` and change the H1 header to just `IdeaBox`. Save the template, go to your browser, refresh, and you should see the updated heading.

### Creating a Form

#### HTML Form

Now we need to add a little HTML form which is, itself, outside the scope of this tutorial. Here's how your view template should look:

```erb
<html>
  <head>
    <title>IdeaBox</title>
  </head>
  <body>
    <h1>IdeaBox</h1>
    <form action='/create' method='post'>
      <p>
        Your Idea:
      </p>
      <input type='text' name='idea_name'/><br/>
      <textarea name='idea_description'></textarea><br/>
      <input type='submit'/>
    </form>
  </body>
</html>
```

Preview it in the browser. Pretty ugly, eh? Go ahead and fill in a title and brief description, then hit `Submit`.

#### Sinatra Doesn't Know This Ditty

Get used to seeing this screen. It's Sinatra's default `404` page, which is rendered whenever you submit a request which doesn't have a matching route.

Typically it means you:

1. Didn't define the route pattern at all
2. The route pattern doesn't match the request like you thought it did
3. Your method is using the wrong HTTP verb (ex: your method uses `get`, but the request is coming in as a `post`)

The default error page is pretty useless in helping you debug. Let's create a better error page.

#### Create the `not_found` Method

Within your `application.rb`, call the `not_found` method:

```ruby
not_found do
  erb :error
end
```

Then in your `views` folder, define a file named `error.erb` with these contents:

```erb
<html>
  <head>
    <title>IdeaBox Error</title>
  </head>
  <body>
    <h1>An Error Occured</h1>
    
    <h3>Params</h3>
    <table>
      <tr>
        <th>Request Verb</th>
        <td><%= request.request_method %></td>
      </tr>
      <tr>
        <th>Request Path</th>
        <td><%= request.path %></td>
      </tr>
      <tr>
        <th colspan=2>Parameters</th>
      </tr>
      <% request.params.each do |key, value| %>
        <tr>
          <td><%= key %></td>
          <td><%= value %></td>
        </tr>
      <% end %>
    </table>
  </body>
</html>
```

Refresh your browser page and you should see more useful information about the error.

_Note_: If you'd like to output other things about the request, check out the API for `Rack::Request` at http://rack.rubyforge.org/doc/classes/Rack/Request.html

#### Creating `create`

Looking at the error page, you see that the form is submitting a `POST` request to the application at the path `/create`. Within `application.rb` we need to setup a route for that method:

```ruby
post '/create' do
  "Creating an IDEA!"
end
```

Refresh the browser and that line of text should appear. But what should our `create` path actually do? Let's chart some pseudocode:

```ruby
post '/create' do
  # 1. Create an idea based on the form parameters
  # 2. Store it
  # 3. Send us back to the index page to see all ideas
end
```

#### Creating an `Idea`

Following the ideals of MVC, we should build a domain object that represents an idea in our domain logic.

Create a folder under the project root named `models`. In there, create a file named `idea.rb` with these contents:

```ruby
class Idea
  def initialize(input = {})

  end
end
```

Then, in your `/create` path method, try to create an instance of `Idea`:

```ruby
post '/create' do
  # 1. Create an idea based on the form parameters
  idea = Idea.new

  # 2. Store it
  # 3. Send us back to the index page to see all ideas
end
```

##### `uninitialized constant Idea`

Derp. We need to tell Sinatra to load our new model file, it doesn't automatically load the files in `/models`. Near the top of your `application.rb`:

```ruby
require './models/idea'
```

Flip to the browser, refresh, and you'll see a plain white page. There's no error and our `post` call isn't rendering anything.

##### Saving an Idea

Our step 2 is "store it", which I'd like to be as easy as calling `.save` on the instance:

```ruby
post '/create' do
  # 1. Create an idea based on the form parameters
  idea = Idea.new
  
  # 2. Store it
  idea.save
  
  # 3. Send us back to the index page to see all ideas
end
```

Refresh the page and boom: `undefined method 'save'` for an `Idea` instance.

##### Defining Save

Hop into the `idea.rb` and add a `save` method:

```ruby
def save
  
end
```

Refresh the browser and you're back to the plain white screen.

##### A Real Save

But obviously our method didn't save the instance anywhere. How should we deal with our data? Store it in memory, to a file, to a database?



#### Storing Data

T

## I2: Editing and Destroying

## I3: Ranking and Sorting

## I4: Extensions
