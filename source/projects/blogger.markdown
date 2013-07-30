---
layout: page
title: Blogger
alias: [ /blogger, /blogger.html ]
sidebar: true
language: ruby
topics: rails
---

In this project you'll create a simple blog system and learn the basics of Ruby on Rails including:

* Models, Views, and Controllers (MVC)
* Data Structures & Relationships
* Routing
* Migrations
* Views with forms, partials, and helpers
* RESTful design

The project will be developed in three iterations.

<div class="note">
<p>This tutorial is open source. If you notice errors, typos, or have questions/suggestions, please <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/projects/blogger.markdown">submit them to the project on Github</a>.</p>
</div>

## I0: Up and Running

Part of the reason Ruby on Rails became popular quickly is that it takes a lot of the hard work off your hands, and that's especially true in starting up a project. Rails practices the idea of "sensible defaults" and will, with one command, create a working application ready for your customization.

### Setting the Stage

First we need to make sure everything is set up and installed. See the [Environment Setup]({% page_url topics/environment/environment %}) page for instructions on setting up and verifying your Ruby, Rails, and add-ons.

This tutorial was created with Rails 4.0.0, and may need slight adaptations for other versions of Rails. Let us know if you find something strange!

From the command line, switch to the folder that will store your projects. For instance `/Users/you/projects/`.

Within that folder, run the `rails` command:

{% terminal %}
$ rails new blogger
{% endterminal %}

Use `cd blogger` to change into the directory, then open it in your text editor. If you're using Sublime Text run `subl .`.

### Project Tour

The generator has created a Rails application for you. Let's figure out what's in there. Looking at the project root, we have these folders:

* `app` - This is where 98% of your effort will go. It contains subfolders which will hold most of the code you write including Models, Controllers, Views, Helpers, JavaScript, etc.
* `config` - Control the environment settings for your application. It also includes the `initializers` subfolder which holds items to be run on startup.
* `db` - Will eventually have a `migrations` subfolder where your migrations, used to structure the database, will be stored. When using SQLite3, as is the Rails default, the database file will be stored in this folder.
* `doc` - Who writes documentation? If you did, it'd go here. Someday.
* `lib` - Not commonly used, this folder is to store code you control that is reusable outside the project. Instead of storing code here, consider packaging it as a gem.
* `log` - Log files, one for each environment.
* `public` - Static files can be stored and accessed from here, but all the interesting things (JavaScript, Images, CSS) live in `app/assets`.
* `test` - If your project is using the default `Test::Unit` testing library, the tests will live here
* `tmp` - Temporary cached files
* `vendor` - Infrequently used, this folder is to store code you *do not* control. With Bundler and Rubygems, we generally don't need anything in here during development.

### Configuring the Database

Look in the `config` directory and open the file `database.yml`. This file controls how Rails' database connection system will access your database. You can configure many different databases, including SQLite3, MySQL, PostgreSQL, SQL Server, and Oracle.

If you were connecting to an existing database you would enter the database configuration parameters here. Since we're using SQLite3 and starting from scratch, we can leave the defaults to create a new database, which will happen automatically. The database will be stored in `db/development.sqlite3`

### Starting the Server

At your terminal and inside the project directory, start the server.

On Mac/Linux, you start the server with:

{% terminal %}
$ bin/rails server
{% endterminal %}

On Windows, you need to explicitly tell the computer to use Ruby:

{% terminal %}
$ ruby bin/rails server
{% endterminal %}

<div class="note">
Note that we use <code>bin/rails</code> here but we used <code>rails</code> previously. The <code>rails</code> command is used for generating new projects, and the <code>bin/rails</code> command is used for controlling Rails. For all the commands that start with <code>bin/rails</code>, you will need to use <code>ruby bin/rails</code> if you are on Windows.
</div>

It generally takes about 15 seconds. When you see seven lines like this:

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

### Accessing the Server

Open any web browser and enter the address [http://0.0.0.0:3000](http://0.0.0.0:3000). You can also use `http://localhost:3000` or `http://127.0.0.1:3000` -- they are all "loopback" addresses that point to your machine.

You'll see the Rails' "Welcome Aboard" page. Click the "About your application’s environment" link and you should see the versions of various gems. As long as there's no error, you're good to go.

#### Getting an Error?

If you see an error here, it's most likely related to the database.

If you are running Windows you may not have the SQLite3 application installed, or the sqlite3 gem isn't installed properly. Go back to [Environment Setup]({% page_url topics/environment/environment %}) and use the Rails Installer package. Make sure you check the box during setup to configure the environment variables. Restart your machine after the installation and give it another try.

### Creating the Article Model

Our blog will be centered around "articles," so we'll need a table in the database to store all the articles and a model to allow our Rails app to work with that data. We'll use one of Rails' generators to create the required files. Switch to your terminal and enter the following:

{% terminal %}
$ bin/rails generate model Article
{% endterminal %}

We're running the `generate` script, telling it to create a `model`, and naming that model `Article`. From that information, Rails creates the following files:

* `db/migrate/TIMESTAMP_create_articles.rb` - A database migration to create the `articles` table
* `app/models/article.rb` - The file that will hold the model code
* `test/models/article_test.rb` - A file to hold unit tests for `Article`
* `test/fixtures/articles.yml` - A fixtures file to assist with unit testing

With those files in place we can start developing.

### Working with the Database

Rails uses migration files to perform modifications to the database. Almost any modification you can make to a DB can be done through a migration. The killer feature about Rails migrations is that they're generally database agnostic. When developing applications I usually use SQLite3 as we are in this tutorial, but when I deploy to my server it is running PostgreSQL. Many others choose MySQL. It doesn't matter -- the same migrations will work on all of them.

This is an example of how Rails takes some of the painful work off your hands. You write your migrations once, then run them against almost any database.

#### What is a Migration?

Open `db/migrate/TIMESTAMP_create_articles.rb` and take a look. First you'll notice that the filename begins with a mish-mash of numbers, which is a timestamp of when the migration was created. Migrations need to be ordered, so the timestamp serves to keep them in chronological order.

Inside the file, you'll see just the method `change`. It's not obvious by looking at the file, but Rails has a built-in safety-valve allowing you to to undo a migration. Rails automatically figures out which operations to perform in order to reverse the change described in the `change` method.

<div class="note">
If we are creating a complicated migration, Rails might not know how to undo it. If that is the case we can create two methods called <code>up</code> and <code>down</code> rather than a single method named <code>change</code>. <code>up</code> is for the change we want to make, and <code>down</code> is for the steps to undo that change.
</div>

#### Modifying `change`

Inside the `change` method you'll see the generator has placed a call to the `create_table` method, passed the symbol `:articles` as a parameter, and created a block with the variable `t` referencing the table that's created.

We call methods on `t` to create columns in the `articles` table. What kind of fields does our Article need to have?  Since migrations make it easy to add or change columns later, we don't need to think of EVERYTHING right now, we just need a few to get us rolling. Let's start with _title_ (a string) and _body_ (a "text").

Add these to your `change` so it looks like this:

```ruby
def change
  create_table :articles do |t|
    t.string :title
    t.text :body

    t.timestamps
  end
end
```

You might be wondering, what is a "text" type?

This is an example of relying on the Rails database adapters to make the right call. For some databases, large text fields are stored as `varchar`, while others like Postgres use a `text` type. The database adapter will figure out the best choice for us depending on the configured database -- we don't have to worry about it.

#### Timestamps

What is that `t.timestamps` doing there? It will create two columns inside our table titled `created_at` and `updated_at`. Rails will manage these columns for us, so when an article is created its `created_at` and `updated_at` are automatically set. Each time we make a change to the article, the `updated_at` will automatically be updated. Very handy.

#### Running the Migration

Save that migration file and run this command in your terminal:

{% terminal %}
$ bin/rake db:migrate
{% endterminal %}

The `rake` program is a ruby utility for running maintenance-like functions on your application such as working with the database, executing unit tests, or deploying to a server. We tell `rake` to `db:migrate` which means "look in your set of functions for the database (`db`) and run the `migrate` function."

The `migrate` action finds all migrations in the `db/migrate/` folder, looks at a special table in the database to determine which migrations have and have not been run yet, then runs any migration that hasn't been run.

In this case we had just one migration to run and it should print some output like this to your terminal:

{% terminal %}
$ bin/rake db:migrate
==  CreateArticles: migrating =================================================
-- create_table(:articles)
   -> 0.0012s
==  CreateArticles: migrated (0.0013s) ========================================
{% endterminal %}

It tells you that it is running the migration named `CreateArticles`. And the "migrated" line means that it completed without errors.

Try running `rake db:migrate` again now, and see what happens.

We've now created the `articles` table in the database and can start working on our `Article` model.

### Working with a Model in the Console

Another awesome feature of working with Rails is the `console`. The `console` is a command-line interface to your application. It allows you to access and work with just about any part of your application directly instead of going through the web interface. This can simplify your development process, and even once an app is in production the console makes it very easy to do bulk modifications, searches, and other data operations.

Open the console by going to your terminal and entering:

{% terminal %}
$ bin/rails console
{% endterminal %}

You'll then just get back a prompt of `>>`. You're now inside an `irb` interpreter with full access to your application.

#### Some Experiments

The console is essentially `IRB`, but with your whole Rails application loaded into it. You can do anything you previously did inside `IRB` in the `console`:

{% irb %}
$ Time.now
{% endirb %}

For the moment, your app consists of a single `Article` model.

You can call the `all` method which returns an array of all articles in the database -- so far an empty array.

{% irb %}
$ Article.all
{% endirb %}

Next, create a new Article object. You can see that this new object had attributes `id`, `title`, `body`, `created_at`, and `updated_at`.

{% irb %}
$ Article.new
{% endirb %}

### Looking at the Model

All the code for the `Article` model is in the file `app/models/article.rb`, so let's open that now.

Not very impressive, right?  There are no attributes defined inside the model, so how does Rails know that an Article should have a `title`, a `body`, etc? It queries the database, looks at the articles table, and assumes that whatever columns that table has should probably be the attributes accessible through the model.

You created most of those in your migration file, but what about `id`?  Every table you create with a migration will automatically have an `id` column which serves as the table's primary key. When you want to find a specific article, you'll look it up in the articles table by its unique ID number. Rails and the database work together to make sure that these IDs are unique, usually using a special column type in the DB like "serial".

In your console, try entering `Article.all` again. Do you see the blank article that we created with the `Article.new` command?  No?  The console doesn't change values in the database until we explicitly call the `.save` method on an object. Let's create a sample article and you'll see how it works. Enter each of the following lines one at a time:

{% irb %}
$ a = Article.new
$ a.title = "Sample Article Title"
$ a.body = "This is the text for my article, woo hoo!"
$ a.save
$ Article.all
{% endirb %}

Now you'll see that the `Article.all` command gave you back an array holding the one article we created and saved.

*Create 3 more sample articles.*

### Setting up the Router

We've created a few articles through the console, but we really don't have a web application until we have a web interface. Let's get that started. We said that Rails uses an "MVC" architecture and we've worked with the Model, now we need a Controller and View.

When a Rails server gets a request from a web browser it first goes to the _router_. The router decides what resources the request is trying to interact with. The router dissects a request based on the address it is requesting combined with the HTTP verb (like GET or PUT).

We can use `rake` to see which routes are defined for our application. Since you have the console running in your terminal window, open up a new window, navigate to your project, and enter:

{% terminal %}
$ bin/rake routes
{% endterminal %}

Running that command outputs:

```plain
You don't have any routes defined!

Please add some routes in config/routes.rb.

For more information about routes, see the Rails guide: http://guides.rubyonrails.org/routing.html.
```

We don't have any routes yet.

Open the router's configuration file, `config/routes.rb`. Inside this file you'll see a LOT of comments that show you examples of how to define routes.

Remove all the comments, leaving only two lines in the file:

```ruby
Blogger::Application.routes.draw do
end
```

Add a `resources :articles` declaration:

```ruby
Blogger::Application.routes.draw do
  resources :articles
end
```

This line tells Rails that we have a resource named `articles` and the router should expect requests to follow the *RESTful* model of web interaction (REpresentational State Transfer).

The details don't matter right now, but when you make a request like `http://localhost:3000/articles`, the router will understand you're looking for a listing of the articles, and `http://localhost:3000/articles/new` means you're trying to create a new article.

Go to a command prompt and run `bin/rake routes` again.

This time, you'll get a listing like this:

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

These are the seven core actions of Rails' REST implementation. To understand the table, let's look at the first row as an example:

{% terminal %}
      Prefix Verb   URI Pattern                  Controller#Action
    articles GET    /articles(.:format)          articles#index
{% endterminal %}

The left most column says `articles`. This is the *prefix* of the path. The router will provide two methods to us using that name, `articles_path` and `articles_url`. The `_path` version uses a relative path while the `_url` version uses the full URL with protocol, server, and path. The `_path` version is always preferred.

The second column, `GET`, is the HTTP verb for the route. Web browsers typically submit requests with the verbs `GET` or `POST`. In this column, you'll see other HTTP verbs including `PUT`, `PATCH`, and `DELETE` which browsers don't actually use. We'll talk more about those later.

The third column is similar to a regular expression which is matched against the requested URL. Elements in parentheses are optional. Markers starting with a `:` will be made available to the controller with that name. In our example line, `/articles(.:format)` will match the URLs `/articles/`, `/articles.json`, `/articles` and other similar forms.

The fourth column is what part of the application will handle a request that matches this route.

### Creating the Articles Controller

Declaring the articles resources lets the router know where to direct requests about articles, but if we spin up the application and go to [http://localhost:3000/articles](http://localhost:3000/articles) we'll get an error.

The router will try to send us to the `index` action of the `ArticlesController`, which doesn't exist yet.

We'll use another generator to create the missing controller:

{% terminal %}
$ bin/rails generate controller articles
{% endterminal %}

The output shows that the generator created several files/folders for you:

* `app/controllers/articles_controller.rb` : The controller file itself
* `app/views/articles` : The directory to contain the controller's view templates
* `test/controllers/articles_controller_test.rb` : The controller's unit tests file
* `app/helpers/articles_helper.rb` : A helper file to assist with the views
* `test/helpers/articles_helper_test.rb` : The helper's unit test file
* `app/assets/javascripts/articles.js.coffee` : A CoffeeScript file for this controller
* `app/assets/stylesheets/articles.css.scss` : An SCSS stylesheet for this controller

Open up the controller file, `app/controllers/articles_controller.rb`. You'll see that this is basically a blank class, beginning with the `class` keyword and ending with the `end` keyword. Any code we add to the controller must go _between_ these two lines.

### Defining the Index Action

The first feature we want to add is an "index" page. This is what the app will send back when a user requests [http://localhost:3000/articles](http://localhost:3000/articles) -- following the RESTful conventions, this should be a list of the articles. So when the router sees this request come in, it tries to call the `index` action inside `articles_controller`.

First try it out by going to [http://localhost:3000/articles](http://localhost:3000/articles) into your web browser. You should get an error message that looks like this:

```plain
Unknown action

The action 'index' could not be found for ArticlesController
```

The router tried to call the `index` action, but the articles controller doesn't have a method with that name.

Add the following method inside the controller:

```ruby
def index
  @articles = Article.all
end
```

#### Instance Variables

The at-sign (`@`) at the front of `@articles` marks this variable as an "instance variable".

We want the list of articles to be accessible from both the controller and the view that we're about to create. In order for it to be visible in both places it has to be an instance variable. If we had just named it `articles`, that local variable would only be available within the `index` method of the controller.

A normal Ruby instance variable is available to all methods within an instance.

In Rails' controllers, there's a *hack* which copies instance variables from the controller to the object which renders the view template. Any data we want available in the view template should be promoted to an instance variable by adding a `@` to the beginning.

<div class="note">
<p>There are ways to accomplish the same goals without instance variables, but they're not widely used. Check out the <a href="https://github.com/voxdolo/decent_exposure">Decent Exposure</a> gem to learn more.</p>
</div>

### Creating the Template

Refresh your browser. The error message changed.

```plain
Template is missing

Missing template articles/index, application/index with {:locale=>[:en], :formats=>[:html], :handlers=>[:erb, :builder, :raw, :ruby, :jbuilder, :coffee]}. Searched in: * "/Users/you/projects/blogger/app/views"
```

The error message is pretty helpful. It tells us that the app is looking for a (view) template in `app/views/articles/` but it can't find one named `index`. Rails has *assumed* that our `index` action in the controller should have a corresponding `index` view template in the views folder.

We didn't have to put any code in the controller to tell it what view we wanted, Rails just figures it out.

If you look closely at the error message, you'll see that it's not looking for any old `index` file, it's looking for an HTML index file (`format`), and it's expecting it to use a handler in the following list:

* `:erb`
* `:builder`
* `:raw`
* `:ruby`
* `:jbuilder`
* `:coffee`

We could fix this error message by creating an empty file in `app/views/articles/` named any of the following:

* `index.html.erb`
* `index.html.builder`
* `index.html.raw`
* `index.html.ruby`
* `index.html.jbuilder`
* `index.html.coffee`

We'll use `erb`.

In your editor, find the folder `app/views/articles` and, in that folder, create a file named `index.html.erb`.

#### Index Template Content

Now you're looking at a blank file. Enter in this view template code:

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

Back in `app/views/articles/index.html.erb`, find the line:

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

At the very bottom of the template, add a link to the "Create a New Article" page.

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
NoMethodError in Articles#new
Showing /Users/you/projects/blogger/app/views/articles/new.html.erb where line #3 raised:
undefined method `model_name' for NilClass:Class
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

The `show` page has the title, but where's the body? Add a line to the action to pull out the `:body` key from the `params` hash and store it into `@article`.

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
the time, they're used in a helper method:

```ruby
  def article_params
    params.require(:article).permit(:title, :body)
  end
```

You then use this method instead of the `params` hash directly:

```ruby
  @article = Article.new(article_params)
```

Go ahead and add this helper method to your code, and change the arguments to `new`. It should look like this when you're done:

```ruby
  def create
    @article = Article.new(article_params)
    @article.save

    redirect_to article_path(@article)
  end

  def article_params
    params.require(:article).permit(:title, :body)
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

There's one more parameter you might want to add to your `link_to` call:

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

Open `config/routes.rb` and right above the other routes add in this one:

```ruby
root to: 'articles#index'
```

Now visit `http://localhost:3000` and you should see your article list.


####Another Save to Github.

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

## I2: Adding Comments

Most blogs allow the reader to interact with the content by posting comments. Let's add some simple comment functionality.

### Designing the Comment Model

First, we need to brainstorm what a comment _is_...what kinds of data does it have...

* It's attached to an article
* It has an author name
* It has a body

With that understanding, let's create a `Comment` model. Switch over to your terminal and enter this line:

{% terminal %}
$ bin/rails generate model Comment author_name:string body:text article:references
{% endterminal %}

We've already gone through what files this generator creates, we'll be most interested in the migration file and the `comment.rb`.

### Setting up the Migration

Open the migration file that the generator created,
`db/migrate/some-timestamp_create_comments.rb`. Let's see the fields that were
added:

```ruby
t.string  :author_name
t.text    :body
t.references :article
```

Once that's complete, go to your terminal and run the migration:

{% terminal %}
$ bin/rake db:migrate
{% endterminal %}

### Relationships

The power of SQL databases is the ability to express relationships between
elements of data. We can join together the information about an order with the
information about a customer. Or in our case here, join together an article in
the `articles` table with its comments in the `comments` table. We do this by
using foreign keys.

Foreign keys are a way of marking one-to-one and one-to-many relationships. An
article might have zero, five, or one hundred comments. But a comment only
belongs to one article. These objects have a one-to-many relationship -- one
article connects to many comments.

Part of the big deal with Rails is that it makes working with these
relationships very easy. When we created the migration for comments we started
with an `references` field named `article`. The Rails convention for a
one-to-many relationship:

* the objects on the "many" end should have a foreign key referencing the "one" object.
* that foreign key should be titled with the name of the "one" object, then an underscore, then "id".

In this case one article has many comments, so each comment has a field named `article_id`.

Following this convention will get us a lot of functionality "for free."  Open your `app/models/comment.rb` and check it out:

```ruby
class Comment < ActiveRecord::Base
  belongs_to :article
end
```

A comment relates to a single article, it "belongs to" an article. We then want to declare the other side of the relationship inside `app/models/article.rb` like this:

```ruby
class Article < ActiveRecord::Base
  has_many :comments
end
```

Now an article "has many" comments, and a comment "belongs to" an article. We have explained to Rails that these objects have a one-to-many relationship.

### Testing in the Console

Let's use the console to test how this relationship works in code. If you don't have a console open, go to your terminal and enter `rails console` from your project directory. If you have a console open already, enter the command `reload!` to refresh any code changes.

Run the following commands one at a time and observe the output:

{% irb %}
$ a = Article.first
$ a.comments
$ Comment.new
$ a.comments.new
$ a.comments
{% endirb %}

When you called the `comments` method on object `a`, it gave you back a blank array because that article doesn't have any comments. When you executed `Comment.new` it gave you back a blank Comment object with those fields we defined in the migration.

But, if you look closely, when you did `a.comments.new` the comment object you got back wasn't quite blank -- it has the `article_id` field already filled in with the ID number of article `a`. Additionally, the following (last) call to `a.comments` shows that the new comment object has already been added to the in-memory collection for the `a` article object.

Try creating a few comments for that article like this:

{% irb %}
$ c = a.comments.new
$ c.author_name = "Daffy Duck"
$ c.body = "I think this article is thhh-thhh-thupid!"
$ c.save
$ d = a.comments.create(author_name: "Chewbacca", body: "RAWR!")
{% endirb %}

For the first comment, `c`, I used a series of commands like we've done before. For the second comment, `d`, I used the `create` method. `new` doesn't send the data to the database until you call `save`. With `create` you build and save to the database all in one step.

Now that you've created a few comments, try executing `a.comments` again. Did your comments all show up?  When I did it, only one comment came back. The console tries to minimize the number of times it talks to the database, so sometimes if you ask it to do something it's already done, it'll get the information from the cache instead of really asking the database -- giving you the same answer it gave the first time. That can be annoying. To force it to clear the cache and lookup the accurate information, try this:

{% irb %}
$ a.reload
$ a.comments
{% endirb %}

You'll see that the article has associated comments. Now we need to integrate them into the article display.

### Displaying Comments for an Article

We want to display any comments underneath their parent article. Open `app/views/articles/show.html.erb` and add the following lines right before the link to the articles list:

```erb
<h3>Comments</h3>
<%= render partial: 'articles/comment', collection: @article.comments %>
```

This renders a partial named `"comment"` and that we want to do it once for each element in the collection `@article.comments`. We saw in the console that when we call the `.comments` method on an article we'll get back an array of its associated comment objects. This render line will pass each element of that array one at a time into the partial named `"comment"`. Now we need to create the file `app/views/articles/_comment.html.erb` and add this code:

```erb
<div>
  <h4>Comment by <%= comment.author_name %></h4>
  <p class="comment"><%= comment.body %></p>
</div>
```

Display one of your articles where you created the comments, and they should all show up.

### Web-Based Comment Creation

Good start, but our users can't get into the console to create their comments. We'll need to create a web interface.

#### Building a Comment Form Partial

The lazy option would be to add a "New Comment" link to the article `show` page. A user would read the article, click the link, go to the new comment form, enter their comment, click save, and return to the article.

But, in reality, we expect to enter the comment directly on the article page. Let's look at how to embed the new comment form onto the article `show`.

Just above the "Back to Articles List" in the articles `show.html.erb`:

```erb
<%= render partial: 'comments/form' %>
```

This is expecting a file `app/views/comments/_form.html.erb`, so create the `app/views/comments/` directory with the `_form.html.erb` file, and add this starter content:

```erb
<h3>Post a Comment</h3>
<p>(Comment form will go here)</p>
```

Look at an article in your browser to make sure that partial is showing up. Then we can start figuring out the details of the form.

#### In the `ArticlesController`

First look in your `articles_controller.rb` for the `new` method.

Remember how we created a blank `Article` object so Rails could figure out which fields an article has?  We need to do the same thing before we create a form for the `Comment`.

But when we view the article and display the comment form we're not running the article's `new` method, we're running the `show` method. So we'll need to create a blank `Comment` object inside that `show` method like this:

```ruby
@comment = Comment.new
@comment.article_id = @article.id
```

Due to the Rails' mass-assignment protection, the `article_id` attribute
of the new `Comment` object needs to be manually assigned with the `id`
of the `Article`. Why do you think we use `Comment.new` instead of
`@article.comments.new`?

#### Improving the Comment Form

Now we can create a form inside our `comments/_form.html.erb` partial like this:

```erb
<h3>Post a Comment</h3>

<%= form_for [ @article, @comment ] do |f| %>
  <p>
    <%= f.label :author_name %><br/>
    <%= f.text_field :author_name %>
  </p>
  <p>
    <%= f.label :body %><br/>
    <%= f.text_area :body %>
  </p>
  <p>
    <%= f.submit 'Submit' %>
  </p>
<% end %>
```

#### Trying the Comment Form

Save and refresh your web browser and you'll get an error like this:

```plain
NoMethodError in Articles#show
Showing app/views/comments/_form.html.erb where line #3 raised:
undefined method `article_comments_path' for #<ActionView::Base:0x10446e510>
```

The `form_for` helper is trying to build the form so that it submits to `article_comments_path`. That's a helper which we expect to be created by the router, but we haven't told the router anything about `Comments` yet. Open `config/routes.rb` and update your article to specify comments as a sub-resource.

```ruby
resources :articles do
  resources :comments
end
```

Then refresh your browser and your form should show up. Try filling out the comments form and click SUBMIT -- you'll get an error about `uninitialized constant CommentsController`.

<div class="note">
  <p>Did you figure out why we aren't using <code>@article.comments.new</code>? If you want, edit the <code>show</code> action and replace <code>@comment = Comment.new</code> with <code>@comment = @article.comments.new</code>. Refresh the browser. What do you see?</p>
  <p>For me, there is an extra empty comment at the end of the list of comments. That is due to the fact that <code>@article.comments.new</code> has added the new <code>Comment</code> to the in-memory collection for the <code>Article</code>. Don't forget to change this back.</p>
</div>

#### Creating a Comments Controller

Just like we needed an `articles_controller.rb` to manipulate our `Article` objects, we'll need a `comments_controller.rb`.

Switch over to your terminal to generate it:

{% terminal %}
$ bin/rails generate controller comments
{% endterminal %}

#### Writing `CommentsController.create`

The comment form is attempting to create a new `Comment` object which triggers the `create` action. How do we write a `create`?

You can cheat by looking at the `create` method in your `articles_controller.rb`. For your `comments_controller.rb`, the instructions should be the same just replace `Article` with `Comment`.

There is one tricky bit, though! We need to assign the article id to our comment like this:

```ruby
def create
  @comment = Comment.new(comment_params)
  @comment.article_id = params[:article_id]

  @comment.save

  redirect_to article_path(@comment.article)
end

def comment_params
  params.require(:comment).permit(:author_name, :body)
end
```

#### After Creation

As a user, imagine you write a witty comment, click save, then what would you expect? Probably to see the article page, maybe automatically scrolling down to your comment.

At the end of our `create` action in `CommentsController`, how do we handle the redirect? Instead of showing them the single comment, let's go back to the article page:

```ruby
redirect_to article_path(@comment.article)
```

Recall that `article_path` needs to know *which* article we want to see. We might not have an `@article` object in this controller action, but we can find the `Article` associated with this `Comment` by calling `@comment.article`.

Test out your form to create another comment now -- and it should work!

### Cleaning Up

We've got some decent comment functionality, but there are a few things we should add and tweak.

#### Comments Count

Let's make it so where the view template has the "Comments" header it displays how many comments there are, like "Comments (3)". Open up your article's `show.html.erb` and change the comments header so it looks like this:

```erb
<h3>Comments (<%= @article.comments.size %>)</h3>
```

#### Form Labels

The comments form looks a little silly with "Author Name". It should probably say "Your Name", right?  To change the text that the label helper prints out, you pass in the desired text as a second parameter, like this:

```erb
<%= f.label :author_name, "Your Name"  %>
```

Change your `comments/_form.html.erb` so it has labels "Your Name" and "Your Comment".

#### Add a Timestamp to the Comment Display

We should add something about when the comment was posted. Rails has a really neat helper named `distance_of_time_in_words` which takes two dates and creates a text description of their difference like "32 minutes later", "3 months later", and so on.

You can use it in your `_comment.html.erb` partial like this:

```erb
<p>Posted <%= distance_of_time_in_words(comment.article.created_at, comment.created_at) %> later</p>
```

With that, you're done with I2!


####Time to Save to Github Again!

Now that the comments feature has been added push it up to Github:

{% terminal %}
$ git commit -am "finished blog comments feature"
$ git push
{% endterminal %}


## I3: Tagging

In this iteration we'll add the ability to tag articles for organization and navigation.

First we need to think about what a tag is and how it'll relate to the Article model. If you're not familiar with tags, they're commonly used in blogs to assign the article to one or more categories.

For instance, if I write an article about a feature in Ruby on Rails, I might want it tagged with all of these categories: "ruby", "rails" and "programming". That way if one of my readers is looking for more articles about one of those topics they can click on the tag and see a list of my articles with that tag.

### Understanding the Relationship

What is a tag?  We need to figure that out before we can create the model. First, a tag must have a relationship to an article so they can be connected. A single tag, like "ruby" for instance, should be able to relate to *many* articles. On the other side of the relationship, the article might have multiple tags (like "ruby", "rails", and "programming" as above) - so it's also a *many* relationship. Articles and tags have a *many-to-many* relationship.

Many-to-many relationships are tricky because we're using an SQL database. If an Article "has many" tags, then we would put the foreign key `article_id` inside the `tags` table - so then a Tag would "belong to" an Article. But a tag can connect to *many* articles, not just one. We can't model this relationship with just the `articles` and `tags` tables.

When we start thinking about the database modeling, there are a few ways to achieve this setup. One way is to create a "join table" that just tracks which tags are connected to which articles. Traditionally this table would be named `articles_tags` and Rails would express the relationships by saying that the Article model `has_and_belongs_to_many` Tags, while the Tag model `has_and_belongs_to_many` Articles.

Most of the time this isn't the best way to really model the relationship. The connection between the two models usually has value of its own, so we should promote it to a real model. For our purposes, we'll introduce a model named "Tagging" which is the connection between Articles and Tags. The relationships will setup like this:

* An Article `has_many` Taggings
* A Tag `has_many` Taggings
* A Tagging `belongs_to` an Article and `belongs_to` a Tag

### Making Models

With those relationships in mind, let's design the new models:

* Tag
  * `name`: A string
* Tagging
  * `tag_id`: Integer holding the foreign key of the referenced Tag
  * `article_id`: Integer holding the foreign key of the referenced Article

Note that there are no changes necessary to Article because the foreign key is stored in the Tagging model. So now lets generate these models in your terminal:

{% terminal %}
$ bin/rails generate model Tag name:string
$ bin/rails generate model Tagging tag:references article:references
$ bin/rake db:migrate
{% endterminal %}

### Expressing Relationships

Now that our model files are generated we need to tell Rails about the relationships between them. For each of the files below, add these lines:

In `app/models/article.rb`:

```ruby
has_many :taggings
```

In `app/models/tag.rb`:

```ruby
has_many :taggings
```

After Rails had been around for awhile, developers were finding this kind of relationship very common. In practical usage, if I had an object named `article` and I wanted to find its Tags, I'd have to run code like this:

```ruby
tags = article.taggings.collect{|tagging| tagging.tag}
```

That's a pain for something that we need commonly.

An article has a list of tags through the relationship of taggings. In Rails we can express this "has many" relationship through an existing "has many" relationship. We will update our article model and tag model to express that relationship.

In `app/models/article.rb`:

```ruby
has_many :taggings
has_many :tags, through: :taggings
```

In `app/models/tag.rb`:

```ruby
has_many :taggings
has_many :articles, through: :taggings
```

Now if we have an object like `article` we can just ask for `article.tags` or, conversely, if we have an object named `tag` we can ask for `tag.articles`.

To see this in action, start the `bin/rails console` and try the following:

{% irb %}
$ a = Article.first
$ a.tags.create name: "tag1"
$ a.tags.create name: "tag2"
$ a.tags
=> [#<Tag id: 1, name: "tag1", created_at: "2012-11-28 20:17:55", updated_at: "2012-11-28 20:17:55">, #<Tag id: 2, name: "tag2", created_at: "2012-11-28 20:31:49", updated_at: "2012-11-28 20:31:49">]
{% endirb %}

### An Interface for Tagging Articles

The first interface we're interested in is within the article itself. When I write an article, I want to have a text box where I can enter a list of zero or more tags separated by commas. When I save the article, my app should associate my article with the tags with those names, creating them if necessary.

Add the following to our existing form in `app/views/articles/_form.html.erb`:

```erb
<p>
  <%= f.label :tag_list %><br />
  <%= f.text_field :tag_list %>
</p>
```

With that added, try to create an new article in your browser and your should see this error:

```plain
NoMethodError in Articles#new
Showing app/views/articles/_form.html.erb where line #14 raised:
undefined method `tag_list' for #<Article:0x10499bab0>
```

An Article doesn't have an attribute or method named `tag_list`. We made it up in order for the form to display, we need to add a method to the `article.rb` file like this:

```ruby
def tag_list
  tags.join(", ")
end
```

Back in your console, find that article again, and take a look at the results of `tag_list`:

{% irb %}
a = Article.first
a.tag_list
=> "#<Tag:0x007fe4d60c2430>, #<Tag:0x007fe4d617da50>"
{% endirb %}

That is not quite right. What happened?

Our array of tags is an array of Tag instances. When we joined the array Ruby called the default `#to_s` method on every one of these Tag instances. The default `#to_s` method for an object produces some really ugly output.

We could fix the `tag_list` method by:

* Converting all our tag objects to an array of tag names
* Joining the array of tag names together

```ruby
def tag_list
  self.tags.collect do |tag|
    tag.name
  end.join(", ")
end
```

Another alternative is to define a new `Tag#to_s` method which overrides the default:

```ruby
class Tag < ActiveRecord::Base
  attr_accessible :name

  has_many :taggings
  has_many :articles, through: :taggings

  def to_s
    name
  end
end
```

Now, when we try to join our `tags`, it'll delegate properly to our name
attribute. This is because `#join` calls `#to_s` on every element of the
array.

Your form should now show up and there's a text box at the bottom named "Tag list".
Enter content for another sample article and in the tag list enter 'ruby, technology'.
Click save. It.... worked?

But it didn't. Click 'edit' again, and you'll see that we're back to the `#<Tag...` business, like before. What gives?

```
Started PATCH "/articles/1" for 127.0.0.1 at 2013-07-17 09:25:20 -0400
Processing by ArticlesController#update as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"qs2M71Rmb64B7IM1ASULjlI1WL6nWYjgH/eOu8en+Dk=", "article"=>{"title"=>"Sample Article", "body"=>"This is the text for my article, woo hoo!", "tag_list"=>"ruby, technology"}, "commit"=>"Update Article", "id"=>"1"}
  Article Load (0.1ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = ? LIMIT 1  [["id", "1"]]
Unpermitted parameters: tag_list
```

Unpermitted parameters? Oh yeah! Strong Parameters has done its job, saving us from parameters we don't want. But in this case, we _do_ want that parameter. Open up your `app/controllers/articles_controller.rb` and fix the `article_params` method:

```ruby
  def article_params
    params.require(:article).permit(:title, :body, :tag_list)
  end
```

If you go back and put "ruby, technology" as tags, and click save, you'll get this new error:

```plain
ActiveRecord::UnknownAttributeError in ArticlesController#create
unknown attribute: tag_list
```

What is this all about?  Let's start by looking at the form data that was posted when we clicked SAVE. This data is in the terminal where you are running the rails server. Look for the line that starts "Processing ArticlesController#create", here's what mine looks like:

```plain
Processing ArticlesController#create (for 127.0.0.1) [POST]
  Parameters: {"article"=>{"body"=>"Yes, the samples continue!", "title"=>"My Sample", "tag_list"=>"ruby, technology"}, "commit"=>"Save", "authenticity_token"=>"xxi0A3tZtoCUDeoTASi6Xx39wpnHt1QW/6Z1jxCMOm8="}
```

The field that's interesting there is the `"tag_list"=>"technology, ruby"`. Those are the tags as I typed them into the form. The error came up in the `create` method, so let's peek at `app/controllers/articles_controller.rb` in the `create` method. See the first line that calls `Article.new(params[:article])`?  This is the line that's causing the error as you could see in the middle of the stack trace.

Since the `create` method passes all the parameters from the form into the `Article.new` method, the tags are sent in as the string `"technology, ruby"`. The `new` method will try to set the new Article's `tag_list` equal to `"technology, ruby"` but that method doesn't exist because there is no attribute named `tag_list`.

There are several ways to solve this problem, but the simplest is to pretend like we have an attribute named `tag_list`.

We can define the `tag_list=` method inside `article.rb` like this:

```ruby
def tag_list=(tags_string)

end
```

Just leave it blank for now and try to resubmit your sample article with tags. It goes through!

### Not So Fast

Did it really work?  It's hard to tell. Let's jump into the console and have a look.

{% irb %}
$ a = Article.last
$ a.tags
{% endirb %}

I bet the console reported that `a` had `[]` tags -- an empty list. (It also probably said something about an `ActiveRecord::Associations::CollectionProxy` 😉 ) So we didn't generate an error, but we didn't create any tags either.

We need to return to the `Article#tag_list=` method in `article.rb` and do some more work.

The `Article#tag_list=` method accepts a parameter, a string like **"tag1, tag2, tag3"** and we need to associate the article with tags that have those names. The pseudo-code would look like this:

* Split the *tags_string* into an array of strings with leading and trailing whitespace removed (so `"tag1, tag2, tag3"` would become `["tag1","tag2","tag3"]`
* For each of those strings...
  * Ensure each one of these strings are unique
  * Look for a Tag object with that name. If there isn't one, create it.
  * Add the tag object to a list of tags for the article
* Set the article's tags to the list of tags that we have found and/or created.

The first step is something that Ruby does very easily using the `String#split` method. Go into your console and try **"tag1, tag2, tag3".split**. By default it split on the space character, but that's not what we want. You can force split to work on any character by passing it in as a parameter, like this: `"tag1, tag2, tag3".split(",")`.

Look closely at the output and you'll see that the second element is `" tag2"` instead of `"tag2"` -- it has a leading space. We don't want our tag system to end up with different tags because of some extra (non-meaningful) spaces, so we need to get rid of that. The `String#strip` method removes leading or trailing whitespace -- try it with `" my sample ".strip`. You'll see that the space in the center is preserved.

So first we split the string, and then trim each and every element and collect those updated items:

{% irb %}
$ "programming, Ruby, rails".split(",").collect{|s| s.strip.downcase}
{% endirb %}

The `String#split(",")` will create the array with elements that have the extra spaces as before, then the `Array#collect` will take each element of that array and send it into the following block where the string is named `s` and the `String#strip` and `String#downcase` methods are called on it. The `downcase` method is to make sure that "ruby" and "Ruby" don't end up as different tags. This line should give you back `["programming", "ruby", "rails"]`.

Lastly, we want to make sure that each and every tag in the list is unique. `Array#uniq` allows us to remove duplicate items from an array.

{% irb %}
$ "programming, Ruby, rails, rails".split(",").collect{|s| s.strip.downcase}.uniq
{% endirb %}

Now, back inside our `tag_list=` method, let's add this line:

```ruby
tag_names = tags_string.split(",").collect{|s| s.strip.downcase}.uniq
```

So looking at our pseudo-code, the next step is to go through each of those `tag_names` and find or create a tag with that name. Rails has a built in method to do just that, like this:

```ruby
tag = Tag.find_or_create_by(name: tag_name)
```

And finally we need to collect up these new or found new tags and then assign them to our article.

```ruby
def tag_list=(tags_string)
  tag_names = tags_string.split(",").collect{|s| s.strip.downcase}.uniq
  new_or_found_tags = tag_names.collect { |name| Tag.find_or_create_by(name: name) }
  self.tags = new_or_found_tags
end
```

### Testing in the Console

Go back to your console and try these commands:

{% irb %}
$ reload!
$ article = Article.create title: "A Sample Article for Tagging!", body: "Great article goes here", tag_list: "ruby, technology"
$ article.tags
{% endirb %}

You should get back a list of the two tags. If you'd like to check the other side of the Article-Tagging-Tag relationship, try this:

{% irb %}
$ tag = article.tags.first
$ tag.articles
{% endirb %}

And you'll see that this Tag is associated with just one Article.

### Adding Tags to our Display

According to our work in the console, articles can now have tags, but we haven't done anything to display them in the article pages.

Let's start with `app/views/articles/show.html.erb`. Right below the line that displays the `article.title`, add this line:

```erb
<p>
  Tags:
  <% @article.tags.each do |tag| %>
    <%= link_to tag.name, tag_path(tag) %>
  <% end %>
</p>
```

Refresh your view and...BOOM:

```plain
NoMethodError in Articles#show
Showing app/views/articles/index.html.erb where line #6 raised:
undefined method `tag_path' for #<ActionView::Base:0x104aaa460>
```

The `link_to` helper is trying to use `tag_path` from the router, but the router doesn't know anything about our Tag object. We created a model, but we never created a controller or route. There's nothing to link to -- so let's generate that controller from your terminal:

{% terminal %}
$ rails generate controller tags
{% endterminal %}

Then we need to add it to our `config/routes.rb` like this:

```ruby
resources :tags
```

Refresh your article page and you should see tags, with links, associated with this article.

### Listing Articles by Tag

The links for our tags are showing up, but if you click on them you'll see our old friend "No action responded to show." error.

Open `app/controllers/tags_controller.rb` and define a show action:

```ruby
def show
  @tag = Tag.find(params[:id])
end
```

Then create the show template `app/views/tags/show.html.erb`:

```erb
<h1>Articles Tagged with <%= @tag.name %></h1>

<ul>
  <% @tag.articles.each do |article| %>
    <li><%= link_to article.title, article_path(article) %></li>
  <% end %>
</ul>
```

Refresh your view and you should see a list of articles with that tag. Keep in mind that there might be some abnormalities from articles we tagged before doing our fixes to the `tag_list=` method. For any article with issues, try going to its `edit` screen, saving it, and things should be fixed up. If you wanted to clear out all taggings you could do `Tagging.destroy_all` from your console.

### Listing All Tags

We've built the `show` action, but the reader should also be able to browse the tags available at `http://localhost:3000/tags`. I think you can do this on your own. Create an `index` action in your `tags_controller.rb` and an `index.html.erb` in the corresponding views folder. Look at your `articles_controller.rb` and Article `index.html.erb` if you need some clues.

With that, a long Iteration 3 is complete!


####Saving to Github.

Woah! The tagging feature is now complete. Good on you. Your going to want to push this to the repo.

{% terminal %}
$ git commit -am "Tagging feature completed"
$ git push
{% endterminal %}
