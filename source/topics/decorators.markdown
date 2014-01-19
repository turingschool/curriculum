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

But we can simplify that common pattern. If we call the `decorates_finders` method in `ArticleDecorator` like following: 

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

Now let's add some actual functionality to our decorator.

#### Article Published On

Currently the show page just displays the raw `created_at` attribute. Often we want to standardize date formatting across our application, and the decorator makes this easy.

Let's override the `created_at` method in our decorator:

```ruby
  def formatted_created_at
    object.created_at.strftime("%m/%d/%Y - %H:%M")
  end
```

Since the decorator knows that it is decorating an instance of `Article`, it dynamically generates a method named `article` which returns the wrapped object. Here, calling `article.created_at` gets us the value from the original database model.

Now in the show.html.erb for the show view of Article you need to change the following line:

```ruby
<h4>Published <%= @article.created_at %></h4>
```

to:

```ruby
<h4>Published <%= @article.formatted_created_at %></h4>
```

Refresh the `show` in your browser and the date will be reformatted.

#### Comment Counter

Currently the show page uses the `pluralize` helper:

```ruby
  <h3><%= pluralize @article.comments.count, "Comment" %></h3>
```

That's a Law of Demeter violation right away, and it isn't setup for future internationalization. We can pull the functionality into the decorator by adding a method:

```ruby
def comments_count
  h.pluralize article.comments.count, "Comment"
end
```

Then in the view template:

```erb
  <h3><%= @article.comments_count %><h3>
```

#### Dealing with a Collection

If you look in the `index.html.erb`, you'll see a similar `pluralize` line. Can you just reuse the decorator method? Try calling the `.comments_count` method.

We need the article objects to be decorated in the controller. In your `index` action you have:

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

Now all elements of the collection are decorated and our index should work properly.

The original Demeter violation is *still there*, but now it can be cleaned in just one spot -- by adding a counter cache column to the `articles` table and accessing the cache in the decorator.

### Links

I hate writing delete links. In the `show.html.erb`, I'm using a helper to generate the link with icon:

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

It works fine and wraps up some of the ugliness, but using the helper is a procedural approach. The decorator allows us to be object-oriented.

#### Writing the Decorator Method

To rework this helper, let's start by just dropping the helper method into our decorator class

```ruby
class ArticleDecorator
  #...

  def delete_icon(object, link_text = nil)
    delete_icon_filename = 'cancel.png'
    h.link_to h.image_tag(delete_icon_filename) + link_text,
              h.polymorphic_path(object),
              method: :delete,
              confirm: "Delete '#{object}'?"
  end
end
```

We don't need to pass in the `object` parameter because the decorator will already know it's `article`. We can write this:

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

Note how `object` became `article`.

#### In the Show Template

Originally, we used a procedural-style helper method:

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

Approach one is to make an `app/decorators/application_decorator.rb` and move the method in there:

```ruby
class ApplicationDecorator
  def delete_icon(link_text = nil)
    delete_icon_filename = 'cancel.png'
    h.link_to h.image_tag(delete_icon_filename) + link_text,
              h.polymorphic_path(article),
              method: :delete,
              confirm: "Delete '#{article}'?"
  end
end
```

You'll also need to make your ArticleDecorator inherit from ApplicationDecorator.

It'll work for what we have so far, but if we try and use this from a `CommentDecorator`, it's going to blow up because of the call to `article`.

Draper provides a generic way to access the wrapped object -- the `object` or `model` method. Just change `article` to `object` or `model` and we're good to go:

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

The main downside to this approach is that every decorator in the system is going to have this method. What if some decorators need a different style of delete icon?

#### The Module Approach

One of the limitations of helpers is that they all live in the same name space. You can't have two different implementations of a `delete_icon` helper.

But since decorators are objects, that's not an issue. We can use modules and mix them into the decorator classes.

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

### Now, Play!

Those are the fundamental ideas, now you should try things on your own. Here are a few ideas:

#### More Links

Steve Klabnik wrote an example of implementing HATEOAS in his article here: http://blog.steveklabnik.com/posts/2012-01-06-implementing-hateoas-with-presenters

The resulting HTML looks like this:

```html
<h2>Links</h2>
<ul>
    <li><a href="http://localhost:3000/posts/1" rel="self">This post</a></li>
    <li><a href="http://localhost:3000/posts" rel="index">All posts</a></li>
</ul>
```

Going a step further than Steve's approach:

* Implement an `.index_link` presenter method that outputs the HTML link with the `REL` attribute set to `"index"`
* Implement a `.link` presenter method that outputs a link to the article, but sets the `REL` to `"self"` if the app is currently on that article's show page. If it's called from the index page, make the `REL` `"article_1"` with the correct ID
* Can you abstract this into a `module` such that it could be included in a `CommentPresenter` and work for both? Try it.

#### Controlling Marshalling

We usually need `to_json` and `to_xml` operations to present an API. They're often implemented in the model, but they really belong in the view layer. The decorator pattern can make it clean.

* Implement a `to_json` method in the decorator that just calls the `ActiveRecord` method

Beyond that, it would be great to scope the JSON based on the current user. Since we don't have an authentication/authorization setup, we'll fake it using a request parameter.

* Define two constants:
  * `PUBLIC_ATTRIBUTES` as an array containing symbols for the `title`, `body`, and `created_at`
  * `ADMIN_ATTRIBUTES` as an array containing everything from `PUBLIC_ATTRIBUTES`, plus `updated_at`
* Manually add a parameter to your request URL with `admin=true`
* Write a `current_user_is_admin?` method in your `ApplicationHelper` which returns true if that parameter is set to `"true"`
* Call that helper method (using `h.current_user_is_admin?`) in your decorator.
  * When the user is an admin, show them the values specified by `ADMIN_ATTRIBUTES`
  * When the user is not an admin, show them only the values specified by `PUBLIC_ATTRIBUTES`

If you want to play more with marshalling, what would it be like to create descendents of your `ArticleDecorator` like `ArticleDecoratorXML` and `ArticleDecoratorJSON`? What functionality could you add which would allow the user to stay in the "duck typing" mindset, calling the same method on an instance of any of the three decorators but getting back HTML, XML, or JSON?

### Moving Forward with Decorators

The concept of Draper is still young. Please try it out on your projects and give us feedback at https://github.com/jcasimir/draper. Thanks!
