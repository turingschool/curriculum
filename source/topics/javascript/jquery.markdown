---
layout: page
title: Using JQuery
section: JavaScript & AJAX
---

jQuery has become the most popular JavaScript library both inside and outside of the Rails community. Let's look at how to take advantage of the library with our applications.

## Setup

The setup process differs depending on whether your app is running on a version of Rails before 3.1 or after 3.1.

### Before Rails 3.1: `jquery-rails`

For political reasons, Rails has always shipped with the Prototype library instead of jQuery. The last "Rails Survey" showed that around 70% of projects were using jQuery instead. Developers install the library and override the default Prototype.

#### Installing `jquery-rails`

You could setup the library yourself, but that is too much work. Instead, rely on the official `jquery-rails` gem.

Add `gem 'jquery-rails'` to your `Gemfile` then run `bundle`.

#### Running the Generator

From your project's directory, run the generator:

{% terminal %}
$ rails generate jquery:install
{% endterminal %}

The generator will remove the Prototype libraries and install the latest version of jQuery:

{% terminal %}
$ rails generate jquery:install
      remove  public/javascripts/prototype.js
      remove  public/javascripts/effects.js
      remove  public/javascripts/dragdrop.js
      remove  public/javascripts/controls.js
     copying  jQuery (1.6.1)
      create  public/javascripts/jquery.js
      create  public/javascripts/jquery.min.js
     copying  jQuery UJS adapter (0e7426)
      remove  public/javascripts/rails.js
      create  public/javascripts/jquery_ujs.js
{% endterminal %}

Note that the `jquery_ujs.js` is a replacement for the `rails.js` which handles functions like making your delete links work.

#### Redefining `:defaults`

When the gem is loaded it automatically overrides Rails' list of default JavaScripts. In your layout you can use this include tag, like normal:

```erb
<%= javascript_include_tag :defaults %>
```

That will load jQuery on all your pages.

### After Rails 3.1

In Rails 3.1, jQuery is the default JavaScript library. `jquery-rails` is automatically included in your `Gemfile` and running the generator is not necessary.

## Writing Your JavaScript

Once you have the library, it is time to write your JavaScript. Where you put your work varies based on whether you are using Rails pre-3.1 or after 3.1.

### Before Rails 3.1

In older Rails applications, your JavaScript files were loaded from `public/javascripts`. Your app will have an `application.js` file there which is included in the Rails defaults.

As your JavaScript code grows, you'll likely want to break it into several files.

#### Including Other JavaScript Files

You have two options for loading those additional files. The first is to just add them to the layout:

```erb
<%= javascript_include_tag :defaults, 'my_custom_file' %>
```

This is a good choice if you want to be explicit and especially if you want to load different JS files for different pages/layouts.

You could choose to change the definition of `:defaults`. In your `config/application.rb` you would add this:

```ruby
config.action_view.javascript_expansions[:defaults] += ['my_custom_file']
```

Or, if you are managing a large number of JS files, you might define your own expansion name. In `application.rb`:

```ruby
config.action_view.javascript_expansions[:shopping_cart] = ['cart', 'product', 'support']
```

Then in the layout:

```erb
<%= javascript_include_tag :defaults, :shopping_cart %>
```

### Rails 3.1 and Beyond

In Rails 3.1 the game has changed significantly. Developing effective web applications today necessitates writing JavaScript, and often a lot of it.

Before 3.1, dumping all JavaScript into `public/javascripts` got messy as applications grew. Many teams chose to move the folder to the `app` directory so it was closer to the Ruby application code. 

As you split up JavaScript into a bunch of separate files you are increasing the number of request/response cycles that the client must perform to display the page. This can really slow the client down.

#### Enter the Pipeline

The solution to both of these issues is the *Asset Pipeline*. The pipeline allows us to assemble multiple JS files server side, minify and compress them, and then output a single file to the browser. This results in just one request/response cycle, lower total I/O, and faster processing on the client. The component files live in the `app` directory and mirror the structure of other components.

#### Writing JavaScript for the Pipeline

The Rails 3.1 generators are set up to help you. When you generate an `ArticlesController`, for instance, it will create `app/assets/javascripts/articles.js.coffee`. This file is where you will write the JavaScript related to articles.

What's `.coffee`? Next we will take a look at CoffeeScript.

## Exercises

{% include custom/sample_project.html %}

1. Add the `jquery-rails` gem to Blogger and use the generator to setup the library.
2. Create a file named `interface.js` in the `javascripts` directory.
3. Load that file by adding it to the include in the application layout. Verify it is in the head by looking at the page source.
4. Remove it from the application layout, and instead add it to the `:defaults` in the configuration. Note that you'll need to restart the server for it to take effect. Verify the script appears in the head of a page's source.
5. CHALLENGE: Write the jQuery in `interface.js` so that clicking the "Comments" header toggles the visibility of all comments.

## References

* jQuery-Rails on GitHub: https://github.com/rails/jquery-rails
* Asset Pipeline in Rails 3.1: http://guides.rubyonrails.org/asset_pipeline.html
