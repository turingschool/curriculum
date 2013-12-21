---
layout: page
title: Blogger 2
alias: [ /blogger, /blogger.html ]
sidebar: true
---

In this project you'll create a simple blog system and learn the basics of Ruby on Rails including:

* Models, Views, and Controllers (MVC)
* Data Structures & Relationships
* Routing
* Migrations
* Views with forms, partials, and helpers
* RESTful design
* Adding gems for extra features

<div class="note">
<p>This tutorial is open source. If you notice errors, typos, or have questions/suggestions, please <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/projects/blogger.markdown">submit them to the project on Github</a>.</p>
</div>

## I0: Up and Running

Part of the reason Ruby on Rails became popular quickly is that it takes a lot of the hard work off your hands, and that's especially true in starting up a project. Rails practices the idea of "sensible defaults" and will, with one command, create a working application ready for your customization.

### Setting the Stage

First we need to make sure everything is set up and installed. See the [Environment Setup]({% page_url topics/environment/environment %}) page for instructions on setting up and verifying your Ruby and Rails environment.

This tutorial targets Rails 4.0.0, and may need slight adaptations for other versions. Let us know if you run into something strange!

From the command line, switch to the folder that will store your projects. For instance, I use `/Users/jcasimir/projects/`. Within that folder, run the following command:

{% terminal %}
$ rails new blogger
{% endterminal %}

Use `cd blogger` to change into the directory, then open it in your text editor. If you're using Sublime Text you can do that with `subl .`.

### Project Tour

The generator has created a Rails application for you. Let's figure out what's in there. Looking at the project root, we have these folders:

* `app` - This is where 98% of your effort will go. It contains subfolders which will hold most of the code you write including Models, Controllers, Views, Helpers, JavaScript, etc.
* `config` - Control the environment settings for your application. It also includes the `initializers` subfolder which holds items to be run on startup.
* `db` - Will eventually have a `migrations` subfolder where your migrations, used to structure the database, will be stored. When using SQLite3, as is the Rails default, the database file will also be stored in this folder.
* `doc` - Who writes documentation? If you did, it'd go here. Someday.
* `lib` - This folder is to store code you control that is reusable outside the project. 
* `log` - Log files, one for each environment (development, test, production)
* `public` - Static files can be stored and accessed from here, but all the interesting things (JavaScript, Images, CSS) have been moved up to `app` since Rails 3.1
* `test` - If your project is using the default `Test::Unit` testing library, the tests will live here
* `tmp` - Temporary cached files
* `vendor` - Infrequently used, this folder is to store code you *do not* control. With Bundler and Rubygems, we generally don't need anything in here during development.

### Configuring the Database

Look in the `config` directory and open the file `database.yml`. This file controls how Rails' database connection system will access your database. You can configure many different databases, including SQLite3, MySQL, PostgreSQL, SQL Server, and Oracle.

If you were connecting to an existing database you would enter the database configuration parameters here. Since we're using SQLite3 and starting from scratch, we can leave the defaults to create a new database, which will happen automatically. The database will be stored in `db/development.sqlite3`

### Starting the Server

Let's start up the server. From your project directory:

{% terminal %}
$ bin/rails server
=> Booting WEBrick
=> Rails 4.0.0 application starting in development on http://0.0.0.0:3000
=> Call with -d to detach
=> Ctrl-C to shutdown server
[2012-01-07 11:16:52] INFO  WEBrick 1.3.1
[2012-01-07 11:16:52] INFO  ruby 1.9.3 (2011-10-30) [x86_64-darwin11.2.0]
[2012-01-07 11:16:52] INFO  WEBrick::HTTPServer#start: pid=36790 port=3000
{% endterminal %}

You're ready to go!

### Viewing the App

Open any web browser and enter the address `http://0.0.0.0:3000`. You can also use `http://localhost:3000` or `http://127.0.0.1:3000` -- they are all "loopback" addresses that point to your machine.

You'll see the Rails' "Welcome Aboard" page. Click the "About your application’s environment" link and you should see the versions of various gems. As long as there's no big ugly error message, you're good to go.

#### Getting an Error?

If you see an error here, it's most likely related to the database. You are probably running Windows and don't have either the SQLite3 application installed or the gem isn't installed properly. Go back to [Environment Setup]({% page_url topics/environment/environment %}) and use the Rails Installer package. Make sure you check the box during setup to configure the environment variables. Restart your machine after the installation and give it another try.

### Creating the Article Model

Our blog will be centered around "articles," so we'll need a table in the database to store all the articles and a model to allow our Rails app to work with that data. We'll use one of Rails' generators to create the required files. Switch to your terminal and enter the following:

{% terminal %}
$ bin/rails generate model Article
{% endterminal %}

Note that we use `bin/rails` here but we used `rails` previously. The `rails` command is used for generating new projects, and the `bin/rails` command is used for controlling Rails.

We're running the `generate` script, telling it to create a `model`, and naming that model `Article`. From that information, Rails creates the following files:

* `db/migrate/(some_time_stamp)_create_articles.rb` : A database migration to create the `articles` table
* `app/models/article.rb` : The file that will hold the model code
* `test/models/article_test.rb` : A file to hold unit tests for `Article`
* `test/fixtures/articles.yml` : A fixtures file to assist with unit testing

With those files in place we can start developing!

### Working with the Database

Rails uses migration files to perform modifications to the database. Almost any modification you can make to a DB can be done through a migration. The killer feature about Rails migrations is that they're generally database agnostic. When developing applications developers might use SQLite3 as we are in this tutorial, but in production we'll use PostgreSQL. Many others choose MySQL. It doesn't matter -- the same migrations will work on all of them!  This is an example of how Rails takes some of the painful work off your hands. You write your migrations once, then run them against almost any database.

#### Migration?

What is a migration?  Let's open `db/migrate/(some_time_stamp)_create_articles.rb` and take a look. First you'll notice that the filename begins with a mish-mash of numbers which is a timestamp of when the migration was created. Migrations need to be ordered, so the timestamp serves to keep them in chronological order. Inside the file, you'll see just the method `change`.

Migrations used to have two methods, `up` and `down`. The `up` was used to make your change, and the `down` was there as a safety valve to undo the change. But this usually meant a bunch of extra typing, so with Rails 3.1 those two were replaced with `change`.

We write `change` migrations just like we used to write `up`, but Rails will figure out the undo operations for us automatically.

#### Modifying `change`

Inside the `change` method you'll see the generator has placed a call to the `create_table` method, passed the symbol `:articles` as a parameter, and created a block with the variable `t` referencing the table that's created.

We call methods on `t` to create columns in the `articles` table. What kind of fields does our Article need to have?  Since migrations make it easy to add or change columns later, we don't need to think of everything right now, we just need a few to get us rolling. Let's start with:

* `title` (a string)
* `body` (a "text")

That's it! You might be wondering, what is a "text" type?  This is an example of relying on the Rails database adapters to make the right call. For some DBs, large text fields are stored as `varchar`, while others like Postgres use a `text` type. The database adapter will figure out the best choice for us depending on the configured database -- we don't have to worry about it.

Add those into your `change` like this:

```ruby
def change
  create_table :articles do |t|
    t.string :title
    t.text :body

    t.timestamps
  end
end
```

#### Timestamps

What is that `t.timestamps` doing there? It will create two columns inside our table named `created_at` and `updated_at`. Rails will manage these columns for us. When an article is created its `created_at` and `updated_at` are automatically set. Each time we make a change to the article, the `updated_at` will automatically be updated.

#### Running the Migration

Save that migration file, switch over to your terminal, and run this command:

{% terminal %}
$ bin/rake db:migrate
{% endterminal %}

This command starts the `rake` program which is a ruby utility for running maintenance-like functions on your application (working with the DB, executing unit tests, deploying to a server, etc). 

We tell `rake` to `db:migrate` which means "look in your set of functions for the database (`db`) and run the `migrate` function."  The `migrate` action finds all migrations in the `db/migrate/` folder, looks at a special table in the DB to determine which migrations have and have not been run yet, then runs any migration that hasn't been run.

In this case we had just one migration to run and it should print some output like this to your terminal:

{% terminal %}
$ bin/rake db:migrate
==  CreateArticles: migrating =================================================
-- create_table(:articles)
   -> 0.0012s
==  CreateArticles: migrated (0.0013s) ========================================
{% endterminal %}

It tells you that it is running the migration named `CreateArticles`. And the "migrated" line means that it completed without errors. When the migrations are run, data is added to the database to keep track of which migrations have *already* been run. Try running `rake db:migrate` again now, and see what happens.

We've now created the `articles` table in the database and can start working on our `Article` model.

### Working with a Model in the Console

Another awesome feature of working with Rails is the `console`. The `console` is a command-line interface to your application. It allows you to access and work with just about any part of your application directly instead of going through the web interface. This will accelerate your development process. Once an app is in production the console makes it very easy to do bulk modifications, searches, and other data operations. So let's open the console now by going to your terminal and entering this:

{% terminal %}
$ bin/rails console
{% endterminal %}

You'll then just get back a prompt of `>>`. You're now inside an `irb` interpreter with full access to your application. Let's try some experiments. Enter each of these commands one at a time and observe the results:

{% irb %}
$ Time.now
$ Article.all
$ Article.new
{% endirb %}

The first line was just to demonstrate that you can run normal Ruby, just like `irb`, within your `console`. The second line referenced the `Article` model and called the `all` class method which returns an array of all articles in the database -- so far an empty array. The third line created a new article object. You can see that this new object had attributes `id`, `title`, `body`, `created_at`, and `updated_at`.

### Looking at the Model

All the code for the `Article` model is in the file `app/models/article.rb`, so let's open that now.

Not very impressive, right?  There are no attributes defined inside the model, so how does Rails know that an Article should have a `title`, a `body`, etc?  The answer is a technique called reflection. Rails queries the database, looks at the articles table, and assumes that whatever columns that table has should be the attributes for the model.

You'll recognize most of them from your migration file, but what about `id`?  Every table you create with a migration will automatically have an `id` column which serves as the table's primary key. When you want to find a specific article, you'll look it up in the articles table by its unique ID number. Rails and the database work together to make sure that these IDs are unique, usually using a special column type in the DB called "serial".

In your console, try entering `Article.all` again. Do you see the blank article that we created with the `Article.new` command?  No?  The console doesn't change values in the database until we explicitly call the `.save` method on an object. Let's create a sample article and you'll see how it works. Enter each of the following lines one at a time:

{% irb %}
$ a = Article.new
$ a.title = "Sample Article Title"
$ a.body = "This is the text for my article, woo hoo!"
$ a.save
$ Article.all
{% endirb %}

Now you'll see that the `Article.all` command gave you back an array holding the one article we created and saved. Go ahead and **create 3 more sample articles**.

### Setting up the Router

We've created a few articles through the console, but we really don't have a web application until we have a web interface. Let's get that started. We said that Rails uses an "MVC" architecture and we've worked with the Model, now we need a Controller and View.

When a Rails server gets a request from a web browser it first goes to the _router_. The router decides what the request is trying to do, what resources it is trying to interact with. The router dissects a request based on the address it is requesting and other HTTP parameters (like the request type of GET or PUT). Let's open the router's configuration file, `config/routes.rb`.

Inside this file you'll see a LOT of comments that show you different options for routing requests. Let's remove everything _except_ the first line (`Blogger::Application.routes.draw do`) and the final `end`. Then, in between those two lines, add `resources :articles` so your file looks like this:

```ruby
Blogger::Application.routes.draw do
  resources :articles
end
```

This line tells Rails that we have a resource named `articles` and the router should expect requests to follow the *RESTful* model of web interaction (REpresentational State Transfer). The details don't matter right now, but when you make a request like `http://localhost:3000/articles/`, the router will understand you're looking for a listing of the articles, and `http://localhost:3000/articles/new` means you're trying to create a new article.

#### Looking at the Routing Table

Dealing with routes is commonly very challenging for new Rails programmers. There's a great tool that can make it easier on you. To get a list of the routes in your application, go to a command prompt and run `rake routes`. You'll get a listing like this:

{% terminal %}
$ bin/rake routes
      Prefix Verb   URI Pattern                  Controller#Action
    articles GET    /articles(.:format)          articles#index
             POST   /articles(.:format)          articles#create
 new_article GET    /articles/new(.:format)      articles#new
edit_article GET    /articles/:id/edit(.:format) articles#edit
     article GET    /articles/:id(.:format)      articles#show
             PATCH  /articles/:id(.:format)      articles#update
             PUT    /articles/:id(.:format)      articles#update
             DELETE /articles/:id(.:format)      articles#destroy
{% endterminal %}

Experiment with commenting out the `resources :articles` in `routes.rb` and running the command again. Un-comment the line after you see the results.

These are the seven core actions of Rails' REST implementation. To understand the table, let's look at the first row as an example:

{% terminal %}
      Prefix Verb   URI Pattern                  Controller#Action
    articles GET    /articles(.:format)          articles#index
{% endterminal %}

The left most column says `articles`. This is the *prefix* of the path. The router will provide two methods to us using that name, `articles_path` and `articles_url`. The `_path` version uses a relative path while the `_url` version uses the full URL with protocol, server, and path. The `_path` version is always preferred.

The second column, here `GET`, is the HTTP verb for the route. Web browsers typically submit requests with the verbs `GET` or `POST`. In this column, you'll see other HTTP verbs including `PUT` and `DELETE` which browsers don't actually use. We'll talk more about those later.

The third column is similar to a regular expression which is matched against the requested URL. Elements in parentheses are optional. Markers starting with a `:` will be made available to the controller with that name. In our example line, `/articles(.:format)` will match the URLs `/articles/`, `/articles.json`, `/articles` and other similar forms.

The fourth column is where the route maps to in the applications. Our example has `articles#index`, so requests will be sent to the `index` method of the `ArticlesController` class.

Now that the router knows how to handle requests about articles, it needs a place to actually send those requests, the *Controller*.

### Creating the Articles Controller

We're going to use another Rails generator but your terminal has the console currently running. Let's open one more terminal or command prompt and move to your project directory which we'll use for command-line scripts. In that new terminal, enter this command:

{% terminal %}
$ bin/rails generate controller articles
{% endterminal %}

The output shows that the generator created several files/folders for you:

* `app/controllers/articles_controller.rb` : The controller file itself
* `app/views/articles` : The directory to contain the controller's view templates
* `test/controllers/articles_controller_test.rb` : The controller's unit tests file
* `app/helpers/articles_helper.rb` : A helper file to assist with the views (discussed later)
* `test/helpers/articles_helper_test.rb` : The helper's unit test file
* `app/assets/javascripts/articles.js.coffee` : A CoffeeScript file for this controller
* `app/assets/stylesheets/articles.css.scss` : An SCSS stylesheet for this controller

Let's open up the controller file, `app/controllers/articles_controller.rb`. You'll see that this is basically a blank class, beginning with the `class` keyword and ending with the `end` keyword. Any code we add to the controller must go _between_ these two lines.

### Defining the Index Action

The first feature we want to add is an "index" page. This is what the app will send back when a user requests `http://localhost:3000/articles/` -- following the RESTful conventions, this should be a list of the articles. So when the router sees this request come in, it tries to call the `index` action inside `articles_controller`.

Let's first try it out by entering `http://localhost:3000/articles/` into your web browser. You should get an error message that looks like this:

```plain
Unknown action

The action 'index' could not be found for ArticlesController
```

The router tried to call the `index` action, but the articles controller doesn't have a method with that name. It then lists available actions, but there aren't any. This is because our controller is still blank. Let's add the following method inside the controller:

```ruby
def index
  @articles = Article.all
end
```

#### Instance Variables

What is that "at" sign doing on the front of `@articles`?  That marks this variable as an "instance level variable". We want the list of articles to be accessible from both the controller and the view that we're about to create. In order for it to be visible in both places it has to be an instance variable. If we had just named it `articles`, that local variable would only be available within the `index` method of the controller.

A normal Ruby instance variable is available to all methods within an instance.

In Rails' controllers, there's a *hack* which allows instance variables to be automatically transferred from the controller to the object which renders the view template. So any data we want available in the view template should be promoted to an instance variable by adding a `@` to the beginning.

There are ways to accomplish the same goals without instance variables, but they're not widely used. Check out the [Decent Exposure](https://github.com/voxdolo/decent_exposure) gem to learn more.

### Creating the Template

Now refresh your browser. The error message changed, but you've still got an error, right?

```plain
Template is missing

Missing template articles/index, application/index with {:locale=>[:en], :formats=>[:html], :handlers=>[:erb, :builder, :raw, :ruby, :jbuilder, :coffee]}. Searched in: * "/Users/you/projects/blogger/app/views" 
```

The error message is pretty helpful here. It tells us that the app is looking for a (view) template in `app/views/articles/` but it can't find one named `index.erb`. Rails has *assumed* that our `index` action in the controller should have a corresponding `index.erb` view template in the views folder. We didn't have to put any code in the controller to tell it what view we wanted, Rails just figures it out.

In your editor, find the folder `app/views/articles` and, in that folder, create a file named `index.html.erb`.

#### Naming Templates

Why did we choose `index.html.erb` instead of the `index.erb` that the error message said it was looking for?  Putting the HTML in the name makes it clear that this view is for generating HTML. In later versions of our blog we might create an RSS feed which would just mean creating an XML view template like `index.xml.erb`. Rails is smart enough to pick the right one based on the browser's request, so when we just ask for `http://localhost:3000/articles/` it will find the `index.html.erb` and render that file.

#### Index Template Content

Now you're looking at a blank file. Enter in this view template code which is a mix of HTML and what are called ERB tags:

```erb
<h1>All Articles</h1>

<ul id="articles">
  <% @articles.each do |article| %>
    <li>
      <%= article.title %>
    </li>
  <% end %>
</ul>
```

ERB is a templating language that allows us to mix Ruby into our HTML. There are only a few things to know about ERB:

* An ERB clause starts with `<%` or `<%=` and ends with `%>`
* If the clause started with `<%`, the result of the ruby code will be hidden
* If the clause started with `<%=`, the result of the ruby code will be output in place of the clause

Save the file and refresh your web browser. You should see a listing of the articles you created in the console. We've got the start of a web application!

### Adding Navigation to the Index

Right now our article list is very plain, let's add some links.

#### Looking at the Routing Table

Remember when we looked at the Routing Table using `bin/rake routes` from the command line? Look at the left-most column and you'll see the route names. These are useful when creating links.

When we create a link, we'll typically use a "route helper" to specify where the link should point. We want our link to display the single article which happens in the `show` action. Looking at the table, the name for that route is `article` and it requires a parameter `id` in the URL. The route helper we'll use looks like this:

```ruby
article_path(id)
```

For example, `article_path(1)` would generate the string `"/articles/1"`. Give the method a different parameter and you'll change the ID on the end.

#### Completing the Article Links

Back in `app/views/articles/index.html.erb`, find where we have this line:

```erb
<%= article.title %>
```

Instead, let's use a `link_to` helper:

```erb
<%= link_to article.title, article_path(article) %>
```

The first part of this helper after the `link_to`, in this case `article.title`, is the text you want the link to say. The next part is our route helper.

When the template is rendered, it will output HTML like this:

```html
<a href="/articles/1">First Sample Article</a>
```

#### New Article Link

At the very bottom of the template, let's add a link to the "Create a New Article" page.

We'll use the `link_to` helper, we want it to display the text `"Create a New Article"`, and where should it point? Look in the routing table for the `new` action, that's where the form to create a new article will live. You'll find the name `new_article`, so the helper is `new_article_path`. Assemble those three parts and write the link in your template.

But wait, there's one more thing. Our stylesheet for this project is going to look for a certain class on the link to make it look fancy. To add HTML attributes to a link, we include them in a Ruby hash style on the end like this:

```erb
<%= link_to article.title, article_path(article), class: 'article_title' %>
```

Or, if you wanted to also have a CSS ID attribute:

```erb
<%= link_to article.title, article_path(article),
    class: 'article_title', id: "article_#{article.id}" %>
```

Use that technique to add the CSS class `new_article` to your "Create a New Article" link.

```erb
<%= link_to "Create a New Article", new_article_path, class: "new_article" %>
```

#### Review the Results

Refresh your browser and each sample article title should be a link. If you click the link, you'll get an error as we haven't implemented the `show` method yet. Similarly, the new article link will lead you to a dead end. Let's tackle the `show` next.

### Creating the SHOW Action

Click the title link for one of your sample articles and you'll get the "Unknown Action" error we saw before. Remember how we moved forward?

An "action" is just a method of the controller. Here we're talking about the `ArticlesController`, so our next step is to open `app/controllers/articles_controller.rb` and add a `show` method:

```ruby
def show

end
```

Refresh the browser and you'll get the "Template is Missing" error. Let's pause here before creating the view template.

#### A Bit on Parameters

Look at the URL: `http://localhost:3000/articles/1`. When we added the `link_to` in the index and pointed it to the `article_path` for this `article`, the router created this URL. Following the RESTful convention, this URL goes to a SHOW method which would display the Article with ID number `1`. Your URL might have a different number depending on which article title you clicked in the index.

So what do we want to do when the user clicks an article title?  Find the article, then display a page with its title and body. We'll use the number on the end of the URL to find the article in the database.

Within the controller, we have access to a method named `params` which returns us a hash of the request parameters. Often we'll refer to it as "the `params` hash", but technically it's "the `params` method which returns a hash".

Within that hash we can find the `:id` from the URL by accessing the key `params[:id]`. Use this inside the `show` method of `ArticlesController` along with the class method `find` on the `Article` class:

```ruby
@article = Article.find(params[:id])
```

#### Back to the Template

Refresh your browser and we still have the "Template is Missing" error. Create the file `app/views/articles/show.html.erb` and add this code:

```erb
<h1><%= @article.title %></h1>
<p><%= @article.body %></p>
<%= link_to "<< Back to Articles List", articles_path %>
```

Refresh your browser and your article should show up along with a link back to the index. We can now navigate from the index to a show page and back.

### Styling

This is not a CSS project, so to make it a bit more fun we've prepared a CSS file you can drop in. It should match up with all the example HTML in the tutorial.

Download the file from http://tutorials.jumpstartlab.com/assets/blogger/screen.css and place it in your `app/assets/stylesheets/` folder. It will be automatically picked up by your project.

####Saving Your Work On Github

Now that we have completed our first feature, it's a great time to start thinking about how to save our project.

If you have not already installed git, please follow the instructions on installation [here](http://tutorials.jumpstartlab.com/topics/environment/environment.html).

Git tracks changes in code throughout time, and is a great tool once you have started working collaboratively.  First you need to create a [Github account](https://github.com/signup/free).

Next, [create a repository](https://github.com/new) for the project and on the command line do;

{% terminal %}
$ git init
$ git add .
$ git commit -m "first blogger commit"
$ git remote add origin git@github.com:your_github_username/your_repository_name.git
$ git push -u origin master
{% endterminal %}

Congratulations! You have pushed the code to your Github repository. At any time in the future you can backtrack to this commit and refer to your project in this state.  We'll cover this in further detail later on.

## I1: Form-based Workflow

We've created sample articles from the console, but that isn't a viable long-term solution. The users of our app will expect to add content through a web interface. In this iteration we'll create an HTML form to submit the article, then all the backend processing to get it into the database.

### Creating the NEW Action and View

Previously, we set up the `resources :articles` route in `routes.rb`, and that told Rails that we were going to follow the RESTful conventions for this model named Article. Following this convention, the URL for creating a new article would be `http://localhost:3000/articles/new`. From the articles index, click your "Create a New Article" link and it should go to this path.

Then you'll see an "Unknown Action" error. The router went looking for an action named `new` inside the `ArticlesController` and didn't find it.

First let's create that action. Open `app/controllers/articles_controller.rb` and add this method, making sure it's _inside_ the `ArticlesController` class, but _outside_ the existing `index` and `show` methods:

```ruby
def new

end
```

#### Starting the Template

With that defined, refresh your browser and you should get the "Template is Missing" error.

Create a new file `app/views/articles/new.html.erb` with these contents:

```erb
<h1>Create a New Article</h1>
```

Refresh your browser and you should just see the heading "Create a New Article".

<div class="note">
<p>Why the name <code>new.html.erb</code>? The first piece, <code>new</code>, matches the name of the controller method. The second, <code>html</code>, specifies the output format sent to the client. The third, <code>erb</code>, specifies the language the template is written in. Under different circumstances, we might use <code>new.json.erb</code> to output JSON or <code>new.html.haml</code> to use the HAML templating language.</p>
</div>

### Writing a Form

It's not very impressive so far -- we need to add a form to the `new.html.erb` so the user can enter in the article title and body. Because we're following the RESTful conventions, Rails can take care of many of the details. Inside that `erb` file, enter this code below your header:

```erb
<%= form_for(@article) do |f| %>
  <ul>
  <% @article.errors.full_messages.each do |error| %>
    <li><%= error %></li>
  <% end %>
  </ul>
  <p>
    <%= f.label :title %><br />
    <%= f.text_field :title %>
  </p>
  <p>
    <%= f.label :body %><br />
    <%= f.text_area :body %>
  </p>
  <p>
    <%= f.submit %>
  </p>
<% end %>
```

What is all that?  Let's look at it piece by piece:

* `form_for` is a Rails helper method which takes one parameter, in this case `@article` and a block with the form fields. The first line basically says "Create a form for the object named `@article`, refer to the form by the name `f` and add the following elements to the form..."
* The `f.label` helper creates an HTML label for a field. This is good usability practice and will have some other benefits for us later
* The `f.text_field` helper creates a single-line text box named `title`
* The `f.text_area` helper creates a multi-line text box named `body`
* The `f.submit` helper creates a button labeled "Create"

#### Does it Work?

Refresh your browser and you'll see this:

```plain
ArgumentError in Articles#new
Showing /Users/you/projects/blogger/app/views/articles/new.html.erb where line #2 raised:
First argument in form cannot contain nil or be empty
```

Huh? We didn't call a method `model_name`?

We didn't *explicitly*, but the `model_name` method is called by `form_for`. What's happening here is that we're passing `@article` to `form_for`. Since we haven't created an `@article` in this action, the variable just holds `nil`. The `form_for` method calls `model_name` on `nil`, generating the error above.

#### Setting up for Reflection

Rails uses some of the _reflection_ techniques that we talked about earlier in order to set up the form. Remember in the console when we called `Article.new` to see what fields an `Article` has? Rails wants to do the same thing, but we need to create the blank object for it. Go into your `articles_controller.rb`, and _inside_ the `new` method, add this line:

```ruby
@article = Article.new
```

Then refresh your browser and your form should come up. Enter in a title, some body text, and click CREATE.

### The `create` Action

Your old friend pops up again...

```plain
Unknown action
The action 'create' could not be found for ArticlesController
```

We accessed the `new` action to load the form, but Rails' interpretation of REST uses a second action named `create` to process the data from that form. Inside your `articles_controller.rb` add this method (again, _inside_ the `ArticlesContoller` class, but _outside_ the other methods):

```ruby
def create

end
```

Refresh the page and you'll get the "Template is Missing" error.

#### We Don't Always Need Templates

When you click the "Create" button, what would you expect to happen? Most web applications would process the data submitted then show you the object. In this case, display the article.

We already have an action and template for displaying an article, the `show`, so there's no sense in creating another template to do the same thing.

#### Processing the Data

Before we can send the client to the `show`, let's process the data. The data from the form will be accesible through the `params` method.

To check out the structure and content of `params`, I like to use this trick:

```ruby
def create
  fail
end
```

The `fail` method will halt the request allowing you to examine the request
parameters.

Refresh/resubmit the page in your browser.

#### Understanding Form Parameters

The page will say "RuntimeError".

Below the error information is the request information. We are interested
in the parameters (I've inserted line breaks for readability):

```plain
{"utf8"=>"✔", "authenticity_token"=>"UDbJdVIJjK+qim3m3N9qtZZKgSI0053S7N8OkoCmDjA=",
 "article"=>{"title"=>"Fourth Sample", "body"=>"This is my fourth sample article."},
 "commit"=>"Create", "action"=>"create", "controller"=>"articles"}
```

What are all those? We see the `{` and `}` on the outside, representing a `Hash`. Within the hash we see keys:

* `utf8` : This meaningless checkmark is a hack to force Internet Explorer to submit the form using UTF-8. [Read more on StackOverflow](http://stackoverflow.com/questions/3222013/what-is-the-snowman-param-in-rails-3-forms-for)
* `authenticity_token` : Rails has some built-in security mechanisms to resist "cross-site request forgery". Basically, this value proves that the client fetched the form from your site before submitting the data.
* `article` : Points to a nested hash with the data from the form itself
  * `title` : The title from the form
  * `body` : The body from the form
* `commit` : This key holds the text of the button they clicked. From the server side, clicking a "Save" or "Cancel" button look exactly the same except for this parameter.
* `action` : Which controller action is being activated for this request
* `controller` : Which controller class is being activated for this request

#### Pulling Out Form Data

Now that we've seen the structure, we can access the form data to mimic the way
we created sample objects in the console. In the `create` action, remove the
`fail` instruction and, instead, try this:

```ruby
def create
  @article = Article.new
  @article.title = params[:article][:title]
  @article.save
end
```

If you refresh the page in your browser you'll still get the template error. Add one more line to the action, the redirect:

```ruby
redirect_to article_path(@article)
```

Refresh the page and you should go to the show for your new article. (_NOTE_: You've now created the same sample article twice)

#### More Body

The `show` page has the title, but where's the body? Add a line to the `create` action to pull out the `:body` key from the `params` hash and store it into `@article`.

Then try it again in your browser. Both the `title` and `body` should show up properly.

#### Fragile Controllers

Controllers are middlemen in the MVC framework. They should know as little as necessary about the other components to get the job done. This controller action knows too much about our model.

To clean it up, let me first show you a second way to create an instance of `Article`. You can call `new` and pass it a hash of attributes, like this:

```ruby
def create
  @article = Article.new(
    title: params[:article][:title],
    body: params[:article][:body])
  @article.save
  redirect_to article_path(@article)
end
```

Try that in your app, if you like, and it'll work just fine.

But look at what we're doing. `params` gives us back a hash, `params[:article]` gives us back the nested hash, and `params[:article][:title]` gives us the string from the form. We're hopping into `params[:article]` to pull its data out and stick it right back into a hash with the same keys/structure.

There's no point in that! Instead, just pass the whole hash:

```ruby
def create
  @article = Article.new(params[:article])
  @article.save
  redirect_to article_path(@article)
end
```

Test and you'll find that it... blows up! What gives?

For security reasons, it's not a good idea to blindly save parameters
sent into us via the params hash. Luckily, Rails gives us a feature
to deal with this situation: Strong Parameters.

It works like this: You use two new methods, `require` and `permit`.
They help you declare which attributes you'd like to accept. Most of
the time, they're used in a helper method. Add the below code to `app/helpers/article_helper.rb`.

```ruby
  def article_params
    params.require(:article).permit(:title, :body)
  end
```

Now on your articles_controller.rb add: 'include ArticlesHelper' directly below your class name.

You then use this method instead of the `params` hash directly:

```ruby
  @article = Article.new(article_params)
```

Go ahead and add this helper method to your code, and change the arguments to `new`. It should look like this, in your articles_controller.rb file, when you're done:

```ruby
class ArticlesController < ApplicationController
include ArticlesHelper

…

  def create 
    @article = Article.new(article_params) 
    @article.save 
 
    redirect_to article_path(@article) 
  end 
```

Now in your articles_helper.rb file it should look like this:

```ruby
module ArticlesHelper

  def article_params
    params.require(:article).permit(:title, :body)
  end

end
```

We can then re-use this method any other time we want to make an
`Article`.

### Deleting Articles

We can create articles and we can display them, but when we eventually deliver this to less perfect people than us, they're going to make mistakes. There's no way to remove an article, let's add that next.

We could put delete links on the index page, but instead let's add them to the `show.html.erb` template. Let's figure out how to create the link.

We'll start with the `link_to` helper, and we want it to say the word "delete" on the link. So that'd be:

```erb
<%= link_to "delete", some_path %>
```

But what should `some_path` be? Look at the routes table with `rake routes`. The `destroy` action will be the last row, but it has no name in the left column. In this table the names "trickle down," so look up two lines and you'll see the name `article`.

The helper method for the destroy-triggering route is `article_path`. It needs to know which article to delete since there's an `:id` in the path, so our link will look like this:

```erb
<%= link_to "delete", article_path(@article) %>
```

Go to your browser, load the show page, click the link, and observe what happens.

#### REST is about Path and Verb

Why isn't the article being deleted? If you look at the server window, this is the response to our link clicking:

{% terminal %}
Started GET "/articles/3" for 127.0.0.1 at 2012-01-08 13:05:39 -0500
  Processing by ArticlesController#show as HTML
  Parameters: {"id"=>"3"}
  Article Load (0.1ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = ? LIMIT 1  [["id", "3"]]
Rendered articles/show.html.erb within layouts/application (5.2ms)
Completed 200 OK in 13ms (Views: 11.2ms | ActiveRecord: 0.3ms)
{% endterminal %}

Compare that to what we see in the routes table:

{% terminal %}
             DELETE /articles/:id(.:format)      articles#destroy
{% endterminal %}

The path `"articles/3"` matches the route pattern `articles/:id`, but look at the verb. The server is seeing a `GET` request, but the route needs a `DELETE` verb. How do we make our link trigger a `DELETE`?

You can't, exactly. While most browsers support all four verbs, `GET`, `PUT`, `POST`, and `DELETE`, HTML links are always `GET`, and HTML forms only support `GET` and `POST`. So what are we to do?

Rails' solution to this problem is to *fake* a `DELETE` verb. In your view template, you can add another attribute to the link like this:

```erb
<%= link_to "delete", article_path(@article), method: :delete %>
```

Through some JavaScript tricks, Rails can now pretend that clicking this link triggers a `DELETE`. Try it in your browser.

#### The `destroy` Action

Now that the router is recognizing our click as a delete, we need the action. The HTTP verb is `DELETE`, but the Rails method is `destroy`, which is a bit confusing.

Let's define the `destroy` method in our `ArticlesController` so it:

1. Uses `params[:id]` to find the article in the database
2. Calls `.destroy` on that object
3. Redirects to the articles index page

Do that now on your own and test it.

#### Confirming Deletion

There's one more parameter you might want to add to your `link_to` call in your `show.html.erb`:

```ruby
data: {confirm: "Really delete the article?"}
```

This will pop up a JavaScript dialog when the link is clicked. The Cancel button will stop the request, while the OK button will submit it for deletion.

### Creating an Edit Action & View

Sometimes we don't want to destroy an entire object, we just want to make some changes. We need an edit workflow.

In the same way that we used `new` to display the form and `create` to process that form's data, we'll use `edit` to display the edit form and `update` to save the changes.

#### Adding the Edit Link

Again in `show.html.erb`, let's add this:

```erb
<%= link_to "edit", edit_article_path(@article) %>
```

Trigger the `edit_article` route and pass in the `@article` object. Try it!

#### Implementing the `edit` Action

The router is expecting to find an action in `ArticlesController` named `edit`, so let's add this:

```ruby
def edit
  @article = Article.find(params[:id])
end
```

All the `edit` action does is find the object and display the form. Refresh and you'll see the template missing error.

#### An Edit Form

Create a file `app/views/articles/edit.html.erb` but *hold on before you type anything*. Below is what the edit form would look like:

```erb
<h1>Edit an Article</h1>

<%= form_for(@article) do |f| %>
  <ul>
  <% @article.errors.full_messages.each do |error| %>
    <li><%= error %></li>
  <% end %>
  </ul>
  <p>
    <%= f.label :title %><br />
    <%= f.text_field :title %>
  </p>
  <p>
    <%= f.label :body %><br />
    <%= f.text_area :body %>
  </p>
  <p>
    <%= f.submit %>
  </p>
<% end %>
```

In the Ruby community there is a mantra of "Don't Repeat Yourself" -- but that's exactly what I've done here. This view is basically the same as the `new.html.erb` -- the only change is the H1. We can abstract this form into a single file called a _partial_, then reference this partial from both `new.html.erb` and `edit.html.erb`.

#### Creating a Form Partial

Partials are a way of packaging reusable view template code. We'll pull the common parts out from the form into the partial, then render that partial from both the new template and the edit template.

Create a file `app/views/articles/_form.html.erb` and, yes, it has to have the underscore at the beginning of the filename. Partials always start with an underscore.

Open your `app/views/articles/new.html.erb` and CUT all the text from and including the `form_for` line all the way to its `end`. The only thing left will be your H1 line.

Add the following code to that view:

```erb
<%= render partial: 'form' %>
```

Now go back to the `_form.html.erb` and paste the code from your clipboard.

#### Writing the Edit Template

Then look at your `edit.html.erb` file. You already have an H1 header, so add the line which renders the partial.

#### Testing the Partial

Go back to your articles list and try creating a new article -- it should work just fine. Try editing an article and you should see the form with the existing article's data -- it works OK until you click "Update Article."

#### Implementing Update

The router is looking for an action named `update`. Just like the `new` action sends its form data to the `create` action, the `edit` action sends its form data to the `update` action. In fact, within our `articles_controller.rb`, the `update` method will look very similar to `create`:

```ruby
def update
  @article = Article.find(params[:id])
  @article.update(article_params)

  redirect_to article_path(@article)
end
```

The only new bit here is the `update` method. It's very similar to `Article.new` where you can pass in the hash of form data. It changes the values in the object to match the values submitted with the form. One difference from `new` is that `update` automatically saves the changes.

We use the same `article_params` method as before so that we only
update the attributes we're allowed to.

Now try editing and saving some of your articles.

### Adding a Flash

Our operations are working, but it would be nice if we gave the user some kind of status message about what took place. When we create an article the message might say "Article 'the-article-title' was created", or "Article 'the-article-title' was removed" for the remove action. We can accomplish this with the `flash`.

The controller provides you with accessors to interact with the `flash`. Calling `flash.notice` will fetch a value, and `flash.notice = "Your Message"` will store the string in the `flash`.

#### Flash for Update

Let's look first at the `update` method we just worked on. It currently looks like this:

```ruby
def update
  @article = Article.find(params[:id])
  @article.update(article_params)

  redirect_to article_path(@article)
end
```

We can add a flash message by inserting one line:

```ruby
def update
  @article = Article.find(params[:id])
  @article.update(article_params)

  flash.notice = "Article '#{@article.title}' Updated!"

  redirect_to article_path(@article)
end
```

#### Testing the Flash

Try editing and saving an article through your browser. Does anything show up?

We need to add the flash to our view templates. The `update` method redirects to the `show`, so we _could_ just add the display to our show template.

However, we will use the flash in many actions of the application. Most of the time, it's preferred to add it to our layout.

#### Flash in the Layout

If you look in `app/views/layouts/application.html.erb` you'll find what is called the "application layout". A layout is used to wrap multiple view templates in your application. You can create layouts specific to each controller, but most often we'll just use one layout that wraps every view template in the application.

Looking at the default layout, you'll see this:

```erb
<!DOCTYPE html>
<html>
<head>
  <title>Blogger</title>
  <%= stylesheet_link_tag    "application", media: "all", "data-turbolinks-track" => true %>
  <%= javascript_include_tag "application", "data-turbolinks-track" => true %>
  <%= csrf_meta_tags %>
</head>
<body>

<%= yield %>

</body>
</html>

```

The `yield` is where the view template content will be injected. Just *above* that yield, let's display the flash by adding this:

```erb
<p class="flash"><%= flash.notice %></p>
```

This outputs the value stored in the `flash` object in the attribute `:notice`.

#### More Flash Testing

With the layout modified, try changing your article, clicking save, and you should see the flash message appear at the top of the `show` page.

#### Adding More Messages

Typical controllers will set flash messages in the `update`, `create`, and `destroy` actions. Insert messages into the latter two actions now.

Test out each action/flash, then you're done with I1.

### An Aside on the Site Root

It's annoying me that we keep going to `http://localhost:3000/` and seeing the Rails starter page. Let's make the root show our articles index page.

Open `config/routes.rb` and right above the other routes (in this example, right above `resources :articles`) add in this one:

```ruby
root to: 'articles#index'
```

Now visit `http://localhost:3000` and you should see your article list.


#### Another Save to Github.

The form-based workflow is complete, and it is common to commit and push changes after each feature. Go ahead and add/commit/push it up to Github:

{% terminal %}
$ git add -A
$ git commit -m "form-based workflow feature completed"
$ git push
{% endterminal %}

If you are not happy with the code changes you have implemented in this iteration, you don't have to throw the whole project away and restart it.  You can use Github's reset --hard functionality to roll back to your first commit, and retry this iteration from there.  To do so, in your terminal, type in:

{% terminal %}
$ git log
commit 15384dbc144d4cb99dc335ecb1d4608c29c46371
Author: your_name your_email
Date:   Thu Apr 11 11:02:57 2013 -0600
    first blogger commit
$ git reset --hard 15384dbc144d4cb99dc335ecb1d4608c29c46371
{% endterminal %}
