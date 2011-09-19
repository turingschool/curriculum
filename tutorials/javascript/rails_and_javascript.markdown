# Rails and JavaScript

( Rails has always had some JS capability )
( But it's always been a weird relationship )

## Generating JavaScript from Ruby

( There used to be RJS )
( And helpers like `link_to_remote`)
( Now, in general, handle your JS in JS -- don't get involved with Rails and helpers)

### Before Rails 3.1

( Drop JS into `public`)
( Use separate files as necessary for organization )
( modify the includes as mentioned in some other section )

### Rails 3.1

( Asset Pipeline )

## `rails.js`

( JavaScript is necessary for some of the functionality rails offers )

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
