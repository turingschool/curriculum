---
layout: page
title: Driving the Domain Model Using TDD and Minitest
sidebar: true
---

Every developer has more ideas than time. As David Allen likes to say "the human brain is for creating ideas, not remembering them." Let’s build a system to record your good, bad, and awful ideas - IdeaBox.

## Learning Goals

### Before You Begin

The tutorial assumes that you:

* are comfortable with basic Ruby syntax
* have likely run tests before
* are new to writing tests
* are new to the TDD workflow

### After The Tutorial

Once you've completed the tutorial you will be able to:

* design and implement tests using Minitest
* read error and failure messages to guide your implementation
* follow the TDD workflow
* perform refactoring while keeping tests green

## I0: Getting Started

### Environment Setup

For this project you need to have setup:

* Ruby 2.1
* Ruby's Bundler gem

### File/Folder Structure

Let's start our project with the minimum and build up from there. We need:

* a project folder
* a `Gemfile`
* a `lib/ideabox` directory
* a `test/ideabox` directory

### The `Gemfile`

This tutorial will show how the design can be driven using `Minitest`. There's a
version of Minitest included in Ruby, but it's outdated. Let's instead use the
Minitest gem by specifying it in the `Gemfile` like this:

```ruby
source 'https://rubygems.org'

group :test do
  gem 'minitest'
end
```

Save that and, from your project directory, run `bundle` to install the dependencies.

### Minitest vs. RSpec

Minitest is a "small and incredibly fast unit testing framework". Minitest is written using Ruby and reads like Ruby.

You might be familiar with another testing framework, RSpec, and wondering why we are using Minitest here instead. In a way, RSpec is its own language. While it is very popular and powerful, it also does a lot of 'magic' behind the scenes and has a lot more 'content' to it. You can think of Minitest vs. RSpec a little bit like Sinatra vs. Rails.

In testing, and in development, it's all about picking the right tool for the job. Since our IdeaBox application is going to start small, Minitest feels like a natural fit.

## I1: Defining Ideas

### Writing the First Test

We are going to use tests to drive us to create a simple ruby object that takes a title and a description.

#### Creating `test/ideabox`

If you haven't already, create a directory named `test`:

{% terminal %}
$ mkdir test
{% endterminal %}

Within the `test` directory, create another directory named `ideabox`, which is where we will put the model tests:

{% terminal %}
$ mkdir test/ideabox
{% endterminal %}

#### Starting `idea_test.rb`

Then in that folder create a file `test/ideabox/idea_test.rb`

```ruby
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/ideabox/idea'

class IdeaTest < Minitest::Test
  def test_basic_idea
    idea = Idea.new("title", "description")
    assert_equal "title", idea.title
    assert_equal "description", idea.description
  end
end
```

### Making the First Test Pass

Run the test with `ruby test/ideabox/idea_test.rb`.

The error message says:

{% terminal %}
cannot load such file -- ./lib/ideabox/idea (LoadError)
{% endterminal %}

_Note: You might see an error like `No such file or directory` - if so, make sure that you are running your test from the main directory of your app. You will want to always work from that main directory_

That makes sense, since we haven't created the `idea` file that we're trying to test. Do that now:

{% terminal %}
mkdir -p lib/ideabox
touch lib/ideabox/idea.rb
{% endterminal %}

Run the test again.

#### Starting `Idea`

You should get the following message:

{% terminal %}
  1) Error:
IdeaTest#test_basic_idea:
NameError: uninitialized constant IdeaTest::Idea
    test/ideabox/idea_test.rb:8:in `test_basic_idea'
{% endterminal %}

Both error messages essentially say the same thing: A constant `Idea` is being referenced, and the test doesn't know about it.

We need to create a class named `Idea` in the `lib/ideabox/idea.rb` file.

```ruby
class Idea
end
```

Then run the test again.

#### Defining `initialize`

The next error says that we're calling the `initialize` method incorrectly:

{% terminal %}
  1) Error:
IdeaTest#test_basic_idea:
ArgumentError: wrong number of arguments(2 for 0)
    test/ideabox/idea_test.rb:8:in `initialize'
    test/ideabox/idea_test.rb:8:in `new'
    test/ideabox/idea_test.rb:8:in `test_basic_idea'
{% endterminal %}

Notice that Minitest makes a distinction between failures and errors.

In Minitest an error means that the Ruby code is wrong somehow. There might be a syntax error, or we're calling a method that doesn't exist, or calling a method that *does* exist, but we're doing it incorrectly. A failure, on the other hand means that the code is running, but not doing what we expected.

Minitest is complaining about an `ArgumentError`. According to the test we wrote, an `Idea` should take two arguments:

```ruby
Idea.new("a title", "a detailed and riveting description")
```

However, the Idea class as it is currently defined has only the default initialize method, which takes no arguments. We need to override it with the following code:

```ruby
class Idea
  def initialize(title, description)
  end
end
```

Run the tests again.

#### Accessing `title`

We're still getting an error:

{% terminal %}
  1) Error:
IdeaTest#test_basic_idea:
NoMethodError: undefined method `title' for #&lt;Idea:0x007fec0516de80&gt;
    test/ideabox/idea_test.rb:9:in `test_basic_idea'
{% endterminal %}

The important bit is the same in both:

```plain
NoMethodError: undefined method `title' for #&lt;Idea:0x007fec0516de80&gt;
```

We can define a method `title` using `attr_reader`:

```ruby
class Idea
  attr_reader :title
  def initialize(title, description)
  end
end
```

Then run the test again.

#### Storing the `title`

Finally, Minitest is complaining about a failure rather than an error:

{% terminal %}
  1) Failure:
IdeaTest#test_basic_idea [test/ideabox/idea_test.rb:9]:
Expected: "title"
  Actual: nil
{% endterminal %}

Make the expectation pass by assigning the `title` argument to an instance variable:

```ruby
class Idea
  attr_reader :title
  def initialize(title, description)
    @title = title
  end
end
```

Run the test and you'll find it passes the first assertion, but blows up on
the second.

#### Defining & Storing `description`

You'll see

{% terminal %}
NoMethodError: undefined method `description' for #&lt;Idea:0x007f89532b1900 @title="title"&gt;
{% endterminal %}

Add an `attr_reader` for `description` and store the value coming into the `initialize`.

Run the test and it should finally pass!

## I2: Implementing Likes

Some ideas are better than others. Let's build in functionality to handle
ranking the ideas against each other based on the number of *likes*.

### Testing `like!`

Let's decide that instances of our `Idea` class will have a `like!` method.
When that method is called, the number of likes is incremented.

#### Writing the Test

Add a new test inside of the `IdeaTest` class in your test file which checks
that a new test has zero likes, but once we call `like!` then it has one like.

```ruby
def test_ideas_can_be_liked
  idea = Idea.new("diet", "carrots and cucumbers")
  assert_equal 0, idea.likes
  idea.like!
  assert_equal 1, idea.likes
end
```

Run the test and you'll get an error.

#### Defining `likes`

The test gives us an error:

{% terminal %}
NoMethodError: undefined method `likes' for #&lt;Idea:0x007fd15b3fa460&gt;
{% endterminal %}

Add an `attr_reader` for `likes` to get past this error, then re-run the test.

#### Starting at Zero

You'll see:

{% terminal %}
Expected: 0
  Actual: nil
{% endterminal %}

The first assertion said `assert_equal 0, idea.likes`, meaning that an idea
should start with zero likes. But the test is getting `nil` as the value from
`likes`.

To give `likes` a reasonable default, assign an instance variable in the
`initialize` method with a value of 0. Then run the test.

#### What's `like!`?

This gets the first assertion passing but there's a new error:

{% terminal %}
NoMethodError: undefined method `like!' for #&lt;Idea:0x007fa14bb4c7d0&gt;
{% endterminal %}

Add a `like!` method that sets the value stored in the instance variable
used by the `likes` method to `1`.

Run the test and it passes.

#### More `likes!`

Our implementation isn't that great. No matter how many times we call `like!`
the rank will still be `1`. We could just fix the implementation, but that
wouldn't be test-driven development.

Let's add a more complex test:

```ruby
def test_ideas_can_be_liked_more_than_once
  idea = Idea.new("diet", "carrots and cucumbers")
  assert_equal 0, idea.likes
  idea.like!
  assert_equal 1, idea.likes
  idea.like!
  assert_equal 2, idea.likes
end
```

Run the test and observe the error message. Then improve the implementation
of `like!` to increment the number of likes rather than just setting it to `1`.

## I3: Sorting Ideas

Let's figure out how we can order the ideas by the number of likes.

#### Starting with a Test

We'll create a test that has multiple ideas, and gives them different ranks by
liking them a different number of times:

```ruby
def test_ideas_can_be_sorted_by_rank
  diet = Idea.new("diet", "cabbage soup")
  exercise = Idea.new("exercise", "long distance running")
  drink = Idea.new("drink", "carrot smoothy")

  exercise.like!
  exercise.like!
  drink.like!

  ideas = [drink, exercise, diet]

  assert_equal [diet, drink, exercise], ideas.sort
end
```

`exercise` should have two likes, `drink` just one, and `diet` zero. The normal
Ruby `sort` puts the smallest values first, so we expect the order after sorting
to be `[diet, drink, exercise]`.

Run the test.

#### Comparing `Idea` with `Idea`

The error message we get for this test is a bit more cryptic than the previous ones:

{% terminal %}
ArgumentError: comparison of Idea with Idea failed
{% endterminal %}

What does `comparison of Idea with Idea failed` even mean?

The `sort` method depends on a method known as _the spaceship operator_, which
is used to compare one object to another.

The spaceship operator looks like this: `<=>` and a definition normally looks
like this:

```ruby
def <=>(other)
  # comparison code here
end
```

The expectation is that `<=>` returns `-1`, `0`, or `1` depending on the order
priority of the objects.

But usually we don't need to think about the numeric return value. Instead we
can rely on the spaceship defined on some attribute of the objects, like this:

```ruby
def <=>(other)
  likes <=> other.likes
end
```

Effectively this means that *"you can sort instances of `Idea` by comparing their
number of `likes`"*.

Run the tests and they should pass.

#### Saving with Git

Initialize a git repository, and check your changes in:

{% terminal %}
git init
git add .
git commit -m "Implement `Idea` with sorting"
{% endterminal %}

## I4: Saving Ideas

We need to be able to organize ideas. We're going to create a class that stores ideas.

### A First `IdeaStore` Test

Once again we'll define what we want to happen by writing a test. We want our test to:

* create an idea
* save it
* get it back out of the datastore
* verify that the one we got out is the one we put in

#### Adding Dependencies

Create `idea_store_test.rb` in the `test/ideabox` directory.

Start with the dependencies themselves at the top of that file:

```ruby
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
```

We also will want to use the `Idea` class:

```ruby
require './lib/ideabox/idea'
```

And finally the `IdeaStore` itself:

```ruby
require './lib/ideabox/idea_store'
```

#### The First Test

Start with this frame:

```ruby
class IdeaStoreTest < Minitest::Test
  def test_save_and_retrieve_an_idea
    # Add the test code here
  end
end
```

Then build up the test piece by piece:

* Create the idea: `idea = Idea.new("celebrate", "with champagne")`
* Store it in `IdeaStore`: `id = IdeaStore.save(idea)`
* Check that there's now an idea: `assert_equal 1, IdeaStore.count`
* Find the idea by `id`: `idea = IdeaStore.find(id)`
* Verify the `title`: `assert_equal "celebrate", idea.title`
* Verify the `description`: `assert_equal "with champagne", idea.description`

Run the test:

{% terminal %}
$ ruby test/ideabox/idea_store_test.rb
{% endterminal %}

#### Creating `idea_store.rb`

The first failure complains that there is no `idea_store` file:

{% terminal %}
cannot load such file -- ./lib/ideabox/idea_store (LoadError)
{% endterminal %}

Create a new file `lib/ideabox/idea_store.rb` then run the test again.

#### Defining `IdeaStore`

There's no constant `IdeaStore`:

{% terminal %}
NameError: uninitialized constant IdeaStoreTest::IdeaStore
{% endterminal %}

Define an empty class named `IdeaStore` and run the test again.

#### Adding the Class Method `save`

The next error complains about the `save` method:

{% terminal %}
NoMethodError: undefined method `save' for IdeaStore:Class
{% endterminal %}

Notice that when we call the save method in the test, it looks like this:

```ruby
IdeaStore.save(idea)
```

Previously called `new` on a class itself. All our other method definitions and
calls were on instances of the class.

But here we're calling `save` on `IdeaStore` _class_, not an instance of that class.

So we define the method like this:

```ruby
class IdeaStore
  def self.save
  end
end
```

And run the tests. The test is giving us a new error:

{% terminal %}
ArgumentError: wrong number of arguments (1 for 0)
{% endterminal %}

We need to accept an argument to the `save` method:

```ruby
def self.save(idea)
end
```

Run the tests.

#### Adding a Class Method `count`

The error message has changed again:

{% terminal %}
NoMethodError: undefined method `count' for IdeaStore:Class
{% endterminal %}

Fix it by adding a blank class method named `count` and run the tests again.

#### Actual Counting

The test is now failing rather than giving us an error:

{% terminal %}
Expected: 1
  Actual: nil
{% endterminal %}

The failing line of code is this:

```ruby
assert_equal 1, IdeaStore.count
```

This makes sense, of course, since we're not doing any work in the `IdeaStore`
yet. Let's just fake it for now:

```ruby
def self.count
  1
end
```

And run the tests.

#### Adding the Class Method `find`

We get a new error message:

{% terminal %}
NoMethodError: undefined method `find' for IdeaStore:Class
{% endterminal %}

Add an empty `find` method. Run the tests and you'll get an `ArgumentError`,
then fix it and run the tests.

#### Saving One Idea

The next error message is going to be harder to overcome:

{% terminal %}
NoMethodError: undefined method `title' for nil:NilClass
{% endterminal %}

Our `find` method is returning `nil`. So then when we attempt to verify the
`title` we're calling that method on `nil` which raises an error. We need
`find` to return an instance of `Idea` and the idea it returns has to have
a matching title/description to what we put in.

There are two important pieces. First the `save` method has to store the idea we
give it, and second, the `find` method has to get it back out.

The simplest possible implementation is to store the incoming idea into an
instance variable `@idea`. Then when `find` is called it can just return the
value stored in `@idea` without actually doing any kind of search or match on
the passed in `id`.

`save` stores the idea into `@idea`:

```ruby
def self.save(idea)
  @idea = idea
end
```

Then `find` then returns whatever was stored in `@idea`:

```ruby
def self.find(id)
  @idea
end
```

Run the test and it'll pass. But we know the implementation is junk.

### Testing Multiple Ideas

Our first `IdeaStore` test wasn't very robust because it was "finding" one idea
out a collection of one.

#### Write a New Test

Let's write an additional test that uses two ideas:

```ruby
def test_save_and_retrieve_multiple_ideas
  idea1 = Idea.new("celebrate", "with champagne")
  id1 = IdeaStore.save(idea1)

  assert_equal 1, IdeaStore.count

  idea2 = Idea.new("dream", "of unicorns and rainbows")
  id2 = IdeaStore.save(idea1)

  assert_equal 2, IdeaStore.count

  found_idea1 = IdeaStore.find(id1)
  assert_equal "celebrate", found_idea1.title
  assert_equal "with champagne", found_idea1.description

  found_idea2 = IdeaStore.find(id2)
  assert_equal "dream", found_idea2.title
  assert_equal "of unicorns and rainbows", found_idea2.description
end
```

This will of course break our existing implementation because when the second
idea is stored it'll blow away the previously stored idea. Then when we try to
call `find` with `id1` we'll get back the most recently saved idea, `idea2`.

Run the test and confirm that it fails. But why?

#### Problems with `count`

The test is failing because we hard-coded the `count` method to return 1:

{% terminal %}
Expected: 2
  Actual: 1
{% endterminal %}

There's no quick hack to work both when there's been one and two ideas saved.
The easiest thing is to start a collection of saved ideas.

#### Using `@all`

Let's store the incoming ideas in an array called `@all`:

```ruby
def self.save(idea)
  @all << idea
end
```

Then modify `count` to return the `count` of `@all`.

Run the tests and they'll generate an error:

{% terminal %}
NoMethodError: undefined method `<<' for nil:NilClass
    /Users/you/ideabox/lib/ideabox/idea_store.rb:7:in `save'
{% endterminal %}

We can't shovel into `@all` because it's `nil`.

Can we just set it to `[]` in the `initialize`? That won't work because we're
using class methods -- there is no `initialize`! We'll have to start `@all` with
the value `[]` inside of `save`:

```ruby
def self.save(idea)
  @all = []
  @all << idea
end
```

Run the tests and you'll get another failure:

{% terminal %}
Expected: 2
  Actual: 1
{% endterminal %}

We expected to have 2 ideas, but we only have 1. Why is that?

Because of the way we wrote `@all = []`, every time we call `save` we're
resetting `@all` to an empty array. No matter how many times we call `save` we
will always end up with exactly one idea in `@all`. What we need is a way to
only set `@all` to be an empty array if it is `nil`.

#### Using `||=`

The **logical or** operator, `||`, is used when we want to do something when **either** one side **or** the other, **or both** are `true`.

So the expression `a || b` will evaluate to true if either `a` or `b` are true, or if they both are:

```ruby
a = true
b = false
a || b
# => true
```

In Ruby we aren't very picky about `true` and `false`. We are quite content to accept _truthy_ and _falsey_. Only two objects are _falsey_ in Ruby: `false` and `nil`. **Everything else** is _truthy_.

```ruby
a = nil
b = "hello"
a || b
# "hello" which is truthy
```

Returning to the first line of our `save` method:

```ruby
@all = []
```

We really only want to set `@all` to `[]` if it's `nil`. This is such a common
pattern in Ruby that there's a shorthand operator for it:

```ruby
@all ||= []
```

This means "if `@all` is truthy, leave it alone. If it's not, set it equal to `[]`".

With that in place, run the tests and they still fail.

#### A Better `count`

Now that we have the collection `@all`, the `count` method should just call `count`
on the collection.

Run the tests.

#### There Is No `@idea`

We're back to a failure when fetching the idea:

{% terminal %}
  1) Error:
NoMethodError: undefined method `title' for nil:NilClass
{% endterminal %}

Our `find` is still returning `@idea`. Since that instance variable is not being
set anywhere, it has the value `nil`. When the test call `.title` on the result
of `find` it generates the `NoMethodError`.

We need to find a way to get the correct idea back out of the collection, but
we need a unique `id` for each idea.

### Assigning IDs

To make `find` work properly...

* `Idea` instances need to be able to set and get their `id` value.
* `IdeaStore.save` needs to give the idea an `id` and return the `id` to the
  caller.
* `IdeaStore.find` needs to use the provided `id` and look through the stored
  ideas to find the correct one.

#### Save with `next_id`

We need to generate a unique `id` number when saving an idea. Rather than
figure out what the next ID should be, let's write our `save` to rely on a
method named `next_id` which determines the next ID to use:

```ruby
def self.save(idea)
  @all ||= []
  idea.id = next_id
  @all << idea
  idea.id
end
```

Run the test and it'll give an error because there is no `next_id` method:

{% terminal %}
  1) Error:
NameError: undefined local variable or method `next_id' for IdeaStore:Class
    /Users/you/ideabox/lib/ideabox/idea_store.rb:4:in `save'
{% endterminal %}

#### Stubbing `next_id`

For now, let's just create an empty method:

```ruby
def self.next_id
end
```

And run the test.

#### You Can't Store `id`

The next error is:

{% terminal %}
NoMethodError: undefined method `id=' for #&lt;Idea:0x007fea5a390480&gt;
    /Users/you/ideabox/lib/ideabox/idea_store.rb:4:in `save'
{% endterminal %}

Note that the error is because we're trying to call `id=` to store the `id`
attribute inside an instance of `Idea`.

It'd be best to add a test to `idea_test.rb` to test and implement this functionality
before continuing with `IdeaStore`.

#### Setting `id` on `Idea`

Open up the `idea_test.rb` file and add a new test:

```ruby
def test_ideas_have_an_id
  idea = Idea.new("dinner", "beef stew")
  idea.id = 1
  assert_equal 1, idea.id
end
```

Run the idea test suite with `ruby test/ideabox/idea_test.rb`.

{% terminal %}
NoMethodError: undefined method `id=' for #&lt;Idea:0x007fcd153214e8&gt;
{% endterminal %}

Make the test pass by adding an `attr_accessor` to the Idea class:

```ruby
class Idea
  attr_accessor :id
  attr_reader :title, :description, :rank

  # ...
end
```

Why use `attr_accessor` instead of `attr_reader`?

If you noticed in the last failing test, the NoMethodError complained about `no method 'id='`, and not just `id`. The `attr_reader` method generates just a method for reading an attribute. But we want to be able to modify the value stored in `id`. `attr_accessor` generates both an `id` method to read the value and a `id=` method to change the value.

This change gets the unit tests for `Idea` passing, and we can go back to our unit
test for the `IdeaStore`.

Run `ruby test/ideabox/idea_store_test.rb`.

#### Building `next_id`

Our test is still failing. The next component we need to build is a decent
`next_idea` method. There are a lot of approaches we could take to generate
ID numbers, but the easiest is to add one to the number of ideas which have
already been stored:

```ruby
def self.next_id
  count + 1
end
```

We use the `count` method on `IdeaStore` to find the current number of items,
then add one because our new idea will be added to the collection.

#### A Proper Find

Now that we generate and store an `id`, we can find the element in the `@all`
collection using the method `find` provided by Enumerable:

```ruby
def self.find(id)
  @all.find do |idea|
    idea.id == id
  end
end
```

Finally the test passes, yay! Commit your changes to Git before moving on.

## I5: Refactor & Simplify

### Removing Duplication in Minitest

Both of the Minitest test suites start with this code:

```ruby
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
```

Cut those lines and move them into a file `test/test_helper.rb`. Then in the
test files require the new `test_helper`:

```ruby
require './test/test_helper'
```

### Creating a `rake` Task

Right now we don't have an easy way to run all the test files. You'd have to...

{% terminal %}
ruby test/ideabox/idea_test.rb
ruby test/ideabox/idea_store_test.rb
{% endterminal %}

We need a simpler way to run the tests. We're going to use a library named
`rake` which is used to automate things in Ruby.

Rake is frequently used for runnig tests, and there are some handy helper classes and methods to let us define our "task" quickly.

#### Creating the `Rakefile`

Try running `rake` from the terminal. You should see an error message that looks something like this:

```ruby
rake aborted!
No Rakefile found (looking for: rakefile, Rakefile, rakefile.rb, Rakefile.rb)
```

By default `rake` looks for a file named `Rakefile` in the root of the project
directory. Create it now.

#### Defining the Task

First we want to include the built-in helper library to create test tasks:

```ruby
require 'rake/testtask'
```

Then define this test task:

```ruby
Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end
```

The `pattern` tells the test where to find your test files. In this case, we're going to pick up all files in the `test/` directory that end in `_test.rb`. The `**` part says to look not only directly in the `test/` directory, but also in all the subdirectories.

This weird little snippet is something you'll setup once per project, so it's
really not necessary to memorize it. Just be able to find it when you need it.

#### Running the Task

Run `rake -T` in your terminal to see what rake tasks are now available to you:

{% terminal %}
$ rake -T
rake test  # Run tests
{% endterminal %}

The `TestTask` automatically defined a task named `test` for us. Run your tests
with `rake test`.

#### Defining a Default Taks

We can make it even easier. If you call `rake` without telling it which task to run, it will look for a task named `default`. Right now there is no default task, but we can define one.

Add this to the bottom of the `Rakefile`:

```ruby
task default: :test
```

#### Using the Default Task

Now run your tests by running `rake` by itself:

{% terminal %}
$ rake
{% endterminal %}

Much better! Commit your changes to your git repository.

## I6: Editing Ideas

Sometimes an idea is OK but not great. We need to be able to improve on our ideas.

### Plan of Attack

In order to prove that we're able to update ideas, we need to

* start with an idea
* save it
* get it back out of the datastore
* change the values
* save it again
* find it again and see that it has all the new values

Another observation that is important here is that if we've saved a single idea and updated it, the `count` of ideas in our datastore should be exactly one.

### Writing a Test

Here's a test that exercises this functionality:

```ruby
def test_update_idea
  idea = Idea.new("drink", "tomato juice")
  id = IdeaStore.save(idea)

  idea = IdeaStore.find(id)
  idea.title = "cocktails"
  idea.description = "spicy tomato juice with vodka"

  IdeaStore.save(idea)

  assert_equal 1, IdeaStore.count

  idea = IdeaStore.find(id)
  assert_equal "cocktails", idea.title
  assert_equal "spicy tomato juice with vodka", idea.description
end
```

Run it and you'll get a familiar error message:

```ruby
NoMethodError: undefined method 'title=' for #<Idea:0x007fe25a2e4c28>
```

We're trying to change a read-only value on Idea.

### Making Title & Description Changeable

Open the `idea_test` and add a test that ensures the `title` and `description`
attributes can be set like this:

```ruby
def test_update_values
  idea = Idea.new("drinks", "sparkly water")
  idea.title = "happy hour"
  idea.description = "mojitos"
  assert_equal "happy hour", idea.title
  assert_equal "mojitos", idea.description
end
```

Make it pass by using `attr_accessor` instead of `attr_reader` for `title` and
`description`.

### Back to `idea_store_test`

The `idea_test` suite is passing, but the `idea_store_test` about updating an
idea is failing:

{% terminal %}
Expected: 1
  Actual: 4
{% endterminal %}

It seems odd that we have 4 ideas. The test only saves twice, so at the most it should have 2 ideas. What's happening is that the first test is creating two ideas in the `IdeaStore` class, then the second test is creating two more.

### Clearing Ideas Between Tests

Tests that interfere with each other are not good. We need to clear out all the ideas after each test so the next test can start with a blank slate.

Minitest provides us with two methods that can help us here. The `setup` method runs before each individual test, and the `teardown` method runs after each individual test.

We want to clean up after each test, so we'll use the `teardown` method:

```ruby
class IdeaStoreTest < Minitest::Test
  def teardown
    IdeaStore.delete_all
  end

  # ...
end
```

That blows up, because we don't have a `delete_all` method on the `IdeaStore`
class.

Within `IdeaStore`, define a `delete_all` the clears out `@all`.

Then run the tests.

### Saving Existing Ideas

With this change, our test is failing with a much more appropriate error
message:

```ruby
Expected: 1
  Actual: 2
```

When we call `save` with the modified data our code is storing a new idea
rather than modifying the existing one. We need to change the `save` method so
it doesn't create a new `id` if the idea already has one.

We only want to set the `id` and stick the idea in the `@all` array if it's a
new idea.

```ruby
def self.save(idea)
  @all ||= []
  if idea.new?
    idea.id = next_id
    @all << idea
  end
  idea.id
end
```

That is going to fail because we don't have a `new?` method on `Idea`.

### Adding `new?` to `Idea`

Open the test file for `Idea` and create a test that uses the `new?` method:

```ruby
def test_a_new_idea
  idea = Idea.new('sleep', 'all day')
  assert idea.new?
end
```

Define a `new?` method stub in `Idea`. Run it and you'll see:

{% terminal %}
  1) Failure:
IdeaTest#test_a_new_idea [test/ideabox/idea_test.rb:15]:
Failed assertion, no message given.
{% endterminal %}

Try having `new?` always return `true`:

```ruby
def new?
  true
end
```

That gets the test passing, but we know the implementation isn't good enough.

#### Old Ideas are Not New

Create another test to explore `new?` for an existing `Idea`:

```ruby
def test_an_old_idea
  idea = Idea.new('drink', 'lots of water')
  idea.id = 1
  refute idea.new?
end
```

Let's modify our `new?` to return `true` if there is an `id`:

```ruby
def new?
  if id
    false
  else
    true
  end
end
```

We can achieve the exact same outcome with simplifyied logic skipping the `if`
statement:

```ruby
def new?
  !id
end
```

#### Wrap Up Editing

Run that code and everything should be passing.

We've finished the edit feature. Commit your changes to git.

## I7: Deleting Ideas

We can create ideas, look them up, and edit them. But if we have a particularly bad idea, we're going to want to delete it.

### Setup a Test

To prove that we can delete ideas properly let's...

* create 3 ideas
* delete one of them
* verify that the target idea is no longer there
* verify that the other two ideas are still around

Here's a test that does all four steps:

```ruby
def test_delete_an_idea
  id1 = IdeaStore.save Idea.new("song", "99 bottles of beer")
  id2 = IdeaStore.save Idea.new("gift", "micky mouse belt")
  id3 = IdeaStore.save Idea.new("dinner", "cheeseburger with bacon and avocado")

  assert_equal ["dinner", "gift", "song"], IdeaStore.all.map(&:title).sort
  IdeaStore.delete(id2)
  assert_equal ["dinner", "song"], IdeaStore.all.map(&:title).sort
end
```

Run the test.

### Adding `all`

The first complaint is that we don't have an `all` method:

{% terminal %}
NoMethodError: undefined method `all' for IdeaStore:Class
{% endterminal %}

We have an `@all` instance variable in `IdeaStore`, but we need to expose it.
Note that we can't use `attr_reader` because that's for instance methods, we
need a class method:

```ruby
class IdeaStore
  def self.all
    @all
  end

  # ...
end
```

Run the test again.

### Defining `.delete`

Now we have a different `NoMethodError`:

{% terminal %}
NoMethodError: undefined method `delete' for IdeaStore:Class
{% endterminal %}

We can change the error message by defining an empty `delete` method:

```ruby
def self.delete
end
```

Run the test and we get another error:

{% terminal %}
ArgumentError: wrong number of arguments (1 for 0)
{% endterminal %}

Fix it by adding an `id` argument to the definition of `delete` and run the test.

#### Actually Deleting Ideas

This gives us a real failure:

{% terminal %}
Expected: ["dinner", "song"]
  Actual: ["dinner", "gift", "song"]
{% endterminal %}

We need to do the actual work. Our data is stored in an array, and there are
several ways of deleting things from arrays.

* `Array#delete_if`
* `Array#delete_at`
* `Array#delete`

`delete_if` accepts a block and will delete any items for which the block
evaluates to a truthy value. Use `delete_if` to remove the idea which has an
`id` matching your parameter `id`.

The test is passing. Commit your changes.

## I8: Refactor

In the previous iteration we added a method `Ideabox.all`, so let's update `Ideabox.count` and `Ideabox.find` to use the `all` method rather than the `@all` instance variable.

The final code looks this this:

```ruby
class Idea
  attr_reader :rank
  attr_accessor :id, :title, :description
  def initialize(title, description)
    @title = title
    @description = description
    @rank = 0
  end

  def like!
    @rank += 1
  end

  def <=>(other)
    rank <=> other.rank
  end

  def new?
    !id
  end
end

class IdeaStore
  def self.all
    @all
  end

  def self.save(idea)
    @all ||= []
    if idea.new?
      idea.id = next_id
      @all << idea
    end
    idea.id
  end

  def self.find(id)
    all.find do |idea|
      idea.id == id
    end
  end

  def self.delete(id)
    all.delete find(id)
  end

  def self.count
    all.length
  end

  def self.next_id
    count + 1
  end

  def self.delete_all
    @all = []
  end
end
```

Make sure that the tests are all passing, and commit your changes.
