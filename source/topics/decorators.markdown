---
layout: page
title: Experimenting with Draper
---

Let's play around with the concept of decorators and check out some of the features offered by the [Draper gem](http://rubygems.org/gems/draper).

<div class="note">
<p>This tutorial is open source. Please contribute fixes or additions to <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/topics/decorators.markdown">the markdown source on GitHub.</a></p>
</div>

### Setup

{% include custom/sample_project_advanced.html %}

### Install Draper

Next, open the `Gemfile` and add a dependency on `'draper'` like this:

```ruby
  gem 'draper'
```

Run `bundle`, then start up your server.

### Generate a Decorator

We'll create a decorator to wrap the `Article` model. Draper gives you a handy generator:

{% terminal %}
$ rails generate decorator article
{% endterminal %}

It will create the folders `app/decorators/`, `spec/decorators/`and the files `app/decorators/article_decorator.rb`, `spec/decorators/article_decorator_spec.rb`. Open the file and you'll find the frame of a `ArticleDecorator` class.

*Restart* your server so the new folder is added to the load path.

### First Usage

Without adding anything to the decorator, let's see the simplest usage. Open the `articles_controller` and look at the `show` action. It currently has:

```ruby
  def show
    @article = Article.find(params[:id])
  end  
```

To make use of the decorator, call the `.new` method and pass in the Article from the database:

```ruby
  def show
    source = Article.find(params[:id])
    @article = ArticleDecorator.new(source)
  end
```

Test it by displaying a single article in your browser and making sure things work
as expected. The tests should also pass.

#### Using `decorates_finders`

The pattern of finding an object then immediately decorating it is a common one.
In the decorator you can use `decorates_finders` method like the following:

```ruby
  class ArticleDecorator < Draper::Decorator
    ...
    decorates_finders
    ...
  end
```

Then the decorator will delegate the `find` method to the wrapped class, allowing us to write this:

```ruby
  def show
    @article = ArticleDecorator.find(params[:id])
  end
```

Then go and view the show page for a single Article by clicking on its name on the index.

### Adding Methods

Now let's add some useful functionality to our decorator.

#### Article Published On

Currently the show page just displays the raw `created_at` data in the "Published" line.
Often we want to standardize date formatting across our application, and the decorator makes this easy.

Let's create a formatter method for `created_at` method in our decorator:

```ruby
def formatted_created_at
  object.created_at.strftime("%m/%d/%Y - %H:%M")
end
```

The `object` method here refers to the instance of `Article` that the decorator wraps.

#### Using `article`

For better semantics, the `ArticleDecorator` creates an alias for `object` named `article`.
So we can replace `object` with `article`:

```ruby
def formatted_created_at
  article.created_at.strftime("%m/%d/%Y - %H:%M")
end
```

#### Modifying the View Template

Now in the `show.html.erb` for Article you need to change the following line:

```ruby
<h4>Published <%= @article.created_at %></h4>
```

to:

```ruby
<h4>Published <%= @article.formatted_created_at %></h4>
```

Refresh your browser and the "Published" line will use the new formatting.

#### Overriding Existing Methods

You aren't limited to defining new methods in the decorator. If the decorator
defines a method then that method will be found first, even if the wrapped
model has an identical method. This means you can effectively override methods
of the wrapped object like so:

```ruby
def created_at
  article.created_at.strftime("%m/%d/%Y - %H:%M")
end
```

Then return the view template to just:

```ruby
<h4>Published <%= @article.created_at %></h4>
```

#### Comment Counter

Currently the show page uses the `pluralize` helper:

```ruby
  <h3><%= pluralize @article.comments.count, "Comment" %></h3>
```

That's a bit of logic we can rip out of the view template. Let's add a method
to the `ArticleDecorator`:

```ruby
def comments_count
  h.pluralize article.comments.count, "Comment"
end
```

Then in the view template:

```erb
<h3><%= @article.comments_count %></h3>
```

Notice how the `comments_count` method used `h`? That's the method Draper offers
to access all the built in Rails view helpers. Without it you'd be calling
`pluralize` on the decorator which isn't defined. With it, you get the same effect
as calling `pluralize` in your view template.

#### Dealing with a Collection

If you look in the `index.html.erb`, you'll see a similar `pluralize` line.
Can you just reuse the decorator method? Try calling the `.comments_count` method
and you won't get anywhere.

We need the article objects to be decorated in the `index` action of the controller.
Currently the `index` has:

```ruby
  def index
    @articles, @tag = Article.search_by_tag_name(params[:tag])
  end
```

Let's tweak it a bit to decorate the collection:

```ruby
  def index
    articles, @tag = Article.search_by_tag_name(params[:tag])
    @articles = ArticleDecorator.decorate_collection(articles)
  end
```

Now all elements of the collection are decorated and our index should display properly.

### Links

Delete links are a pain to write. Want your delete link to actually be an image? Double pain.

The `show.html.erb` is currently using a custom helper to generate the link with icon:

```erb
<%= delete_icon(@article, "Delete") %>
```

Which calls this helper in `IconsHelper`:

```ruby
  def delete_icon(object, link_text = nil)
    delete_icon_filename = 'cancel.png'
    link_to image_tag(delete_icon_filename) + " " + link_text,
            polymorphic_path(object),
            method: :delete,
            confirm: "Delete '#{object}'?"
  end
```

It works fine and wraps up some of the ugliness, but using the helper is a
procedural approach. The decorator allows us to be object-oriented.

#### Writing `ArticleDecorator#delete_icon`

To rework this helper, let's start by just copying & pasting the helper method into our decorator class:

```ruby
class ArticleDecorator
  #...

  def delete_icon(object, link_text = nil)
    delete_icon_filename = 'cancel.png'
    link_to image_tag(delete_icon_filename) + " " + link_text,
            polymorphic_path(object),
            method: :delete,
            confirm: "Delete '#{object}'?"
  end
end
```

It won't work as-is. We need to make some changes.

First, looking at the arguments, we don't need to pass in `object` anymore because
the decorator will already have the `article`.

Then all the Rails helpers (like `link_to` and `image_tag`) need to rely on the
`h` helper. The result looks like this:

```ruby
class ArticleDecorator
  #...

  def delete_icon(link_text = nil)
    delete_icon_filename = 'cancel.png'
    h.link_to h.image_tag(delete_icon_filename) + link_text,
              h.polymorphic_path(article),
              method: :delete,
              confirm: "Delete '#{article}'?"
  end
end
```

Note how `object` became `article` in the call to `polymorphic_path`.

#### In the Show Template

Originally, we used a normal helper method:

```erb
<%= delete_icon(@article, "Delete") %>
```

Now we can use the decorator method:

```erb
<%= @article.delete_icon("Delete") %>
```

Keeping it object-oriented is the Ruby way.

### Abstracting Decorators

In the conversion from Helper to Decorator in the last section, something was lost. The helper method worked on any object passed in, the decorator method belonged to the `ArticleDecorator`. We definitely don't want to re-implement this code in multiple decorators, so how can we make it shareable?

#### `ApplicationDecorator.rb`

A first approach is to make an `app/decorators/application_decorator.rb` and move the method in there:

```ruby
class ApplicationDecorator < Draper::Decorator
  def delete_icon(link_text = nil)
    delete_icon_filename = 'cancel.png'
    h.link_to h.image_tag(delete_icon_filename) + link_text,
              h.polymorphic_path(article),
              method: :delete,
              confirm: "Delete '#{article}'?"
  end
end
```

Then have the 'ArticleDecorator' inherit from 'ApplicationDecorator' (like `class ArticleDecorator < ApplicationDecorator`)
instead of `Draper::Decorator`.

It'll work for what we have so far, but if we try and use this from a `CommentDecorator`, it's going to blow up because of the call to `polymorphic_path(article)`.

Draper provides generic ways to access the wrapped object -- the `object` or `model` methods. Change `article` to `object` or `model` (they're aliases for one another) and we're good to go:

```ruby
class ApplicationDecorator
  def delete_icon(link_text = nil)
    delete_icon_filename = 'cancel.png'
    h.link_to h.image_tag(delete_icon_filename) + link_text,
              h.polymorphic_path(model),
              method: :delete,
              confirm: "Delete '#{model}'?"
  end
end
```

The downside to this inheritance approach is that every decorator in the system is going to have this method.
What if some decorators need a different style of delete icon?

#### The Module Approach

One of the limitations of normal custom helpers is that they all live in the same global name space. You can't have two different implementations of a `delete_icon` helper in `articles_helper` and `comments_helper`. But since decorators are objects, that's not an issue. We can use modules and mix them into the decorator classes.

For instance, we can create `app/decorators/icon_link_decorations.rb` and define this module:

```ruby
module IconLinkDecorations
  def delete_icon(link_text = nil)
    delete_icon_filename = 'cancel.png'
    h.link_to h.image_tag(delete_icon_filename) + link_text,
              h.polymorphic_path(model),
              method: :delete,
              confirm: "Delete '#{model}'?"
  end
end
```

Remove the similar code from the `ApplicationDecorator`, and `include` the module from the `ArticleDecorator`:

```ruby
class ArticleDecorator
  #...
  include IconLinkDecorations
end
```

Any other decorators that want to use that method can similarly include the module.

## Experiments

Now that you've got the basics down, try the following experiments on your own:

* Can you relocate `IconsHelper#edit_icon` like you did the `delete_icon`?
* In the `articles/index.html.erb` there's `<%= link_to article.title, article_path(article) %>`. Could you rework this into `<%= article.link %>`?
* Check out the `TagsHelper`. Can you rewrite any/all of these by creating a `TagDecorator`?

## Generating XML and JSON with Decorators

We usually need `to_json` and `to_xml` operations to present an API. They're often implemented in the model, but they really belong in the view layer because they're presentation concerns. The decorator pattern can help us clean up responsibilities.

### Proxying `to_json`

As a first step, implement a `to_json` method in the `ArticleDecorator` that just calls the `ActiveRecord` method. Add support in the controller to render this JSON out to the browser.

### Per-User Scoping

It would be great to scope the JSON based on the current user. We'd want admin users to see all the article attributes in the JSON, but public users would just get a subset.

This Blogger doesn't have authentication/authorization setup, so we'll fake it using a request parameter.

* Define two constants in the decorator:
  * `PUBLIC_ATTRIBUTES` as an array containing symbols for the `title`, `body`, and `created_at`
  * `ADMIN_ATTRIBUTES` as an array containing everything from `PUBLIC_ATTRIBUTES`, plus `updated_at`
* Manually add a parameter to your request URL with `admin=true`
* Write a `current_user_is_admin?` method in your `ApplicationHelper` which returns true if that parameter is set to `"true"`
* Call that helper method (using `h.current_user_is_admin?`) in your decorator.
  * When the user is an admin, show them the values specified by `ADMIN_ATTRIBUTES`
  * When the user is not an admin, show them only the values specified by `PUBLIC_ATTRIBUTES`

If you want to play more with marshalling, what would it be like to create descendents of your `ArticleDecorator` like `ArticleDecoratorXML` and `ArticleDecoratorJSON`? What functionality could you add which would allow the user to stay in the "duck typing" mindset, calling the same method on an instance of any of the three decorators but getting back HTML, XML, or JSON?
