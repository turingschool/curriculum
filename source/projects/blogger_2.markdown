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

