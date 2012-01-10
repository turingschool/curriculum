---
layout: page
title: Experimenting with Decorators & Draper
---

Let's play around with the concept of decorators and check out some of the features offered by the Draper gem.

### Setup

First we need a sample project. I've setup a more advanced version of our JSBlogger project, a simple blog, that we can experiment with. To clone the sample project:

```plain
  git clone git://github.com/JumpstartLab/jsblogger_advanced/
```

Then change into the project directory.

### Install Draper

Next, open the `Gemfile` and add a dependency on `'draper'` like this:

```ruby
  gem 'draper'
```

Run `bundle`, then start up your server.

### Generate a Decorator

We'll create a decorator to wrap the `Article` model. Draper gives you a handy generator:

```plain
  rails generate draper:model Article
```

It will create the folder `app/decorators/` and the file `app/decorators/article_decorator.rb`. Open the file and you'll find the frame of a `ArticleDecorator` class.

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

Then go and view the show page for a single Article by clicking on its name on the index.

### Adding Methods

Now let's add some actual functionality to our decorator.

#### Article Published On

Currently the show page just displays the raw `created_at` attribute. Often we want to standardize date formatting across our application, and the decorator makes this easy.

Let's override the `created_at` method in our decorator:

```ruby
  def created_at
    article.created_at.strftime("%m/%d/%y - %H:%M")
  end
```

Since the decorator knows that it is decorating an instance of `Article`, it dynamically generates a method named `article` which returns the wrapped object. Here, calling `article.created_at` gets us the value from the original database model.

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

We need the article objects are decorated in the controller. In your `index` action you have:

```ruby
  def index
    @articles, @tag = Article.search(params)
  end
```

Let's tweak it a bit to decorate the collection:

```ruby
  def index
    articles, @tag = Article.search(params)
    @articles = ArticleDecorator.decorate(@articles)
  end
```

Now all elements of the collection are decorated and our index should work properly.

The original Demeter violation is *still there*, but it's now it can be cleaned in just one spot -- by adding a counter cache column to the `articles` table.


### Using Allows

When we define an interface we want to be able to exclude or include specific accessors. With Draper decorators, we can do this with `denies` and `allows`. The `allows` is more common, so let's try it.

In your browser, load the `show` page for an article. In the decorator, add this:

```
allows :title
```

Then refresh the page. It should blow up.

Allows is modeled after `attr_accessible` in Rails. If your decorator calls `allows`, then all methods _not_ listed are denied. This is a whitelist approach.

#### Allowing More Methods

So far you're only allowing `:title`, so you'll get exceptions as the other accessors try to pull out data. Add the needed methods to `allows`, separated by commas. Make sure you include `to_param` so your links will work properly.

Note that if you don't use `allow` at all, everything is permitted.

### Links

I hate writing delete links. In the `show.html.erb`, I'm using a helper to generate the link with icon:

```erb
<%= delete_icon(@article, " Delete") %>
```

Which calls this helper in `IconsHelper`: 

```ruby
  def delete_icon(object, link_text = nil)
    delete_icon_filename = 'cancel.png'
    link_to image_tag(delete_icon_filename) + link_text,
            polymorphic_path(object),
            :method => :delete,
            :confirm => "Delete '#{object}'?"
  end
```

It works fine and wraps up some of the ugliness, but using the helper is a procedural approach. The decorator allows us to take an object-oriented approach.

#### Writing the Decorator Method

To rework this helper, let's start by just dropping it into the decorator class

```ruby
class ArticleDecorator
  #...

  def delete_icon(object, link_text = nil)
    delete_icon_filename = 'cancel.png'
    link_to image_tag(delete_icon_filename) + link_text,
            polymorphic_path(object),
            :method => :delete,
            :confirm => "Delete '#{object}'?"
  end
end
```

We don't need to pass in the `object` parameter because the decorator will already know its `article`. We can write this:

```ruby
class ArticleDecorator
  #...

  def delete_icon(link_text = nil)
    delete_icon_filename = 'cancel.png'
    link_to image_tag(delete_icon_filename) + link_text,
            polymorphic_path(article),
            :method => :delete,
            :confirm => "Delete '#{article}'?"
  end
end
```

Note how `object` became `article`.

#### In the Show Template

Originally, we used a procedural-style helper method:

```erb
<%= delete_icon(@article, " Delete") %>
```

Now we can use the decorator method:

```erb
<%= @article.delete_icon(" Delete") %>
```

Cool? Pointless? You be the judge.

### Abstracting Decorators

In the conversion from Helper to Decorator in the last section, something was lost. The helper method worked on any object passed in, the decorator method belonged to the `ArticleDecorator`. We definitely don't want to re-implement this code in multiple decorators, so how can we make it shareable?

#### `ApplicationDecorator.rb`

Approach one is to open `app/decorators/application_decorator.rb` and move the method in there:

```ruby
class ApplicationDecorator
  def delete_icon(link_text = nil)
    delete_icon_filename = 'cancel.png'
    link_to image_tag(delete_icon_filename) + link_text,
            polymorphic_path(article),
            :method => :delete,
            :confirm => "Delete '#{article}'?"
  end
end
```

It'll work for what we have so far, but if we try and use this from a `CommentDecorator`, it's going to blow up because of the call to `article`.

Draper provides a generic way to access the wrapped object -- the `model` method. Just change `article` to `model` and we're good to go:

```ruby
class ApplicationDecorator
  def delete_icon(link_text = nil)
    delete_icon_filename = 'cancel.png'
    link_to image_tag(delete_icon_filename) + link_text,
            polymorphic_path(model),
            :method => :delete,
            :confirm => "Delete '#{model}'?"
  end
end
```

The main downside to this approach is that every decorator in the system is going to have this method. What if some decorators need a different style of delete icon?

#### The Module Approach

One of the limitations of helpers is that they all live in the same name space. You can't have two different implementations of a `delete_icon` helper.

But since decorators are objects, that's not an issue. We can use modules and mix them into the decorator classes.

For instance, we can create an `app/decorators/icon_decorations.rb` and define this module:

```ruby
module IconLinkDecorations
  def delete_icon(link_text = nil)
    delete_icon_filename = 'cancel.png'
    link_to image_tag(delete_icon_filename) + link_text,
            polymorphic_path(model),
            :method => :delete,
            :confirm => "Delete '#{model}'?"
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

#### Now, Play!

Here are some other things you can try:

* Define a `to_xml` or `to_json` in the decorator and use `respond_with` to serve them up
* Try calling `ArticleDecorator.decorate(sources)` to create an array of decorated objects from an array of source objects, then use experiment with the `index`
* Try defining a format attribute on your decorator (so it'd hold a value like `:xml` or `:json`), set it when creating the decorator instance, then in your methods react to that attribute to output formatted data. (_ASIDE:_ Is this a good idea? It'd probably be better to define a parent decorator like `ArticleDecorator`, then create subclasses `ArticleDecoratorXML` and `ArticleDecoratorJSON`.)

### Where We Go from Here

The decorator pattern is ready to start replacing your helpers and defining an interface between view template and data. What's next?

The next challenge is to provide access to traditional user-defined helpers from within the decorator. For instance, to do proper data shaping based on authorization, we would want to call `current_user` from within the decorator. ActiveView provides a way to proxy the built in helpers, but there isn't one for user defined helpers. There's a tricky hack to do it that we'll likely implement soon.

Respected friend Xavier Shay posts his solution here: https://gist.github.com/1077274

From there, it's time for some real-world usage. I'd love your help testing this out with experimental code. Please don't use it in a Articleion system until it hits 1.0!