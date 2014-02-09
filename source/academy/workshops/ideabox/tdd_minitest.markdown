---
layout: page
title: Driving the Domain Model Using TDD and Minitest
sidebar: true
---

Every developer has more ideas than time. As David Allen likes to say "the human brain is for creating ideas, not remembering them." Let’s build a system to record your good, bad, and awful ideas.

## I0: Getting Started

### Environment Setup

For this project you need to have setup:

* Ruby 2.0.0
* Ruby's Bundler gem

### File/Folder Structure

Let's start our project with the minimum and build up from there. We need:

* a project folder
* a `Gemfile`
* a `lib/ideabox` directory
* a `test/ideabox` directory

### `Gemfile`

This tutorial will show how the design can be driven using `minitest`.

We're going to depend on one external gem in our `Gemfile`:

```ruby
source 'https://rubygems.org'

group :test do
  gem 'minitest'
end
```

Save that and, from your project directory, run `bundle` to install the dependencies.

## I1: Defining Ideas

This project will use a fairly classic style of TDD. First we will implement the core business logic using unit tests to drive the implementation and design.

Once we have the business logic implemented, we can decide how we want people to access the program.

This would make a very good command line application, so perhaps we'll add a command line interface (CLI). Or, maybe we want to use this via a web interface using a simple framework like Sinatra. We don't need to make that decision just yet.

### Writing the First Test

Create a directory named `test`:

{% terminal %}
$ mkdir test
{% endterminal %}

We are going to use tests to drive us to create a simple ruby object that takes a title and a description.

Within the `test` directory, create another directory named `ideabox`, which is where we will put the model tests:

{% terminal %}
$ mkdir test/ideabox
{% endterminal %}

Create a file `test/ideabox/idea_test.rb`

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

That makes sense, since we haven't created the file.

Do that now:

{% terminal %}
mkdir -p lib/ideabox
touch lib/ideabox/idea.rb
{% endterminal %}

Run the test again.

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

The next error says that we're calling the `initialize` method wrong:

{% terminal %}
  1) Error:
IdeaTest#test_basic_idea:
ArgumentError: wrong number of arguments(2 for 0)
    test/ideabox/idea_test.rb:8:in `initialize'
    test/ideabox/idea_test.rb:8:in `new'
    test/ideabox/idea_test.rb:8:in `test_basic_idea'
{% endterminal %}

Notice that minitest makes a distinction between failures and errors.

In minitest an error means that the Ruby code is wrong somehow. There might be a syntax error, or we're calling a method that doesn't exist, or calling a method that *does* exist, but we're doing it wrong. A failure, on the other hand means that the code is running, but not doing what we expected.

Minitest is complaining about an `ArgumentError`. An Idea takes two arguments:

```ruby
Idea.new("a title", "a detailed and riveting description")
```

However, the Idea class as it is currently defined has only the default initialize method, which takes no arguments. We need to overwrite it with the following code:

```ruby
class Idea
  def initialize(title, description)
  end
end
```

Run the tests again.

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

We can define a method `:title` using an `attr_reader`:

```ruby
class Idea
  attr_reader :title
  def initialize(title, description)
  end
end
```

Finally, minitest is complaining about a failure rather than an error:

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

That makes the first assertion pass, which allows the test to blow up on the next assertion:

{% terminal %}
NoMethodError: undefined method `description' for #&lt;Idea:0x007f89532b1900 @title="title"&gt;
{% endterminal %}

Add an attribute reader for `:description`, and run the test again. We get a proper failure, and can fix it by assigning the incoming `description` to an instance variable.

The Idea class now looks like this:

```ruby
class Idea
  attr_reader :title, :description
  def initialize(title, description)
    @title = title
    @description = description
  end
end
```

The test is passing.

### Implementing Rank

We also want to be able to rank ideas. The API for this will be to say `like!` on the idea:

```ruby
def test_ideas_can_be_liked
  idea = Idea.new("diet", "carrots and cucumbers")
  assert_equal 0, idea.rank
  idea.like!
  assert_equal 1, idea.rank
end
```

The test gives us an error:

{% terminal %}
NoMethodError: undefined method `rank' for #&lt;Idea:0x007fd15b3fa460&gt;
{% endterminal %}

The `rank` method doesn't have any behavior per se, it's just reporting a
value. Let's create it using an `attr_reader`.

Running the tests again gives us a proper failure:

{% terminal %}
Expected: 0
  Actual: nil
{% endterminal %}

The first assertion in the test is placed before anything happens. If we only made an assertion after calling `like!` then we could have gotten the test to pass by assigning an instance variable in the `initialize` method that hard-coded the rank to `1`. We want to make sure that there's a reasonable default **and** that calling `like!` changes the rank by the expected amount.

To give `rank` a reasonable default, assign an instance variable in the `initialize` method with a value of 0.

This gets the first assertion passing, and we now get an error:

{% terminal %}
NoMethodError: undefined method `like!' for #&lt;Idea:0x007fa14bb4c7d0&gt;
{% endterminal %}

Undefined method `like!`. This needs to have behavior that changes the idea, so a simple `attr_reader` will not do. Define a method explicitly:

```ruby
def like!
end
```

Again, we get a failure:

{% terminal %}
Expected: 1
  Actual: 0
{% endterminal %}

Make it pass by setting `@rank = 1` within the new `like!` method.

This gets the test passing.

Our implementation isn't bulletproof. No matter how many times we call `like!` the rank will be `1`. We could just fix the implementation, but that would mean that our test isn't as robust as it could be.

Let's improve the test:

```ruby
def test_ideas_can_be_liked
  idea = Idea.new("diet", "carrots and cucumbers")
  assert_equal 0, idea.rank
  idea.like!
  assert_equal 1, idea.rank
  idea.like!
  assert_equal 2, idea.rank
end
```

We get a good failure, and can now update the implementation to be correct:

```ruby
@rank += 1
```

The full `Idea` class now looks like this:

```ruby
class Idea
  attr_reader :title, :description, :rank
  def initialize(title, description)
    @title = title
    @description = description
    @rank = 0
  end

  def like!
    @rank += 1
  end
end
```

### Sorting Ideas by Rank

Since we're ranking ideas, we also want to sort them by their rank.

We'll create a test that has multiple ideas, and gives them different ranks by liking them a different number of times:

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

The error message we get for this test is a bit more cryptic than the previous ones:

{% terminal %}
ArgumentError: comparison of Idea with Idea failed
{% endterminal %}

What does `comparison of Idea with Idea failed` even mean?

The `sort` method depends on a method known as _the spaceship operator_, which is used to compare one object to another.

The spaceship operator looks like this: `<=>`, and can be defined like any other method:

```ruby
def <=>(other)
  # comparison code here
end
```

This method should return either `-1` (meaning the first object should be ordered _before_ the other), or `0` (meaning that the objects have equivalent
rank), or `1`, which means that the first object should be ordered _after_ the second one.

In code, this becomes:

```ruby
def <=>(other)
  if rank > other.rank
    1
  elsif rank == other.rank
    0
  else
    -1
  end
end
```

The argument is named `other`, which is an idiomatic choice in Ruby, as well as in many other languages.

Since we're comparing the idea's `rank`s, and `rank` is a `Fixnum`, and `Fixnum` has defined the spaceship operator, we can refactor the above to:

```ruby
def <=>(other)
  rank <=> other.rank
end
```

### Performing Conventional Comparisons

If we want to do more types of comparisons than just sorting, we could include the `Comparable` in the `Idea` class. That would give us all the conventional comparison operators (`<`, `<=`, `==`, `>=`, and `>`) as well as a method called `between?`.

We don't really need all those methods. Besides, it would be kind of odd to have the following:

{% terminal %}
idea1 = Idea.new('dessert', 'chocolate cake')
idea2 = Idea.new('entertainment', 'dogfight')
idea1 == idea2
# => true
{% endterminal %}

So we won't include `Comparable`.

#### Checking In

The business logic for our `Idea` is complete, and the tests are all green.

This is the final implementation of `Idea`:

```ruby
class Idea
  attr_reader :title, :description, :rank
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
end
```

Create a README with a short description of the project, then initialize a git repository, and check your changes in:

{% terminal %}
git init
git add .
git commit -m "Implement `Idea`"
{% endterminal %}

## I2: Saving Ideas

We need to be able to organize ideas. We're going to create a class that stores ideas.

### Starting With a Test

Once again we'll define what we want to happen by writing a test.

We want to:

* create an idea
* save it
* get it back out of the datastore (it should be the same idea)

Create an empty file `idea_store_test.rb` in the `test/ideabox` directory.

When using minitest, we need to include the testing dependencies themselves at the top of that file:

```ruby
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
```

Next, we want to create actual ideas, so we also need to require the `Idea` class.

```ruby
require './lib/ideabox/idea'
```

Then we're going to need the class that actually does the work of storing the ideas:

```ruby
require './lib/ideabox/idea_store'
```

Finally, we need a test that proves that the idea gets saved:

```ruby
class IdeaStoreTest < Minitest::Test
  def test_save_and_retrieve_an_idea
    idea = Idea.new("celebrate", "with champagne")
    id = IdeaStore.save(idea)

    assert_equal 1, IdeaStore.count

    idea = IdeaStore.find(id)
    assert_equal "celebrate", idea.title
    assert_equal "with champagne", idea.description
  end
end
```

Run the test:

{% terminal %}
ruby test/ideabox/idea_store_test.rb
{% endterminal %}

The first failure complains that there is no `idea_store` file:

{% terminal %}
cannot load such file -- ./lib/ideabox/idea_store (LoadError)
{% endterminal %}

Create a new file called `idea_store.rb` in `lib/ideabox/`:

{% terminal %}
touch lib/ideabox/idea_store.rb
{% endterminal %}

Run the test again, and you should get a complaint that there's no constant
`IdeaStore`:

{% terminal %}
NameError: uninitialized constant IdeaStoreTest::IdeaStore
{% endterminal %}

Define an empty class in the `lib/ideabox/idea_store.rb` file:

```ruby
class IdeaStore
end
```

The next error complains about a missing method, `save`:

{% terminal %}
NoMethodError: undefined method `save' for IdeaStore:Class
{% endterminal %}

Change the error message by defining an empty `save` method on the IdeaStore class:

```ruby
class IdeaStore
  def self.save
  end
end
```

Notice that when we call the save method in the test, it looks like this:

```ruby
IdeaStore.save(idea)
```

Previously, we've only sent the `new` message to a class, which gives us back a new instance:

```ruby
idea = Idea.new("activity", "coloring with crayons")
```

And then we'd call methods on that instance:

```ruby
idea.rank
# => 0
```

Here we're sending the `save` method to the `IdeaStore` _class_, not an instance of that class.

Notice the difference between these two method definitions:

```ruby
class World
  def self.hello
    "Greetings from the class #{self}."
  end

  def hello
    "Greetings from the instance #{self}."
  end
end
```

You can test this in IRB by copying and pasting the code into an IRB session, and then saying:

{% irb %}
World.hello
World.new.hello
{% endirb %}

If that seems confusing, just roll with it for now, accepting that `def self.something` will let you send `something` directly to the class, whereas `def something` lets you send `something` to the instance of the class.

So, back to our `IdeaStore`.

We created a `save` method directly on the `IdeaStore` class:

```ruby
class IdeaStore
  def self.save
  end
end
```

The test is giving us a new error:

{% terminal %}
ArgumentError: wrong number of arguments (1 for 0)
{% endterminal %}

We need to accept an argument to the `save` method:

```ruby
def self.save(idea)
end
```

The error message has changed again:

{% terminal %}
NoMethodError: undefined method `count' for IdeaStore:Class
{% endterminal %}

Let's fix that in the same way:

```ruby
class IdeaStore
  def self.save(idea)
  end

  def self.count
  end
end
```

The test is now failing rather than giving us an error:

{% terminal %}
Expected: 1
  Actual: nil
{% endterminal %}

The failing line of code is this:

```ruby
assert_equal 1, IdeaStore.count
```

This makes sense, of course, since we're not doing any work in the `IdeaStore` class yet.

Let's just fake it for now:

```ruby
def self.count
  1
end
```

We get a new error message:

{% terminal %}
NoMethodError: undefined method `find' for IdeaStore:Class
{% endterminal %}

Add an empty find method:

```ruby
def self.find
end
```

The test complains that the method signature is incorrect:

{% terminal %}
ArgumentError: wrong number of arguments (1 for 0)
    /Users/you/ideabox/lib/ideabox/idea_store.rb:9:in `find'
{% endterminal %}

Correct that by providing an argument to `find`. We'll be finding by the ID of the idea, so use `id` as the argument name:

```ruby
def self.find(id)
end
```

The next error message is going to be harder to fake:

{% terminal %}
NoMethodError: undefined method `title' for nil:NilClass
{% endterminal %}

Let's do some real work.

There are two important pieces. First the `save` method has to store the idea we give it, and second, the `find` method has to get it back out.

We can ignore all the details for now, and just make that work:

```ruby
class IdeaStore
  def self.save(idea)
    @idea = idea
  end

  def self.find(id)
    @idea
  end

  def self.count
    1
  end
end
```

That gets the test passing, but it's not a very satisfactory implementation.

Let's make it so we can store and retrieve two different ideas. Update the test:

```ruby
class IdeaStoreTest < Minitest::Test
  def test_save_and_retrieve_ideas
    idea = Idea.new("celebrate", "with champagne")
    id1 = IdeaStore.save(idea)

    assert_equal 1, IdeaStore.count

    idea = Idea.new("dream", "of unicorns and rainbows")
    id2 = IdeaStore.save(idea)

    assert_equal 2, IdeaStore.count

    idea = IdeaStore.find(id1)
    assert_equal "celebrate", idea.title
    assert_equal "with champagne", idea.description

    idea = IdeaStore.find(id2)
    assert_equal "dream", idea.title
    assert_equal "of unicorns and rainbows", idea.description
  end
end
```

The test is failing again, because we hard-coded the `count` method to return 1:

{% terminal %}
Expected: 2
  Actual: 1
{% endterminal %}

We can't just hard-code a return value of 2, because we now have two different assertions for the `count` method.

We need to actually store the incoming ideas. Let's store them in an array called `@all`:

```ruby
def self.save(idea)
  @all << idea
end
```

The tests blow up:

{% terminal %}
NoMethodError: undefined method `<<' for nil:NilClass
    /Users/you/ideabox/lib/ideabox/idea_store.rb:7:in `save'
{% endterminal %}

`@all` is nil. We need it to be an array before we can shovel anything into it:

```ruby
def self.save(idea)
  @all = []
  @all << idea
end
```

Now we get a somewhat cryptic failure:

{% terminal %}
Expected: 2
  Actual: 1
{% endterminal %}

We expected to have 2 ideas, but we only have 1. Why is that?

Well, every single time we call `save`, we reset the `@all` instance variable to be an empty array. No matter how many times we call `save` we will always end up with exactly one idea in `@all`.

What we need is a way to only set `@all` to be an empty array if it is nil.

For this, we're going to co-opt the ruby `||` operator.

The **logical or** operator, `||`, is used when we want to do something when **either** one side **or** the other, **or both** are true.

So the expression `a || b` will evaluate to true if either `a` or `b` are true, or if they both are:

```ruby
a = true
b = false
a || b
# => true
```

Actually, in Ruby we aren't very picky about `true` and `false`. We are quite content to accept _truthy_ and _falsey_. Only two objects are _falsey_ in Ruby: `false` and `nil`. Everything else is _truthy_.

```ruby
a = nil
b = true
a || b
# true
```

Since the entire expression will evaluate to _truthy_ if `a` is _truthy_, the `||` operator is lazy. It won't even bother to check `b` if `a` is true or a truthy value. It will go ahead and just return whatever `a` is, making the entire statement _truthy_.

Now, let's rename `a` to `@all` and let's make `b` an empty array:

```ruby
@all || []
```

Is this statement _truthy_ or _falsey_?

Well, the result of the entire statement will **always** be _truthy_, because an empty array is _truthy_. But will it always be an empty array? No.

If `@all` is nill, then the `||` operator needs to go check the second part, and it will return an empty array.

Now imagine that `@all` contains an array of ideas: `@all = [idea1, idea2]`.

This is _truthy_, so the `||` operator returns the value of `@all`.

Our problem in save is that we were always setting `@all` to be an empty array:

```ruby
def self.save(idea)
  @all = []
  @all << idea
end
```

What we really want is to use the value of `@all` if there's something there, and then fall back to an empty array if `@all` is `nil`. We can do that using the `||` operator:

```ruby
def self.save(idea)
  @all = @all || []
  @all << idea
end
```

This is something that comes up so often in Ruby that we have a shorthand for it, known as the **or-equal** operator:

```ruby
def self.save(idea)
  @all ||= []
  @all << idea
end
```

This doesn't quite get our tests passing. We also need to tell the `count` method to use the length of the array with the saved ideas:

```ruby
def self.count
  @all.length
end
```

We're back to a failure when fetching the idea:

{% terminal %}
  1) Error:
NoMethodError: undefined method `title' for nil:NilClass
{% endterminal %}

We're returning the `@idea` value, which is no longer being set.

Let's return the first idea in the `@all` array:

```ruby
def self.find(id)
  @all.first
end
```

That works for the first idea, but not for the second one.

We need to find a way to get the correct idea back out.

The information we have to go on is the `id`, but we haven't implemented an `id` for the ideas yet.

Several things need to happen:

* `Idea` instances need to be able to set and get an `id` value.
* `IdeaStore.save` needs to give the idea an `id` and return the id to the
  caller.
* `IdeaStore.find` needs to use the provided `id` and look through the stored
  ideas to find the correct one.

Let's start by changing the `save` method to be the way we wish it were:

```ruby
def self.save(idea)
  @all ||= []
  idea.id = next_id
  @all << idea
  idea.id
end
```

The failing test tells us where we need to go next:

{% terminal %}
  1) Error:
NameError: undefined local variable or method `next_id' for IdeaStore:Class
    /Users/you/ideabox/lib/ideabox/idea_store.rb:4:in `save'
{% endterminal %}

We need a `next_id` method.

For now, let's just create an empty one.

```ruby
def self.next_id
end
```

The next error is:

{% terminal %}
NoMethodError: undefined method `id=' for #&lt;Idea:0x007fea5a390480&gt;
    /Users/you/ideabox/lib/ideabox/idea_store.rb:4:in `save'
{% endterminal %}

This one is _not_ a complaint about the `IdeaStore` class, but a missing method on the Idea instance.

We can't change the `Idea` class without changing the test first, so open up the `idea_test.rb` file and add a new test:

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

That gets the unit tests for `Idea` passing, and we can go back to our unit
test for the `IdeaStore`.

This is failing because it always retrieves the first idea.

```ruby
Expected: "dream"
  Actual: "celebrate"
```

We can use the `Enumerable#find` method to get the correct idea:

```ruby
def self.find(id)
  @all.find do |idea|
    idea.id == id
  end
end
```

The test is still failing with the same error message. What the heck?

Remember back when we implemented the `next_id` method? Take another look at it:

```ruby
def self.next_id
end
```

That's not going to work.

Let's use the `count` to determine the next id:

```ruby
def self.next_id
  count + 1
end
```

This, finally, gets the test passing.

Commit your changes.

## I3: Refactor & Simplify

### Removing Duplication in Minitest

Both of the minitest test suites start with this code:

```ruby
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
```

Let's move that common setup code to a file called `test/test_helper.rb`.

Next replace the setup code with the following in both of the test suites:

```ruby
require './test/test_helper'
```

### Creating a `rake` task for Minitest

If you want to run all of the tests, you have to say:

{% terminal %}
ruby test/ideabox/idea_test.rb
ruby test/ideabox/idea_store_test.rb
{% endterminal %}

That gets old really quickly. We need a simpler way to run the tests.

We're going to use a library called `rake` which a lot of people and projects use to automate things in Ruby.

It lets you write scripts in Ruby, and then run them on the command-line:

{% terminal %}
$ rake whatever
$ rake do:stuff
{% endterminal %}

One of the things that we use `rake` for a lot, is to automatically run our tests. Since this is a very common use case, there are some handy helper classes and methods to let us define our test task quickly.

By default `rake` looks for a file in the root of the project directory named `Rakefile`, so we'll create one of these.

{% terminal %}
touch Rakefile
{% endterminal %}

First we want to include the default helper library to create test tasks:

```ruby
require 'rake/testtask'
```

Then we'll create a test task:

```ruby
Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end
```

The `pattern` tells the test where to find your test files. In this case, we're going to pick up all files living under the `test/` directory that end in `_test.rb`.

The `**` part says to look not only directly in the `test/` directory, but also recursively in all the subdirectories.

Run `rake -T` in your terminal to see what rake tasks are available to you:

{% terminal %}
$ rake -T
rake test  # Run tests
{% endterminal %}

The `TestTask` automatically defined a task named `test` for us.

Run your tests with `rake test`.

We can make it even easier. If you call `rake` without telling it which task to run, it will look for a task named `default`. For the moment, there is no default task, but we can define one.

Add this to the bottom of the Rakefile:

```ruby
task default: :test
```

Run your tests simply by calling `rake` by itself:

{% terminal %}
$ rake
{% endterminal %}

Much better! Commit your changes.

## I4: Editing Ideas

Sometimes an idea is OK but not great. We need to be able to improve our ideas.

### Starting With a Test

In order to prove that we're able to update ideas, we need to

* start with an idea
* save it
* get it back out of the datastore
* change the values
* save it again
* find it again and see that it has all the new values

Another observation that is important here is that if we've saved a single idea and updated it, the `count` of ideas in our datastore should be exactly one.

Here's a test that proves all these things:

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

We get a familiar error message:

```ruby
NoMethodError: undefined method `title=' for #<Idea:0x007fe25a2e4c28>
```

We're trying to change a read-only value on Idea.

Pop over to the idea test/spec file and make sure that we can set a new title and description on an idea.

Something like this:

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
`description`:

```ruby
class Idea
  attr_reader :rank
  attr_accessor :id, :title, :description

  # ...
end
```

The idea test suite is passing, but the idea store one for updating an idea is not.

{% terminal %}
Expected: 1
  Actual: 4
{% endterminal %}

It seems odd that we should have 4 ideas. The test only saves twice, so at the most it should have 2 ideas.

What's happening is that the first test is creating two ideas in the `IdeaStore` class, and then the second test is creating two more.

Tests that interfere with each other are not good. We need to clear out all the ideas between each test.

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

Within `IdeaStore`, define this method:

```ruby
def self.delete_all
  @all = []
end
```

With this change, our test is failing with a much more appropriate error
message:

```ruby
Expected: 1
  Actual: 2
```

Now we need to change the `save` method so that it doesn't create a new `id`
if the idea already has one.

The old code looks like this:

```ruby
def self.save(idea)
  @all ||= []
  idea.id = next_id
  @all << idea
  idea.id
end
```

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

Open the test file for `Idea` and create a test for it:

```ruby
def test_a_new_idea
  idea = Idea.new('sleep', 'all day')
  assert idea.new?
end
```

That fails for obvious reasons. Create an empty `new?` method for Idea:

```ruby
def new?
end
```

Now the test fails because the `new?` method returns a falsy value.

{% terminal %}
  1) Failure:
IdeaTest#test_a_new_idea [test/ideabox/idea_test.rb:15]:
Failed assertion, no message given.
{% endterminal %}

Return `true` from the `new?` method:

```ruby
def new?
  true
end
```

That gets the test passing, but we're not quite there yet. Create another test to force a real implementation:

```ruby
def test_an_old_idea
  idea = Idea.new('drink', 'lots of water')
  idea.id = 1
  refute idea.new?
end
```

To get the test to pass we'll say that an idea is `new?` if it doesn't have an `id`:

```ruby
def new?
  !id
end
```

That gets that test passing. Let's pop back over to the idea store test. It turns out, all of the IdeaStore tests are passing as well.

We've finished the edit feature. Commit your changes.

## I5: Deleting Ideas

We can create ideas, look them up, and edit them. If we have a particularly bad idea, we're going to want to delete it as well.

To prove that we can delete ideas let's create 3 ideas, and then delete one of them. Then we can verify two things: first, that the idea is no longer there, and second, that the other ideas are still around.

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

The first complaint is that we don't have an `all` method:

{% terminal %}
NoMethodError: undefined method `all' for IdeaStore:Class
{% endterminal %}

We have an `@all` instance variable in `IdeaStore`, we simply need to expose it:

```ruby
class IdeaStore
  def self.all
    @all
  end

  # ...
end
```

This changes the error message, giving us a different `NoMethodError`:

{% terminal %}
NoMethodError: undefined method `delete' for IdeaStore:Class
{% endterminal %}

We can change the error message again by defining an empty `delete` method:

```ruby
def self.delete
end
```

We get another familiar error message:

{% terminal %}
ArgumentError: wrong number of arguments (1 for 0)
{% endterminal %}

Fix it by adding an argument to the definition of `delete`:

```ruby
def self.delete(id)
end
```

This gives us a real failure:

{% terminal %}
Expected: ["dinner", "song"]
  Actual: ["dinner", "gift", "song"]
{% endterminal %}

We need to do actual work.

Our data is stored in an array, and there are several ways of deleting things from arrays.

* `Array#delete_if`
* `Array#delete_at`
* `Array#delete`

`delete_if` is an alias for `reject`, and it will delete all the items that match a given condition:

```ruby
all.delete_if do |idea|
  idea.id == id
end
```

That works, but it doesn't really communicate the fact that we only expect one particular idea to get deleted.

`delete_at` communicates this idea better: Delete just the idea that is at index `i` in the array. The only problem here is that we don't know where the idea is located in the array, so we'd have to:

1. find the idea
2. figure out what the index of that idea is
3. delete at the index

```ruby
idea = all.find(id)
index = all.index(idea)
all.delete_at(index)
```

That seems like a lot of work.

Our last option is `Array#delete`, and this one will delete an object from an array. We only have the id, so we need to find the idea first, and then we can delete it directly, without going via the index:

```ruby
idea = all.find(id)
all.delete(idea)
```

This seems like our best option, leaving the `Ideabox.delete` method looking like this:

```ruby
def self.delete(id)
  all.delete find(id)
end
```

The test is passing. Commit your changes.

## I6: Refactor

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