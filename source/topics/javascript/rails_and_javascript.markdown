---
layout: page
title: Rails and Javascript
section: JavaScript & AJAX
---

Rails has always provided basic capabilities for utilizing JavaScript in an application. Generally though, it's been a tenuous relationship as a majority of what was provided focused on simple helpers.

## Generating JavaScript from Ruby

In the past, Rails shipped with a JS library called `RJS` that, when utilized, would give access to helpers for things such as making AJAX calls. These JS functions were typically meant to interact with other JS generated via Rails helpers, such as `link_to_remote`, from within your view files. 

Now, it is best practice to write JavaScript in JavaScript (or CoffeeScript) and leave generated code and Rails helpers out of the picture.

### Before Rails 3.1

In Rails 2.X and 3.0.X applications, JavaScript lives in your public directory. You would write JS as needed and separate your files for code organization, modularity or other reasons. The web server would treat these files as static assets and serve them to the browser.

### Rails 3.1

In Rails 3.1, the Asset Pipeline was introduced along with the idea that your JavaScript, along with other types of assets, is just as important to your application as your Ruby. 

Assets such as JavaScript, CSS and images now live inside of the `app/assets` directory and are cached, compressed and compiled as necessary. The power behind this approach is explained well in the [official Rails Guide](http://guides.rubyonrails.org/asset_pipeline.html) and is powered by [Sprockets](https://github.com/sstephenson/sprockets).

## jQuery UJS / `rails.js`

Rails still utilizes a basic helper library of utility JavaScript functions under the name `jquery-ujs` when using jQuery, or `rails.js` when using Prototype. It is included into your layout by default.

### Delete Links

The JavaScript searches the DOM for any elements with an attribute `data-method` and manipulates them.

The most common example is when, in our view template, we've written:

```erb
<%= link_to "Delete", article_path(@article), method: :delete %>
```

The generated HTML looks like this:

```html
<a href="/articles/11-the-article" data-method="delete" rel="nofollow">Delete</a>
```

When the JavaScript detects this element it dynamically:

* Wraps the element in a hidden HTML form
* Adds a click action to the link which will submit the form
* Injects a hidden form input named `_method` with the value specified by `data-method`, here `delete`

This way, when the link is clicked:

* An HTTP `POST` submits the form
* The router recognizes the special `_method` parameter and *pretends* the incoming request is using the verb specified
* The router will trigger the `articles#destroy` path based on the path and `DELETE` verb

None of this will work without the JavaScript.

### Confirmation Dialog

Confirmation dialogs are handled similarly. When we write this in our view template:

```erb
<%= link_to "Delete", article_path(@article),
            method: :delete,
            confirm: "Delete #{@article.title}?" %>
```

We get out HTML like this:

```html
<a href="/articles/11-the-article" data-confirm="Delete The Article?" data-method="delete" rel="nofollow">Delete</a>
```

See the `data-confirm` attribute? The Rails JavaScript scans the DOM for elements with that attribute. When found, it attaches a click listener to the link, such that:

* Clicking the link will pop up a JS confirmation dialog with the message supplied by the `data-confirm`
* Selecting `OK` will follow the link specified
* Selecting `CANCEL` will return to the page with no changes

## Exercises

{% include custom/sample_project.html %}

1. Go to the `show` page for an Article and inspect the delete link. What markers do you see embedded there?
2. Try changing the `data-method` to `GET` using your browser's source navigator, then click the link. What happens?
3. Try #2 again, but with a bogus verb like `HOWDY`. What happens when you click the link?
4. Experiment with adding a `:confirm` parameter to a link that is not a delete. Does it work?

## References

* jQuery UJS Adapter for Rails: https://github.com/rails/jquery-ujs
* `ActionView` JS API: http://api.rubyonrails.org/classes/ActionView/Helpers/JavaScriptHelper.html
* `link_to` API: http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html
