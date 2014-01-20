---
layout: page
title: IdeaBox
sidebar: true
---

Every developer has more ideas than time. As David Allen likes to say "the
human brain is for creating ideas, not remembering them." Let's build a system
to record your good, bad, and awful ideas.

And let's use it as an excuse to learn about Sinatra.

## I0: Getting Started

### Environment Setup

For this project you need to have setup:

* Ruby 2.0.0
* Ruby's Bundler gem

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

In the `app.rb` we'll start writing the meat of our application.

```ruby
require 'bundler'
Bundler.require

class IdeaBoxApp < Sinatra::Base
  get '/' do
    "Hello, World!"
  end

  run! if app_file == $0
end
```

Save the file.

### Starting the Server

From your project directory, start the server:

{% terminal %}
$ ruby app.rb
[2013-07-08 10:27:00] INFO  WEBrick 1.3.1
[2013-07-08 10:27:00] INFO  ruby 1.9.3 (2013-02-22) [x86_64-darwin12.4.0]
== Sinatra/1.4.3 has taken the stage on 4567 for development with backup from WEBrick
[2013-07-08 10:27:00] INFO  WEBrick::HTTPServer#start: pid=94643 port=4567
{% endterminal %}

In the third line of output note that the server is, by default, running on
port `4567`.

Access [http://localhost:4567](http://localhost:4567) in your web browser.
You should see `Hello, World` then pat yourself on the back for developing a
web application.

### What Just Happened?

#### Require dependencies

```ruby
require 'bundler'
Bundler.require
```

In the first two lines of `app.rb` we made sure that our ruby file has access
to the dependencies that we defined in the Gemfile and installed with the
`bundle install` command.

### Create the application container

```ruby
class IdeaBoxApp < Sinatra::Base
end
```

Then we create a ruby class which is going to be our application, and make it
inherit from `Sinatra::Base`, which provides the application with a bunch of
behavior that we can use to define our web app:

### Define the URL to match

```ruby
class IdeaBoxApp < Sinatra::Base
  get '/' do
  end
end
```

Inside of this ruby class we call a method called `get`, giving it a parameter
`/` and a block of code. The string parameter to `get` is the URL pattern to
match.

Our Sinatra application knows that it is running on
[http://localhost:4567](http://localhost:4567), so we only need to define the
part of the url that comes after that.

In this case we passed `'/'`, which will match when someone visits the
homepage, also known as the _root_ of the application.

### Tell the application how to respond

```ruby
class IdeaBoxApp < Sinatra::Base
  get '/' do
    'Hello, world!'
  end
end
```

The block of code that we pass to the `get` method, the stuff between the `do`
and the `end`, is the code that Sinatra is going to run when someone requests
the root page.

The response to the request is a string, in this case `'Hello, World!'`, which
is sent to the browser and displayed.

#### Run the application

```ruby
class IdeaBoxApp < Sinatra::Base
  # ...

  run! if app_file == $0
end
```

Finally, we say that if the application file was called directly, like this:

{% terminal %}
$ ruby app.rb
{% endterminal %}

then actually spin up the application (`run!`).

And that's it. You've built a web app!

### Refactor

It's not considered a very good idea to have the app run itself. That line
`run! if app_file == $0` is pretty dirty.

Let's separate the concerns of defining the application and running the
application.

Create an empty file called `config.ru` next to your `app.rb` file. Your
`idea_box` project directory should now look like this:

```plain
idea_box/
├── Gemfile
├── Gemfile.lock
├── app.rb
└── config.ru
```

`config.ru` is called a _rack up_ file, hence the `ru` file extension. It's
just a plain text file with a fancy name. We're going to move the business of
actually running the application into that file.

Open up the file and add the following code to it:

```ruby
require 'bundler'
Bundler.require

run IdeaBoxApp
```

Try starting your application with:

{% terminal %}
$ rackup
{% endterminal %}

It will give you the following error:

```plain
path/to/idea_box/config.ru:4:in `block in <main>': uninitialized constant IdeaBoxApp (NameError)
```

Let's pick that error message apart!

First, it tells us what the name of the file is where the error occurred:

```plain
path/to/idea_box/config.ru
```

So it's in the rackup file.

Then it tells us which line the error occurred on:

```plain
path/to/idea_box/config.ru:4
```

So it happened on line 4. What's on line 4 of `config.ru`?

```ruby
run IdeaBoxApp
```

OK, so it has something to do with running the application we wrote.

Next it tells us which method the error happened in:

```plain
path/to/idea_box/config.ru:4:in `block in <main>'
```

It's the method named `main`. Wait, what method named `main`? There's no
`main` in there!

It turns out that `main` is the top level method for all of a ruby program.
It's where your program starts, and if you haven't defined any methods
yourself, then `main` is where you are.

Ok, so what is it complaining about, really?

```plain
path/to/idea_box/config.ru:4:in `block in <main>': uninitialized constant IdeaBoxApp (NameError)
```

It doesn't know anything about any `IdeaBoxApp`. That's because we haven't
told our rackup file where to find it.

We need to tell the rackup file to load the application we defined. Change the
`config.ru` file to the following:

```ruby
require 'bundler'
Bundler.require

require './app'

run IdeaBoxApp
```

Now, if you call

{% terminal %}
$ rackup
{% endterminal %}

The application should start normally.

When we started the application directly, it started on port 4567, so we could
open our browser to [localhost:4567](http://localhost:4567) to get to the
page.

`rackup` defaults to the port `9292` instead of port `4567`. You can pick
whatever port you like, and tell `rackup` to use it.

{% terminal %}
$ rackup -p 1337
{% endterminal %}

Let's go ahead and stick with Sinatra's default, `4567`.

{% terminal %}
$ rackup -p 4567
{% endterminal %}

Before we move on, we can now delete the redundant code inside of `app.rb` so
the entire contents of the file is this:

```ruby
class IdeaBoxApp < Sinatra::Base
  get '/' do
    'Hello, world!'
  end
end
```

There! Now you're ready to start building the application.

## I1: Recording Ideas

For the early iterations we're going to ignore authentication and
authorization. Just imagine that our users are going to run this app on their
local machine behind a firewall.

When they visit the root URL, we should...

* Display a text field where they can record a new idea with a "SAVE" button
* Show a list of their existing ideas

Let's build that functionality now.

### View Templating Basics

Our current "application" is just rendering a plain text string.

Let's make it render some HTML.

Change the `get '/'` block to look like this:

```ruby
get '/' do
  "<h1>Hello, World!</h1><blockquote>I guess I always felt even if the world came to an end, McDonald's would still be open. <cite>Susan Beth Pfeffer</cite></blockquote>"
end
```

Refresh the page.

![Hello World](idea_box/hello_world.png)

HTML is just a string with some structure. The browser understands that
structure and has opinions about what it should look like.

Putting our HTML in the block of the `get` method is clearly not a very
maintainable approach. We need to find a better way to render the response.

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

#### Manual Reloading

If you've developed anything in Rails before, you've been spoiled by automatic
reloading. In Ruby it's actually pretty complex to dynamically undefine and
redefine classes when files change. In Sinatra, this functionality is **not**
built in by default.

Go to your server terminal session and hit `CTRL-C` to stop the process.
Restart the server (`rackup -p 4567`), flip over to your browser, and refresh
the page. Now you should see the "View Template Edition" header.

#### Automatic Reloading

The easiest way to get automatic reloading is to use the `sinatra/reloader` portion of the `sinatra-contrib` gem.

Just add `sinatra-contrib` to your `Gemfile`:

```ruby
gem 'sinatra-contrib', require: 'sinatra/reloader'
```

And add this to your application. You already have the `class` line, put these
three right below it:

```ruby
class IdeaBoxApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end
```

Then run `bundle` from your terminal to install the gem.

Kill your server process (`CTRL-C`) and restart it using `rackup`:

{% terminal %}
$ rackup -p 4567
== WEBrick on http://127.0.0.1:4567/
[2013-02-26 17:41:28] INFO  WEBrick 1.3.1
[2013-02-26 17:41:28] INFO  ruby 1.9.3 (2013-02-06) [x86_64-darwin11.4.2]
[2013-02-26 17:41:28] INFO  WEBrick::HTTPServer#start: pid=9648 port=4567
{% endterminal %}

Now go to your `index.erb` and change the H1 header to just `IdeaBox`. Save
the template, go to your browser, refresh, and you should see the updated
heading.

### Creating a Form

#### HTML Form

Now we need to add a little HTML form which is, itself, outside the scope of
this tutorial. Here's how your view template should look:

```erb
<html>
  <head>
    <title>IdeaBox</title>
  </head>
  <body>
    <h1>IdeaBox</h1>
    <form action='/' method='POST'>
      <p>
        Your Idea:
      </p>
      <input type='text' name='idea_title'/><br/>
      <textarea name='idea_description'></textarea><br/>
      <input type='submit'/>
    </form>
  </body>
</html>
```

Preview it in the browser.

![Idea Box v1](idea_box/idea_box_v1.png)

Pretty ugly, eh? Go ahead and fill in a title and
brief description, then hit `Submit`.

#### Sinatra Doesn't Know This Ditty

![Missing Error](idea_box/missing_error.png)

Get used to seeing this screen. It's Sinatra's default `404` page, which is
rendered whenever you submit a request which doesn't have a matching route.

Typically it means you:

1. Didn't define the route pattern at all
2. Your method is using the wrong HTTP verb
   (ex: your method uses `get`, but the request is coming in as a `post`)
3. The route pattern doesn't match the request like you thought it did

The default error page is pretty useless in helping you debug. Let's create a
better error page.

#### Create the `not_found` Method

Within your `app.rb`, call the `not_found` method:

```ruby
class IdeaBoxApp < Sinatra::Base
  not_found do
    erb :error
  end

  # ...
end
```

Then in your `views` folder, define a file named `error.erb` with these
contents:

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

Refresh your browser page and you should see more useful information about the
error.

_Note_: If you'd like to output other things about the request, check out the
[API documentation](http://rack.rubyforge.org/doc/classes/Rack/Request.html)
for `Rack::Request`.

#### Creating the "`/`" route

It seems like we already have a method to handle `/`, but if you look at the
error page, you see that the form is submitting a `POST` request to the
application at the path `/`.

We've defined a method that handles the `GET` request (`get '/'`), not the
`POST` request (`post '/'`).

Within `app.rb` we need to setup a route for the `POST`:

```ruby
post '/' do
  "Creating an IDEA!"
end
```

Refresh the browser and that line of text should appear. But what should our
`POST /` path actually do? Let's chart some pseudocode.

```ruby
post '/' do
  # 1. Create an idea based on the form parameters
  # 2. Store it
  # 3. Send us back to the index page to see all ideas
  "Creating an IDEA!"
end
```

#### Creating an `Idea`

Following the ideals of MVC, we should build a domain object that represents
an idea in our domain logic.

Create a file in the root of your project named `idea.rb` with these contents:

```ruby
class Idea
end
```

Then, in your `POST /` path method, try to create an instance of `Idea`:

```ruby
post '/' do
  # 1. Create an idea based on the form parameters
  idea = Idea.new

  # 2. Store it
  # 3. Send us back to the index page to see all ideas
  "Creating an IDEA!"
end
```

##### `uninitialized constant IdeaBoxApp::Idea`

Derp. We need to tell Sinatra to load our new idea file, it doesn't
automatically load just any files. Only the files that we tell it we care about.

At the top of your `app.rb`:

```ruby
require './idea'
```

Flip to the browser, refresh, and you'll see "Creating an IDEA!". This means
that it got to that line in the `post '/'` method without any errors.

##### Saving an Idea

Our step 2 is "store it", which I'd like to be as easy as calling `.save` on
the instance:

```ruby
post '/' do
  # 1. Create an idea based on the form parameters
  idea = Idea.new

  # 2. Store it
  idea.save

  # 3. Send us back to the index page to see all ideas
  "Creating an IDEA!"
end
```

Refresh the page and boom: `undefined method 'save'` for an `Idea` instance.

##### Defining Save

Hop into the `idea.rb` and add a `save` method:

```ruby
class Idea
  def save
  end
end
```

Refresh the browser and you're back to "Creating an IDEA!".

### A Real Save

Obviously our method didn't save the instance anywhere. How should we deal
with our data? Store it in memory, to a file, to a database?

#### Storing Data

Almost every web application is backed by a database that stores its data.
We're going to use an incredibly simple database that comes with Ruby called
`YAML::Store` to store our ideas.

#### Saving

The first problem in front of us is how to make `Idea#save` work, so instances
of `Idea` need access to the db.

Let's give the idea instances a reference to a database:

```ruby
class Idea
  def save
  end

  def database
    @database ||= YAML::Store.new "ideabox"
  end
end
```

#### Simplistic Save

With that database at hand, let's write a `save` method:

```ruby
def save
  database.transaction do |db|
    db['ideas'] ||= []
    db['ideas'] << {title: 'diet', description: 'pizza all the time'}
  end
end
```

#### Testing Ideas in the Database

We're building some complex functionality here. Let's see if things are
actually working.

From a terminal in the project directory, fire up IRB:

{% terminal %}
$ irb
{% endterminal %}

Then within IRB:

{% irb %}
$ require './idea'
=> true
$ idea = Idea.new
=> #<Idea:0x007f86fc04a0a8>
$ idea.save
=> NameError: uninitialized constant Idea::YAML
{% endirb %}

Ah-ha! Loading `idea.rb` goes fine, but when we try to save, it blows up in
`save` when it calls database. It doesn't know what `YAML` is.

Let's just tell irb to load `YAML`, then try to save again:

{% irb %}
$ require 'yaml'
$ idea.save
=> NameError: uninitialized constant Psych::Store
{% endirb %}

OK, so we get a new error message. We didn't require quite enough stuff.

The thing we're using in the `database` method, `YAML::Store`, is a
wrapper around `Psych::Store`.

We can pull it in by requiring 'yaml/store'

{% irb %}
$ require 'yaml/store'
$ idea.save
=> {title: 'diet', description: 'pizza all the time'}
{% endirb %}

Did it work?

Within IRB you can look at what's in the database:

{% irb %}
$ idea = Idea.new
$ idea.database.transaction { idea.database['ideas'] }
=> [{:title=>"diet", :description=>"pizza all the time"}]
{% endirb %}

What happens if we save another one?

{% irb %}
$ idea = Idea.new
$ idea.save
$ idea.database.transaction { idea.database['ideas'] }
=> [{:title=>"diet", :description=>"pizza all the time"}, {:title=>"diet", :description=>"pizza all the time"}]
{% endirb %}

They're definitely going into the database. It's kind of pointless, since
we're saving the same idea over and over again, but the basic functionality is
working.

Before we move on, remember to add `require 'yaml/store'` to the top of the
`idea.rb` file.

### Inspecting the database

Take a look at the files in your project:

```plain
├── Gemfile
├── Gemfile.lock
├── app.rb
├── config.ru
├── idea.rb
├── ideabox
└── views
    ├── error.erb
    └── index.erb
```

Notice the one called `ideabox`? Open it up.

It looks like this:

```yaml
---
ideas:
- :title: diet
  :description: pizza all the time
- :title: diet
  :description: pizza all the time
```

Our database is in a regular, plain text file right there on the file system.

It's in a structured format known as `YAML`. Try editing the file:

```yaml
---
ideas:
- :title: diet
  :description: pizza all the time
- :title: exercise
  :description: play video games
```

Start a new IRB session if you don't already have one running:

{% terminal %}
$ irb
{% endterminal %}

{% irb %}
$ require './idea'
$ idea = Idea.new
$ idea.database.transaction { idea.database['ideas'] }
=> [{:title=>"diet", :description=>"pizza all the time"}, {:title=>"exercise", :description=>"play video games"}]
{% endirb %}

#### Saving real ideas

Rather than saving the same tired pizza idea every time, let's let our idea
instance save the real title and description to the database.

I want this to look something like this:

```ruby
$ idea = Idea.new("app", "social network for dogs")
$ idea.save
```

What happens if we try doing this in IRB?

{% irb %}
$ idea = Idea.new("app", "social network for dogs")
=> ArgumentError: wrong number of arguments(2 for 0)
{% endirb %}

The `new` method for `Idea` doesn't like this at all. The error is telling us
that we're trying to give it two arguments, but it only accepts zero.

How rude.

We can change this by adding a custom `initialize` method to `Idea`:

```ruby
class Idea
  def initialize(something, something_else)
  end

  # ...
end
```

Now if we kill the IRB session and start over, we don't get an error:

{% irb %}
$ require './idea'
$ idea = Idea.new("app", "social network for dogs")
=> #<Idea:0x007f7f608472b8>
$ idea.save
=> [{:title=>"diet", :description=>"pizza all the time"}, {:title=>"exercise", :description=>"play video games"}, {:title=>"diet", :description=>"pizza all the time"}]
{% endirb %}

So it worked, kind of. If you take a look inside your database YAML file, it
didn't actually save the social network thing, it saved the same old pizza
idea. Again.

We're almost there, though.

We need to take the `something, something_else` and make it available to the
save method.

First of all, `something` is more like `title`, and `something_else` is
`description`.

Update the `Idea` class:

```ruby
require 'yaml/store'

class Idea
  def initialize(title, description)
  end

  # ...
end
```

And then we need to make those things available to the rest of the instance:

```ruby
class Idea
  attr_reader :title, :description

  def initialize(title, description)
    @title = title
    @description = description
  end

  # ...
end
```

And finally, we'll let the `save` method use them:

```ruby
def save
  database.transaction do |db|
    db['ideas'] ||= []
    db['ideas'] << {title: title, description: description}
  end
end
```

Restart your IRB session and try this out:

{% irb %}
$ require './idea'
$ Idea.new("app", "social network for dogs").save
$ Idea.new("excursion", "take everyone to the zoo").save
$ Idea.new("party", "dance all night and all day").save
{% endirb %}

Open up your `ideabox` file and make sure that the ideas you just created are
there.

#### Back to the Web

Remember like a decade or so ago we were building a web application? Let's hop
over there and see what's going on.

* Go to [localhost:4567](http://localhost:4567) in your browser
* Enter an idea in the form
* Click `Submit`

Are you surprised to see an exception?

We're getting an `ArgumentError` that says `wrong number of arguments (0 for
2)`. This sounds kind of familiar. It says the problem is in `app.rb` the
line:

```rb
idea = Idea.new
```

We changed the definition of `initialize` in Idea to take `title` and
`description`, so the error makes sense.

We need to grab the idea that we submitted from the form.

#### Getting form data

Sinatra gives us a `params` object that gives us what we need. Let's take a
look at it. Comment out the existing content of the `post '/'` block.

```ruby
post '/' do
  params.inspect
  ## 1. Create an idea based on the form parameters
  # idea = Idea.new
  #
  ## 2. Store it
  # idea.save
  #
  ## 3. Send us back to the index page to see all ideas
  # "Creating an IDEA!"
end
```

Now go to [localhost:4567](http://localhost:4567) and fill in a new idea.
Click submit, and the page shows you the following.

```plain
{"idea_title"=>"story", "idea_description"=>"a princess steals a spaceship"}
```

Now we can use the keys that we see here to give our new idea what it needs:

```ruby
post '/' do
  # 1. Create an idea based on the form parameters
  idea = Idea.new(params['idea_title'], params['idea_description'])

  # 2. Store it
  idea.save

  # 3. Send us back to the index page to see all ideas
  "Creating an IDEA!"
end
```

Try submitting a new idea through the web interface again.

The website should respond with "Creating an IDEA!".

Take a look inside your database file. Your idea should be there.

So we're doing step 1 and step 2 correctly. Step 3 _Send us back to the index
page to see all the ideas_ is still not right.

Replace "Creating an IDEA!" with `redirect '/'`:

```ruby
post '/' do
  # 1. Create an idea based on the form parameters
  idea = Idea.new

  # 2. Store it
  idea.save

  # 3. Send us back to the index page to see all ideas
  redirect '/'
end
```

Go back to your root page, submit the form again, and...

It clears? Did it work? Maybe?

The new idea has been saved because we can see it in the database file, and
clearly we're back on the index page because we're seeing the form, but it's
not showing all the ideas.

We need to get the data back out of the database and into the view.

#### Refactor

Before we abandon the controller, let's clean up. Our comments are not useful
anymore, so we can delete them, leaving us with:

```ruby
post '/' do
  idea = Idea.new(params['idea_title'], params['idea_description'])
  idea.save
  redirect '/'
end
```

#### Ideas in the View Template

Hop over to the `index.erb` and add a bit of HTML to display the known ideas,
assuming that the instances are stored in a variable `ideas`.

```erb
<html>
  <head>...</head>
  <body>
    <h1>...</h1>
    <form>...</form>

    <h3>Existing Ideas</h3>

    <ul>
      <% ideas.each do |idea| %>
        <li>
          <%= idea.title %><br/>
          <%= idea.description %>
        </li>
      <% end %>
    </ul>
  </body>
</html>
```

Reload the root page.

We get an error:

```plain
NameError: undefined local variable or method 'ideas'
```

The error is occurring on line 20 of the `views/index.erb`.

We have to tell the view about the local variable `ideas`. Open up `app.rb`,
and change the `GET /` action:

```ruby
get '/' do
  erb :index, locals: {ideas: something}
end
```

#### Querying for the `ideas`

We don't actually know what `something` is yet, though. We want to show all
the ideas, but we don't have a good way of getting them out of the database
yet.

I'd like it to look like this:

```ruby
get '/' do
  erb :index, locals: {ideas: Idea.all}
end
```

Since we're programming by wishful thinking, let's see what our application
thinks about this. Reload the root page of the app.

```plain
NoMethodError: undefined method 'all' for Idea:Class
```

Well, that's not entirely unexpected. We never defined a method `all` for
`Idea`.

#### Implementing `Idea.all`

```ruby
class Idea
  def self.all
    database.transaction do |db|
      db['ideas'] || []
    end
  end

  # ...
end
```

<div class="note">
<p>If you remember, the `x || y` idiom in Ruby means that if `x` is `nil`, it will return `y`. If `x` is not `nil`, it will just return `x`. We use this here to return the list of all `Idea`s, but if there are none, return an empty array. That way, we can call array methods (like `map`) without worrying if we have data.</p>
</div>

Reload the page.

We get a new error.

```plain
NameError: undefined local variable or method `database' for Idea:Class
```

That looks fairly familiar. We have a `database` method, but it's only
available to the instances of Idea, not the Idea class itself.

Let's change the Idea class so that the `database` definition is on the class
instead of the instance:

```ruby
class Idea
  def self.all
    # ...
  end

  def self.database
    @database ||= YAML::Store.new('ideabox')
  end

  # ...

  def database
    Idea.database
  end
end
```

Notice that we also updated the instance's `database` method to refer to the
one in the class.

Reload the page.

Yet another error:

```plain
NoMethodError: undefined method `title' for {:title=>"diet", :description=>"pizza all the time"}:Hash
```

Oops. Our `Idea.all` method is returning hashes directly from the database,
but we need idea objects.

Let's update the `all` method:

```ruby
def self.all
  database.transaction do |db|
    db['ideas'] || []
  end.map do |data|
    new(data[:title], data[:description])
  end
end
```

This works, but it's pretty nasty. Let's call the hash version of an idea a
`raw_idea`:

```ruby
def self.all
  raw_ideas.map do |data|
    new(data[:title], data[:description])
  end
end

def self.raw_ideas
  database.transaction do |db|
    db['ideas'] || []
  end
end
```

### Test it

* Stop your server with `CTRL-C`
* Delete the `ideabox` database file
* Restart the server
* Visit the root page in your browser
* It should load correctly and display no ideas
* Add an idea using the form
* Tada!

## I2: Editing and Destroying

It's great that you can write down ideas, but what happens to the bad ones? Let's build out features to edit and delete ideas.

### Deleting Ideas

For deletion to work, we need a few things:

1) We need to be able to identify a particular idea.
   Right now they only have a title and a description, but what if we have the
   same idea in the database twice by accident? We only want to delete one of
   them.
2) We need a controller action that, given some unique identifier, will tell
   the Idea model to delete it.
3) We need the Idea model to know how to delete an idea.

### Unique Identifier

For the moment, let's assume that this application is only used by a single
person at a time.

Let's use the position of the idea in the database to identify that entry uniquely at a given point in time.

In the view we can get the position, or index, by changing the `ideas.each` loop to be an `ideas.each_with_index` loop:

```erb
<ul>
  <% ideas.each_with_index do |idea, id| %>
    <li>
      <%= idea.title %><br/>
      <%= idea.description %>
    </li>
  <% end %>
</ul>
```

This gives us a way to identify an idea.

We need to use this unique identifier to send a request to the application.
Let's create a very small form that only has a single button:

```erb
<ul>
  <% ideas.each_with_index do |idea, id| %>
    <li>
      <%= idea.title %><br/>
      <%= idea.description %>
      <form action="/<%= id %>" method="POST">
        <input type="hidden" name="_method" value="DELETE">
        <input type="submit" value="delete"/>
      </form>
    </li>
  <% end %>
</ul>
```

This uses some trickery. We want to send the DELETE verb to the server, but
HTML forms aren't particularly good with anything other than POST. So we're
sending a POST, and then passing some extra data to the page in a hidden
input.

The request will come in to sinatra as a POST, but before sinatra passes it to
your application, it will see the `_method=DELETE`, and instead of looking for a
method in your application that matches `post '/:id'`, it will look for
`delete '/:id'`.

Refresh the page, click the button, and... boom.

It fails because we haven't defined `delete '/:id'`. Let's do that now:

```ruby
delete '/:id' do |id|
  "DELETING an idea!"
end
```

Try deleting an idea again and... still boom. Dang it.

Sinatra is still looking for a `post` not a `delete`.

We need to tell Sinatra that it's supposed to look for the `_method` parameter
when requests come in.

In your `app.rb` file add this line to the top of your class definition:

```ruby
class IdeaBoxApp < Sinatra::Base
  set :method_override, true

  # ...
end
```

Try deleting an idea again, and you should see "DELETING an idea!" in the browser.

What do we want `delete '/:id'` to actually do?

* Delete the idea
* Redirect back to the root page

This might look like this:

```ruby
delete '/:id' do |id|
  Idea.delete(id)
  redirect '/'
end
```

Flip back to your browser, and try to delete an idea. You should get an error saying that we don't know about any method `delete` on the Idea class.

### Add the missing method in Idea

We can fix this by adding a `delete` method in `idea.rb`:

```ruby
class Idea
  def self.delete(position)
    database.transaction do
      database['ideas'].delete_at(position)
    end
  end
end
```

Now try deleting the idea again.

```plain
can't convert String into Integer
```

We're trying doing the equivalent of this:

```ruby
["a", "b", "c", "d", "e"].delete_at("2")
```

The position needs to be an integer, not a string.

Let's let the controller deal with that:

```ruby
delete '/:id' do |id|
  Idea.delete(id.to_i)
  redirect '/'
end
```

Try deleting an idea again.

This time it works.

### Editing an Idea

We can add new ideas and delete ideas we don't like, but sometimes things are almost right. We should be able to improve existing ideas.

Let's add a link for each idea that will take us to a page where we can edit it.

We'll use the same positional identifier to figure out which element to edit.

```erb
<ul>
  <% ideas.each_with_index do |idea, id| %>
    <li>
      <%= idea.title %><br/>
      <%= idea.description %>
      <a href="/<%= id %>/edit">Edit</a>
      <form action="/<%= id %>" method="POST">
        <input type="hidden" name="_method" value="DELETE">
        <input type="submit" value="delete"/>
      </form>
    </li>
  <% end %>
</ul>
```

Reload the page, and click the _edit_ link for one of the ideas.

The error message we get is:

```plain
An Error Occured

Params

Request Verb	GET
Request Path	/0/edit
Parameters
```

### Add the edit controller action

Within `app.rb` add:

```ruby
get '/:id/edit' do |id|
  "Edit an idea!"
end
```

Now when we click the edit button we get to the right place.

Let's render a view template instead of just returning a string:

```ruby
get '/:id/edit' do |id|
  erb :edit
end
```

Since we don't actually have a template yet, we get the following error:

```plain
Errno::ENOENT at /0/edit
No such file or directory - /Users/code/idea_box/views/edit.erb
```

Create a file in the _views_ directory named `edit.erb`, and put the following
code into it:

```erb
<html>
  <head>
    <title>IdeaBox</title>
  </head>
  <body>
    <h1>IdeaBox</h1>

    <form action="/<%= id %>" method="POST">
      <p>
        Edit your Idea:
      </p>
      <input type="hidden" name="_method" value="PUT" />
      <input type='text' name='idea_title' value="<%= idea.title %>"/><br/>
      <textarea name='idea_description'><%= idea.description %></textarea><br/>
      <input type='submit'/>
    </form>
  </body>
</html>
```

Again we're creating a form which uses the POST method, and giving Sinatra the
extra information in `_method=PUT` to say that even though this is coming in
with the POST verb, we actually intend it to be a PUT.

Then we add the title and description for the current idea into the form so
that it can be edited.

The next error we get is:

```plain
NameError: undefined local variable or method `id'
```

This is in the `edit.erb` file on line 8.

It's complaining that it doesn't know about a local variable named `id`.
That's because we haven't given the view any local variables.

Jump back into the `app.rb` file and change the `get '/:id/edit'` method:

```ruby
get '/:id/edit' do |id|
  erb :edit, locals: {id: id}
end
```

Reload the page again, and you should get a new error:

```plain
NameError: undefined local variable or method `idea'
```

We need get the idea out of the database, and pass it to the view template.

Change the controller action so that it looks like this:

```ruby
get '/:id/edit' do |id|
  idea = Idea.find(id.to_i)
  erb :edit, locals: {id: id}
end
```

Reload the page.

The application complains about not having a `find` method on Idea:

```ruby
NoMethodError: undefined method `find' for Idea:Class
```

Jump into the `idea.rb` file and add this method:

```ruby
def self.find(id)
  database.transaction do
    database['ideas'].at(id)
  end
end
```

```plain
TypeError: can't convert String into Integer
```

Once again, we're trying to index into an array with a string rather than an
integer.

Fix the controller action, calling `to_i` on the `id`:

```ruby
get '/:id/edit' do |id|
  idea = Idea.find(id.to_i)
  erb :edit, locals: {id: id}
end
```

Reload the page again, and we're back to this error:

```plain
NameError: undefined local variable or method `idea'
```

Oh, right. We have to actually pass our idea to the view template:

```ruby
get '/:id/edit' do |id|
  idea = Idea.find(id.to_i)
  erb :edit, locals: {id: id, idea: idea}
end
```

Reload the page.

Now we're getting:

```plain
NoMethodError: undefined method `title' for {:title=>"diet", :description=>"pizza all the
time"}:Hash
```

We are getting the raw hash out of the database, and we need to turn it into
an idea.

Change the `find` method in `idea.rb` so we're getting a raw idea and then
creating a new Idea instance with it:

```ruby
def self.find(id)
  raw_idea = find_raw_idea(id)
  new(raw_idea[:title], raw_idea[:description])
end

def self.find_raw_idea(id)
  database.transaction do
    database['ideas'].at(id)
  end
end
```

And finally, the edit page shows up with a form and our ideas in it.

What happens if you tweak the idea and submit the form?

```plain
An Error Occured

Params

Request Verb	PUT
Request Path	/0
Parameters
_method	PUT
idea_title	music
idea_description	really fast drums
```

We're missing another controller action.

Create this action:

```ruby
put '/:id' do |id|
  "Tweaking the IDEA!"
end
```

We no longer get a failure, but we're not doing anything useful yet.

We need to:

* update the idea in the database
* redirect to the index page

What should this look like?

Maybe something like this:

```ruby
put '/:id' do |id|
  data = {
    :title => params['idea_title'],
    :description => params['idea_description']
  }
  Idea.update(id.to_i, data)
  redirect '/'
end
```

It's not too pretty, but we can make it work and then we can improve it later.

Reload the page.

```plain
NoMethodError: undefined method `update' for Idea:Class
```

We need to write the `update` method. In `idea.rb` add:

```ruby
def self.update(id, data)
  database.transaction do
    database['ideas'][id] = data
  end
end
```

Reload the page again, and you should see your updated idea.

## I3: Refactor!

There's a lot that is klunky about this.

First, when we create a new idea we say:

```ruby
Idea.new(title, description)
```

We often want to create an idea based on a hash that comes out of the
database:

```ruby
def self.find(id)
  raw_idea = find_raw_idea(id)
  new(raw_idea[:title], raw_idea[:description])
end
```

It would be nice if we could just give that hash straight to `Idea.new` like
this:

```ruby
Idea.new(raw_idea)
```

In `idea.rb` we need to:

1. update the `initialize` method definition to take a hash.
2. update the `self.find` method to pass a hash to `new`.
3. update the `self.all` method to pass a hash to `new`.

We also need to make a change in `app.rb` in the `POST /` endpoint to pass a
hash to the `Idea.new` method.

The updated methods in idea.rb look like this:

```ruby
def self.all
  raw_ideas.map do |data|
    new(data)
  end
end

def self.find(id)
  raw_idea = find_raw_idea(id)
  new(raw_idea)
end

def initialize(attributes)
  @title = attributes[:title]
  @description = attributes[:description]
end
```

And the new `POST /` endpoint looks like this:

```ruby
post '/' do
  idea = Idea.new(title: params['idea_title'], description: params['idea_description'])
  idea.save
  redirect '/'
end
```

Test your app to make sure you can still add new ideas and edit them, and that
the right ideas show up in the list of all the ideas.


### Improving `POST /`

That `POST /` endpoint looks worse than it did. It would be nice if we could
just give the `Idea.new` a hash straight from the `params`.

We can. Update the form so that it looks like this:

```erb
<form action='/' method='POST'>
  <p>
  Your Idea:
  </p>
  <input type='text' name='idea[title]'/><br/>
  <textarea name='idea[description]'></textarea><br/>
  <input type='submit'/>
</form>
```

Notice how we changed `idea_title` and `idea_description` to `idea[title]` and
`idea[description]`? This will allow us to access this data in the params object
by just saying `params[:idea]`.

The new `POST /` looks like this:

```ruby
post '/' do
  idea = Idea.new(params[:idea])
  idea.save
  redirect '/'
end
```

Test your app, to make sure it still works.

### Fixing edit and update

We also need to fix the form in `edit.erb`  and the corresponding `PUT /:id`
endpoint:

```erb
<form action="/<%= id %>" method='POST'>
  <p>
    Edit your Idea:
  </p>
  <input type="hidden" name="_method" value="PUT" />
  <input type='text' name='idea[title]' value="<%= idea.title %>"/><br/>
  <textarea name='idea[description]'><%= idea.description %></textarea><br/>
  <input type='submit'/>
</form>
```

```ruby
put '/:id' do |id|
  Idea.update(id.to_i, params[:idea])
  redirect '/'
end
```

This doesn't quite work. When we update ideas, we end up with empty ideas in
the list.

If you look at the database file, some of the ideas look like this:

```yaml
---
ideas:
- :title: dinner
  :description: pizza
- :title: dessert
  :description: candy, soda, and ice cream
```

Whereas other ideas look like this:

```yaml
---
ideas:
- title: dinner
  description: pizza
- title: dessert
  description: candy, soda, and ice cream
```

Can you see how they're different?

It's pretty subtle. In one, the `title` and `description` have colons on both
sides of the string, and in the other, they only have a colon at the end of
the string.

Essentially, `:title:` is the YAML for the Ruby _symbol_ `:title`, whereas
`title:` is YAML for the Ruby _string_ `"title"`.

When the `params` object comes back, we send it directly to `Idea.update`.
While we can access fields in the `params` using both strings and symbols for
the keys, if we just grab the value of `params[:idea]`, we'll get a hash with
string values for the keys:

```ruby
{"title" => "game", "description" => "tic tac toe"}
```

We can either jump through some hoops to deal with both strings and symbols,
or change the update so we explicitly pass symbols to the database, or we can
just use strings all the way through the app. Let's do that.

We need to update the `initialize` and `save` methods in `idea.rb` to use
strings for the hash keys instead of symbols:

```ruby
def initialize(attributes = {})
  @title = attributes["title"]
  @description = attributes["description"]
end

def save
  database.transaction do
    database['ideas'] ||= []
    database['ideas'] << {"title" => title, "description" => description}
  end
end
```

There. Now both creating and editing ideas should work.

### Using a View Partial

It seems kind of impractical that we had to update two HTML forms when they're
essentially the same thing. Let's create a new view called `form.erb` and
tweak both the `index.erb` and the `edit.erb` templates to use it.

First, we can copy the form from the `index.erb` into the `form.erb` page and
get that working, then we'll see how we need to tweak it to make it work for
the edit page as well.

The `form.erb` file looks like this:

```erb
<form action='/' method='POST'>
  <p>
  Your Idea:
  </p>
  <input type='text' name='idea[title]'/><br/>
  <textarea name='idea[description]'></textarea><br/>
  <input type='submit'/>
</form>
```

We need to get the index page to render that form, so change it to send the
`erb` message, like this:

```erb
<h1>IdeaBox</h1>

<%= erb :form %>

<h3>Existing Ideas</h3>
```

Check that you can still add ideas.



Now, what's different between the _create_ form and the _edit_ form?

* the url in the form action ('/' vs '/:id')
* the form caption (`Your idea:` vs `Edit your idea:`)
* the edit form has a hidden input with `_method="PUT"`
* the edit form has the title and description of the idea in the `value`
  attributes of the form fields.

Let's start at the bottom and work our way up.

We can make the index page take an empty idea, and put those empty values into
the form to make it more similar to the edit form.

In the `GET /` endpoint, change the call to `erb`:

```ruby
get '/' do
  erb :index, locals: {ideas: Idea.all, idea: Idea.new}
end
```

Update the form in `form.erb`:

```erb
<form action='/' method='POST'>
  <p>
  Your Idea:
  </p>
  <input type='text' name='idea[title]' value="<%= idea.title %>"/><br/>
  <textarea name='idea[description]'><%= idea.description %></textarea><br/>
  <input type='submit'/>
</form>
```

Test that you can still add ideas.

You can't. We broke the app. The form view doesn't seem to have access to the
`idea` object.

We need to pass it to the form template from the index template.

In `index.erb` pass a `locals` hash to the form partial.:

```erb
<%= erb :form, locals: {idea: idea} %>
```

Now when we try to load the root page of the app, we're told that we're not
calling `Idea.new` correctly.

That makes sense. We're saying `Idea.new` with no arguments, but `Idea.new`
takes a hash. Let's change `def initialize` in `idea.rb` to provide an empty
hash by default if nothing is provided:

```ruby
def initialize(attributes = {})
  @title = attributes["title"]
  @description = attributes["description"]
end
```

The home page should finally load correctly. Make sure you can still add
ideas.

OK, we're still not done. We want to be able to use the form partial in the
edit template as well. What's missing?

* the url in the form action ('/' vs '/:id')
* the form caption (`Your idea:` vs `Edit your idea:`)
* the edit form has a hidden input with `_method="PUT"`

Let's simply give the form a flag, `mode`, that tells us if the form is for
creating a new idea or editing an existing one.

Change the form in the `form.erb` file:

```erb
<form action='/<%= id if mode == "edit" %>' method='POST'>
  <p>
    <% if mode == "edit" %>
      Edit your Idea:
    <% else %>
      Your Idea:
    <% end %>
  </p>
  <% if mode == "edit" %>
    <input type="hidden" name="_method" value="PUT" />
  <% end %>
  <input type='text' name='idea[title]' value="<%= idea.title %>"/><br/>
  <textarea name='idea[description]'><%= idea.description %></textarea><br/>
  <input type='submit'/>
</form>
```

Then update the `edit.erb` to use the form partial:

```erb
<%= erb :form, locals: {idea: idea, id: id, mode: "edit"} %>
```

We also need to update the `index.erb` template to send in the `mode` flag:

```erb
<%= erb :form, locals: {idea: idea, mode: "new"} %>
```

Test your app to make sure you can still add and edit ideas.

### Using a Layout Template

We still have a lot of duplication in the views. Let's use a layout template
to reduce the amount of boilerplate we have to deal with.

Copy `views/index.erb` to a file called `views/layout.erb`. Open up the new
`layout.erb` file, and delete everything inside the <body> tags so that you
end up with this:

```erb
<html>
  <head>
    <title>IdeaBox</title>
  </head>
  <body>

  <%= yield %>

  </body>
</html>
```

If you reload the root page of your application and look at the source, you
should now see that it has duplicated all the <html> and <head> stuff.

We need to delete the boilerplate from the `index.erb` and the `edit.erb` files.

Go ahead and delete everything except what's inside the <body> tags.

### One idea or many?

If you open up your `idea.rb` file, you'll notice that most of the methods in
that file are not about a single idea, but about dealing with the storage and
retrieval of ideas.

Let's move the database stuff out of Idea into a separate class, `IdeaStore`.

Create a new file `idea_store.rb` in the root of your project, and move all of
the method definitions that start with `self.` out of `idea.rb` and into the
new `idea_store.rb`.

Go ahead and move `require 'yaml/store'` as well, since that is relevant to
the storage, not the idea itself.

We have to change the calls to `new` in `IdeaStore` so that they're calling
`Idea.new` instead.

Then we need to require the `idea_store` file from `app.rb`.

We also need to update the endpoints in the Sinatra app to talk to the
`IdeaStore` rather than `Idea`:

```ruby
require './idea'
require './idea_store'
class IdeaBoxApp < Sinatra::Base
  set :method_override, true

  not_found do
    erb :error
  end

  get '/' do
    erb :index, locals: {ideas: IdeaStore.all, idea: Idea.new}
  end

  post '/' do
    idea = Idea.new(params[:idea])
    idea.save
    redirect '/'
  end

  delete '/:id' do |id|
    IdeaStore.delete(id.to_i)
    redirect '/'
  end

  get '/:id/edit' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :edit, locals: {id: id, idea: idea}
  end

  put '/:id' do |id|
    IdeaStore.update(id.to_i, params[:idea])
    redirect '/'
  end
end
```

We're left with something odd. Our `idea.rb` file still has some database
specific stuff in it, in the `save` method, and in the Sinatra app, all of the
endpoints are talking to the IdeaStore, except the `POST /` endpoint.

By moving the database-related things into a separate class, we can see that
we didn't have a very consistent approach to how we're dealing with the
database.

Let's create a new method in `IdeaStore`:

```ruby
def self.create(attributes)
  database.transaction do
    database['ideas'] ||= []
    database['ideas'] << attributes
  end
end
```

Then we can call this method from the `POST /` endpoint in the web app,
allowing us to get rid of both the `save` and `database` method in Idea.

```ruby
post '/' do
  IdeaStore.create(params[:idea])
  redirect '/'
end
```

This is better.

### Project Structure

Until now we've pretty much been sticking everything into the root of the
project.

It looks like this:

```plain
idea_box/
├── Gemfile
├── Gemfile.lock
├── app.rb
├── config.ru
├── idea.rb
├── idea_store.rb
├── ideabox
└── views
    ├── edit.erb
    ├── error.erb
    ├── form.erb
    ├── index.erb
    └── layout.erb
```

Let's move towards a somewhat more idiomatic project structure.

We want to end up with the following:

```plain
idea_box/
├── Gemfile
├── Gemfile.lock
├── config.ru
├── db
│   └── ideabox
└── lib
    ├── app
    │   └── views
    │       ├── edit.erb
    │       ├── error.erb
    │       ├── form.erb
    │       ├── index.erb
    │       └── layout.erb
    ├── app.rb
    ├── idea_box
    │   ├── idea.rb
    │   └── idea_store.rb
    └── idea_box.rb
```

This puts all of our application under `lib/`, but separates the web-stuff
from the pure logic-stuff.

To get to that project structure we need to make a few changes:

Create new directories:

* `lib/`
* `lib/idea_box`
* `lib/app`
* `db`

Create a new file:

* `lib/idea_box.rb`

Move files to their new locations:

* `app.rb` -> `lib/app.rb`
* `views/` -> `lib/app/views/`
* `ideabox` -> `db/ideabox`
* `idea.rb` -> `lib/idea_box/idea.rb`
* `idea_store.rb` -> `lib/idea_box/idea_store.rb`

Update the require statements:

In `lib/app.rb`:

```ruby
require 'idea_box'
class IdeaBoxApp < Sinatra::Base
  # ...
end
```

In `lib/idea_box.rb`:

```ruby
require 'idea_box/idea'
require 'idea_box/idea_store'
```

In `config.ru`:

```ruby
require 'app'
```

For all of these require statements to work correctly, we need to put `lib` on
our PATH.  Add this to the very top of `config.ru`:

```ruby
$:.unshift File.expand_path("./../lib", __FILE__)
```

We also need to change the name of the database in `IdeaStore` to point to
the new location:

```ruby
class IdeaStore
  def self.database
    @database ||= YAML::Store.new('db/ideabox')
  end

  # ...
end
```

Finally, we need to tell the sinatra application where to look for its
templates:

```ruby
class IdeaBoxApp < Sinatra::Base
  set :method_override, true
  set :root, 'lib/app'
  # ...
end
```

There. Instead of a junk drawer, we have a project.

## I4: Ranking and Sorting

How do we separate the good ideas from the **GREAT** ideas? Let's implement
ranking and sorting.

First, we'll need to store a rank inside of our ideas.

Update the `lib/idea_box/idea.rb` to have a rank attribute:

```ruby
class Idea
  attr_reader :title, :description, :rank

  def initialize(attributes = {})
    @title = attributes["title"]
    @description = attributes["description"]
    @rank = attributes["rank"] || 0
  end

  def save
    IdeaStore.create("title" => title, "description" => description, "rank" => rank)
  end
end
```

That line inside of `save` is getting really long. Let's move the list of attributes into its own method called `to_h`, which is an idiomatic way of saying _to hash_.

```ruby
def save
  IdeaStore.create(to_h)
end

def to_h
  {
    "title" => title,
    "description" => description,
    "rank" => rank
  }
end
```

OK, so we have our rank, now let's make it possible to give an idea a higher rank.

In the `lib/app/views/index.erb` file, add the following form inside the list of ideas, maybe before the edit link:

```erb
<form action='/<%= id %>/like' method='POST' style="display: inline">
  <input type='submit' value="+"/>
</form>
```

Now, when you click the `+` button, you'll get a `not_found` error:

```plain
An Error Occured

Params

Request Verb	POST
Request Path	/0/like
Parameters
```

We need an endpoint in our Sinatra application that uses the `POST` HTTP verb, and has a path that matches `/:id/like`. Let's add it:

```ruby
post '/:id/like' do |id|
  "I like this idea!"
end
```

If you click it again, you should see _I like this idea!_ in the browser. That means that you've hooked up your Sinatra endpoint correctly.

First, let's find the right idea. We've done that before:

```ruby
post '/:id/like' do |id|
  idea = IdeaStore.find(id.to_i)
  "I like this idea!"
end
```

Then we'll _like_ it. That might look something like this:

```ruby
post '/:id/like' do |id|
  idea = IdeaStore.find(id.to_i)
  idea.like!
  "I like this idea!"
end
```

We need to make sure that our idea makes it back into the database:

```ruby
post '/:id/like' do |id|
  idea = IdeaStore.find(id.to_i)
  idea.like!
  IdeaStore.update(id.to_i, idea.to_h)
  "I like this idea!"
end
```

And finally, we're going to want to redirect back to the index page:

```ruby
post '/:id/like' do |id|
  idea = IdeaStore.find(id.to_i)
  idea.like!
  IdeaStore.update(id.to_i, idea.to_h)
  redirect '/'
end
```

Go ahead and try it out by clicking a `+` button by one of your ideas.

You should get a `NoMethodError` complaining that Idea doesn't know anything about a `like!` method.

Let's create it.

In `idea.rb` add the following:

```ruby
def like!
  @rank += 1
end
```

Then try liking another idea.

This should take you back to the index page, which probably won't look any different than it did. To see if it worked, take a look inside of your `db/ideabox` file.

One of your ideas should now have an extra line:

```yaml
---
ideas:
- title: get noticed
  description: wear barefoot shoes
  rank: 1
```

### Sorting ideas

We want to be able to sort ideas, so let's include the Ruby `Comparable` module in `Idea`:

```ruby
class Idea
  include Comparable
  # ...
end
```

For `Comparable` to help us, we have to tell it how two ideas compare to each other. The way we do that is with the so-called spaceship operator, which looks like this: `<=>`.

Add this method definition to your Idea class:

```ruby
def <=>(other)
  rank <=> other.rank
end
```

Now, in the `GET /` endpoint of your Sinatra app, go ahead an sort the ideas after you pull them out of IdeaStore:

```ruby
get '/' do
  erb :index, locals: {ideas: IdeaStore.all.sort, idea: Idea.new}
end
```

If you reload your root page, the idea you _like_d ended up at the bottom. We need to swap the spaceship operator around:

```ruby
def <=>(other)
  other.rank <=> rank
end
```

_like_ a few ideas, and see what happens.

Something _decidedly strange_ happens, that's what! If you look inside the database, the ideas you've been liking are not the ones with higher ranks. What's going on?

It turns out that our simplistic way of giving ideas an `id` based on their order in the list isn't cutting it. The id in the index page is based on the sort order, whereas the id when we update an idea is based on the position of the idea in the database.

Let's have the database tell the idea what its id is when it gets pulled out.

Add another attribute `id` to idea, along with its corresponding `attr_reader`:

```ruby
class Idea
  include Comparable
  attr_reader :title, :description, :rank, :id

  def initialize
    # ...
    @id = attributes["id"]
  end

  # ...
end
```

Then, in IdeaStore, tell the Idea what id it has:

```ruby
def self.all
  ideas = []
  raw_ideas.each_with_index do |data, i|
    ideas << Idea.new(data.merge("id" => i))
  end
  ideas
end

def self.find(id)
  raw_idea = find_raw_idea(id)
  Idea.new(raw_idea.merge("id" => id))
end
```

Next we have to update the index page to use this id rather than the index of the array of ideas:

```erb
<ul>
  <% ideas.each do |idea| %>
    <li>
      <form action='/<%= idea.id %>/like' method='POST' style="display: inline">
        <input type='submit' value="+"/>
      </form>
      <%= idea.title %><br/>
      <%= idea.description %>
      <a href="/<%= idea.id %>/edit">Edit</a>
      <form action='/<%= idea.id %>' method='POST'>
        <input type="hidden" name="_method" value="DELETE">
        <input type='submit' value="delete"/>
      </form>
    </li>
  <% end %>
</ul>
```

That takes care of showing ideas on the index page and liking the right ideas, but we've broken the `create` functionality.

Update the first line of `lib/app/form.erb` to use `idea.id` instead of `id`:

```erb
<form action='/<%= idea.id mode == "edit" %>' method='POST'>
```

Now that we have an `id` on the idea, we don't have to tell the edit page the id separately:

```ruby
get '/:id/edit' do |id|
  idea = IdeaStore.find(id.to_i)
  erb :edit, locals: {idea: idea}
end
```

Then, in the edit page, change `id` to `idea.id`.

Notice how we have an id on ideas in the database, but that value is nil if the idea was just created with `Idea.new`?

This means that we can get rid of the hacky `mode` variable that we send to the `new` and `edit` forms.

Open up the `lib/app/view/form.erb` and change it to this:

```erb
<form action='/<%= idea.id %>' method='POST'>
  <p>
    <% if idea.id %>
      Edit your Idea:
    <% else %>
      Your Idea:
    <% end %>
  </p>
  <% if idea.id %>
    <input type="hidden" name="_method" value="PUT" />
  <% end %>
  <input type='text' name='idea[title]' value="<%= idea.title %>"/><br/>
  <textarea name='idea[description]'><%= idea.description %></textarea><br/>
  <input type='submit'/>
</form>
```

Now we can delete the stray `mode` variables. There's one in `index.erb` and one in `edit.erb`.

Delete your database, restart your application, and try adding, deleting, editing, and voting on ideas.

We've managed to break the application yet again!

In IdeaStore, we don't actually create an empty array in the database until we create the first idea, but we want to get all the ideas and loop through them to show them on the root page. Since they're nil, the page is blowing up.

Let's fix this by always making sure that the database has an empty array of ideas when we load it up:

```ruby
def self.database
  return @database if @database

  @database = YAML::Store.new('db/ideabox')
  @database.transaction do
    @database['ideas'] ||= []
  end
  @database
end
```

Since we now know that the database always has an array of ideas on it, we can simplify the `create` method:

```ruby
def self.create(data)
  database.transaction do
    database['ideas'] << data
  end
end
```

There. This time we really are done.

## Extensions

Your application is able to capture, rank and sort ideas. If only that was enough
for you. The following extensions allow you to define additional features to
make your application more dynamic and interesting.

### Tagging

Besides viewing ideas in ranked order  it would be great if you could also view
ideas that are similar to one another or share the same thing that ignited the
idea.

* When you create an idea you can specify one or more tags.
* A tag is a single phrase, a single word or fragment sentence, that you use
  to describe an idea.
* Each idea can have one or more tags
* You are able to view all ideas for a given tag
* You are able to view all ideas sorted by tags

### Statistics

After creating ideas you want to start tracking when you create your ideas.

* When ideas are created the time they were created is captured.
* You are able to view a breakdown of ideas created across the hours of the day
  (e.g. 12:00AM to 12:59AM, 1:00AM to 1:59AM)
* You are able to view a breakdown of ideas created acorss the days of the week
  (i.e. Mon, Tue, Wed, Thu, Fri, Sat, Sun)

### Revisions

You start with an idea that eventually changes over time. Where you started from
and where you ended is a very different place. Sometimes you would like to see
the evolution of an idea.

* When you edit and save an idea the previous version of the idea is also saved.
* An idea now has a history or list of revisions
* You are able to view the history of an idea

### Grouped Ideas

Tagging allows for you to view ideas that within a certian category. Sometimes
you want to differentiate your work ideas from your personal ideas.

* By default all ideas are added to a default group
* You are to define additional groups
* When you create an idea you can specify the group for that idea
* An idea can only belong to a single group
* You can view only the ideas contained in a particular group
* When sorting ideas on rank or tags only the ideas within that group are sorted

### Mobile Friendly

Ideas strike like lightning and it is important to be able to be able to enter
your ideas from a small-screen device. While the original site works with a
mobile device, it would be great to optimize the experience.

* You are able to add, view, and edit ideas easily through a mobile browser.

### Searching for Idea

After creating so many ideas it becomes hard to manage all the ideas. It would
be great if you could search for a specific idea based on a word or phrase
contained within an idea.

* The main index page has a search field
* The search field allows you to specify a phrase.
* A phrase is a word or or fragment sentence
* When search is initiated the contents of the search field will be used to
  find only the ideas with that contain the phrase, case insensitive, provided
  within the search field.

### Fuel

With your defined ideas it would be great to start adding more details and
resources for each of those ideas.

* For each idea you can add a new resource
* A resource is text or link related to the idea
* You are not able to see the resources of an idea on the index page
* You are able to view all the resources for an idea when you view the details
  of an idea.

### Haml

You have templated your application with ERB. It might be interesting to see
what it would look like using Haml.

* Replace all the *erb* templates with *haml* templates.

### Image Upload

Pictures are worth a 1000 words.

* When you create an idea you can specify an image
* When you create a resource for an idea you can specify an image
* You are able to upload an image that will be associated with the idea
* When viewing an idea the image is displayed within the idea
* When viewing a resource the image is displayed within that resource

### Sound Upload

The power of the spoken word

* When you create an idea you can specify an sound
* When you create a resource for an idea you can specify an sound
* When viewing an idea the sound is displayed as a downloadable link
* When viewing a resource the sound is displayed as a downloadable link

### SMS Integration

Faster than even a mobile website might be the ability to define ideas through
text message.

* You able to text a new idea to a particular phone number
* The message from the text appear in your list of ideas

### Users

Currently you can only track the ideas of one person. What would help you to
generate ideas is if you could take idea generation socially

* A person is able to generate a user account
* A user account has a username
* When viewing a user's page you are only able to the ideas for that user
* When viewing a user's page you are able to add ideas as previously defined

> At the moment we are not going to discuss the policies for good password
> creation and rentention or maintaining a logged in user. The idea of a
> user in this implementation simply allows you to segment the ideas across
> users. Any person viewing a user's page can add a new idea for that user.
