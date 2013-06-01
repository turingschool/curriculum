---
layout: page
title: "Scribblr: A JavaScript Blogging App"
sidebar: true
language: ruby
topics: rails
---

In this project we will create a simple blog using JavaScript for portions of the front-end. We'll cover:

* Rails Asset Pipeline
* JavaScript Unit Testing with Konacha
* JavaScript Integration Testing with Capybara

This project assumes you have a small amount of experience with Rails, and will primarily focus on the JavaScript.

## 0. Initial Setup

### Rails

First off, we need a Rails project. We're going to work with Rails 4, which as of the writing of this material is currently on RC1, which is a prerelease. You will need at least Ruby 1.9.3, and Ruby 2.0.0 is recommended.

Install Rails 4's RC1 with this command:

{% terminal %}
$ gem install rails -v 4.0.0.rc1
{% endterminal %}

Next, setup our initial project. It's going to be a JavaScript heavy Blog, so let's give it a cool name, like Scribblr:

{% terminal %}
$ rails new scribblr
$ cd scribblr
{% endterminal %}

Now let's boot up the Rails server:

{% terminal %}
$ rails server
=> Booting WEBrick
=> Rails 4.0.0.rc1 application starting in development on http://0.0.0.0:3000
=> Run `rails server -h` for more startup options
=> Ctrl-C to shutdown server
[2013-06-01 14:00:12] INFO  WEBrick 1.3.1
[2013-06-01 14:00:12] INFO  ruby 2.0.0 (2013-05-14) [x86_64-darwin12.3.0]
[2013-06-01 14:00:12] INFO  WEBrick::HTTPServer#start: pid=51959 port=3000
{% endterminal %}

Note that on the last line our server is running on port 3000. Visit [localhost:3000](http://localhost:3000) and you should see Rails's welcome screen.

## 1. Posts

To start with, we will need the basic interface for our blogging application, plus the associated database tables and ActiveRecord models.

### Scaffold

We're going to use Rails's built-in generators so we can get started quickly.Create a Post scaffold with a title and body:

{% terminal %}
$ rails g scaffold post title:string body:text
      invoke  active_record
      create    db/migrate/20130601180801_create_posts.rb
      create    app/models/post.rb
      invoke    test_unit
      create      test/models/post_test.rb
      create      test/fixtures/posts.yml
      invoke  resource_route
       route    resources :posts
      invoke  jbuilder_scaffold_controller
      create    app/controllers/posts_controller.rb
      invoke    erb
      create      app/views/posts
      create      app/views/posts/index.html.erb
      create      app/views/posts/edit.html.erb
      create      app/views/posts/show.html.erb
      create      app/views/posts/new.html.erb
      create      app/views/posts/_form.html.erb
      invoke    test_unit
      create      test/controllers/posts_controller_test.rb
      invoke    helper
      create      app/helpers/posts_helper.rb
      invoke      test_unit
      create        test/helpers/posts_helper_test.rb
      invoke    jbuilder
       exist      app/views/posts
      create      app/views/posts/index.json.jbuilder
      create      app/views/posts/show.json.jbuilder
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/posts.js.coffee
      invoke    scss
      create      app/assets/stylesheets/posts.css.scss
      invoke  scss
      create    app/assets/stylesheets/scaffolds.css.scss
{% endterminal %}

Wow, that's a lot of files! Let's walk through them:

1. `active_record`: this is our database migration, model, and unit tests
2. `resource_route`: this sets up `/posts` routes
3. `jbuilder_scaffold_controller`: this builds the controller, html views, controller test, helper, and jbuilder views (for json output)
4. `assets`: coffeescript and scss files for posts
5. `scss`: because this is our first scaffold, it brings in the default scaffold style

### Migrate

We need to run the pending database migrations so that we have the appropriate tabels and columns in our application.

{% terminal %}
 rake db:migrate
==  CreatePosts: migrating ====================================================
-- create_table(:posts)
   -> 0.0013s
==  CreatePosts: migrated (0.0014s) ===========================================
{% endterminal %}

Run the server (`rails server`) and visit [localhost:3000/posts](localhost:3000/posts). You should see an empty list of posts.

## 2. Asset Pipeline

Now that we have an application to explore, let's talk about the Rails asset pipeline. Remember when we built our scaffold, and it included a separate scaffolds file in `app/assets/stylesheets/scaffolds.css.scss`? Let's look at how that scaffold file gets included into our page.

In Chrome, open up the Inspector. On a Mac this is Option+Command+I, on Windows it is F12. You can also find it under the View menu, then the Developer submenu, or by right clicking on the page and clicking "Inspect".

Next, click on the Network tab at the top of the inspector, then refresh the page. You should see all the assets transferred to load this web page. At the bottom of the inspector, click Stylesheets. This should filter the list down to just the css files included in the page. You should see three files:

![Inspector with Stylesheets](/images/scribblr/inspector-stylesheets.png)

We have the `posts.css` file, `scaffolds.css`, and `application.css`.

Click on `application.css` each one to see what's inside each file. Note that only `scaffolds.css` has any real content.

Open up `app/assets/stylesheets/application.css` in your editor. Aside from the comments we saw in the inspector, there are two special directives at the end that look like this:

```css
 *= require_self
 *= require_tree .
```

These are Asset Pipeline require directives. They tell the Rails application what files to load in order to build `application.css`. The first one says to include the code found in `application.css` itself. The second tells Rails to scan the current directory tree for files, and include them.

Let's look at the directory tree for stylesheets:

{% terminal %}
$ tree app/assets/stylesheets/
app/assets/stylesheets/
├── application.css
├── posts.css.scss
└── scaffolds.css.scss

0 directories, 3 files
{% endterminal %}

So that makes sense, the Asset Pipeline found the posts and scaffolds files and sent them to the browser. Now, how did it do that?

Click over to the "Elements" tab in the inspector, and drive down into the `head` tag.

![Inspector with Head Tags](/images/scribblr/inspector-head.png)

You can see we have three `link` tags that are including those three css files. Open up `app/views/layouts/application.html.erb`.

```html
  <%= stylesheet_link_tag    "application", media: "all", "data-turbolinks-track" => true %>
```

This line asks rails for the stylesheet link tag for `"application"`, which will read `application.css`. At this point, we're seeing a difference between Rails in development mode versus Rails in production mode.

In development mode, this line includes a separate `link` tag for every styleshet. That way, it serves them up in an uncompiled, readable way that makes it way easier to develop and application. Now let's look at how Rails behaves in production mode.

### Production mode

Stop your server, run migrations in production mode, then run the server in production mode:

{% terminal %}
$ RAILS_ENV=production rake db:migrate
==  CreatePosts: migrating ====================================================
-- create_table(:posts)
   -> 0.0015s
==  CreatePosts: migrated (0.0016s) ===========================================
 
$ rails server -e production
=> Booting WEBrick
=> Rails 4.0.0.rc1 application starting in production on http://0.0.0.0:3000
=> Run `rails server -h` for more startup options
=> Ctrl-C to shutdown server
[2013-06-01 14:44:58] INFO  WEBrick 1.3.1
[2013-06-01 14:44:58] INFO  ruby 2.0.0 (2013-05-14) [x86_64-darwin12.3.0]
[2013-06-01 14:44:58] INFO  WEBrick::HTTPServer#start: pid=52481 port=3000
{% endterminal %}

Now visit [localhost:3000/posts](http://localhost:3000/posts).

Notice that the scaffold styles have not been applied. If you look in the inspector's network tab, you'll see that `application.css` is red. If you click on it and click the Headers tab the status shows 404 Not Found.

This is because in production mode, Rails will not serve your assets. This is because it would be poor performance practice to serve lots of small css files, especially without minifying them first.

There's a Rails task you must run in order to prepare your assets for production mode:

{% terminal %}
$ rake assets:precompile
I, [2013-06-01T14:50:25.145311 #52543]  INFO -- : Writing scribblr/public/assets/application-2afd65459052c45a9e23d317dc22ee64.js
I, [2013-06-01T14:50:25.189536 #52543]  INFO -- : Writing scribblr/public/assets/application-12b3c7dd74d2e9df37e7cbb1efa76a6d.css
{% endterminal %}

That built our `application.css` file, including a hash on the end to help bust browser caches. But if you refresh the page, it's still not serving the file.

This is because in production mode, Rails doesn't serve static files at all. It's best to have a real web server, like Apache or nginx serving static files. However, in our case, let's make Rails do that too.

Edit `config/environments/production.rb` and change this:

```ruby
  config.serve_static_assets = false
```

to

```ruby
  config.serve_static_assets = true
```

You will need to restart your Rails server for it to pick up the change.

Open the inspector's network tab and click on `application.css`. You can see that it contains both the comment from `application.css` as well as the styles from `scaffolds.css`

### Wrap-up

We only talked about CSS, but the same process applies to JavaScript, and we'll explore JavaScript files more in the following sections.

One last command that may come in handy is:

{% terminal %}
$ rake assets:clobber
I, [2013-06-01T15:18:07.209737 #52752]  INFO -- : Removed scribblr/public/assets
rm -rf scribblr/tmp/cache/assets
{% endterminal %}

That clears out any compiled assets. This is not necessary in production or development, but it's nice to know in case you suspect that data is being cached and you're troubleshooting.

Finally: from now on, we're going to go back to running rails server in development mode, so just run the server as `rails server` without the production option.

## 3. Twitter Bootstrap

To quickly improve the look of our application, we're going to bring in Twitter Bootstrap. The `twitter-bootstrap-rails` gem wraps up Twitter Bootstrap in a Rails Engine. That means the gem can provide code at all levels of a Rails application. The `twitter-bootstrap-rails` gem includes:

* CSS Assets
* JavaScript Assets
* Fonts (icons as fonts, actually!)
* Images
* Generators
* Helpers

### Install and Setup

#### Remove Turbolinks

We're going to be doing some JavaScript that will conflict with `turbolinks`. Turbolinks accelerates simple html pages very effectively, but for simplicity's sake we're going to remove it from our application since it doesn't behave well with heavy JavaScript applications.

Edit `Gemfile` and comment out or remove:

```ruby
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
```

Then edit `app/assets/application.js` and remove the turbolinks line there.

#### Install `twitter-bootstrap-rails`

First off, let's add it to our Gemfile. It can go anywhere, but let's put it near the other asset-oriented gems. I'm going to put it under `jquery-rails`:

```ruby
gem 'twitter-bootstrap-rails'
```

Next, we have to bundle the application to bring in the gem:

{% terminal %}
$ bundle
Fetching gem metadata from https://rubygems.org/..........
Fetching gem metadata from https://rubygems.org/..
Resolving dependencies...
... lots of gems ...
Installing twitter-bootstrap-rails (2.2.6)
{% endterminal %}

If you start your server and refresh your browser, you'll note that the application still looks the same. That's because the new assets are available, but they're not being loaded by our application.

`twitter-bootstrap-rails` provides a handy generator for installing:

{% terminal %}
$ rails generate bootstrap:install static
      insert  app/assets/javascripts/application.js
      create  app/assets/javascripts/bootstrap.js.coffee
      create  app/assets/stylesheets/bootstrap_and_overrides.css
      create  config/locales/en.bootstrap.yml
        gsub  app/assets/stylesheets/application.css
        gsub  app/assets/stylesheets/application.css
{% endterminal %}

The main change here is that it added `bootstrap_and_overrides.css` into `app/assets/stylesheets`. Open up that file.

There are two require directives here: one for bootstrap, and the second for font-awesome. The bootstrap one is including all of bootstrap's styles, and the font-awesome one includes the font-awesome icon font, which is a great starter-kit of icons for a web application.

Now if you reload your browser you should see a change. The most noticable for me is that the main heading font is now a very large sans-serif font.

### Scaffolding

`twitter-bootstrap-rails` also provides scaffold styles to replace Rails's default scaffolding, and it has handy generators for those too.

First we'll setup a bootstrap layout:

{% terminal %}
$ rails g bootstrap:layout application fixed
    conflict  app/views/layouts/application.html.erb
Overwrite /Users/nick/workspace/scribblr/app/views/layouts/application.html.erb? (enter "h" for help) [Ynaqdh]
       force  app/views/layouts/application.html.erb
{% endterminal %}

Note that I got a prompt due to conflicts in the file. Since this is a new app we can just say `Y` (or hit enter). In an app with changes to this file, we would want to intelligently merge them ourselves.

Open up `app/views/layouts/application.html.erb`. `twitter-bootstrap-rails` does a ton of smart stuff to setup our application layout:

1. A `meta` tag for the viewport, which will cause phones and tablets to zoom in and use a responsive layout
2. An html5 shim for older browsers
3. Alternative high resolution icons for phones
4. A navigation bar
5. A sidebar
6. Bootstrappified flash messages
7. A footer
8. JavaScript files at the end of the body, so that the page appears quickly while the JavaScript tags load


`twitter-bootstrap-rails` also has a generator to replace the scaffolding styles. Let's replace our `Post` scaffolding styles:

{% terminal %}
$ rails g bootstrap:themed Posts
    conflict  app/views/posts/index.html.erb
Overwrite scribblr/app/views/posts/index.html.erb? (enter "h" for help) [Ynaqdh]
       force  app/views/posts/index.html.erb
    conflict  app/views/posts/new.html.erb
Overwrite scribblr/app/views/posts/new.html.erb? (enter "h" for help) [Ynaqdh]
       force  app/views/posts/new.html.erb
    conflict  app/views/posts/edit.html.erb
Overwrite scribblr/app/views/posts/edit.html.erb? (enter "h" for help) [Ynaqdh]
       force  app/views/posts/edit.html.erb
    conflict  app/views/posts/_form.html.erb
Overwrite scribblr/app/views/posts/_form.html.erb? (enter "h" for help) [Ynaqdh]
       force  app/views/posts/_form.html.erb
    conflict  app/views/posts/show.html.erb
Overwrite scribblr/app/views/posts/show.html.erb? (enter "h" for help) [Ynaqdh]
       force  app/views/posts/show.html.erb
{% endterminal %}

Finally, we want to remove our old scaffold styles that Rails included:

{% terminal %}
$ rm app/assets/stylesheets/scaffolds.css.scss
{% endterminal %}

If you reload the page, you'll notice there are a couple of things we'd like to fix:

1. The top content is being cut off
2. The links in the navbar are examples, and we don't need them
3. The Scribblr link in the navbar doesn't go to the root of the app
4. We don't need a sidebar

#### Top Content Cut Off

The reason it's getting cutoff is because we have a fixed navbar. Fixing an object in css means that it doesn't flow with the rest of the content on the page. Open up `app/views/layouts/application.html.erb` and change:

```html
<div class="navbar navbar-fixed-top">
```

to

```html
<div class="navbar">
```

That should fix our cutoff issue.

#### Navbar Links

Let's remove the links in the navbars, and fix the root link. Change:

```html
<div class="navbar">
  <div class="navbar-inner">
    <div class="container">
      <a class="btn btn-navbar" data-target=".nav-collapse" data-toggle="collapse">
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </a>
      <a class="brand" href="#">Scribblr</a>
      <div class="container nav-collapse">
        <ul class="nav">
          <li><%= link_to "Link1", "/path1"  %></li>
          <li><%= link_to "Link2", "/path2"  %></li>
          <li><%= link_to "Link3", "/path3"  %></li>
        </ul>
      </div><!--/.nav-collapse -->
    </div>
  </div>
</div>
```

to:

```html
<div class="navbar">
  <div class="navbar-inner">
    <div class="container">
      <%= link_to "Scribblr", "/", class: "brand" %>
    </div>
  </div>
</div>
```

If you click on "Scribblr" you'll notice that it goes to the rails welcome page and the styles are all messed up. Let's fix that by giving our application a root route.

Edit `config/routes.rb` and right before `resources :posts` add:

```ruby
root to: "posts#index"
```

Now edit `app/views/layouts/application.html.erb` and change the Scribblr link to:

```html
<%= link_to "Scribblr", root_path, class: "brand" %>
```

#### No Sidebar Needed

We can remove the sidebar, which means we also don't need the spans that setup a 3/4 + 1/4 grid. Change:

```html
<div class="container">
  <div class="row">
    <div class="span9">
      <%= bootstrap_flash %>
      <%= yield %>
    </div>
    <div class="span3">
      <div class="well sidebar-nav">
        <h3>Sidebar</h3>
        <ul class="nav nav-list">
          <li class="nav-header">Sidebar</li>
          <li><%= link_to "Link1", "/path1"  %></li>
          <li><%= link_to "Link2", "/path2"  %></li>
          <li><%= link_to "Link3", "/path3"  %></li>
        </ul>
      </div><!--/.well -->
    </div><!--/span-->
  </div><!--/row-->

  <footer>
    <p>&copy; Company 2013</p>
  </footer>

</div> <!-- /container -->
```

to

```html
<div class="container">
  <%= bootstrap_flash %>
  <%= yield %>

  <footer>
    <p>&copy; Company 2013</p>
  </footer>

</div> <!-- /container -->
```

### Add Some Posts

Much better, but let's add some content. Add a couple of posts so we have something to look at.

## 3-X. Incorporate autosaving widget

* mostly use Jim's tutorial
* extract some functions so they can be tested later

## 4. Konacha

* add gem
* bring in assets
* setup an "assert true" test to ensure it's working
* browser run mode for debugging? Console?

## 5. Unit test the autosaver

* test the extracted functions
* extract autotest into OO, guided by our tests, TDD style

## 6. Acceptance (Integration) testing

* setup capybara
* create plain integration test (visit root, see Posts)
* write an editing test

## 7. Formatting

* Write acceptance test for formatting, a few simple markdown checks
* Add markdown server-side
* Write acceptance test for live preview
* Drop to unit test for a preview function
* write glue jquery for preview
