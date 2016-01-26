---
layout: page
title: Task Manager
---

Let's use Sinatra to build an application where we can manage our tasks. 

### Getting Configured

Let's make a project folder from the command line: `mkdir task_manager`. Go into the directory with `cd task_manager`. 

We'll also need a Gemfile: `touch Gemfile`. Inside of your Gemfile, add Sinatra and Shotgun. [Shotgun](https://github.com/rtomayko/shotgun) will allow us to make changes to our code base without having to restart the server each time. 

```ruby
source 'https://rubygems.org'

gem 'sinatra', require: 'sinatra/base'
gem 'shotgun'
```

We will be using the [modular](http://www.sinatrarb.com/intro.html#Modular%20vs.%20Classic%20Style) style of Sinatra app, which is why we need to require 'sinatra/base'.

Next, let's make a config file from the command line: `touch config.ru`. This file will be used by Rackup. Add this code inside of the config file: 

```ruby
require 'bundler'
Bundler.require

$LOAD_PATH.unshift(File.expand_path("app", __dir__))

require 'controllers/task_manager_app'

run TaskManagerApp
```

The first two lines of this file allow all of your gems to be required. Then, we change the load path so that everything inside of our `app` folder (we haven't created it yet) can be required. Next, we require a file called `task_manager_app` that will be inside of our `controllers` folder. Finally, we call the run method and specify that our app is called TaskManagerApp.

Go ahead and run `bundle install` from the command line. 

### Project Folder Structure

So far, we just have a Gemfile, config.ru, and Gemfile.lock. Let's create the folders we'll need for our Task Manager. 

```
$ mkdir app
$ mkdir db
```

We'll use the `app` folder for all of our implementation code. Our `db` folder will hold our fake database (we're going to use a [YAML](http://www.yaml.org/) file, not a real database).

We'll need a few folders inside of our app folder so that we can separate our files.

```
$ mkdir app/controllers
$ mkdir app/models
$ mkdir app/views
```

Although we could put all of our code inside of the same folder (or even most of it in the same file), we're going to use this structure to mimic the [MVC](http://www.codelearn.org/ruby-on-rails-tutorial/mvc-in-rails) setup that Rails will give us. 

### Getting the App Running

Ok, so we have our project structure. Let's now get our app up and running! Make a file inside of app/controllers called `task_manager_app.rb`:

```
$ touch app/controllers/task_manager_app.rb
```

Inside of it, add the following code:

```ruby
class TaskManagerApp < Sinatra::Base
  set :root, File.expand_path("..", __dir__)

  get '/' do
    'hello, world!'
  end
end
```

Remember when we wrote `run TaskManagerApp` in our `config.ru` file? Well, the class we just defined is what that line in our config.ru refers to.

Line 2 sets the root of our project. Here, we're taking the current file (`app/controllers/task_manager_app`) and going one folder up the chain. This should take us to our `app` folder. The reason we're doing this is because Sinatra will look relative to our app for views and stylesheets. We don't want to put these things in our controller folder, so we're specifying that our root is just `app`.

Next, we tell our app that when a `get` request is sent to the `'/'` path, it should send back 'hello, world!' as the response. Let's try it!

From the command line, change back into the `task_manager` directory where the `config.ru` file is and run:

```
$ shotgun
```

Navigate to http://localhost:9393/ and you should see magic!

### Using Views

Let's change our controller to render an ERB view instead of 'hello, world!'. Inside of `task_manager_app.rb`:

```ruby
class TaskManagerApp < Sinatra::Base
  set :root, File.expand_path("..", __dir__)

  get '/' do
    erb :dashboard
  end
end
```

This piece of code will look for an .erb file called 'dashboard' in the views folder at the root of the app. Since we've already set the root of the app and created a views folder there, we're ready to make a dashboard file. If you're still running your server, press control+c to stop it. 

```
$ touch app/views/dashboard.erb
```

Inside of this file, let's add links to some functionality we might want in our app:

```erb
<h1>Welcome to the Task Manager</h1>

<ul>
  <li><a href="/tasks">Task Index</a></li>
  <li><a href="/tasks/new">New Task</a></li>
</ul>
```

We have an h1 tag for our welcome message, then an unordered list (ul) with two list items (li) inside. If you are unfamiliar with HTML tags, try one of the [HTML tutorials](https://github.com/turingschool/intermission-assignments/blob/master/prep-for-module-2.markdown) before continuing. 

Inside of each li tag, we have an `a` tag. The href of the tag is the path where the link will go. In the first a tag, the path will be `http://localhost:9393/tasks`. The second path will be `http://localhost:9393/tasks/new`. 

Restart your server with `shotgun` from the command line, then refresh the page. You should see our welcome message and two links. We haven't set up our controller to handle either of these yet, so clicking on these should give us a "Sinatra doesn't know this ditty" error. 

### Adding a Task Index Route

In a Sinatra app, we can add routes by combining an HTTP verb (get, post, put, delete, etc.) with a URL pattern. If you're unfamiliar with HTTP verbs, check out [A Beginner's Guide to HTTP and REST](http://code.tutsplus.com/tutorials/a-beginners-guide-to-http-and-rest--net-16340). 

Our controller currently has one route:

```ruby
  get '/' do
    erb :dashboard
  end
```

Let's add a route for the first link we want -- our Task Index. In `app/controllers/task_manager_app.rb`:

```ruby
class TaskManagerApp < Sinatra::Base
  set :root, File.expand_path("..", __dir__)

  get '/' do
    erb :dashboard
  end

  get '/tasks' do
    @tasks = ["task1", "task2", "task3"]
    erb :index
  end
end
```

What are we doing here? Well, we create an instance variable `@tasks` and assign an array of three strings to it. Then, we render the `index.erb` file. Our instance variable will be available to use in the view. 

Let's try rendering this array in the view. First, we need to create our `index.erb`:

```
$ touch app/views/index.erb
```

Inside of the view, we will iterate through the array and display each string:

```erb
<h1>All Tasks</h1>

<% @tasks.each do |task| %>
  <h3><%= task %></h3>
<% end %>
```

Navigate to `http://localhost:9393/tasks` and check that each task is displayed. Our `index.erb` is looking ok right now.

### Adding a New Task Route

We need a route that will bring a user to a form where they can enter a new task. This is the second link we had in our dashboard. In our controller:

```ruby
class TaskManagerApp < Sinatra::Base
  set :root, File.expand_path("..", __dir__)

  get '/' do
    erb :dashboard
  end

  get '/tasks' do
    @tasks = ["task1", "task2", "task3"]
    erb :index
  end

  get '/tasks/new' do
    erb :new
  end
end
```

We don't need any instance variables here; we just need to render the view. Let's make that view:

```
$ touch app/views/new.erb
```

In that file, we'll add a form:

```erb
<form action="/tasks" method="post">
  <p>Enter a new task:</p>
  <input type='text' name='task[title]'/><br/>
  <textarea name='task[description]'></textarea><br/>
  <input type='submit'/>
</form>
```

Here we have a form with an action (url path) of `/tasks` and a method of `post`. This combination of path and verb will be important when we create the route in the controller. We then have an text input field for the title, a textarea for the description, and a submit button. 

Navigate to `http://localhost:9393/tasks/new` to see your beautiful form!

Try clicking the submit button. You should get a "Sinatra doesn't know that ditty" error because we haven't set up a route in our controller to handle this action - method combination from the form submission.

In our controller:

```ruby
class TaskManagerApp < Sinatra::Base
  set :root, File.expand_path("..", __dir__)

  get '/' do
    erb :dashboard
  end

  get '/tasks' do
    @tasks = ["task1", "task2", "task3"]
    erb :index
  end

  get '/tasks/new' do
    erb :new
  end

  post '/tasks' do
    "<p>Params: #{params}</p> <p>Task params: #{params[:task]}</p>"
  end
end
```

Why `post` instead of `get`? First, we specified a method of post in our form (go look at the form if that sentence doesn't make sense to you). Although we could make it work using `get`, HTTP convention specifies that a `get` request should request data from a specified resource while a `post` should submit data to be processed. In our case, we are submitting form data that needs to be processed, so we're using `post`. 

Inside of this route, we'll need to eventually do some work. But for right now, we're just displaying the params.

Go back to `http://localhost:9393/tasks/new`. Fill in a fake title and a fake description. Click submit. On the page, you should see something like:

```
Params: {"task"=>{"title"=>"Make cookies", "description"=>"Chocolate chip cookies are so delicious. I am hungry."}}

Task params: {"title"=>"Make cookies", "description"=>"Chocolate chip cookies are so delicious. I am hungry."}
```

Notice that `params` is just a hash. The key is `"task"` and the value is another hash containing the `title` and `description`. This structure was created because of the way we named the input fields in our form (go back and look at the form if this is confusing to you). 

When we access `params[:task]`, we get back just the part we want; the title and description. This is what we'll use to build a task.

### Saving Tasks

Let's change the code inside of our controller. Find the `post '/tasks'` route:

```
  post '/tasks' do
    task_manager.create(params[:task])
    redirect '/tasks'
  end

  def task_manager
    database = YAML::Store.new('db/task_manager')
    @task_manager ||= TaskManager.new(database)
  end
```

We are going to delegate the creation of a task to an instance of the TaskManager class. You can think of this class as one whose job it is to manage all of our tasks. Once the task is created, we'll redirect to `'/tasks'` (our index) so that the user can see the task. 

First, we'll need to require this class in our controller. At the top of the controller file, add this line:

```ruby
require 'models/task_manager'
```

We will also need to create this class which will live in our `models` folder. From the command line:

```
$ touch app/models/task_manager.rb
```

Inside of that file, we'll add the following code:

```ruby
require 'yaml/store'

class TaskManager
  attr_reader :database

  def initialize(database)
    @database = database
  end

  def create(task)
    database.transaction do
      database['tasks'] ||= []
      database['total'] ||= 0
      database['total'] += 1
      database['tasks'] << { "id" => database['total'], "title" => task[:title], "description" => task[:description] }
    end
  end
end
```

First, we require `'yaml/store'` which will allow us to store data in a specific file using [YAML](http://en.wikipedia.org/wiki/YAML) format. This is part of the [Ruby standard library](http://ruby-doc.org/stdlib-1.9.3/libdoc/yaml/rdoc/YAML.html). 

Next, define a reader for `database` (`attr_reader :database`) which will return an instance of our YAML::Store using the "db/task_manager" file. This file will be created if it does not already exist. 

Finally, we define an instance method `create(task)` which will accept a task hash (remember `params[:task]`?). We call the `transaction` method on our `database`, which will allow us to execute several pieces of code together. 

Inside of this transaction, we try to find ['tasks']. If it doesn't exist, we make it an empty array ([]). We also want to keep track of a total number of tasks, so we either find that (`database['total']`) or assign it to 0. Next, we increase that total by 1 (`database['total'] += 1`) because we are creating a new task. Finally, we take our `database['tasks']` and shovel in a hash that includes an `id` key with a value of the total number of tasks, a `title` key with a value of `task[:title]`, and a `description` key with a value of `task[:description]`.

Go back to the form and submit a new task. Although you won't see anything different in your index page (we haven't taken care of that functionality yet), we should be able to see something new in the `db/task_manager` file. Open it up. It should look like this:

```
---
tasks:
- id: 1
  title: Make cookies
  description: Chocolate chip cookies are so delicious. I am hungry.
total: 1
```

What happened? Well, we have a section called `tasks` which will keep track of each task and a section called `total` which keeps track of the total number of tasks we have entered. Try entering a few more tasks using the web interface and watch this file change. You should see the total change, and each new tasks will be added under `tasks`. 

### Displaying Real Tasks on the Index Page

So that's pretty cool. But what about displaying these on the index page? Right now, we have just hard-coded an array of fake tasks in our controller when we hit `get '/tasks'`:

```ruby
  get '/tasks' do
    @tasks = ["task1", "task2", "task3"]
    erb :index
  end
```

We actually want to pull these tasks using our TaskManager class. Let's change that code in our controller:

```ruby
  get '/tasks' do
    @tasks = task_manager.all
    erb :index
  end
```

We haven't defined this `task_manager.all` method yet, but we want it to return an array of Task objects. Let's do that. Inside of your `app/models/task_manager.rb` file:

```ruby
require 'yaml/store'
require_relative 'task'

class TaskManager
  def self.database
    @database ||= YAML::Store.new("db/task_manager")
  end

  def self.create(task)
    database.transaction do
      database['tasks'] ||= []
      database['total'] ||= 0
      database['total'] += 1
      database['tasks'] << { "id" => database['total'], "title" => task[:title], "description" => task[:description] }
    end
  end

  def raw_tasks
    database.transaction do
      database['tasks'] || []
    end
  end

  def all
    raw_tasks.map { |data| Task.new(data) }
  end
end
```

We added two new methods. Let's talk about the first one, `raw_tasks`. This will go into our YAML file and retrieve everything under `database['tasks']`. What does this output look like? Well, if we were to call just that method, we would get something that looks like this: 

```
[{"id"=>1, "title"=>"Make cookies", "description"=>"They are delicious."}, {"id"=>2, "title"=>"Write code.", "description"=>"Always write code."}]
```

It's an array of hashes; one hash for each task in our YAML file. This is ok, but what we really want is for these hashes to be actual Task objects. 

This is where our `all` method comes in. We will map over the `raw_tasks` and pass that data hash into `Task.new`. Let's create a new model for Task:

```
$ touch app/models/task.rb
```

Inside of that file, we'll add the following code:

```ruby
class Task
  attr_reader :title, 
              :description, 
              :id

  def initialize(data)
    @id          = data["id"]
    @title       = data["title"]
    @description = data["description"]
  end
end
```

Here we are defining the class `Task` and then creating attr_readers for title, description, and id. Upon initialization, it will accept a data hash and access each piece of data via the keys (`data["id"]`, `data["title"]`, `data["description"]`). 

Now, when we call `task_manager.all`, we will get back an array of Task objects. Navigate to `http://localhost:9393/tasks`. You should see a `#` sign for each task in your YAML file, but no actual data. 

### Updating the Index View

We need to change our `index.erb` file so that we display each task's id and title. Let's make it so that the title is a link to a page where you will see that individual task and its description. So, in the `index.erb` file, this is what we should write:

```erb
<h1>All Tasks</h1>

<% @tasks.each do |task| %>
  <h3><%= task.id %>: <a href="/tasks/<%= task.id %>"><%= task.title %></a></h3>
<% end %>
```

Refresh `http://localhost:9393/tasks`. You should see your tasks each with an id and a title. The title should be clickable even though you'll get a "Sinatra doesn't know this ditty" error. 

### Showing Individual Tasks

Notice that the URL when you clicked on a link was something like `http://localhost:9393/tasks/1`. We want that last number, the task id number, to be flexible. If we go to `http://localhost:9393/tasks/1`, we should see task 1 displayed. If we go to `http://localhost:9393/tasks/2`, we should see task 2. 

Let's set up another route in our controller to handle this behavior:

```ruby
require 'models/task_manager'

class TaskManagerApp < Sinatra::Base
  set :root, File.expand_path("..", __dir__)

  get '/' do
    erb :dashboard
  end

  get '/tasks' do
    @tasks = task_manager.all
    erb :index
  end

  get '/tasks/new' do
    erb :new
  end

  post '/tasks' do
    task_manager.create(params[:task])
    redirect '/tasks'
  end

  get '/tasks/:id' do |id|
    @task = task_manager.find(id.to_i)
    erb :show
  end

  def task_manager
    database = YAML::Store.new('db/task_manager')
    @task_manager ||= TaskManager.new(database)
  end
end
```

The `/:id` will take whatever is at that point in the URL and allow us to access it as a local variable `id`. Next, we create an instance varaible `@task` which will hold the return value of `task_manager.find(id.to_i)`. We don't have this method yet. Why `id.to_i`? `id` is coming in as a string (like `"1"` or `"2"`) from the URL but we want it to be an integer. 

Before we build our find method, let's create the view:

```
$ touch app/views/show.erb
```

In this file, we'll add HTML and ERB that will display one specific task along with a link back to the task index:

```erb
<a href="/tasks">Task Index</a>

<h1><%= @task.title %></h1>

<p><%= @task.description %></p>

```

### Building the `.find` Method

Let's head over to `app/models/task_manager.rb` and add two methods that will allow us to find a task:

```ruby
require 'yaml/store'
require_relative 'task'

class TaskManager
  attr_reader :database

  def initialize(database)
    @database = database
  end

  def create(task)
    database.transaction do
      database['tasks'] ||= []
      database['total'] ||= 0
      database['total'] += 1
      database['tasks'] << { "id" => database['total'], "title" => task[:title], "description" => task[:description] }
    end
  end

  def raw_tasks
    database.transaction do
      database['tasks'] || []
    end
  end

  def all
    raw_tasks.map { |data| Task.new(data) }
  end

  def raw_task(id)
    raw_tasks.find { |task| task["id"] == id }
  end

  def find(id)
    Task.new(raw_task(id))
  end
end
```

In the `raw_task(id)` method, we're taking the `raw_tasks` and finding the one where the `task["id"]` is the same as the id that is passed in. That will return a hash of the task data. In the `find(id)` method, we'll create a Task object from that hash of task data.

Refresh `http://localhost:9393/tasks/1`. Assuming that you have a task in your YAML file with the id of 1, you should see the task title and description displayed. You should also be able to click back to the task index. 
