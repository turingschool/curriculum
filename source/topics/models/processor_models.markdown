---
layout: page
title: Processor Model Design Pattern
section: Models
---

As projects grow in size the models tend to grow in complexity. Let's look at a few strategies for managing the situation.

## Background

The core issue is that `ActiveRecord` classes mix two roles: persistence and business logic. This is convenient, especially when first starting an application, but it violates the "Single Responsibility Principle."

As a project matures there becomes a clearer division between these roles, and breaking them up into distinct domain objects is often a good idea.

## Creating a Processor Object

A processor object is concerned only with manipulating the data from other objects, it has no persistence itself. It might be an implementation of the [Facade Pattern](http://en.wikipedia.org/wiki/Facade_pattern) or even a kind of [Decorator Pattern](http://en.wikipedia.org/wiki/Decorator_pattern).

Writing a processor is very easy:

```ruby
class MyProcessor
  def initialize(thing, stuff)
    @thing = thing
    @stuff = stuff
  end
end
```

It's just a "PORO" or "Plain Old Ruby Object".

### Where Does It Live?

You can store your processor objects into `app/models`, but if you'd like a little more separation it's common to create `app/lib` and store them in there. Any folder added under `app/` will be added to the automatic load path when the server starts, so create folders whenever they make sense for the organization of your project.

## Practical Techniques

A processor object will primarily use the same Ruby techniques you're accustomed to, but here are a few methods that will make life easier:

### `attr_reader`

`attr_reader`, short for "Attribute Reader", creates an instance variable and accessor method for you:

```ruby
class MyClass
  attr_reader :my_attribute

  # That's the same as doing this...

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

How does this relate to processor objects? When you create a facade, you'll often want to act on attributes and methods of the child objects. Don't do this:

```ruby
@my_object.child.the_method
```

Instead:

```ruby
@my_object.the_method
```

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
  delegate :the_method, to: child
end
```

This has the exact same effect as the wrapper above. You can delegate many methods at once:

```ruby
class MyObject
  attr_reader :child
  delegate :the_method, :second_method, :third_method, to: child
end
```

Now you can preserve encapsulation but have easily maintained proxies.

## Example Usage

Imagine we're writing a reporting system for a school. We want to follow a REST pattern, and our top-down design says that we should access a `Report` resource. We'll calculate the data on the fly, so it isn't necessary to store anything about the report in the database. So we start the `Report` class like this:

```ruby
class StudentReport
end
```

### Child Objects

The report is going to mix an instance of `Student`, `Term`, and `ReportType`:

```ruby
class StudentReport
  attr_reader :student, :term, :report_type
end
```

That will setup `@student`, `@term`, and `@report_type` instance variables as well as the similarly named accessor methods.

### Delegations

From there we could expose child attributes:

```ruby
class StudentReport
  attr_reader :student, :term, :report_type
  delegate :first_name, :last_name, to: :student
  delegate :title, :subtitle, to: :report_type
  delegate :start_date, :end_date, to: :term
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

1. Implement a `ContentThread` processor object that wraps both an article and the set of comments.
2. Implement a `word_count` method that calculates the total word count of the article and all comments.
3. Proxy the `title` method so when it is called on an instance of `ContentThread` it returns the title of the article.
4. Create a `commentors` method that fetches all the comment authors.
5. Create a `last_updated` method that returns the most recent change to the thread, either a change to the article or to a comment.
