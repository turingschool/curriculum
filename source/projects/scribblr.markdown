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

### Chrome

We will be using the Chrome developer tools. [Download and install Chrome](https://www.google.com/intl/en/chrome/browser/) if you don't already have it installed. The developer tools are included by default, so you don't need to install any add-ons or plugins.

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

Wow, a lot just happened there! Let's walk through it:

1. `active_record`: this is our database migration, model, and unit tests
2. `resource_route`: this sets up `/posts` routes
3. `jbuilder_scaffold_controller`: this builds the controller, html views, controller test, helper, and jbuilder views (for JSON output)
4. `assets`: coffeescript and scss files for posts
5. `scss`: because this is our first scaffold, it brings in the default scaffold style

### Migrate

We need to run the pending database migrations so that we have the appropriate tables and columns in our application.

{% terminal %}
 rake db:migrate
==  CreatePosts: migrating ====================================================
-- create_table(:posts)
   -> 0.0013s
==  CreatePosts: migrated (0.0014s) ===========================================
{% endterminal %}

Run the server (`rails server`) and visit [localhost:3000/posts](localhost:3000/posts). You should see an empty list of posts.

## 2. Asset Pipeline

Now that we have an application to explore, let's talk about the Rails asset pipeline. When we built our scaffold it included a separate scaffolds file in `app/assets/stylesheets/scaffolds.css.scss`. Let's look at how that scaffold file gets included into our page.

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

Stop your server and run migrations in production mode.


{% terminal %}
$ RAILS_ENV=production rake db:migrate
==  CreatePosts: migrating ====================================================
-- create_table(:posts)
   -> 0.0015s
==  CreatePosts: migrated (0.0016s) ===========================================
{% endterminal %}

Run the server in production mode:

{% terminal %}
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

Notice that the scaffold styles have not been applied. If you look in the inspector's Network tab, you'll see that `application.css` is red. If you click on it and click the Headers tab the status shows 404 Not Found.

This is because in production mode, Rails will not serve your assets. It would be poor performance practice to serve lots of small css files, especially without minifying them first.

There's a Rails task you must run in order to prepare your assets for production mode:

{% terminal %}
$ rake assets:precompile
I, [2013-06-01T14:50:25.145311 #52543]  INFO -- : Writing scribblr/public/assets/application-2afd65459052c45a9e23d317dc22ee64.js
I, [2013-06-01T14:50:25.189536 #52543]  INFO -- : Writing scribblr/public/assets/application-12b3c7dd74d2e9df37e7cbb1efa76a6d.css
{% endterminal %}

That built our `application.css` file, creating a file named `application-12b3c7dd74d2e9df37e7cbb1efa76a6d.css`. The hash included on the end will be different if the stylesheets change and we recompile the assets. This helps bust browser caches.

If you refresh the page, it's still not serving the file.

In production mode, Rails doesn't serve static files at all. It's best to have a real web server, like Apache or nginx serving static files. However, in our case, let's make Rails do that too.

Edit `config/environments/production.rb` and change this:

```ruby
# Disable Rails's static asset server (Apache or nginx will already do this).
config.serve_static_assets = false
```

to

```ruby
# Enable Rails's static asset server (Apache or nginx will already do this).
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

### Switch back to development mode

From now on, we're going to go back to running rails server in development mode so that we can see changes without restarting the server. Go ahead and run the server as `rails server` without the production option.

## 3. Twitter Bootstrap

To quickly improve the look of our application, we're going to bring in Twitter Bootstrap. The `twitter-bootstrap-rails` gem wraps up Twitter Bootstrap in a Rails Engine. That means the gem can provide code at all levels of a Rails application. The `twitter-bootstrap-rails` gem includes:

* CSS Assets
* JavaScript Assets
* Icons (in the form of icon fonts)
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

Then edit `app/assets/javascripts/application.js` and remove the turbolinks line there.

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

If you restart your server and refresh your browser, you'll note that the application still looks the same. The new assets are available, but they're not being loaded by our application.

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

Now if you restart your server and reload your browser you should see a change. The most noticeable for me is that the main heading font is now a very large sans-serif font.

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

If you click on "Scribblr" you'll notice that it goes to the rails welcome page. Let's fix that by giving our application a root route.

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
<%= f.text_field :title, :class => 'text_field' %>
```

to

```html
<%= f.text_field :title, :class => 'input-xxlarge' %>
```

Much better. Now let's add some content. Add a couple of posts so we have something to look at.

Now that we have our basic application up and running, it's time to get into some JavaScript.

## 4. Autosaving Posts

It's time to implement our first JavaScript feature: autosaving posts. In this tutorial, we'll write a set of JavaScript functions that will automatically save a post while it is being edited.

We're going to build this project using two best practices: *Progressive Enhancement* and *Unobtrusive JavaScript*. Progressive enhancement involves layering our JavaScript functionality on top of a traditional form, so that even if JavaScript is not available (or not functioning properly) the form will still work in the usual way of POSTing to the server. Unobtrusive JavaScript means that we will barely change the form itself, and the JavaScript we write will not be directly tied to the form, but instead be setup in a component-oriented way.

Also, we should note that for simplicity's sake we'll only be enhancing the `edit` page, not the `new` page. This is just because it will be easier for us to update an existing post, instead of storing a new post in a new `drafts` table.

### HTML5 Enhancements

#### The Placeholder Attribute

Before we even touch JavaScript, there are a number of things we can add to the edit form for the benefit of newer browsers. For instance, the [placeholder](http://diveintohtml5.info/forms.html#placeholder) attribute on the title field. The `placeholder` attribute only works on `<input>` elements, not `<textarea>`, so we can't use it for the body.

```html
<%= f.text_field :title, :class => 'input-xxlarge', :placeholder => "Post Title" %>
```

IE10, Firefox 4+, Safari 4+, Chrome 4+ and other modern browsers will automagically put dimmed text into the form field if it's empty, and the text will disappear when you focus (click or tab) on the field. Older browsers ignore the attribute, which is no big whoop.

This is what progressive enhancement is all about. The regular `<input>` field works great as is; the `placeholder` attribute enhances the experience for modern browsers.

<div class='note'>
  <p>If you or your client really needed `placeholder` to work everywhere and not just modern browsers, a growing class of JavaScript shims, like <a href="https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills#web-forms--input-placeholder">these</a>, have developed to fill that need.</p>
</div>

#### Autofocus

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

The next step will be to hijack the form submission process so we can use AJAX to submit the form instead of a traditional page-refreshing POST request. We'll use jQuery for cross-browser compatibility, and luckily jQuery is part of the default Rails 4 stack (it's already in our `application.js`).

Check out `app/assets/javascripts/application.js`:

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

OK, now what we want to do is capture the submit event on our form. jQuery makes this really easy. Replace the `console.debug` line with the following code.

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

The user can click "save" until the cows come home, nothing will happen. Verify it yourself.

Next, let's fire off an AJAX request to the server with the contents of the form, exactly as if the browser was doing a normal form submission. We'll send all the same data, it's just that we're sending it via AJAX instead of the traditional route.

We'll use jQuery's [$.ajax](http://api.jquery.com/jQuery.ajax/) and the following parameters:

* `url`: the address to send the data to (the same as the `action` attribute in `<form>`)
* `type`: GET or POST (in our case, POST)
* `data`: the information we want to send (the content of our `input` and `textarea` fields). jQuery has a wonderful helper function, [.serialize()](http://api.jquery.com/serialize/), which can take a `<form>` element and convert it into a URL-encoded string that's exactly what the server is expecting.
* `dataType`: the kind of data we'd like back from the server. By asking for JSON, we're instructing the server to give us JSON back (as opposed to an HTML page or XML)

Replace the `console.debug` line of code with an `$.ajax` call:

```js
$("form").on("submit", function(event) {
  event.preventDefault();
  $.ajax({
    // parameters go here
  });
});
```

Fill in the parameters:

```js
$.ajax({
  url: $(this).attr("action"),
  type: "POST",
  data: $(this).serialize(),
  dataType: "json"
});
```

The form will now submit the form via an AJAX request instead of a traditional, page-refreshing request. The server is none the wiser, because it just looks like a regular old POST request. Test it yourself by creating a new post and clicking submit.

If you go back to the posts index page, the new post will be there.

But what about the human clicking "save"? There's nothing telling them that the data has been sent properly, which is bad user experience. Luckily the `$.ajax` method returns a `$.Deferred` object, which allows us to easily attach some asynchronous behavior. In a synchronous language, we could just wait for the return value of `$.ajax`, but since this is asynchronous, the request is processed in the background. The deferred object lets us attach functionality to be executed later when the request is done.

This can be attached by chaining calls onto the end of the `$.ajax` method call, changing it from this:

```js
$.ajax({
  // parameters here
});
```

to this:

```js
$.ajax({
  // parameters here
}).done(function(response) {
  console.debug("Form submission succeeded! The server said:", response);
}).fail(function(response, status, errorcode) {
  console.debug("Form submission failed! The server said:", status, errorcode)
});
```

Try it now and watch the console. Since regular users won't be looking at the console, let's create a simple function that displays a status message to the user, then fades out and quietly removes itself after a bit.

```js
$(function() {
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

  $("form").on("submit", function(event) {
    // lots of code
  });
});
```

Now hook this up to the status and error functions, replacing the `console.debug` calls:

```js
$.ajax({
  // parameters here
}).done(function(data, status, response) {
  notify("Post saved.", "success");
}).fail(function(data, status, response) {
  notify("Post failed to save.", "error");
});
```

### Unobtrusive

Right now our plugin is actually very unobtrusive. We didn't have to change the form itself to enhance it into a JavaScript version, and we don't have to include some special JavaScript lines on every page with a form to hook it all up.

The problem is, our code will try to attach itself to *any* form on *any* page. To remedy that, we are going to make a minor change to the form: mark it as an autosave form, and we're going to modify our plugin: make it only attach to autosave forms.

### Autosave Plugin

Let's change our plugin.

First, store `$("form")` in a variable named `$form` so that we don't have to repeat ourselves with our unobtrusive selector all over the place.

It's common practice to name a variable with a `$` at the start when it's a jQuery object.

The code changes from this:

```js
$("form").on("submit", function(event) {
  // lots of code
});
```

to this:

```js
var $form = $("form")
$form.on("submit", function(event) {
  // lots of code
});
```

Next we'll use an HTML5 Data Attribute, which can be anything we want them to be, and the browser will let us store data there. In our case, we're saying that a `form` must have a `data-autosave` attribute. So `<form>` would not match the selector, but `<form data-autosave>` would match the selector.

Update the code from this:

```js
var $form = $("form")
```

to this:

```js
var $form = $("form[data-autosave]");
```

*By the way:* this function will fail spectacularly if you don't pass it a valid form or you pass it multiple forms. If you'd like to try something more advanced, change the line `var $form = $(form);` to only grab the first form that's passed, or to bail out if there's no form at all.

### Autosave Form

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

### Abstracting the Save Functionality

First, we need to abstract our "saving" code into its own function, so it's not just called when the form is manually submitted.

Find the `$.ajax` call:

```js
$.ajax({
  // lots of code
});
```

Copy it into a new function called saveForm():

```js
function saveForm() {
  $.ajax({
    // lots of code
  });
}
```

The file now looks like this:

```js

$(function() {
  function notify(message, level) {
    // ...
  }

  function saveForm() {
    // ...
  }

  var $form = $("form[data-autosave]");
  $form.on("submit", function(event) {
    // ...
  });
});
```

In `saveForm()` there are references to `$(this)` which won't be pointing to the right thing anymore. Replace `$(this)` with `$form`:

```js
function saveForm($form) {
  $.ajax({
    url: $form.attr("action"),
    // ...
    data: $form.serialize(),
    // ...
  }
```

Finally, we need to call the `saveForm()` inside the submit handler for our form:

```js
$form.on("submit", function(event) {
  event.preventDefault();
  saveForm();
});
```

The `autosave.js` should now be structured like this:

```js
$(function() {

  function notify(message, level) { /* ... */ }
  function saveForm(form) { /* ... */ }

  var $form = $("form[data-autosave]");
  $form.on("submit", function(event) {
    // ...
  });
});
```

### Polling for Changes

With the "saving" function in place, let's create a function that will check the form and save it if it's changed. We could loop through each of the `<input>` fields, but we'd need to make sure we got any `<textarea>` elements (or `<select>` elements, etc.). Instead, let's use that good old `.serialize()` function that converts all of the form fields into a string for us. Then it's a simple string comparison.

```js
$(function() {
  function notify() { /* ... */ }
  function saveForm() { /* ... */ }
  function saveFormIfChanged() { /* ... */ }

  var $form = $("form[data-autosave]");
  $form.on("submit", function(event) {
    event.preventDefault();
    saveForm();
  });
});
```

The implementation of `saveFormIfChanged()` is as follows:

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
var $form = $("form[data-autosave]");
var savedForm = $form.serialize();
```

Again, this will fail miserably if there's more than one form on the page! We're staying simple for now.

<div class="note"><p>JavaScript allows you to share variables inside the same scope. That means that since we defined our `savedForm` variable inside the same scope (the `onready`) as our helper functions, they can access it. The `onready` has created a "Closure" around this code, providing a scope to share. This is what happens with any function in JavaScript. The same thing is happening with `$form`. It's effectively a global variable, but only within our local scope. Cool!</p></div>

Finally, we'll set up the interval timer to check every 10 seconds. `Window.setInterval` is set in milliseconds, so 10 seconds * 1000 milliseconds = 10,000 milliseconds.

```js
var $form = $("form[data-autosave]");
var savedForm = $form.serialize();
var autosaveInterval = window.setInterval(saveFormIfChanged, 10000);
```

Try it out! Watch the console (or the message) and make sure the form is automatically saving every ten seconds if something has changed.

With our working auto-saver in place, we could remove the "save" button entirely, since we no longer technically need it. In the real world, this might be bad UX, as users may expect a "save" button and become disoriented when they can't find it. Instead of doing that, let's restore the button to its original state, and let the form submit normally when the user clicks "save." We do this by removing the ` $form.on('submit')` block.

Now the form saves automatically, but when the user clicks "save," it's saved one more time, the normal POST way, and the user is taken to the target page.

### Refactor

Let's move all the variable assignments to the top of the `onready` block.  With that change, here's our entire block of code as it stands:

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

This puts the current state of the form into the global `savedForm` variable. The `unload` event will still fire, but `isFormChanged()` will return `false` because the form contents will be identical to what's on the page.

Another way to solve the problem would be to remove the `unload` event listener entirely when the form is submitted.

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
* Also save the latest version in the browser's LocalStorage, so the data will survive browser crashes ([Hint 1](https://github.com/simsalabim/sisyphus) [Hint 2](http://www.codediesel.com/javascript/auto-save-your-web-form-data/))
* Extract our implementation into a [jQuery plugin](http://learn.jquery.com/plugins/basic-plugin-creation/)

## 5. Unit Testing with Konacha

Our autosave script works pretty well, but there's one down side: we have to click through all possible scenarios to make sure they're all working whenever we make a change. It's just getting to the point by the end of the last section when it starts to feel painful or annoying. And imaging how you'd feel if you were brought on to improve this code, and you weren't familiar with it!

Unit testing has been around for decades, and JavaScript unit testing isn't that new either. JsUnit is one of the oldest frameworks and [it's been around for 12 years](https://github.com/pivotal/jsunit/commit/40c9cbf0f6498eeee81250fc2b01adf1c2bc07b2).

Recently, a new Ruby gem called [Konacha](https://github.com/jfirebaugh/konacha) came along with the express intent to support JavaScript Unit Testing in Rails. This is really helpful, because before we'd have to do a lot of extra work to integrate a pure JavaScript engine into the Asset Pipeline, plus create Rake tasks to run our tests for us.

Konacha didn't start from scratch. It includes the [Mocha](http://visionmedia.github.io/mocha/) testing framework for describing and running tests, and it includes the [Chai](http://chaijs.com/) assertion library for checking code behavior.

So, Konacha is the glue that binds Mocha and Chai to the Rails Asset Pipeline and provides Rake tasks for continuous integration. Sounds amazing (and also delicious) so let's see how it works.

### Konacha Setup

First off, we need to bring in the gem, just like we did with `twitter-bootstrap-rails`. Open up `Gemfile` and add:

```ruby
group :test, :development do
  gem 'konacha'
  gem 'selenium-webdriver'
end
```

Since these are our first development- and test-only gems, I added it at the bottom of my gemfile, away from the core gems.

We are also adding the `selenium-webdriver` gem. This will allow us to run the Konacha tests in an automated browser. You can also use the `poltergeist` gem and configure Konacha to use `poltergeist`, which runs on `phantomjs`, which is a headless browser (meaning there is no gui). We can do this later as an exercise.

Now, we need to bundle our app to bring in the new gems:

{% terminal %}
$ bundle
Fetching gem metadata from https://rubygems.org/..........
Fetching gem metadata from https://rubygems.org/..
Resolving dependencies...
... lots of gems ...
Installing colorize (0.5.8)
Installing konacha (3.0.0)
Installing ffi (1.8.1)
Installing childprocess (0.3.9)
Installing rubyzip (0.9.9)
Installing websocket (1.0.7)
Installing selenium-webdriver (2.33.0)
... more gems ...
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
{% endterminal %}

Now we can boot our Konacha test suite:

{% terminal %}
$ rake konacha:serve
Your tests are here:
  http://localhost:3500/
[2013-06-02 12:53:10] INFO  WEBrick 1.3.1
[2013-06-02 12:53:10] INFO  ruby 2.0.0 (2013-02-24) [x86_64-linux]
[2013-06-02 12:53:10] WARN  TCPServer Error: Address already in use - bind(2)
[2013-06-02 12:53:10] INFO  WEBrick::HTTPServer#start: pid=14804 port=3500
{% endterminal %}

As you can see on the last line, it's running on port 3500, so let's open up [localhost:3500](http://localhost:3500).

The page is almost empty. Up in the top right it says we have 0 passes and 0 failures. That's because we have no tests! First, let's create our test directory:

{% terminal %}
$ mkdir -p spec/javascripts
{% endterminal %}

Now let's make a test file to ensure Konacha is all hooked up. Edit `spec/javascripts/is_it_working_spec.js`:

```js
describe("My Application", function() {
  it("should think that true is true", function() {
    true.should.equal(true);
  });

  // Of course, this should fail, because false isn't true
  it("should think that false is true", function() {
    false.should.equal(true);
  });
});
```

Now refresh your browser that is pointed to Konacha. It should show one pass and one failure. Now we're cooking with gas!

The `describe` and `it` functions are coming from Mocha. They let us separate tests into different sections (with `describe`) and into separate tests (with `it`).

The `should.equal` is coming from Chai. Chai actually has three different styles, and you can pick the one that works for you best:

```js
true.should.equal(true);
expect(true).to.equal(true);
assert.equal(true, true);
```

We'll be using the `should` style, as that is closest to `rspec`, a very popular Rails testing framework.

Konacha also comes with a command line runner. Let's try running it:

{% terminal %}
$ rake konacha:run
.F

  Failed: My Application should think that false is true
    AssertionError: expected false to equal true

Finished in 0.00 seconds
2 examples, 1 failed, 0 pending
{% endterminal %}

It pops up a Firefox instance using Selenium, hits our tests, and then reformats the output for the console. If we were using `poltergeist`, no window would pop up.

It's up to you if you'd rather use the browser or command line version. For the rest of the tutorial, we'll use the command line, just because it's easier to include the output here.

Finally, remove this test, as it doesn't really do anything:

{% terminal %}
$ rm spec/javascripts/is_it_working_spec.js
{% endterminal %}

## 6. Testing Notifications

When you're unit testing, it's often easier to work bottom-up. That means starting with the smallest and most isolated chunk of code first. That way you have to do the least amount of setup and teardown. So the first thing we're going to test are our notification messages, since those are very simple.

Let's look at our notification code again:

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

When we're going to test something, we need to know two important things: what does this code need (its dependencies), and who does it collaborate with?

Since it's a function, what it needs is pretty simple: a `message` and optionally a `level`.

Who does it collaborate with is a little trickier: it collaborates with the `.page-header` since all it does is add a message to the top of the page.

What we need are some HTML fixture. An HTML fixture is a small chunk of HTML that will give us the necessary elements on the page for our code to interact with. We'll implement them as test templates so they play nice with the Rails Asset Pipeline.

First, make a directory for our templates:

{% terminal %}
$ mkdir spec/javascripts/templates
{% endterminal %}

Now let's make a template for our notification system. Since all it needs is a page header, we'll put that in.

Edit `spec/javascripts/templates/page_header.jst.ejs`:

```html
<div class="page-header">
</div>
```

So what's the `.jst.ejs`? JST stands for JavaScript Template, which is a common format for making templates. It means that `templates/page_header.jst` should be accessible as a function at `JST["templates/page_header"]` and if we call that function, it will evaluate the template.

Just like how `.html.erb` files is HTML that is evaluated by ERB (to include ruby snippets), `.jst.ejs` is a JST template that is evaluated by EJS (Embedded JavaScript), which is a template compiler for Ruby.

That means we need the `ejs` gem. Let's add it to our Gemfile:

```ruby
group :test, :development do
  gem 'konacha'
  gem 'selenium-webdriver'
  gem 'ejs'
end
```

OK, we have a template, now we can write our first test. Open up `spec/javascripts/notification_spec.js` and put:

```js
//=require application
//=require_tree ./templates

describe("notification", function() {
  it("should put a message on the page header", function() {
    $("body").html(JST['templates/page_header']());
    notify("hello world");
    $(".page-header").text().should.match(/hello world/);
  });
});
```

Let's walk through it. First off, we have some Asset Pipeline directives to load our application. This pulls in `application.js`, which pulls in all our framework code. Next we are loading the `./templates` tree. We don't want our test templates to be part of our app, so that's why we put them into `spec/javascripts/templates`. That also means we have to load them specifically into this test case.

Next up, we're `describe`ing `notification`, and saying that `it` should put a message on the page header.

The first thing this test does is replace the body of the page with our template. Konacha runs each test in an iframe so that we have a nice clean page for each test, and we can mess up the body all we want. Note that we have to call the template as a function to get the evaluated contents.

Then, we call `notify("hello world")`. That should put a "hello world" message on the page header.

Finally, we grab the page header's text and we ensure that it matches `/hello world/`. We use a match and a regular expression because we don't care about whitespace.

Reload your Konacha suite, and you should see a failure:

{% terminal %}
$ rake konacha:run
F

  Failed: notify should put a message on the page header
    ReferenceError: notify is not defined

Finished in 0.00 seconds
1 examples, 1 failed, 0 pending
{% endterminal %}

We get an error because `notify` is not defined. That's because it's inside our `onready`'s closure. Notify doesn't need to be in there, since it's pretty much a global helper.

Edit `autosave.js` and move the `notify` function outside of the closure. Rerun the test and it should pass.

Cool, our first working test! There's a saying in the Test Driven Development world: "Red, green, refactor!". That means the first thing you do is write a test that fails. We did that by writing our test, and it failed because the `notify` method was not globally available.

Then, we went "green" by fixing our code so the test passed. Now it's time for "refactor". That means we're going to clean up our code and use our test to make sure it still works.

Move the `notify` function into it's own file: `app/assets/javascripts/notification.js`. Re-run your tests to make sure it is still passing.

Great, now we've tested `notify`'s basic case. Let's test the levels. In this case we won't have a "red" phase because our code already has levels. If we were TDDing, we would write the test before we wrote the code to handle levels. But for now we're testing existing code.

First, let's test that the default level is info by adding a new `it` statement:

```js
it("should default to the info level", function() {
  $("body").html(JST['templates/page_header']());
  notify("hello world");
  $(".page-header .alert").hasClass("alert-info").should.be.true;
});
```

Our first two lines are the same. The third line checks that the alert div we create has the `alert-info` class on it. Check your tests. Now there will be two lines, one for each `it`, and they should both pass.

Let's refactor, but this time we'll refactor our tests, since the first two lines are the same. We can do this with Mocha's `beforeEach` function. Check it out:

```js
describe("notification", function() {
  beforeEach(function() {
    $("body").html(JST['templates/page_header']());
    notify("hello world");
  });

  it("should put a message on the page header", function() {
    $(".page-header").text().should.match(/hello world/);
  });

  it("should default to the info level", function() {
    $(".page-header .alert").hasClass("alert-info").should.be.true;
  });
});
```

The `beforeEach` will get run before each test, so they can share a setup. Now let's add a test for error levels. But there's one problem: we want to make a different `notify` call, but that would conflict with the one we're making already. So what we have to do is create two nested `describe` methods, one for the `info` level, and one for the error level:

```js
describe("notification", function() {
  beforeEach(function() {
    $("body").html(JST['templates/page_header']());
  });

  describe("info level", function() {
    beforeEach(function() {
      notify("hello world");
    });

    it("should put a message on the page header", function() {
      $(".page-header").text().should.match(/hello world/);
    });

    it("should default to the info level", function() {
      $(".page-header .alert").hasClass("alert-info").should.be.true;
    });
  });

  describe("error level", function() {
    it("should make error messages", function() {
      notify("everything is terrible", "error");
      $(".page-header .alert").hasClass("alert-error").should.be.true;
    });
  });
});
```

Run your tests to make sure everything is passing. If they seem to be passing but no tests actually ran, you have a syntax error somewhere:

{% terminal %}


Finished in 0.00 seconds
0 examples, 0 failed, 0 pending
{% endterminal %}

Let's walk through the code. At the top, we have a `beforeEach` that sets up our template, as that's shared across all kinds of notifications.

Then, we have a `describe` for the `info level` that has a `beforeEach` that makes an info level notification. This is where our previous tests are.

Finally, we have a `describe` for `error level` that has our single error test. Note that I didn't make a `beforeEach` here. I like to only extract code into setups when I have to, that way the code is as lean as it can be.

<div class="note"><p>
At this point, you may be looking at all the `it`s and `describes` and all the `});`s and thinking the code looks pretty ugly and full of syntactical necessities. I'd like to point out that a lot of the Rails and JavaScript community is moving towards using CoffeeScript, because of its simplifying effect on the syntax of JavaScript. Here's what the tests look like as CoffeeScript:

```coffeescript
describe "notification", ->
  beforeEach -> $("body").html(JST["templates/page_header"]())

  describe "info level", ->
    beforeEach -> notify "hello world"

    it "should put a message on the page header", ->
      $(".page-header").text().should.match /hello world/

    it "should default to the info level", ->
      $(".page-header .alert").hasClass("alert-info").should.be.true


  describe "error level", ->
    it "should make error messages", ->
      notify "everything is terrible", "error"
      $(".page-header .alert").hasClass("alert-error").should.be.true
```

But that's a class all on its own!
</p></div>

## 7. Unit Test Autosave

OK, we extracted out `notify`, now it's time to work on our main autosave script. First let's setup our new test file, `spec/javascripts/autosave_spec.js`:

```js
//= require spec_helper

describe("autosave", function() {
});
```

This time, I'm `require`ing `spec_helper`. I don't want to copy and paste the `require` lines from `notification_spec` since that would duplicate the "what our tests need to run" functionality. Instead, make `spec/javascripts/spec_helper.js` and simply add:

```js
//= require application
//= require_tree ./templates
```

Then go to `notification_spec.js` and change those two lines to:

```js
//= require spec_helper
```

Now we have a shared space to make setting up tests easier. Rerun your tests to make sure you've wired everything together correctly.

### Testing Save

The easiest and simplest course of action here is to work bottom up. We have these behaviors we need to test:

1. Binding to a form on page load
2. Saving on an interval
3. Saving on page `unload`
4. Saving
5. Saving if there's a change
6. Unbinding on an error

Many of these functions call `saveForm`, and `saveForm` has three dependencies:

1. `notify`
2. `$form`
3. `$.ajax`

Notify is already tested, so that should be easy, because we won't have to make sure it works. `$form` means that we'll need a template for an autosaving form, which we can do pretty easily. `$.ajax` is tricky because we need a whole rails server to make sure it works. Luckily, there's `sinon.js`.

#### Sinon

Sinon is another JavaScript test framework, and it has a bunch of helpful code surrounding Test Spies and it also contains a Fake Server. Sinon has a rails gem, but it's a bit out of date, so we get to learn how to bring in our own JavaScript without a gem. It's actually pretty easy.

Visit [sinonjs.org](http://sinonjs.org) and download sinon.js into `vendor/assets/javascripts/sinon-1.7.1.js` (your version number may be slightly different, remember it for the next step).

Now open up `spec/javascripts/spec_helper.js` and add:

```js
//= require sinon-1.7.2
```

You should be able to run your tests and they should still pass. It's always good to check!

#### The test

Now it's time to write our test. Remember, we're going to write what we expect to work, then implement what we need to in order to get it to pass. Here's our test for `saveForm`:

```js
//= require spec_helper
describe("autosave", function() {
  describe("saveForm", function() {
    var server;
    beforeEach(function() {
      server = sinon.fakeServer.create();
    });

    afterEach(function() {
      server.restore();
    });

    it("should save a form via ajax", function() {
      $("body").html(JST['templates/autosave_form']());

      $("form").autosave("save");

      var request = server.requests[0];
      request.url.should.equal("/posts");
      request.requestBody.should.equal("title=My+Post+Title");
      request.respond(204, {}, "");
      $(".page-header").text().should.match(/Post saved/);
    });
  });
});
```

Like before, we have describe blocks and a `beforeEach`, but now we also have a variable in the describe block, and an `afterEach`. What we're doing here is making the `server` variable available to the whole describe block. Setting it in `beforeEach`, then tearing it down in `afterEach`. Since sinon is going to hijack the entire XHR object of the browser, we need to make sure it gets cleaned up.

In our test, we set up our fixture as usual. But then we're calling `$("form").autosave("save")`.

Shouldn't this work?

The issue here is like with `notify` the method is part of the closure. In fact, all our code is closed up and inaccessible to anyone who wants to use it. This makes it hard to test, but really it's just because it's hard to use.

Take, for example, what would happen if we used JavaScript to build a form on-the-fly. Since we bind to forms when the page loads, this new dynamic form wouldn't get the autosaving functionality. jQuery plugins exist so that you can run custom code on objects on the fly. What you're seeing now is a common jQuery plugin syntax for sending a command (`save`) to an object via a plugin.

So what I'm doing here is writing a test for how I *wish* the application worked. This fails, and we're going to write what we need to make it pass, and the code will be more awesome for it.

Next, we grab the server's first request, which is a fake XHR request. We make sure that it is posting to the right url, and that it has the right data being sent along. Then we tell it to respond, which will call back to jQuery. Finally, we make sure the success message is present on the page.

If we run our tests, we get:

{% terminal %}
$ rake konacha:run
F...

  Failed: autosave saveForm should save a form via ajax
    TypeError: JST['templates/autosave_form'] is not a function

Finished in 0.00 seconds
4 examples, 1 failed, 0 pending
{% endterminal %}

So, let's make `spec/javascripts/templates/autosave_form.jst.ejs`:

```html
<div class="page-header"></div>
<form data-autosave="autosave" action="/posts">
  <input name="title" value="My Post Title">
</form>
```

Now if we run our tests, we get:

{% terminal %}
$ rake konacha:run
F...

  Failed: autosave saveForm should save a form via ajax
    TypeError: $("form").autosave is not a function

Finished in 0.00 seconds
4 examples, 1 failed, 0 pending
{% endterminal %}

So, the first thing we need to do is make a jQuery plugin. We're not going to write all the code to do that write now. Instead, we're going to write the *least code necessary* to proceed past this failure.

Add this to the top of `autosave.js`:

```js
(function($) {
  $.fn.autosave = function() {
  }
}( jQuery ));
```

That is the skeleton of a jQuery plugin called `autosave`. Now our tests say:

{% terminal %}
$ rake konacha:run
F...

  Failed: autosave saveForm should save a form via ajax
    TypeError: request is undefined

Finished in 0.00 seconds
4 examples, 1 failed, 0 pending
{% endterminal %}

That's because our plugin doesn't do anything! What we need to do now is move our initialization code into the plugin. Our code now looks like this:

```js
(function($) {
  $.fn.autosave = function() {
    var $form = $("form[data-autosave]");
    var savedForm = $form.serialize();
    var autosaveInterval = window.setInterval(saveFormIfChanged, 10000);

    $(window).on("unload", function() {
      saveFormIfChanged(false);
    });

    $form.on("submit", function() {
      savedForm = $(this).serialize();
    });

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

    function saveFormIfChanged(async) {
      var currentForm = $form.serialize();

      if (currentForm !== savedForm) {
        saveForm($form, async);
        savedForm = currentForm;
        return true;
      } else {
        return false;
      }
    }

    function formError() {
      clearInterval(autosaveInterval);
      $(window).off("unload");
      $form.off("submit");
    }
  }
}( jQuery ));
```

Instead of the `$()` `onready` we moved that code into the plugin. We are still getting the same test error, because when we pass the `"save"` option to the plugin we expect it to call `saveForm`. Let's do that now.

First, at the top, we will accept a command argument:

```js
(function($) {
  $.fn.autosave = function(command) {
  // ...
```

Then, at the very bottom **but inside the plugin** we'll call `saveForm` if the command is `save`:

```js
    // ...
    if (command === "save") saveForm();
  }
}( jQuery ));
```

And voila, our tests pass. However there is one problem: every time we run a command like this, we're running all our plugin's binding code. Also, we aren't binding on page load, so our actual implementation is failing! Since we messed with the structure of the plugin itself, it's good to check it out in a real browser to make sure that things went well.

Let's move the autosave selector into its own onready:

```js
(function($) {
  $.fn.autosave = function(command) {
    this.each(function() {
      var $form = $(this);
      // middle unchanged
    });
  }

  $(function() {
    $("form[data-autosave]").autosave();
  });
}( jQuery ));
```

When the page is loaded, we'll run our autosave plugin on all forms that match the autosave data attribute. This also allows us to call `$("form").autosave()` in our test after the page has loaded.

Now let's mark the form as autosaving once we've loaded our plugin, and then we won't reinitialize it:

```js
(function($) {
  $.fn.autosave = function(command) {
    this.each(function() {
      if (!this.autosaving) {
        this.autosaving = true;
        var $form = $(this);
        // the rest of the code
      }
      if (command === "save") saveForm();
    });
  }

  $(function() {
    $("form[data-autosave]").autosave();
  });
}( jQuery ));
```

Now, we mark the dom element with an `autosaving` attribute. When our JavaScript hits this element again, it won't initialize the form.

### Testing `saveFormIfChanged`

The next thing we can test is `saveFormIfChanged`. This will be pretty simple, because all we'll do is tell the form to save twice, and make sure only one save goes through. Then, we'll change the content and tell it to save again.

Move the template code into the `beforeEach`, then add this `it` case:

```js
it("should only save if values have changed", function() {
  $("form").autosave("save");
  server.requests.length.should.equal(0);

  $("form input").val("A different title");
  $("form").autosave("save");
  server.requests.length.should.equal(1);
});
```

If you run the tests, we get an error `TypeError: Cannot call method 'attr' of undefined` from the `saveForm` method. Our double-initialization checking code is actually preventing the plugin from keeping the `$form` variable around.

What we need to do is get a form reference and define the functions, but we don't want to bind events that are already bound. Since this change effects a couple sections of the code, here's the refactored code, for clarity's sake:

```js
(function($) {
  $.fn.autosave = function(command) {
    this.each(function() {
      var form = this;
      if (!form.autosaving) {
        form.autosaving = true;
        var $form = $(form);
        form.savedForm = $form.serialize();

        $(window).on("unload", function() {
          saveFormIfChanged(false);
        });

        $form.on("submit", function() {
          savedForm = $form.serialize();
        });

        form.saveForm = function(async) {
          if (async === undefined) async = true;

          $.ajax({
            url: $form.attr("action"),
            type: "POST",
            data: $form.serialize(),
            dataType: "json",
            async: async
          }).done(function(data, status, response) {
            notify("Post saved.", "success");
          }).fail(form.formError);
        }

        form.saveFormIfChanged = function(async) {
          var currentForm = $form.serialize();

          if (currentForm !== form.savedForm) {
            form.saveForm($form, async);
            form.savedForm = currentForm;
            return true;
          } else {
            return false;
          }
        }

        form.formError = function() {
          clearInterval(form.autosaveInterval);
          $(window).off("unload");
          $form.off("submit");
        }

        form.autosaveInterval = window.setInterval(form.saveFormIfChanged, 10000);
      }

      if (command === "save") form.saveForm();
    });
  }

  $(function() {
    $("form[data-autosave]").autosave();
  });
}( jQuery ));
```

What we've done is defined all our functions and variabled on the dom element itself. That means any time we visit this element again (subsequent calls to `autosave`) we can call the functions we set up for ourselves, and use the variables we set up too. (Also note I had to move the `setInterval` call down until after `saveFormIfChanged` was defined.)

We're slowly working our way towards a more Object Oriented version of our plugin. Instead of a bag of functions and variables, we have a form object that has methods on it.

At this point, our test gives us:

{% terminal %}
$ rake konacha:run
.F...

  Failed: autosave saveForm should only save if values have changed
    AssertionError: expected 2 to equal 1

Finished in 0.00 seconds
5 examples, 1 failed, 0 pending
{% endterminal %}

Great! Now the only issue is the one under test: we are double saving. It's a simple fix. Just change the command line to:

```js
if (command === "save") form.saveFormIfChanged();
```

But now, our first test failed! It turns out, that test wasn't as specific as it needed to be. Because our form only saves when there is a change, we need to make a change before trying to save (we could wait for the timeout, but who has time for that?):

```js
//= require spec_helper
describe("autosave", function() {
  describe("saveForm", function() {
    var server;
    beforeEach(function() {
      server = sinon.fakeServer.create();
      $("body").html(JST['templates/autosave_form']());
      $("form").autosave();
    });

    afterEach(function() {
      server.restore();
    });

    it("should save a form via ajax", function() {
      $("form input").val("A different title");
      $("form").autosave("save");

      var request = server.requests[0];
      request.url.should.equal("/posts");
      request.requestBody.should.equal("title=A+different+title");
      request.respond(204, {}, "");
      $(".page-header").text().should.match(/Post saved/);
    });

    it("should only save if values have changed", function() {
      server.requests.length.should.equal(0);

      $("form input").val("A different title");
      $("form").autosave("save");
      server.requests.length.should.equal(1);
    });
  });
});
```

We initialize in the `beforeEach`, and then before we want a real save, we change the text in the form. Everything is passing, yay!

## 8. Fully Object Oriented

My favorite part of TDD is refactoring into a great solution, with your tests confirming that everything is working. It's time to make this code really clean and object oriented.

### JavaScript OO Crash Course

Let's do a quick overview of objects in JavaScript. JavaScript uses prototypical inheritance, which means if you give a function a prototype, it can be constructed. Here's an example:

```js
var Person = function(name) {
  this.name = name;
}
Person.prototype = {
  sayHello: function() {
    alert("Hi, I'm " + this.name );
  }
}

var joe = new Person("Joe");
joe.sayHello() // alerts "Hi, I'm Joe"
```

The function is the constructor, then any method on the prototype will have `this` set to the instance it's being called on.

### OO Autosave

As we go through our OO refactor, be sure to run the tests at every step (I'll remind you) to make sure everything is ok so far.

The first thing we're going to do is move the bulk on the code into the constructor, and we'll extract the methods later:

```js
(function($) {
  var AutosaveForm = function(form) {
    var $form = $(form);
    form.savedForm = $form.serialize();

    $(window).on("unload", function() {
      saveFormIfChanged(false);
    });

    $form.on("submit", function() {
      savedForm = $form.serialize();
    });

    form.saveForm = function(async) {
      if (async === undefined) async = true;

      $.ajax({
        url: $form.attr("action"),
        type: "POST",
        data: $form.serialize(),
        dataType: "json",
        async: async
      }).done(function(data, status, response) {
        notify("Post saved.", "success");
      }).fail(form.formError);
    }

    form.saveFormIfChanged = function(async) {
      var currentForm = $form.serialize();

      if (currentForm !== form.savedForm) {
        form.saveForm($form, async);
        form.savedForm = currentForm;
        return true;
      } else {
        return false;
      }
    }

    form.formError = function() {
      clearInterval(form.autosaveInterval);
      $(window).off("unload");
      $form.off("submit");
    }

    form.autosaveInterval = window.setInterval(form.saveFormIfChanged, 10000);
  };

  AutosaveForm.prototype = {
  };


  $.fn.autosave = function(command) {
    this.each(function() {
      var form = this;
      if (!form.autosave) {
        form.autosave = new AutosaveForm(form);
      }
      if (command === "save") form.saveFormIfChanged();
    });
  }

  $(function() {
    $("form[data-autosave]").autosave();
  });
}( jQuery ));
```

All I really did was pass the `form` through to the constructor, and then define all the methods in the constructor. It still puts all the methods back onto the dom element. The tests are still passing.

The next thing we're going to do is store the `form` and `$form` on `this` in the constructor:

```js
var AutosaveForm = function(form) {
    var $form = $(form);
    form.savedForm = $form.serialize();

    this.form = form;
    this.$form = $form;
  // the rest is the same
}
```

Now, we'll move each function into the prototype, and put our instance variables on `this`, and call the other form functions using `this`. For example, here's `formError` moved over:

```js
AutosaveForm.prototype = {
  formError: function() {
    clearInterval(this.autosaveInterval);
    $(window).off("unload");
    this.$form.off("submit");
  }
};
```

Try to move them all over yourself. One of the biggest issues will be function scope. For example, the `fail` handler on `$.ajax` in `saveForm` can't take `this.formError` as a parameter, because when `formError` gets called, it won't be in the scope of the autosaving form instance, it will be called on window. So you'll need to store the scope:

```js
var autosaveForm = this;
$.ajax({
  // ...
}).fail(function() {
  autosaveForm.formError()
});
```

Storing a reference to `this` in a variable and then using that variable later is a common pattern in JavaScript. Often, people will say `var self = this` or `var that = this`.

An alternative is underscore.js's `bind`. For example:

```js
fail(_.bind(this.formError, this))
```

That will create a function that just calls `formError` on the `this` passed in.

Here is a complete implementation. Note that I had to use a `this` reference multiple times in the initializer to keep scope.

```js
(function($) {
  var AutosaveForm = function(form) {
    var $form = $(form);
    this.savedForm = $form.serialize();

    this.form = form;
    this.$form = $form;

    var autosaveForm = this;
    $(window).on("unload", function() {
      autosaveForm.saveFormIfChanged(false);
    });

    $form.on("submit", function() {
      autosaveForm.savedForm = $form.serialize();
    });

    this.autosaveInterval = window.setInterval(function() {
      autosaveForm.saveFormIfChanged()
    }, 10000);
  };

  AutosaveForm.prototype = {
    saveForm: function(async) {
      if (async === undefined) async = true;
      var autosaveForm = this;

      $.ajax({
        url: this.$form.attr("action"),
        type: "POST",
        data: this.$form.serialize(),
        dataType: "json",
        async: async
      }).done(function(data, status, response) {
        notify("Post saved.", "success");
      }).fail(function() {
        autosaveForm.formError()
      });
    },

    saveFormIfChanged: function(async) {
      var currentForm = this.$form.serialize();

      if (currentForm !== this.savedForm) {
        this.saveForm(this.$form, async);
        this.savedForm = currentForm;
        return true;
      } else {
        return false;
      }
    },

    formError: function() {
      clearInterval(this.autosaveInterval);
      $(window).off("unload");
      this.$form.off("submit");
    }
  };


  $.fn.autosave = function(command) {
    this.each(function() {
      var form = this;
      if (!form.autosave) {
        form.autosave = new AutosaveForm(form);
      }
      if (command === "save") form.autosave.saveFormIfChanged();
    });
  }

  $(function() {
    $("form[data-autosave]").autosave();
  });
}( jQuery ));
```

### On your own

Continue to improve this version. Here are a number of tasks to try on your own, but you can work on something you feel is missing:

1. Rename the methods. `this.saveForm` is redundant, since `this` is a form. Change it to `this.save`. Change the names of the other methods to be more succinct.
2. Extract the concepts of "form is different" and "save form state" into their own methods. Add unit tests for these methods.
3. Change `formError` to `unbind`, and make a command so you can run `$("form").autosave("unbind")` and it removes the autosave bindings.
4. Add [underscore.js](http://underscorejs.org) to the project and use `_.bind` and `_.bindAll` to simplify method scoping.

## 9. Exercises

At this point we have all the tools that we need to implement more functionality on Scribblr, and keep it all covered with unit tests. Go back through the previous chapter's extra sections and try implementing those suggestions.

Or, feel free to start working on new plugins. If you have a lot of time, try making a plugin that formats posts using asterisks for italics. Or try adding a `draft` column to the posts table, and save intermediate changes there. Then only publish the draft content when the user saves the form for real.

If you're interested in coffeescript, convert some files to coffeescript. Rails can already handle coffeescript assets, so just change the extension to `.coffee` and Rails will compile it.
