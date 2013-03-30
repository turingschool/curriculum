---
layout: page
title: Rails Views
---

## Complexity

Many technologies meet:

- the basics: html, css, javascript, ruby
- other output formats: text (emails), json, RSS, XML, etc
- templating languages: Erb, Haml, liquid, slim, builder, etc
- browsers: IE, chrome, firefox, opera, safari; webkit
- different consumers: smart phones, tablets, desktop browsers, screen readers, search engines
- additional/supportive/periferal technologies: CoffeeScript, jQuery, sass, compass, the Asset pipeline, boilerplates (HTML5, twitter bootstrap), grid systems (960, blueprint)

## The Unloved Step-Child

Rails views are where developers and designers meet. Communication between developers and designers can already be difficult and strained, but in addition to that, neither developers nor designers really take responsibility for the views.

Developers tend think of views (HTML/CSS) as 'not real programming', and are therefore content to just sling, hack, and tweak until it works. It's very easy to leave the good practices of short lines and modular code behind in this environment.

Designers tend to just care that the end result looks good -- who cares if the source code is ugly and tangled. Also, designers will often find the whole templating/ruby/helpers stuff confusing and opaque and treat it like magic.

## Leaky State

Rails controllers share their state with the views, and all the helper modules are mixed into the fray as well.

(Simplification of how rails shares instance variables)[https://gist.github.com/714be1402a2fa0eaa333]

## Optimize for Sanity

- Use modern defaults. Choose HTML5 and UTF-8.
- Use existing tools - a lot of work has been put down to create a sane foundation on which you can build. Don't reinvent the wheel. Use reset.css and normalize.css.
- Build things in from the start: Accessibility (ARIA). Responsive (smart phones, tablets, desktop)
- Validate! HTML, CSS, jslint, http://www.totalvalidator.com/tools/
- Minimal semantic markup, as few css classes as you can get away with, as lightweight as you can (use the 'cascading' part of 'css', then add classes, then add IDs, and finally, if you must, use important!)
- separation of concerns (markup is for hierarchy and context, add hooks for design and behavior/javascript. Make your javascript unobtrusive.)
- No app-related logic. Only view-related logic, like which tab is active.
- Coding standards: line length, indentation, choice of template language
- Clever is a code smell. Don’t do it. Don't guess which tab should be active based on the name of the controller/action. Don't introduce algorithmic solutions into i18n stuff. Just hardcode all the things!

## The Response

Rails controllers can choose between three responses:

- render
- redirect
- HEAD (no response body, just metadata)

The default is to render a template that has the same name as the action and is located in a view folder matching the name of the controller.

You can override the defaults!

Call render from the controller:

- render :nothing
- render :text => 'ok'
- render :json => {:status => 'ok'}.to\_json
- render :inline => '<h1>Hello, world!</h1>'

Render a different template, either based on the action or by specifying the template

- render :edit # the template corresponding to the :edit action
- render 'farm/animals.html.erb' # render a specific template

## Layouts

If you want to wrap all the pages, you use a layout, which basically consistst of content and a `yield` statement where the content that will be included is ... included. OMG. I CAN'T WRITE ENGLISH. PLEASE SEND HELP.

By default, a controller will use the `layouts/application` layout, unless there is a layout with the same name as the controller. In that case, that will be preferred.

You can also override which layout will be used for a specific action, or at the controller level.

```ruby
def index
  @goats = Goats.all
  render 'barn/stuff', :layout => 'arduino'
end
```

```ruby
class GoatsController < ApplicationController

    layout "main" # can also be a proc or a symbol referring to a method

end
```

An action can also be rendered without a layout by specifying `:layout => false` in the render call.

## Yielding

The most basic yield statement looks like this `<%= yield %>`. This is where the basic page content will be pulled into the layout.

You can also yield specific 'named' content.

For example you can collect content in the page for a specific purpose by saying:

```ruby
<% content_for :goats do %>
  <title>Just another gSchool meme</title>
<% end %>
```

And then you can yield the collected content by saying

```ruby
<%= yield :goats %>
```

You can also make decisions based on whether or not named content has been created:

```ruby
<% if content_for? :goats do %>
  <%= render :goat_nav %>
  <%= yield :goats %>
<% end %>
```

## Clean templates

### Partials

Defaults are your friend.

- render 'something' # partial '_something.html.erb' in the current dir
- render 'whatever/stuff' # partial '_stuff.html.erb' in the 'whatever' dir
- render 'stuff', :title => 'Amazing Things' # local variables
- render 'thing', :object => @thing # use the default local variable
- render 'thing', :collection => @things # loop and render _thing for each one
- render @things # loop and render _thing for each one

You can use spacer templates and layouts for rendering partials.

### Helpers

There are lots of helpers!
http://api.rubyonrails.org/classes/ActionView/Helpers.html

Know your helpers so you don't re-invent the wheel.

To play around with helpers in the console, include the helper module as a mixin in the console context:

```ruby
include ActionView::Helpers::TextHelper
"I spy with my little eye".truncate(10, :separator => '...')
```

You can also write your own helpers. Create a module in the `app/helpers/` directory, and define a method. All the helpers automatically get mixed into the view context.

Helpers are great for logic, partials are better when you have lots of repetitive HTML.
