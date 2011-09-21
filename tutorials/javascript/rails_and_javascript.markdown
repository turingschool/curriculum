# Rails and JavaScript

Rails has always provided basic capabilities for utilizing JavaScript in an application. Generally though, it's been a tenuous relationship as a majority of what was provided focused on simple helpers.

## Generating JavaScript from Ruby

In the past, Rails shipped with a JS library called `RJS` that, when utilized, would give access to helpers for things such as making AJAX calls. These JS functions were typically meant to interact with other JS generated via Rails helpers, such as `link_to_remote`, from within your view files. Now, it is best practice to write JavaScript in JavaScript (or CoffeeScript) and leave generated code and Rails helpers out of the picture.

### Before Rails 3.1

[TODO: what did this comment mean?]  ( modify the includes as mentioned in some other section )

In Rails 2.X and 3.0.X applications, JavaScript lives in your public directory. Here, you would write JS as you needed it and separate your files for code organization, modularity or other reasons. The web server would treat these files as static assets and serve them to the browser.

### Rails 3.1

In Rails 3.1, the Asset Pipeline was introduced along with the realization that your JavaScript, along with other types of assets, is just as important to your application as your Ruby. Assets such as JavaScript, CSS and images now live inside of the `app/assets` directory and are handled much smarter in terms of caching, compression and compilation. The power behind this approach is explained well in the [official Rails Guide](http://guides.rubyonrails.org/asset_pipeline.html) and is powered by [Sprockets](https://github.com/sstephenson/sprockets).

## jQuery UJS

Rails still publishes a basic helper library of utility JavaScript functions under the name `jquery-ujs`. To install it, add the `jquery-rails` gem to your `Gemfile` and require it in your `application.js` manifest:

```javascript
// CURRENT FILE :: app/assets/javascripts/application.js
//
//= require jquery
//= require jquery_ujs
```

See the [GitHub README](https://github.com/rails/jquery-ujs) for information on the functionality it offers.

### Delete Links

( the `rails.js` finds links marked with data-method and builds a form around them with the hidden field named `_method` which stores the desired HTTP verb, like delete)
( The request really goes in as a POST, but the router respects _method and pretends it is a DELETE )
( Create this by using :method => :delete in link_to)

### Confirmation Dialog

( `rails.js` searches for `data-confirm` attributes and attaches a click handler that pops an alert box with the attribute's value. )
( use it by specifying `:confirm => "My Message"` in `link_to`)

## Exercises

[TODO: JSBlogger Setup]

1. Go to the `show` page for an Article and inspect the delete link. What markers do you see embedded there?
2. Try changing the `data-method` to `GET` using your browser's source navigator, then click the link. What happens?
3. Try #2 again, but with a bogus verb like `HOWDY`. What happens when you click the link?
4. Experiment with adding a `:confirm` parameter to a link that is not a delete. Does it work?

## References

* jQuery UJS Adapter for Rails: https://github.com/rails/jquery-ujs
* `ActionView` JS API: http://api.rubyonrails.org/classes/ActionView/Helpers/JavaScriptHelper.html
* `link_to` API: http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html
