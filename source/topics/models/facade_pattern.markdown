---
layout: page
title: Facade Pattern with POROs
section: Models
---

As projects grow in size the models tend to grow in complexity. Let's look at a few strategies for managing the situation.

### Background

The core issue is that `ActiveRecord` classes mix two roles: persistence and business logic. This is convenient, especially when first starting an application, but it violates the "Single Responsibility Principle."

<div class="note">
  <p>
    <i>From Wikipedia:</i><br/>
    In object-oriented programming, the single responsibility principle states that every object should have a single responsibility, and that responsibility should be entirely encapsulated by the class. All its services should be narrowly aligned with that responsibility. A class or module should have one, and only one, reason to change. 
  </p>
</div>

As a project matures there becomes a clearer division between these roles, and breaking them up into distinct domain objects is often a good idea.

### Creating a Facade Object

A facade is concerned only with manipulating the data from other objects, it has no persistence itself. [See the Facade Pattern on Wikipedia](http://en.wikipedia.org/wiki/Facade_pattern).

Writing a facade is very easy:

```ruby
class MyFacade
end
```

It's just a "PORO" or "Plain Old Ruby Object".

#### Where Does It Live?

You can store your facade objects into `app/models`. Some developers prefer more separation and store them in `app/lib`. Any folder added under `app/` will be added to the automatic load path when the server starts, so create folders whenever they make sense for the organization of your project. 

### Practical Techniques

A facade object will primarily use the same Ruby techniques you're accustomed to, but here are a few methods that will make life easier:

#### `attr_reader`

`attr_reader`, short for "Attribute Reader", creates an instance variable and accessor method for you:

```ruby
class MyClass
  attr_reader :my_attribute
  
  # That's the same as doing this...
  
  @my_attribute = nil
  
  def my_attribute
    @my_attribute
  end
end
```

You're creating an attribute that, from outside the instance, can only be read. If you wanted to allow write access you'd use `attr_accessor`, though that's probably violating the encapsulation of the child objects.

If you are creating multiple attributes you can combine them in one call to `attr_reader` like this:

```ruby
attr_reader :first_attribute, :second_attribute
```

#### `delegate` & Law of Demeter

The `delegate` method helps us deal with Law of Demeter violations.

The [Law of Demeter](http://en.wikipedia.org/wiki/Law_of_Demeter) says, generally speaking, that we can talk to an object but shouldn't talk directly to the object's children. 

For instance, imagine we have a `Plane` instance in `@plane`. We want the engines started. The temptation is to write something like this:

```ruby
@plane.engines.each{|e| e.start}
```

But that assumes knowledge of how `@plane` relates to its engines. What if there's only a single engine? Will there still be an `engines` method that returns a collection, or will there only be `engine`? We're breaking the encapsulation of the plane class. 

Instead, proper object oriented design would be to *tell* the plane what to do:

```ruby
@plane.start
```

That leaves it up to the `@plane` to decide what it means to start the engines.

#### Demeter in your Facade

How does this relate to facade objects? When you create a facade, you'll often want to act on attributes and methods of the child objects. Don't do this:

```ruby
@my_object.child.the_method
```

Instead:

```ruby
@my_object.the_method
```

That's why it's called a facade, we present a unified face to the outside world, hiding the components underneath.

#### Using `delegate`

How do you make that work? Here's the simplistic approach:

```ruby
class MyObject
  attr_reader :child
  
  def the_method
    child.the_method
  end
end
```

If you have multiple child objects with many methods, writing and maintaining these proxy methods will be a pain. Instead, use `delegate` like this:

```ruby
class MyObject
  attr_reader :child
  delegate :the_method, :to => :child
end
```

This has the exact same effect as the wrapper above. You can delegate many methods at once:

```ruby
class MyObject
  attr_reader :child
  delegate :the_method, :second_method, :third_method, :to => :child
end
```

But sometimes the child method names don't make sense when called on the parent. Or they could conflict with identically named methods in the parent. In those cases, you can use the `:prefix` option:

```ruby
class MyObject
  attr_reader :child
  delegate :the_method, :second_method, :third_method, :to => :child, :prefix => :child
end
```

Then method calls would look like `my_obj_instance.child_second_method` as a proxy to `my_obj_instance.child.second_method`. If you want to prefix with the name of the receiver, you can use `:prefix => true` instead of repeating the receiver name.

Now you can preserve encapsulation but have easily maintained facade.

### Trying it Out

{% include custom/sample_project_advanced.html %}

Start the server, and visit the root page. This is the `DashboardController#index` which we'll use to illustrate a facade.

#### Why Use a Facade

The dashboard is going to mix instances of `Article` and `Comment`. Check out the `show` action in `DashboardsController`:

```ruby
  def show
    @articles = Article.for_dashboard
    @article_count = Article.count
    @article_word_count = Article.total_word_count
    @most_popular_article = Article.most_popular

    @comments = Comment.for_dashboard
    @comment_count = Comment.count
    @comment_word_count = Comment.total_word_count
  end
```

Even though we're using scopes and model methods, there's a lot going on here. There are seven different instance variables that we have to juggle in the view template.

The intent of the dashboard is to display three things:

* Recent articles
* Recent comments
* Metrics about the total articles and comments

Three concepts should be three objects, maybe even one, but definitely not seven. Let's create a domain concept which supports the third intent.

#### Starting the Facade

Create a file `app/models/dashboard.rb` and add this:

```ruby
class Dashboard

end
```

Then let's start picking off functionality from the existing implementation.

#### Total Word Counts

Add a method to the facade to count the words in all the articles:

```ruby
  def total_article_word_count
    Article.total_word_count
  end
```

Then do the same for comments.

#### Use the Facade

In the controller action, instead of this:

```ruby
  def show
    @articles = Article.for_dashboard
    @article_count = Article.count
    @article_word_count = Article.total_word_count
    @most_popular_article = Article.most_popular

    @comments = Comment.for_dashboard
    @comment_count = Comment.count
    @comment_word_count = Comment.total_word_count
  end
```

We can now do this:

```ruby
  def show
    @articles = Article.for_dashboard
    @article_count = Article.count
    @article_word_count = Dashboard.new.total_article_word_count
    @most_popular_article = Article.most_popular    

    @comments = Comment.for_dashboard
    @comment_count = Comment.count
    @comment_word_count = Dashboard.new.total_comment_word_count
  end
```

No improvement yet. Condense those into one object creation instead:

```ruby
  def show
    @articles = Article.for_dashboard
    @article_count = Article.count
    @most_popular_article = Article.most_popular
    @comments = Comment.for_dashboard
    @comment_count = Comment.count
    @dashboard = Dashboard.new
  end
```

Then modify the view template to use `@dashboard.total_article_word_count` and `@dashboard.total_comment_word_count` instead of the former instance variables.

#### And Your Point Is?

One surface win is that we have one fewer instance variable.

The *real* win is encapsulating the concept of word counts. Now our controller doesn't care where the `Dashboard` gets the counts from. Our current implementation is to calculate them on the fly, but there's no reason it couldn't fetch that from the database, Redis, or elsewhere. We can make that decision later when the performance really matters.

And by getting the responsibility out of the controller we can, more cleanly, test the functionality in our unit tests.

#### Continue the Process

Write wrapper methods in the `dashboard.rb` and refactor your controller/view until your controller is just this:

```ruby
class DashboardController < ApplicationController
  def show
    @dashboard = Dashboard.new
  end
end
```

#### Calculation in the Facade

After that refactoring, I still have this in the view template:

```erb
<li id='total_words'>
  Total Words: 
  <%= @dashboard.total_article_word_count + 
  @dashboard.total_comment_word_count %>
</li>
```

That's logic in the view template, which is never good. Instead, take care of the calculation down in the facade so the view template can look like this:

```erb
    <li id='total_words'>Total Words: <%= @dashboard.total_word_count %></li>
```

By pushing that down into the model layer, it's easier to refactor and test. Without the facade, where would the method have lived? It wouldn't have a logical home, since it belongs to neither `Article` nor `Comment`. The `Dashboard` works as a domain concept.

#### Pulling Up From the Children

The `Article` class has this method:

```ruby
  def self.for_dashboard
    order('created_at DESC').limit(5)
  end
```

What does that method have to do with `Article`? Little. It is conceptually a part of the `Dashboard`. Move it there, then do the same for `Comment`.

Even though the page works, some specs are now breaking due to the refactoring. Create a `dashboard_spec.rb`, move the problem specs over there, and rework them to match the new structures.

### Going Further

Now that you have a facade encapsulating all the logic, some things you might try:

* Create a decorator for the facade and reduce complexity in your view template
* Cache the calculated data into a key-value store like Redis
