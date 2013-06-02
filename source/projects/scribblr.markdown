---
layout: page
title: "Scribblr: A JavaScript Blogging App"
alias: [ /scribblr, /scribblr.html ]
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

Edit `Gemfile` and **comment out or remove**:

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

One last change before we proceed: we need some posts! When you go to create a post, you'll notice that by default Rails's scaffold has used a text field for both inputs. In our case, the `body` could quite long, so let's change that to a `textarea`.

Edit `app/views/posts/_form.html.erb` and change:

```html
<%= f.text_field :body, :class => 'text_field' %>
```

to

```html
<%= f.text_area :body, :class => 'input-xxlarge', :rows => 8 %>
```

Also let's make the title field more spacious too. Change:

```html
<%= f.text_field :title, :class => 'text_area' %>
```

to

```html
<%= f.text_field :title, :class => 'input-xxlarge' %>
```

Much better, now let's add some content. Add a couple of posts so we have something to look at.

Now that we have our basic application up and running, it's time to get into some JavaScript.

## 4. Autosaving Posts

It's time to implement our first JavaScript feature: autosaving posts. In this tutorial, we'll write a set of JavaScript functions that will automatically save a post while it is being edited.

We're going to build this project using two best practices: *Progressive Enhancement* and *Unobtrusive JavaScript*. Progressive enhancement involves layering our JavaScript functionality on top of a traditional form, so that even if JavaScript is not available (or not functioning properly) the form will still work in the usual way of POSTing to the server. Unobtrusive JavaScript means that we will barely change the form itself, and the JavaScript we write will not be directly tied to the form, but instead be setup in a component-oriented way.

Also, we should note that for simplicity's sake we'll only be enhancing the `edit` page, not the `new` page. This is just because it will be easier for us to update an existing post, instead of storing a new post in a new `drafts` table.

### HTML5 Enhancements

Before we even touch JavaScript, there are a number of things we can add to the edit form for the benefit of newer browsers. For instance, the [placeholder](http://diveintohtml5.info/forms.html#placeholder) attribute on the title field. The `placeholder` attribute only works on `<input>` elements, not `<textarea>`, so we can't use it for the body.

```html
<%= f.text_field :title, :class => 'input-xxlarge', :placeholder => "Post Title" %>
```

IE10, Firefox 4+, Safari 4+, Chrome 4+ and other modern browsers will automagically put dimmed text into the form field if it's empty, and the text will disappear when you focus (click or tab) on the field. Older browsers ignore the attribute, which is no big whoop. 

This is what progressive enhancement is all about. The regular `<input>` field works great as is; the `placeholder` attribute enhances the experience for modern browsers.

(By the way, if you or your client really needed `placeholder` to work everywhere and not just modern browsers, a growing class of JavaScript shims, like [these](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills#web-forms--input-placeholder), have developed to fill that need.

Here's another enhancement: if we'd like to automatically place focus on the first form field, so the user can begin typing without needing to click into the field, the HTML5 attribute `autofocus` is ready to help: 

```html
<%= f.text_field :title,
      :class => 'input-xxlarge',
      :placeholder => "Post Title",
      :autofocus => true %>
```

Modern browsers (IE10, Firefox 4+, Safari 4+, Chrome 3+) will give that field focus when the page loads. 

The `autofocus` behavior has traditionally been achieved with JavaScript, but using HTML5 attributes instead of JS puts the onus on the browser to give the field focus. The browser can do it faster than JavaScript can. 

Like before, older browsers ignore the attribute; and if you need to support the behavior in all browsers, you'll need a JavaScript fallback [like this one](http://diveintohtml5.info/forms.html#autofocus). 

There are lots of [HTML5 form goodies](http://diveintohtml5.info/forms.html) to explore, and all of them can be used to "progressively enhance" the user's experience. But, we're here for auto-saving, so let's get to it.

### Hijacking the submit action and replacing it with AJAX

The next step will be to hijack the form submission process so we can use AJAX to submit the form instead of a traditional page-refreshing POST request. We'll use jQuery for cross-browser compatibility, and luckily jQuery is part of the default Rails 4 stack (it's already in our application.js).

Check out `app/assets/application.js`:

```js
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .
```

Just like in our `application.css` we have a bunch of Asset Pipeline directives. jQuery, jQuery UJS, and Twitter Bootstrap are all provided by Rails Engines coming from gems. Then we have `require_tree .` which loads any JavaScript files we create.

<div class='note'><p>jQuery UJS is actually maintained by the Rails project. It's a set of jQuery plugins that Rails has helpers for. The UJS stands for "Unobtrusive JavaScript". We'll check it out more later.</p></div>

Now it's time to start writing our own JavaScript. Create a new file named `app/assets/javascripts/autosave.js` and open it in your editor.

To make sure your file is in the right place and the asset pipeline is working, let's just output some tracing info:

```js
console.debug("autosave.js has been loaded!");
```

Open the Console tab in your inspector, and refresh the page. You should see your console log message.

OK, now what we want to do is capture the submit event on our form. jQuery makes this really easy:

```js
$(function() {
  $("form").on("submit", function(event) {
    console.debug("form is being submitted!")
  });
});
```

When our user presses the "save" button and the form is submitted, but before the data actually gets transmitted to a server, the `submit` event fires and this code catches it. However, the form still continues on to submit to the server, and we want to stop that. The event object `event` is passed into our function by jQuery, and we can disable the data transmission to the server with the `preventDefault` method of the event object.

```js
$("form").on("submit", function(event) {
  event.preventDefault();
  console.debug("form is being submitted!")
});
```

The user can click "save" until the cows come home. Nothing will happen. (Verify it yourself.)

Next, let's fire off an AJAX request to the server with the contents of the form, exactly as if the browser was doing a normal form submission. We'll send all the same data, it's just that we're sending it via AJAX instead of the traditional route.

We'll use jQuery's [$.ajax](http://api.jquery.com/jQuery.ajax/) and the following parameters:

* `url`: the address to send the data to (the same as the `action` attribute in `<form>`)
* `type`: GET or POST (in our case, POST)
* `data`: the information we want to send (the content of our `input` and `textarea` fields). jQuery has a wonderful helper function, [.serialize()](http://api.jquery.com/serialize/), which can take a `<form>` element and convert it into a URL-encoded string that's exactly what the server is expecting.
* `dataType`: the kind of data we'd like back from the server. By asking for json, we're instructing the server to give us json back (as opposed to an HTML page or XML)

```js
$("form").on("submit", function(event) {
  event.preventDefault();
  $.ajax({
    url: $(this).attr("action"),
    type: "POST",
    data: $(this).serialize(),
    dataType: "json"
  });
});
```

The form will now submit the form via an AJAX request instead of a traditional, page-refreshing request. The server is none the wiser, because it just looks like a regular old POST request. Test it yourself; data should be passing normally.

But what about the human clicking "save"? There's nothing telling them that the data has been sent properly, which is bad user experience. Luckily the `$.ajax` method returns a `$.Deferred` object, which allows us to easily attach some asynchronous behavior. In a synchronous language, we could just wait for the return value of `$.ajax`, but since this is asynchronous, the request is processed in the background. The deferred object lets us attach functionality to be executed later when the request is done.

```js
$(function() {
  $("form").on("submit", function(event) {
    event.preventDefault();
    $.ajax({
      url: $(this).attr("action"),
      type: "POST",
      data: $(this).serialize(),
      dataType: "json"
    }).done(function(response) {
      console.debug("Form submission succeeded! The server said:", response);
    }).fail(function(response, status, errorcode) {
      console.debug("Form submission failed! The server said:", status, errorcode)
    });
  });
});
```

Try it now and watch the console. Since regular users won't be looking at the console, let's abstract out a simple function that displays a status message to the user, then fades out and quietly removes itself after a bit. 

```js
function notify(message, level) {
  if (level === undefined) level = "info";
  // display a notification under the page header
  $('<div class="alert alert-' + level + '">' + message + '</div>').
    appendTo('.page-header').
    delay(3000).
    fadeOut(500, function() {
      $(this).remove()
    });
}
```

In the inspector console, try out the function by typing:

```js
notify("Hi mom, I'm from the console!");
```

Now hook this up to the status and error functions:

```js
$("form").on("submit", function(event) {
  event.preventDefault();
  $.ajax({
    url: $(this).attr("action"),
    type: "POST",
    data: $(this).serialize(),
    dataType: "json"
  }).done(function(data, status, response) {
    notify("Post saved.", "success");
  }).fail(function(data, status, response) {
    notify("Post failed to save.", "error");
  });
});
```

### Unobtrusive

Right now our plugin is actually very unobtrusive. We didn't have to change the form itself to enhance it into a JavaScript version, and we don't have to include some special JavaScript lines on every page with a form to hook it all up.

The problem is, our code will try to attach itself to *any* form on *any* page. To remedy that, we are going to make a minor change to the form: mark it as an autosave form, and we're going to modify our plugin: make it only attach to autosave forms.

First, let's change our plugin:

```js
var $form = $("form[data-autosave]");
$form.on("submit", function(event) {
  event.preventDefault();
  $.ajax({
    url: $form.attr("action"),
    type: "POST",
    data: $form.serialize(),
    dataType: "json"
  }).done(function(data, status, response) {
    notify("Post saved.", "success");
  }).fail(function(data, status, response) {
    notify("Post failed to save.", "error");
  });
});
```

This uses an HTML5 Data Attribute, which can be anything we want them to be, and the browser will let us store data there. In our case, we're saying that a `form` must have a `data-autosave` attribute. So `<form>` would not match the selector, but `<form data-autosave>` would match the selector.

Also, we're storing the form as `$form` so that we don't have to repeat ourselves with our unobtrusive selector all over the place. It's common practice to name a variable with a `$` at the start when it's a jQuery object. *By the way:* this function will fail spectacularly if you don't pass it a valid form or you pass it multiple forms. If you'd like to try something more advanced, change the line `var $form = $(form);` to only grab the first form that's passed, or to bail out if there's no form at all.

If you try the form now, it will go back to a normal save, because we haven't updated the form yet. Let's do that now:

```html
<%= form_for @post, :html => { :class => 'form-horizontal', "data-autosave" => true } do |f| %>
```

There we go. Now any form we mark with `data-autosave` will get our plugin, while normal forms won't.


### Automatically saving when fields change

Instead of only saving when the user presses the "save" button, we want to save when the user has changed the content of any of our fields. We can do this several ways:

* Attach event listeners to the `<input>` and `<textarea>` elements that only fire when the content changes
* Use an interval timer to check the entire form every few seconds to see if something's changed

Both approaches have pros and cons. Using an interval timer is simpler JavaScript, but it means that the browser is constantly working (every few seconds, or whatever interval we set) to see if the form fields have changed. It's not a *lot* of work, but it's something, and especially on low-power mobile devices it's nice to do as little work as possible.

However, attaching event listeners is complicated. The `onchange` event is very [widely supported](http://www.quirksmode.org/dom/events/index.html), but only fires when the user has clicked or tabbed *out* of a field. Spending a few hours typing in one `<textarea>`, without clicking or tabbing elsewhere, will yield exactly zero `onchange` events.

We could look for the `keypress` event, which can be bound to the form, and that's a fine answer. Every time a key is pressed, it fires. Hooray! We'd also need to throttle or [debounce](http://unscriptable.com/2009/03/20/debouncing-javascript-methods/) the user input. We wouldn't want an AJAX request sent *every single time* the user types a key. We'd want it sent every few seconds (or longer).

But if we entered content without using the keyboard (say, right-clicking and pasting, or through speech recognition), the `keypress` event won't fire. There's also a newer HTML5 `input` event, which fires when content changes no matter the source, but it's a bit buggy and unsupported on [older browsers.](http://whattheheadsaid.com/2010/09/effectively-detecting-user-input-in-javascript) 

In this tutorial, we'll go with `setInterval`, because it's more straightforward to implement. We'll poll the page every 10 seconds to see if something has changed, and if it has, we'll save the form. The "save" button will also work normally.

First, we need to abstract our "saving" code into its own function, so it's not just called when the form is manually submitted. We're going to take a single parameter, and that's the `<form>`, either as a jQuery object (e.g., `$('form')`) or as a CSS selector (e.g., `'form#myform'`).

```js
$form.on("submit", function(event) {
  event.preventDefault();
  saveForm();

  function saveForm() {
    $.ajax({
      url: $form.attr("action"),
      type: "POST",
      data: $form.serialize(),
      dataType: "json"
    }).done(function(data, status, response) {
      notify("Post saved.", "success");
    }).fail(function(data, status, response) {
      notify("Post failed to save.", "error");
    });
  }
});
```

With the "saving" function in place, let's create a function that will check the form and save it if it's changed. We could loop through each of the <input> fields, but we'd need to make sure we got any `<textarea>` elements (or `<select>` elements, etc.). Instead, let's use that good old `.serialize()` function that converts all of the form fields into a string for us. Then it's a simple string comparison.

```js
function saveFormIfChanged() {
  var currentForm = $form.serialize();

  if (currentForm !== savedForm) {
    saveForm();
    savedForm = currentForm;
    return true;
  } else {
    return false;
  }
}
```

See what's happening here? The contents of the form are being converted into a string with `.serialize()` and we're testing whether it's equivalent to `savedForm`, which is the earlier version of the form fields we already saved. Wait, what earlier version? Oh, right! We need to make an earlier version when the page loads! So we'll need to add in our `onready` block:

```js
var savedForm = $form.serialize();
```

(Again, this will fail miserably if there's more than one form on the page! We're staying simple for now.) 

<div class="note"><p>JavaScript allows you to share variables inside the same scope. That means that since we defined our `savedForm` variable inside the same scope (the `onready`) as our helper functions, they can access it. The `onready` has created a "Closure" around this code, providing a scope to share. This is what happens with any function in JavaScript. The same thing is happening with `$form`. It's effectively a global variable, but only within our local scope. Cool!</p></div>

Finally, we'll set up the interval timer to check every 10 seconds. `Window.setInterval` is set in milliseconds, so 10 seconds * 1000 milliseconds = 10,000 milliseconds.

```js
var autosaveInterval = window.setInterval(saveFormIfChanged, 10000);
```

Try it out! Watch the console (or the message) and make sure the form is automatically saving every ten seconds if something has changed.

With our working auto-saver in place, we could remove the "save" button entirely, since we no longer technically need it. In the real world, this might be bad UX, as users may expect a "save" button and become disoriented when they can't find it. Instead of doing that, let's restore the button to its original state, and let the form submit normally when the user clicks "save." We do this by removing the ` $form.on('submit')` block.

Now the form saves automatically, but when the user clicks "save," it's saved one more time, the normal POST way, and the user is taken to the target page.

So, with that change, here's our entire block of code as it stands:

```js
$(function() {
  var $form = $("form[data-autosave]");
  var savedForm = $form.serialize();
  var autosaveInterval = window.setInterval(saveFormIfChanged, 10000);

  function notify(message, level) {
    if (level === undefined) level = "info";
    // display a notification under the page header
    $('<div class="alert alert-' + level + '">' + message + '</div>').
      appendTo('.page-header').
      delay(3000).
      fadeOut(500, function() {
        $(this).remove()
      });
  }

  function saveForm() {
    $.ajax({
      url: $form.attr("action"),
      type: "POST",
      data: $form.serialize(),
      dataType: "json"
    }).done(function(data, status, response) {
      notify("Post saved.", "success");
    }).fail(function(data, status, response) {
      notify("Post failed to save.", "error");
    });
  }

  function saveFormIfChanged() {
    var currentForm = $form.serialize();

    if (currentForm !== savedForm) {
      saveForm();
      savedForm = currentForm;
      return true;
    } else {
      return false;
    }
  }
});
```

### Solving problems and handling errors

This implementation is pretty fragile, though, and we need to toughen it up to solve a couple of problem scenarios.

#### Problem Scenario: The user navigates away without saving

If the user clicks the back button, or otherwise goes away without hitting "save," their changes will be lost. The JavaScript `unload` event handler is useful to us here. (Alternatively, we could use the `beforeunload` event, which lets us throw up an "Are you sure you want to navigate away from this page?" alert box, giving the user the opportunity to cancel. But for now we'll just use `unload`.) The `unload` event fires on the window when the user is attempting to navigate away. When that happens, we'll go ahead and save the form right then. 

```js
$(window).on('unload', saveFormIfChanged);
```

There are two problems with this. The first problem is that the AJAX request is firing asynchronously, which means the browser won't stick around to wait for an answer. That's no good. Thankfully, changing the AJAX request to be synchronous (the opposite) is as easy as setting `async` to false in our `$.ajax` request. Rather than writing the `$.ajax` request all over again, let's reuse the `saveFormIfChanged` function but add a hook so we can specify if the request should be asynchronous or not.

```js
function saveFormIfChanged(async) {
  var currentForm = $form.serialize();

  if (currentForm !== savedForm) {
    saveForm(async);
    savedForm = currentForm;
    return true;
  } else {
    return false;
  }
}

function saveForm(async) {
  if (async === undefined) async = true;

  $.ajax({
    url: $form.attr("action"),
    type: "POST",
    data: $form.serialize(),
    dataType: "json",
    async: async
  }).done(function(data, status, response) {
    notify("Post saved.", "success");
  }).fail(function(data, status, response) {
    notify("Post failed to save.", "error");
  });
}
```

Our `window.unload` event listener can now pass a flag to say that the request should be synchronous (setting `async` to `false` instead of the default `true`).

```js
$(window).on("unload", function() {
  saveFormIfChanged(false);
});
```

Delightful! First problem solved. Our second problem is when the user legitimately hits the "submit" button. The `unload` event is still fired, which means we're saving the form twice — once through the AJAX call, and once through the normal POST. That's wasteful. There are a couple of ways around this. Here's one:

```js
$form.on("submit", function() {
  savedForm = $(this).serialize();
});
```

This puts the current state of the form into the global `savedForm` variable. The `unload` event will still fire, but `isFormChanged()` will return `false` because the form contents will be identical to what's on the page. (Or, another way to solve the problem would be to remove the `unload` event listener entirely when the form is submitted.)

#### Problem Scenario: The AJAX request fails or stops working

If our AJAX request comes back with an error — let's say a cross-site scripting error, or a strange server bug, or a timeout because the user is temporarily offline, we need to handle that error with grace. Right now we're outputting the error message "Post failed to save" to the user, which isn't very helpful and sounds a little scary. (It failed? What do I do now?)

Instead, let's have an AJAX failure happen quietly, but if it happens, let's *remove the auto-saving feature from the page entirely,* reverting to the standard form submission. That way if there's an error, our JavaScript will get the heck out of there and let the browser do things normally rather than breaking the experience entirely.

So, let's create a function that does that cleanup work in the event of an error:

```js
function formError() {
  clearInterval(autosaveInterval);
  $(window).off("unload");
  $form.off("submit");
}
```

And let's fire that function if there's an error in `saveForm`:

```js
function saveForm(async) {
  if (async === undefined) async = true;

  $.ajax({
    url: $form.attr("action"),
    type: "POST",
    data: $form.serialize(),
    dataType: "json",
    async: async
  }).done(function(data, status, response) {
    notify("Post saved.", "success");
  }).fail(formError);
}
```

We've added some significant flexibility and robustness to this script! 

### Next steps

* Remove the form from the page. What happens? What happens if there are two forms on the page?
* Instead of a notification above the form button, change the text of the button itself to temporarily say "Saved!" instead of "Save" every time there's an automatic save. Check out [Twitter Bootstrap's JavaScript Button Plugin](http://twitter.github.io/bootstrap/javascript.html#buttons).
* Add a "loading" or "progress" graphic when the ajax request is fired and remove it when the request is answered. (Use the `beforeSend` and `complete` [callbacks](http://api.jquery.com/jQuery.ajax/#callback-functions), and an [animated GIF graphic](http://www.ajaxload.info/) or [Twitter Bootstrap's Animated Progress Bar](http://twitter.github.io/bootstrap/components.html#progress).)

### Ready for even more?

* Use the `keypress` (or `keyup` or `keydown` event) along with `paste` to trigger saves only when the user is typing in fields
* Add a "cancel" button that reverts the saved data to the its original state (this can be done solely in JavaScript, btw)
* Recode our code as an object, so that functions, variables, and event listeners have their own namespaces and won't collide with other JavaScript that might be running on the page
* Also save the latest version in the browser's LocalStorage, so the data will survive browser crashes ([Hint 1](https://github.com/simsalabim/sisyphus) [Hint 2](http://www.codediesel.com/javascript/auto-save-your-web-form-data/))
* Extract our implementation into a [jQuery plugin](http://learn.jquery.com/plugins/basic-plugin-creation/)

## 5. Konacha

* add gem
* bring in assets
* setup an "assert true" test to ensure it's working
* browser run mode for debugging? Console?

## 6. Unit test the autosaver

* test the extracted functions
* extract autotest into OO, guided by our tests, TDD style

## 7. Acceptance (Integration) testing

* setup capybara
* create plain integration test (visit root, see Posts)
* write an editing test

## 8. Formatting

* Write acceptance test for formatting, a few simple markdown checks
* Add markdown server-side
* Write acceptance test for live preview
* Drop to unit test for a preview function
* write glue jquery for preview
