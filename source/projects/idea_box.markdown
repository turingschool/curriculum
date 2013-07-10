---
layout: page
title: IdeaBox
---

Every developer has more ideas than time. As David Allen likes to say "the
human brain is for creating ideas, not remembering them." Let's build a system
to record your good, bad, and awful ideas.

And let's use it as an excuse to learn about Sinatra.

## I0: Getting Started

### Envioronment Setup

For this project you need to have setup:

* Ruby 1.9.3
* Ruby's Bundler gem

### File/Folder Structure

Let's start our project with the minimum and build up from there. We need:

* a project folder
* a `Gemfile`
* an `app.rb` file

### `Gemfile`

We're going to depend on an external gem in our `Gemfile`:

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
it looks like this.

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

Refresh the page. The string that sending as the response has structure, and
the browser understands that structure and has opinions about what it should
look like.

This is clearly not a very maintainable approach. We need to find a better way
to render the response.

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

The easiest way to get automatic reloading is to use the `shotgun` gem.

First, add `shotgun` to your `Gemfile`:

```ruby
gem 'shotgun'
```

Then run `bundle` from your terminal to install the gem.

Kill your server process (`CTRL-C`) and restart it using `shotgun`:

{% terminal %}
$ shotgun
== Shotgun/WEBrick on http://127.0.0.1:9393/
[2013-02-26 17:41:28] INFO  WEBrick 1.3.1
[2013-02-26 17:41:28] INFO  ruby 1.9.3 (2013-02-06) [x86_64-darwin11.4.2]
[2013-02-26 17:41:28] INFO  WEBrick::HTTPServer#start: pid=9648 port=9393
{% endterminal %}

Shotgun knows to use the `config.ru` file to start your application, so you
don't have to tell it where to look.

By default Shotgun starts the server on port `9393`, not `9292` like `rackup`
or `4567`, the Sinatra default.

Go ahead and tell shotgun to use the port we've been using all along:

{% terminal %}
$ shotgun -p 4567
{% endterminal %}

Go to [localhost:4567](http://localhost:4567).

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

Preview it in the browser. Pretty ugly, eh? Go ahead and fill in a title and
brief description, then hit `Submit`.

#### Sinatra Doesn't Know This Ditty

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
[API for
`Rack::Request`](http://rack.rubyforge.org/doc/classes/Rack/Request.html).

#### Creating `/`

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

Create a file named `idea.rb` with these contents:

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
automatically load any files. At the top of your `app.rb`:

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
  database.transaction do
    db['ideas'] ||= []
    db['ideas'] << {title: 'amazing idea', description: 'eat pizza for lunch'}
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
require './idea'
\=> true
idea = Idea.new
\=> #<Idea:0x007f86fc04a0a8>
idea.save
\=> NameError: uninitialized constant Idea::YAML
{% endirb %}

Ah-ha! Loading `idea.rb` goes fine, but when we try to save, it blows up in
`save` when it calls database. It doesn't know what `YAML` is.

Let's just tell irb to load `YAML`, then try to save again:

{% irb %}
require 'yaml'
idea.save
\=> NameError: uninitialized constant Psych::Store
{% endirb %}

OK, so we get a new error message. We didn't require quite enough stuff.

The thing we're using in the `database` method, `YAML::Store`, is a
wrapper around `Psych::Store`.

We can pull it in by requiring 'yaml/store'

{% irb %}
require 'yaml/store'
idea.save
\=> {title: 'amazing idea', description: 'eat pizza for lunch'}
{% endirb %}

Did it work?

Within IRB you can look at what's in the database:

{% irb %}
idea = Idea.new
idea.database.transaction { idea.database['ideas'] }
\=> [{:title=>"diet", :description=>"pizza all the time"}]
{% endirb %}

What happens if we save another one?

{% irb %}
idea = Idea.new
idea.save
idea.database.transaction { idea.database['ideas'] }
\=> [{:title=>"diet", :description=>"pizza all the time"}, {:title=>"diet", :description=>"pizza all the time"}]
{% endirb %}

They're definitely going into the database. It's kind of pointless, since
we're saving the same idea over and over again, but the basic functionality is
working.

Before we move on, remember to add `require 'yaml/store'` to the top of `idea.rb`.

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
idea = Idea.new
idea.database.transaction { idea.database['ideas'] }
\=> [{:title=>"diet", :description=>"pizza all the time"}, {:title=>"exercise", :description=>"play video games"}]
{% endirb %}

#### Saving real ideas

Rather than saving the same tired pizza idea every time, let's let our idea
take real ideas and save those in the database.

I want this to look something like this:

```ruby
idea = Idea.new("app", "social network for dogs")
idea.save
```

What happens if we try doing this in IRB?

{% irb %}
idea = Idea.new("app", "social network for dogs")
\=> ArgumentError: wrong number of arguments(2 for 0)
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
require './idea'
idea = Idea.new("app", "social network for dogs")
\=> #<Idea:0x007f7f608472b8>
idea.save
\=> [{:title=>"diet", :description=>"pizza all the time"}, {:title=>"exercise", :description=>"play video games"}, {:title=>"diet", :description=>"pizza all the time"}]
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
  database.transaction do
    database['ideas'] ||= []
    database['ideas'] << {title: title, description: description}
  end
end
```

Restart your IRB session and try this out:

{% irb %}
require './idea'
Idea.new("app", "social network for dogs").save
Idea.new("excursion", "take everyone to the zoo").save
Idea.new("party", "dance all night and all day").save
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

We changed the `initialize` method to take `title` and `description`, so the
error makes sense.

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
{"idea_title"=>"sing", "idea_description"=>"songs"}
```

Now we can use the keys that we see here to give our new `Idea` what it needs:

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

We get an error: `NameError: undefined local variable or method `ideas'`. The
error is occurring on line 20 of the `views/index.erb`.

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

Since we're programming by wishful thinking, let's see what our application
thinks about this. Reload the root page of the app.

```plain
NoMethodError: undefined method `all' for Idea:Class
```

Well, that's not entirely unexpected. We never defined a method `all` for
`Idea`.

#### Implementing `Idea.all`

```ruby
class Idea
  def self.all
    database.transaction do
      database['ideas']
    end
  end

  # ...
end
```

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
  database.transaction do
    database['ideas']
  end.map do |data|
    Idea.new(data[:title], data[:description])
  end
end
```

This works, but it's pretty nasty. Let's call the hash version of an idea a
`raw_idea`:

```ruby
def self.all
  raw_ideas.map do |data|
    Idea.new(data[:title], data[:description])
  end
end

def self.raw_ideas
  database.transaction do
    database['ideas']
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

## I3: Ranking and Sorting

## I4: Extensions
