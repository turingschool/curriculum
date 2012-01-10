---
layout: page
title: Facade Patter with POROs
section: Models
---

As projects grow in size the models tend to grow in complexity. Let's look at a few strategies for managing the situation.

## Background

The core issue is that `ActiveRecord` classes mix two roles: persistence and business logic. This is convenient, especially when first starting an application, but it violates the "Single Responsibility Principle."

As a project matures there becomes a clearer division between these roles, and breaking them up into distinct domain objects is often a good idea.

## Creating a Facade Object

A facade or processor object is concerned only with manipulating the data from other objects, it has no persistence itself. [See the Facade Pattern on Wikipedia](http://en.wikipedia.org/wiki/Facade_pattern).

Writing a facade is very easy:

```ruby
class MyFacade
end
```

It's just a "PORO" or "Plain Old Ruby Object".

### Where Does It Live?

You can store your facade objects into `app/models`. Some developers prefer more separation and store them in `app/lib`. Any folder added under `app/` will be added to the automatic load path when the server starts, so create folders whenever they make sense for the organization of your project. 

## Practical Techniques

A facade object will primarily use the same Ruby techniques you're accustomed to, but here are a few methods that will make life easier:

### `attr_reader`

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

So you're creating an attribute that, from outside the instance, can only be read. If you wanted to allow write access you'd use `attr_accessor`, though that's probably violating the encapsulation of the child objects.

If you are creating multiple attributes you can combine them in one call to `attr_reader` like this:

```ruby
attr_reader :first_attribute, :second_attribute
```

### `delegate`

The `delegate` method helps us deal with Law of Demeter violations.

#### Law of Demeter

The [Law of Demeter](http://en.wikipedia.org/wiki/Law_of_Demeter) says, generally speaking, that we can talk to an object but shouldn't talk directly to the object's children. 

For instance, imagine we have a `Plane` instance in `@plane`. We want the engines started. The temptation is to write something like this:

```ruby
@plane.engines.each{|e| e.start}
```

But that assumes knowledge of how `@plane` relates to its engines. What if there's only a single engine? Will there still be an `engines` method that returns a collection, or will there only be `engine`? We're breaking the encapsulation of the plane class. 

Instead, proper object oriented design would be to *tell* the plane what to do:

```ruby
@plane.start_engines
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

If you have multiple child objects with many methods, writing and maintaining these proxy methods will be a pain. Instead, use `delegate`:

```ruby
class MyObject
  attr_reader :child
  delegate :the_method, :to => child
end
```

This has the exact same effect as the wrapper above. You can delegate many methods at once:

```ruby
class MyObject
  attr_reader :child
  delegate :the_method, :second_method, :third_method, :to => child
end
```

Now you can preserve encapsulation but have easily maintained facade.

## Trying it Out

Get the JSBlogger project from Github:

```plain
git clone git://github.com/JumpstartLab/jsblogger_advanced.git
```

Start the server, and visit the root page. This is the `DashboardController#index` which we'll use to illustrate a facade.

### Why Use a Facade

The dashboard is going to mix instances of `Article` and `Comment`. Check out the `show` action in `DashboardsController`:

```ruby
  def show
    @articles = Article.for_dashboard
    @article_count = Article.count
    @article_word_count = Article.total_word_count

    @comments = Comment.for_dashboard
    @comment_count = Comment.count
    @comment_word_count = Comment.total_word_count
  end
```

Even though we're using scopes and model methods, there's a lot going on here. There are six different instance variables that we have to juggle in the view template.

The intent of the dashboard is to display three things:

* Recent articles
* Recent comments
* Metrics about the total articles and comments

Three concepts should be three objects, not six. Let's create a domain concept which fulfills the third idea.

### Starting the Facade

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
    @comments = Comment.for_dashboard
    @comment_count = Comment.count
    @dashboard = Dashboard.new
  end
```

Then modify the view template to use `@dashboard.total_article_word_count` and `@dashboard.total_comment_word_count`.

#### And Your Point Is?

One surface win is that we've eliminated an instance variable.

The real win is we've encapsulated the concept of word counts. Now our controller doesn't care where the `Dashboard` gets the counts from. Our current implementation is to calculate them on the fly, but there's no reason it couldn't fetch that from Redis or somewhere else. We can make that decision later when the performance really matters.

And by getting the responsibility out of the controller we can, more cleanly, test the functionality in our unit tests.

# Revision Marker

### Delegations

From there we could expose child attributes:

```ruby
class StudentReport
  attr_reader :student, :term, :report_type
  delegate :first_name, :last_name, :to => :student
  delegate :title, :subtitle, :to => :report_type
  delegate :start_date, :end_date, :to => :term
end
```

And from the outside they can be accessed, preserving encapsulation, like `student_report.first_name` or `student_report.start_date`.

### Computations

Then the facade can do work with the child objects:

```ruby
class StudentReport
  # ... attr_reader and delegate calls
  
  def gpa
    course_grades = student.course_grades_for(term)
    course_grades.sum.to_f / course_grades.size
  end
end
```

## Exercises

{% include custom/sample_project.html %}

We have both `Article` and `Comment` models. Let's imagine that we want to start running some statistics on them. For instance, we want to know how many total words are in the articles and its child comments.

1. Implement a `Thread` processor object that wraps both an article and the set of comments.
2. Implement a `word_count` method that calculates the total word count of the article and all comments.
3. Proxy the `title` method so when it is called on an instance of `Thread` it returns the title of the article.
4. Create a `commentors` method that fetches all the comment authors.
5. Create a `last_updated` method that returns the most recent change to the thread, either a change to the article or to a comment.