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

We're going to depend initially on three external gems in our `Gemfile`:

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

### Storing Data

Almost every web application is backed by a database that stores its data. Let's look at how we can use the SQLite3 database engine to store our ideas.

#### Connecting to the Database

What's the right way to share the database connection across different objects in our system? Let's not worry about that yet. Instead, make something work then make it better.

The first problem in front of us is how to make `Idea#save` work, so instances of `Idea` need access to the db. The first, easiest way would be to setup the connection when the object is created:

```ruby
class Idea < Sequel::Model
  attr_reader :database

  def initialize
    @database = Sequel.sqlite('./db/idea_box.sqlite3')
  end

  def save

  end
end
```

That `initialize` simply opens the db for later use through the `database` method.

**NOTE**: Hop over to your editor or file system and **create folder named `db`** under the root folder that'll hold your database. SQLite3 will create the database file on the fly, but not the directory!

**NOTE 2**: If you're not familiar with SQL, pause here and jump over to [our Fundamental SQL](http://tutorials.jumpstartlab.com/topics/fundamental_sql.html) tutorial. Then check out our [Getting Started with Sequel](http://tutorials.jumpstartlab.com/topics/sequel.html) to understand how the library works.

#### Simplistic Save

With that database connection made, let's write a `save` method:

```ruby
def save
  database[:ideas].insert()
end
```

Which presumes that our database has a table named `ideas`. We'd better make that table.

#### Building the `ideas` Table

There are several ways we could create the `ideas` table in the database:

* Manually through the database's command-line interface
* Through Sequel's methods available through `Database`
* Using a Sequel migration

The migration is probably the long-run choice, but let's make it work with a method.

The process of creating the database table should be a one-time process, but it'll happen whenever our application is deployed on a new machine.

This functionality is tied to the idea of a model, but it's not a part of a single model instance. It belongs to the class, the general idea of `Idea`:

```ruby
def self.create_table
  database.create_table :ideas do
    primary_key :id
    String      :title, :size => 255
    Text        :description
  end
end
```

We use the [`create_table` method from Sequel](http://sequel.rubyforge.org/rdoc/classes/Sequel/Database.html#method-i-create_table) to define a table with the name `ideas`, and columns `id`, `title`, and `description`.

When should this method be run? The ideal time is probably when the application starts up, but for now let's run it in `initialize`:

```ruby
  def initialize
    Idea.create_table
    @database = Sequel.sqlite('./db/idea_box.sqlite3')
  end
```

#### Testing Ideas in the Database

We're building some complex functionality here. Let's see if things are actually working.

From a terminal in the project directory, fire up IRB:

{% irb %}
$ bundle exec irb
> Bundler.require
 => [<Bundler::Dependency type=:runtime name="sinatra" requirements=">= 0">, <Bundler::Dependency type=:runtime name="sequel" requirements=">= 0">, <Bundler::Dependency type=:runtime name="sqlite3" requirements=">= 0">, <Bundler::Dependency type=:runtime name="shotgun" requirements=">= 0">] 
> require './models/idea'
 => true 
1.9.3-p385 :003 > idea = Idea.new
NameError: undefined local variable or method `database' for Idea:Class
  from /Users/jcasimir/Dropbox/Projects/idea_box/models/idea.rb:10:in `create_table'
  from /Users/jcasimir/Dropbox/Projects/idea_box/models/idea.rb:5:in `initialize'
  from (irb):3:in `new'
  from (irb):3
  from /Users/jcasimir/.rvm/rubies/ruby-1.9.3-p385/bin/irb:16:in `<main>'
{% endirb %}

Ah-ha! Loading `idea.rb` goes fine, but when we actually create an instance we get an exception: `undefined local variable` for `database`.

If you look at the `.create_table` method it refers to the method `#database`. But that's an instance method, so here inside a class method it's not available.

We'll need to move the database connection up to the class level scope. As long as we're doing that, we should move the call to create table there too:

```ruby
class Idea
  def initialize
  end

  def save
    database[:ideas].insert()
  end

  def self.database
    @database ||= Sequel.sqlite('./db/idea_box.sqlite3')
  end

  def self.create_table
    database.create_table :ideas do
      primary_key :id
      String      :title, :size => 255
      Text        :description
    end
  end
end
```

Let's check it out in IRB again:

{% irb %}
> exit
% bundle exec irb
> Bundler.require
 => [<Bundler::Dependency #... 
> require './models/idea'
 => true 
> idea = Idea.new
 => #<Idea:0x007fc72341e938> 
> Idea.database
 => #<Sequel::SQLite::Database: {:adapter=>:sqlite, :database=>"./db/idea_box.sqlite3"}> 
> Idea.create_table
 => nil 
{% endirb %}

If you look in your project's `db` folder there should now be a file `idea_box.sqlite`! We're making progress.

Then try `#save` on the `idea` we initialized:

{% irb %}
> idea.save
NameError: undefined local variable or method `database' for #<Idea:0x007fa8033b2588> #...
{% endirb %}

A scope problem again. The `#save` method is running in the instance scope, but the `database` method is defined at the class level. Calling a class method from the instance scope is not as easy as adding `self` because that refers to the instance. Instead, the easiest way is to refer to the class by name:

```ruby
def save
  Idea.database[:ideas].insert()
end
```

Then, to test it again in a **new** IRB session:

{% irb %}
> Bundler.require
 => [<Bundler::Dependency #...
> require './models/idea'
 => true 
> idea = Idea.new
 => #<Idea:0x007fbaa33993a0> 
> idea.save
 => 1 
{% endirb %}

Yes! That `1` means that one row was stored to the database!

#### Back to the Web

Remember like 3 pages ago we were building a web application? Let's hop over there and see what's going on.

* Hop back to `http://localhost:9393/` in your browser
* Enter an idea in the form
* Click `Submit`

Are you surprised to see an exception? I get a different error page about `Rack::Lint::LintError` complaining about the status must be >=100. What's happening?

Go back and look at the `/create` path we were working on earlier. Right now the last line of code is `idea.save`. You just saw that the `.save` method, in IRB, returns `1` after inserting one row into the database.

Since it's the last line of code in this block it becomes the return value. Sinatra assumes we're trying to set the HTTP status code to `1`, then Rack freaks out because that's not valid.

Instead, let's implement the step 3 of our `/create`, redirecting back to the root page:

```ruby
post '/create' do
  # 1. Create an idea based on the form parameters
  idea = Idea.new
  
  # 2. Store it
  idea.save

  # 3. Send us back to the index page to see all ideas
  redirect to('/')
end
```

Go back to your root page, submit the form again, and...

It clears? Did it work? Maybe? Our index page isn't displaying the stored ideas, so we have no idea if they're there.

#### Ideas in the View Template

Hop over to the `index.erb` and add a bit of HTML to display the known ideas, assuming that the instances are stored in a variable `@ideas`. In Sinatra, instance variables are shared between the controller (our `/` block) and the view template:

```erb
<h3>Existing Ideas</h3>
<ul>
  <% @ideas.each do |idea| %>
    <li>
      <%= idea.id %>: <%= idea.title %><br/>
      <%= idea.description %>
    </li>      
  <% end %>
</ul>
```

We want to output the ID number, title, and description. Refresh the page and you'll get that old friend, `undefined method 'each' for nil:NilClass`. The variable `@ideas` is nil.

#### Querying for the `@ideas`

Back in `application.rb`, our root block looks like this:

```ruby
get '/' do
  erb :index
end
```

But we need to create `@ideas` with all the idea instances. We could connect to the database and query them directly right here, but the responsibility for data access belongs to the model layer. We should delegate the responsibility to the `Idea` class:

```ruby
get '/' do
  @ideas = Idea.all
  erb :index
end
```

Refresh the browser and you'll get `undefined method 'all' for Idea:Class`.

#### Implementing `Idea.all`

In the `idea.rb`, we can sketch an `.all` method like this:

```ruby
def self.all
  # Find all the rows in the table
  # Create an instance from each row of the table
  # Return those instances
end
```

##### Finding the Rows

We've already done the heavy lifting of connecting to the database and making a wrapper method. So getting back all the rows is just a single method call:

```ruby
rows = database.select
```

##### Creating and Gathering Instances

To make it easy on ourselves, let's make the initialize method take in a row. We know from the table structure that we'll get back a hash like `{:id => 1, :title => "First Idea", :description => "A first idea"}`.

Then in our `.all` we could do this:

```ruby
rows = database.select
ideas = rows.collect{|row| Idea.new(row)}
```

Or simplify it down to one line and remove unnecessary variables:

```ruby
database.select.collect{|row| Idea.new(row)}
```

But that won't work yet because our initialize isn't setup to take a parameter.

##### Rebuilding Initialize

We should modify initialize to take in a single parameter (a hash), and to store the values into instance variables. I'll add an `attr_reader` for those too:

```ruby
attr_reader :id, :title, :description

def initialize(input)
  @id          = input[:id]
  @title       = input[:title]
  @description = input[:description]
end
```

##### All Together

Here's the `Idea` class all together:

```ruby
class Idea
  attr_reader :id, :title, :description

  def initialize(input)
    @id          = input[:id]
    @title       = input[:title]
    @description = input[:description]
  end

  def save
    Idea.database[:ideas].insert()
  end

  def self.database
    @database ||= Sequel.sqlite('./db/idea_box.sqlite3')
  end

  def self.create_table
    database.create_table :ideas do
      primary_key :id
      String      :title, :size => 255
      Text        :description
    end
  end

  def self.all
    database[:ideas].select.collect{|row| Idea.new(row)}
  end
end
```

Refresh your browser and you should see progress. No errors, but the only data that shows up is the ID number!

### Fixing the Data

Right now we're negligent with our data. Let's look at the data flow:

* The user sees the `index.erb` page
* They enter data into the form and click submit
* That data goes into the `/create` block
* Then what?

The form has submitted a `POST` request and the data from the form comes in the request body. We could pick through the request object ourselves, but instead Sinatra makes them available through the `params` method.

#### Understanding `params`

Let's take a look at `params`. Modify your `/create` block like this:

```ruby
post '/create' do
  raise params.inspect
  # 1. Create an idea based on the form parameters
  idea = Idea.new
  
  # 2. Store it
  idea.save

  # 3. Send us back to the index page to see all ideas
  redirect to('/')
end
```

Then, in the browser, fill in the form on the root page and click submit. You'll get the error page and the error message will be the contents of the return value of `params`, a hash:

```
RuntimeError at /create
{"idea_name"=>"Hello", "idea_description"=>"World"}
```

Ah-ha. Our two pieces of data are there. We just need to access them and send them into the `Idea.new` call:

```ruby
post '/create' do
  idea = Idea.new(:title => params['idea_name'], 
                  :description => params['idea_description'])
  idea.save
  redirect to('/')
end
```

#### Looking at `Idea#initialize`

Over in the model we need to check out our `initialize` method:

```ruby
def initialize(input)
  @id          = input[:id]
  @title       = input[:title]
  @description = input[:description]
end
```

It's already setup to deal with `input[:title]` and `input[:description]`, so that should work.

In the `/create` block, after creating the object, `#save` is called.

#### Reviewing `Idea#save`

Our `#save` method currently looks like this:

```ruby
def save
  Idea.database[:ideas].insert()
end
```

That's not good enough. It's inserting a row with no data. The only data that will appear in the database is the automatically-assigned `id`, which is why we were seeing the `id` numbers on the index page.

Let's modify the `insert` call to send the attributes from this instance:

```ruby
def save
  Idea.database[:ideas].insert(:title       => title,
                               :description => description)
end
```

No `id`? Let the database deal with that. Just send in the data which was previously take in from the form, the title and description.

#### Trying It Out

Go back to the root page in your browser. Fill in the form, click submit, and you should be returned to the root page with your idea displayed last in the list.

#### Changing the Sort

It seems like the most recent idea should appear at the top. Since the IDs are sequential, we can reverse-sort them by ID.

In your `Idea.all` method:

```ruby
def self.all
  database[:ideas].select.collect{|row| Idea.new(row)}
end
```

Becomes:

```ruby
def self.all
  database[:ideas].order(:id).collect{|row| Idea.new(row)}.reverse
end
```

Which would reverse the objects at the Ruby level. It's probably smarter and faster to reverse them at the datbase level:

```ruby
def self.all
  database[:ideas].order(Sequel.desc(:id)).collect do |row| 
    Idea.new(row)
  end
end
```

#### Refactoring `Idea`

##### Simplifying `database[:ideas]`

The repetition of `database[:ideas]` a few places in `Idea` is bugging me. Let's pull out a `data` method:

```ruby
def self.data
  database[:ideas]
end
```

Then our `#save` method becomes:

```ruby
def save
  Idea.data.insert(:title       => title,
                   :description => description)
end
```

And `.all` becomes:

```ruby
def self.all
  data.order(Sequel.desc(:id)).collect do |row| 
    Idea.new(row)
  end
end
```

##### Table Creation

We manually ran the `Idea.create_table` method from IRB earlier. It would be cool if the table could be created on the fly as needed.

We can make use of the `create_table?` method in Sequel that only create's the table if needed:

```ruby
def self.create_table
  database.create_table? :ideas do
    primary_key :id
    String      :title, :size => 255
    Text        :description
  end
end
```

Then we could call this method within `Idea.database`:

```ruby
def self.database
  create_table
  @database ||= Sequel.sqlite('./db/idea_box.sqlite3')
end
```

Now the method will get run everytime we call `database` or `data`. That sounds like it might have some performance impact as the system is constantly checking the table's existance. Let's break out a verify method:

```ruby
def self.verify_table_exists
  @table_exists ||= (create_table || true)
end
```

* The first time this method is run `@table_exists` is nil, so it executes the right side of the `||=`
* `create_table` executes, running Sequel's `create_table?` method
* Sequel's `create_table?` always returns `nil`, so Ruby keeps evaluating the `||`
* Ruby hits the `true`, which is then the result of the `||`
* The `true` is then the result of the `||=` and is stored into `@table_exists`
* Next time this method runs `@table_exists` is already `true`, so the right side is not run

This will be a very quick method the second time it's run. We just need to call it. If we put it in `Idea.database` we'll end up with an infinite loop (`Stack Level Too Deep`), so instead it fits into the `data` method. 

Here are the four methods all together:

```ruby
def self.database
  @database ||= Sequel.sqlite('./db/idea_box.sqlite3')
end

def self.data
  verify_table_exists
  database[:ideas]
end

def self.verify_table_exists
  @table_exists ||= (create_table || true)
end

def self.create_table
  database.create_table? :ideas do
    primary_key :id
    String      :title, :size => 255
    Text        :description
  end
end
```

To test it:

* Stop your server with `CTRL-C`
* Delete the `db/idea_box.sqlite3` database file
* Restart the server
* Visit the root page in your browser
* It should load correctly and display no ideas
* Add an idea using the form
* Tada!

## I2: Editing and Destroying

## I3: Ranking and Sorting

## I4: Extensions
