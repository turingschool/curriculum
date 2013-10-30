---
layout: page
title: IdeaBox TDD
sidebar: true
---

Every developer has more ideas than time. As David Allen likes to say "the human brain is for creating ideas, not remembering them." Let’s build a system to record your good, bad, and awful ideas.

And let’s use it as an excuse to learn about Sinatra.

## I0: Getting Started

### Environment Setup

For this project you need to have setup:

* Ruby 2.0.0
* Ruby's Bundler gem

### File/Folder Structure

Let's start our project with the minimum and build up from there. We need:

* a project folder
* a `Gemfile`
* a 'lib/ideabox' directory
* a 'test/ideabox' directory

### `Gemfile`

We're going to depend on one external gem in our `Gemfile`:

```ruby
source 'https://rubygems.org'

group :test do
  gem 'minitest'
end
```

Save that and, from your project directory, run `bundle` to install the
dependencies.

## I1: Defining Ideas

This project will use a fairly classic style of TDD. First we will implement
the core business logic using unit tests to drive the implementation and
design.

Once we have the business logic implemented, we can decide how we want people
to access the program.

This would make a very good command line application, so perhaps we'll add a
command line interface (CLI). Or, maybe we want to use this via a web
interface. We don't need to make that decision just yet.

### Writing the First Test

Create a simple ruby object that takes a title and a description:

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
touch lib/ideabox/idea.rb
{% endterminal %}

Run the test again. Now you should get the following message:

{% terminal %}
  1) Error:
IdeaTest#test_basic_idea:
NameError: uninitialized constant IdeaTest::Idea
    test/ideabox/idea_test.rb:8:in `test_basic_idea'
{% endterminal %}

We need to initialize a constant called `Idea`. Let's do this by creating a
class named `Idea` in the `lib/ideabox/idea.rb` file.

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

An Idea takes two arguments:

```ruby
Idea.new("a title", "a detailed and riveting description")
```

Right now the new Idea class has only the default initialize method, which
takes no arguments. We need to overwride this:

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

We can define a method `:title` using an `attr_reader`:

```ruby
class Idea
  attr_reader :title
  def initialize(title, description)
  end
end
```

Finally, we have our first failure:

{% terminal %}
  1) Failure:
IdeaTest#test_basic_idea [test/ideabox/idea_test.rb:9]:
Expected: "title"
  Actual: nil
{% endterminal %}

Make the expectation pass by assigning the `title` argument to an instance
variable:

```ruby
class Idea
  attr_reader :title
  def initialize(title, description)
    @title = title
  end
end
```

That makes the first assertion pass, which allows the test to blow up on the
next assertion:

{% terminal %}
  1) Error:
IdeaTest#test_basic_idea:
NoMethodError: undefined method `description' for #&lt;Idea:0x007f89532b1900 @title="title"&gt;
    test/ideabox/idea_test.rb:10:in `test_basic_idea'
{% endterminal %}

Add an attribute reader for `:description`, and run the test again. We get a
proper failure, and can fix it by assigning the incoming `description` to an
instance variable.

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

We also want to be able to rank ideas. The API for this will be to
say `like!` on the idea:

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
  1) Error:
IdeaTest#test_ideas_can_be_liked:
NoMethodError: undefined method `rank' for #&lt;Idea:0x007fd15b3fa460&gt;
    test/ideabox/idea_test.rb:15:in `test_ideas_can_be_liked'
{% endterminal %}

The `rank` method doesn't have any behavior per se, it's just reporting a
value. Let's create it using an `attr_reader`.

Running the tests again gives us a proper failure:

{% terminal %}
  1) Failure:
IdeaTest#test_ideas_can_be_liked [test/ideabox/idea_test.rb:15]:
Expected: 0
  Actual: nil
{% endterminal %}

The first assertion in the test is placed before anything happens. If we only
made an assertion after calling `like!` then we could have gotten the test to
pass by assigning an instance variable in the `initialize` method that
hard-coded the rank to `1`. We want to make sure that there's a reasonable
default **and** that calling `like!` changes the rank by the expected amount.

To give `rank` a reasonable default, assign an instance variable in the
`initialize` method with a value of 0.

This gets the first assertion passing, and we now get an error:

{% terminal %}
  1) Error:
IdeaTest#test_ideas_can_be_liked:
NoMethodError: undefined method `like!' for #&lt;Idea:0x007fa14bb4c7d0&gt;
    test/ideabox/idea_test.rb:16:in `test_ideas_can_be_liked'
{% endterminal %}

Undefined method `like!`. This needs to have behavior that changes the idea,
so a reader will not do. Define a method explicitly:

```ruby
def like!
end
```

Again, we get a proper failure:

{% terminal %}
 1) Failure:
IdeaTest#test_ideas_can_be_liked [test/ideabox/idea_test.rb:17]:
Expected: 1
  Actual: 0
{% endterminal %}

Make it pass by setting `@rank = 1` within the new `like!` method.

This gets the test passing.

Our implementation isn't bulletproof. No matter how many times we call `like!`
the rank will be `1`. We could just fix the implementation, but that would
mean that our test isn't as robust as it could be.

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

The full Idea class now looks like this:

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

  ideas = [diet, exercise, drink]

  assert_equal [diet, drink, exercise], ideas.sort
end
```

The error message we get for this test is a bit more cryptic than the previous
ones:

{% terminal %}
  1) Error:
IdeaTest#test_ideas_can_be_sorted_by_rank:
ArgumentError: comparison of Idea with Idea failed
    test/ideabox/idea_test.rb:33:in `sort'
    test/ideabox/idea_test.rb:33:in `test_ideas_can_be_sorted_by_rank'
{% endterminal %}

What does `comparison of Idea with Idea failed` even mean?

The `sort` method depends on a method known as _the spaceship operator_, which
is used to compare one object to another.

The spaceship operator looks like this: `<=>`, and can be defined like any
other method:

```ruby
def <=>(other)
  # comparison code here
end
```

This method should return either `-1` (meaning the first object should be
ordered _before_ the other), or `0` (meaning that the objects have equivalent
rank), or `1`, which means that the first object should be ordered _after_ the
second one.

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

The argument is named `other`, which is an idiomatic choice in Ruby, as well
as in many other languages.

Since we're comparing the idea's `rank`s, and `rank` is a `Fixnum`,
and `Fixnum` has defined the spaceship operator, we can refactor the
above to:

```ruby
def <=>(other)
  rank <=> other.rank
end
```

### Performing Conventional Comparisons

If we want to do more types of comparisons than just sorting, we could
include the `Comparable` in the `Idea` class. That would give us all the
conventional comparison operators (`<`, `<=`, `==`, `>=`, and `>`) as well as
a method called `between?`.

We don't really need all those methods. Besides, it would be kind of odd to
have the following:

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

Create a README, then initialize a git repository, and check your changes in:

{% terminal %}
git init
git add .
git commit -m "Implement `Idea`"
{% endterminal %}

## I2: Saving Ideas

We need to be able to organize ideas. We're going to create a class that
stores ideas.

### Starting With a Test

Once again we'll define what we want to happen by writing a test.

We want to:

* create an idea
* save it
* get it back out of the datastore (it should be the same idea)

Create an empty file `idea_store_test.rb` in the `test/ideabox` directory.

First, we need to include the testing dependencies themselves:

```ruby
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
```

Next, we want to create actual ideas, so we also need to require the `Idea`
class:

```ruby
require './lib/ideabox/idea'
```

Then we're going to need the class that actually does the work of storing the
ideas:

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

Run the test with `ruby test/ideabox/idea_store_test.rb`. The first failure
complains that there is no `idea_store` file:

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
  1) Error:
IdeaStoreTest#test_save_and_retrieve_an_idea:
NameError: uninitialized constant IdeaStoreTest::IdeaStore
    test/ideabox/idea_store_test.rb:10:in `test_save_and_retrieve_an_idea'
{% endterminal %}

Define an empty class in the `lib/ideabox/idea_store.rb` file:

```ruby
class IdeaStore
end
```

The next error complains about a missing method, `save`:

{% terminal %}
  1) Error:
IdeaStoreTest#test_save_and_retrieve_an_idea:
NoMethodError: undefined method `save' for IdeaStore:Class
    test/ideabox/idea_store_test.rb:10:in `test_save_and_retrieve_an_idea'
{% endterminal %}

Change the error message by defining an empty `save` method on the IdeaStore
class:

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

Previously, we've only sent the `new` message to a class, which gives us back
a new instance:

```ruby
idea = Idea.new("activity", "coloring with crayons")
```

And then we'd call methods on that instance:

```ruby
idea.rank
# => 0
```

Here we're sending the `save` method to the `IdeaStore` _class_, not an
instance of that class.

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

You can test this in IRB by copying and pasting the code into an IRB session,
and then saying:

{% irb %}
World.hello
World.new.hello
{% endirb %}

If that seems confusing, just roll with it for now, accepting that `def self.something` will let you send `something` directly to the class, whereas `def something` lets you send `something` to the instance.

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
  1) Error:
IdeaStoreTest#test_save_and_retrieve_an_idea:
ArgumentError: wrong number of arguments (1 for 0)
    /Users/kytrinyx/gschool/ideabox/lib/ideabox/idea_store.rb:2:in `save'
    test/ideabox/idea_store_test.rb:10:in `test_save_and_retrieve_an_idea'
{% endterminal %}

We need to accept an argument to the `save` method:

```ruby
def self.save(idea)
end
```

The error message has changed again:

{% terminal %}
  1) Error:
IdeaStoreTest#test_save_and_retrieve_an_idea:
NoMethodError: undefined method `count' for IdeaStore:Class
    test/ideabox/idea_store_test.rb:12:in `test_save_and_retrieve_an_idea'
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
  1) Failure:
IdeaStoreTest#test_save_and_retrieve_an_idea [test/ideabox/idea_store_test.rb:12]:
Expected: 1
  Actual: nil
{% endterminal %}

The failing line of code is this:

```ruby
assert_equal 1, IdeaStore.count
```

This makes sense, of course, since we're not doing any work in the `IdeaStore`
class yet.

Let's just fake it for now:

```ruby
def self.count
  1
end
```

We get a new error message:

{% terminal %}
  1) Error:
IdeaStoreTest#test_save_and_retrieve_an_idea:
NoMethodError: undefined method `find' for IdeaStore:Class
    test/ideabox/idea_store_test.rb:14:in `test_save_and_retrieve_an_idea'
{% endterminal %}

Add an empty find method:

```ruby
def self.find
end
```

The test complains that the method signature is incorrect:

{% terminal %}
  1) Error:
IdeaStoreTest#test_save_and_retrieve_an_idea:
ArgumentError: wrong number of arguments (1 for 0)
    /Users/kytrinyx/gschool/ideabox/lib/ideabox/idea_store.rb:9:in `find'
    test/ideabox/idea_store_test.rb:14:in `test_save_and_retrieve_an_idea'
{% endterminal %}

Correct that by providing an argument to `find`. We'll be finding by the ID of
the idea, so use `id` as the argument name:

```ruby
def self.find(id)
end
```

The next error message is going to be harder to fake:

{% terminal %}
  1) Error:
IdeaStoreTest#test_save_and_retrieve_an_idea:
NoMethodError: undefined method `title' for nil:NilClass
    test/ideabox/idea_store_test.rb:15:in `test_save_and_retrieve_an_idea'
{% endterminal %}

Let's do some real work.

There are two important pieces. First the `save` method has to store the idea
we give it, and second, the `find` method has to get it back out.

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

Let's make it so we can store and retrieve two different ideas. Update the
test:

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

The test is failing again, because we hard-coded the `count` method to return
1:

{% terminal %}
  1) Failure:
IdeaStoreTest#test_save_and_retrieve_ideas [test/ideabox/idea_store_test.rb:15]:
Expected: 2
  Actual: 1
{% endterminal %}

We can't just hard-code a return value of 2, because we now have two
different assertions for the `count` method.

We need to actually store the incoming ideas:

```ruby
def self.save(idea)
  @all ||= []
  @all << idea
end
```

And we also need to tell the `count` method to use the length of the array
with the saved ideas:

```ruby
def self.count
  @all.length
end
```

We're back to a failure when fetching the idea:

{% terminal %}
  1) Error:
IdeaStoreTest#test_save_and_retrieve_ideas:
NoMethodError: undefined method `title' for nil:NilClass
    test/ideabox/idea_store_test.rb:20:in `test_save_and_retrieve_ideas'
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

The information we have to go on is the `id`, but we haven't implemented an
`id` for the ideas yet.

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
IdeaStoreTest#test_save_and_retrieve_ideas:
NameError: undefined local variable or method `next_id' for IdeaStore:Class
    /Users/kytrinyx/gschool/ideabox/lib/ideabox/idea_store.rb:4:in `save'
    test/ideabox/idea_store_test.rb:10:in `test_save_and_retrieve_ideas'
{% endterminal %}

We need a `next_id` method.

For now, let's just create an empty one.

```ruby
def self.next_id
end
```

The next error is:

{% terminal %}
  1) Error:
IdeaStoreTest#test_save_and_retrieve_ideas:
NoMethodError: undefined method `id=' for #&lt;Idea:0x007fea5a390480&gt;
    /Users/kytrinyx/gschool/ideabox/lib/ideabox/idea_store.rb:4:in `save'
    test/ideabox/idea_store_test.rb:10:in `test_save_and_retrieve_ideas'
{% endterminal %}

This one is _not_ a complaint about the `IdeaStore` class, but a missing
method on the Idea instance.

We can't change the `Idea` class without changing the `IdeaTest` first, so
open up the `idea_test.rb` file and add a new test:

```ruby
def test_ideas_have_an_id
  idea = Idea.new("dinner", "beef stew")
  idea.id = 1
  assert_equal 1, idea.id
end
```

Run the idea test suite with `ruby test/ideabox/idea_test.rb`.

{% terminal %}
  1) Error:
IdeaTest#test_ideas_have_an_id:
NoMethodError: undefined method `id=' for #&lt;Idea:0x007fcd153214e8&gt;
    test/ideabox/idea_test.rb:15:in `test_ideas_have_an_id'
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
  1) Failure:
IdeaStoreTest#test_save_and_retrieve_ideas [test/ideabox/idea_store_test.rb:24]:
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

Remember back when we implemented the `next_id` method? Take another look at
it:

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

### Removing Duplication

Both of the test suites start with this code:

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

### Creating a `rake` task

If you want to run all of the tests, you have to say:

{% terminal %}
ruby test/ideabox/idea_test.rb
ruby test/ideabox/idea_store_test.rb
{% endterminal %}

That gets old really quickly. We need a simpler way to run the tests.

Create an empty file in the root of the project named `Rakefile`.

{% terminal %}
touch Rakefile
{% endterminal %}

In here we'll define a `rake` task that will run all of the tests, no matter
how many you define, provided that they live in the `test/` directory.

```ruby
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end
```

Run `rake -T` in your terminal to see what rake tasks are available to you:

{% terminal %}
$ rake -T
rake test  # Run tests
{% endterminal %}

Now you can run your tests with `rake test`.

We can make it even easier. Add this to the bottom of the Rakefile:

```ruby
task default: :test
```

Run your tests by calling `rake` by itself.

Much better! Commit your changes.

## I4: Editing Ideas

Sometimes an idea is OK but not great. We need to be able to improve our
ideas.

### Starting With a Test

In order to prove that we're able to update ideas, we need to

* start with an idea
* save it
* get it back out of the datastore
* change the values
* save it again
* find it again and see that it has all the new values

Another observation that is important here is that if we've saved a single
idea and updated it, the `count` of ideas in our datastore should be exactly
one.

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
  1) Error:
IdeaStoreTest#test_update_idea:
NoMethodError: undefined method `title=' for #<Idea:0x007fe25a2e4c28>
    test/ideabox/idea_store_test.rb:31:in `test_update_idea'
```

We're trying to change a read-only value on Idea.

Pop over to the `idea_test.rb` file and make sure that we can set a new title
and description on an idea.

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

The `idea_test.rb` test suite is passing, but the `idea_store_test.rb` one is
not.

{% terminal %}
  1) Failure:
IdeaStoreTest#test_update_idea [test/ideabox/idea_store_test.rb:36]:
Expected: 1
  Actual: 4
{% endterminal %}

It seems odd that we should have 4 ideas. The test only saves twice, so at the
most it should have 2 ideas.

What's happening is that the first test is creating two ideas in the
`IdeaStore` class, and then the second test is creating two more.

Tests that interfere with each other are not good. We need to clear out all
the ideas between each test.

Minitest provides us with two methods that can help us here. The `setup`
method runs before each individual test, and the `teardown` method runs after
each individual test.

We want to clean up after each test, so we'll use the `teardown` method:

```ruby
def teardown
  IdeaStore.delete_all
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
  1) Failure:
IdeaStoreTest#test_update_idea [test/ideabox/idea_store_test.rb:40]:
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

Open the `idea_test.rb` file and create a test for it:

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

That gets the test passing, but we're not quite there yet. Create another test
to force a real implementation:

```ruby
def test_an_old_idea
  idea = Idea.new('drink', 'lots of water')
  idea.id = 1
  refute idea.new?
end
```

To get the test to pass we'll say that an idea is `new?` if it doesn't have an
`id`:

```ruby
def new?
  !id
end
```

That gets that test passing. Let's pop back over to the `idea_store_test.rb`.
It turns out, all of the IdeaStore tests are passing as well.

We've finished the edit feature. Commit your changes.

## I5: Deleting Ideas

## I6: Persisting beyond a single request.

We can create ideas, but any ideas we create now are ephemeral. They last only
as long as the program is running... which in the case of our tests is less
than 200 milliseconds. If we make ideas in IRB they'll last until we quit IRB.

That's not very useful.

We need to be able to persist ideas beyond just the current running process.

## OLD STUFF

### EVERYTHING BEYOND HERE HAS NOT BEEN REVISED

Let's add a teardown in the test suite:

## Editing an idea


### Deleting an Idea

Start with a test:

```ruby
def test_delete_an_idea
  id1 = IdeaStore.save Idea.new("song", "99 bottles of beer")
  id2 = IdeaStore.save Idea.new("gift", "micky mouse belt")
  id3 = IdeaStore.save Idea.new("dinner", "cheeseburger with bacon and avocado")

  assert_equal ["song", "gift", "dinner"], IdeaStore.all.map(&:title)
  IdeaStore.delete(id2)
  assert_equal ["song", "dinner"], IdeaStore.all.map(&:title)
end
```

Make it pass.

Hint: You'll need the `Array#delete_at` method.

## Refactor!

This is what the full IdeaStore test suite looks like:

```ruby
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/ideabox/idea'
require './lib/ideabox/idea_store'

class IdeaStoreTest < Minitest::Test

  def teardown
    IdeaStore.delete_all
  end

  def test_save_and_retrieve_an_idea
    idea = Idea.new("celebrate", "with champagne")
    id = IdeaStore.save(idea)

    assert_equal 1, IdeaStore.count

    idea = IdeaStore.find(id)
    assert_equal "celebrate", idea.title
    assert_equal "with champagne", idea.description
  end

  def test_save_and_retrieve_on_of_many
    idea1 = Idea.new("relax", "in the sauna")
    idea2 = Idea.new("inspiration", "looking at the stars")
    idea3 = Idea.new("career", "translate for the UN")
    id1 = IdeaStore.save(idea1)
    id2 = IdeaStore.save(idea2)
    id3 = IdeaStore.save(idea3)

    assert_equal 3, IdeaStore.count

    idea = IdeaStore.find(id2)
    assert_equal "inspiration", idea.title
    assert_equal "looking at the stars", idea.description
  end
end
```

And this is my IdeaStore class:

```ruby
class IdeaStore
  def self.save(idea)
    @all ||= []
    id = next_id
    @all[id] = idea
    id
  end

  def self.find(id)
    @all[id]
  end

  def self.next_id
    @all.size
  end

  def self.count
    @all.length
  end

  def self.delete_all
    @all = []
  end
end
```

The Idea tests look like this:

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

  def test_ideas_can_be_liked
    idea = Idea.new("diet", "carrots and cucumbers")
    assert_equal 0, idea.rank # guard clause
    idea.like!
    assert_equal 1, idea.rank
  end

  def test_ideas_can_be_liked_more_than_once
    idea = Idea.new("exercise", "stickfighting")
    assert_equal 0, idea.rank # guard clause
    5.times do
      idea.like!
    end
    assert_equal 5, idea.rank
  end

  def test_ideas_can_be_sorted_by_rank
    diet = Idea.new("diet", "cabbage soup")
    exercise = Idea.new("exercise", "long distance running")
    exercise.like!

    ideas = [diet, exercise]

    assert_equal [exercise, diet], ideas.sort
  end
end
```

Finally, the Idea class looks like this:

```ruby
class Idea
  include Comparable

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
    rank <=> -other.rank
  end
end
```

All the basic functionality is in place. Let's clean up a little bit.

### Get Rid of `@all` Those Instance Variables

We have an `IdeaStore.all` method, let's use it:

```ruby
class IdeaStore
  def self.save(idea)
    idea.id ||= next_id
    all[idea.id] = idea
    idea.id
  end

  def self.all
    @all ||= []
  end

  def self.find(id)
    all[id]
  end

  def self.count
    all.length
  end

  def self.next_id
    all.size
  end

  def self.delete(id)
    all.delete_at(id)
  end

  def self.delete_all
    @all = []
  end
end
```

Next up: Let's create a test helper to reduce the duplication in the test suites:

Create a file `test/test_helper.rb`:

```ruby
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
```

Clean up the test suites:

```ruby
require './test/test_helper'
require './lib/ideabox/idea'

class IdeaTest < Minitest::Test
  # ...
end
```

```ruby
require './test/test_helper'
require './lib/ideabox/idea'
require './lib/ideabox/idea_store'

class IdeaStoreTest < Minitest::Test
  # ...
end
```

### Adding a default `rake` task

## Wiring up Sinatra and Rack::Test

We need to update the Gemfile:

```ruby
source 'https://rubygems.org'

gem 'sinatra', require: 'sinatra/base'

group :test do
  gem 'minitest', require: false
  gem 'rack-test', require: false
end
```

Then we need a test that will prove that we've wired everything up correctly:

```ruby
require './test/test_helper'
require 'sinatra/base'
require 'rack/test'
require './lib/app'

class IdeaboxAppHelper < Minitest::Test
  include Rack::Test::Methods

  def app
    IdeaboxApp
  end

  def test_hello
    get '/'
    assert_equal "Hello, World!", last_response.body
  end
end
```

This is failing. To get it to pass, create a file `lib/app.rb`:

```ruby
class IdeaboxApp < Sinatra::Base
  get '/' do
    "Hello, World!"
  end
end
```

It's all wired together. Let's make it actually render some ideas.

Replace the `test_hello` test with this test:

```ruby
def test_idea_list
  IdeaStore.save Idea.new("dinner", "spaghetti and meatballs")
  IdeaStore.save Idea.new("drinks", "imported beers")
  IdeaStore.save Idea.new("movie", "The Matrix")

  get '/'

  [
    /dinner/, /spaghetti/,
    /drinks/, /imported beers/,
    /movie/, /The Matrix/
  ].each do |content|
    assert_match content, last_response.body
  end
end
```

Since we're now creating ideas, it's breaking our other tests. We need to clean up after ourselves. Create a `teardown` method:

```ruby
def teardown
  IdeaStore.delete_all
end
```

To make the test pass we need to tell the application to render a view:

```ruby
require './lib/ideabox'

class IdeaboxApp < Sinatra::Base
  set :root, "./lib/app"

  get '/' do
    erb :index, locals: {ideas: IdeaStore.all}
  end
end
```

Notice the `set :root` line. That tells the Sinatra app to look for the view templates in a directory `lib/app/views`.

We don't want to require each individual file from the `app.rb`. Create a file `lib/ideabox.rb` with this in it:

```ruby
require './lib/ideabox/idea'
require './lib/ideabox/idea_store'
```

It still blows up, because we don't have a view. Create a file
`lib/app/views/index.erb`:

```ruby
<html>
  <head>
    <title>IdeaBox</title>
  </head>
  <body>
    <h1>Ideas</h1>
    <ul>
      <% ideas.each do |idea| %>
        <li><%= idea.title %> - <%= idea.description %></li>
      <% end %>
    </ul>
  </body>
</html>
```

This should get the test passing.

Commit your changes.

### Run it in the Browser

It's a web application, but we can't actually run it in the browser yet.

Change the `app.rb` file:

```ruby
require 'bundler'
Bundler.require
require './lib/ideabox'

class IdeaboxApp < Sinatra::Base
  set :root, "./lib/app"

  get '/' do
    erb :index, locals: {ideas: IdeaStore.all}
  end

  run! if app_file == $0
end
```

Now you can start the application like this:

{% terminal %}
ruby lib/app.rb
{% endterminal %}

Visit the application at [localhost:4567](http://localhost:4567).

There's nothing there, because we haven't added any ideas.

Also, this is not the standard way to organize a Sinatra app. Let's create a rackup file (`config.ru`) to run it.

```ruby
require 'bundler'
Bundler.require

require './lib/app'

run IdeaboxApp
```

Now clean up the `app.rb` file:

```ruby
require './lib/ideabox'

class IdeaboxApp < Sinatra::Base
  set :root, "./lib/app"

  get '/' do
    erb :index, locals: {ideas: IdeaStore.all}
  end

end
```

Kill the application and start it again like this:

{% terminal %}
rackup -p 4567
{% endterminal %}

Visit the browser. Our very minimal page is still working.

We can't actually add any ideas because there's no form to do so.

I guess we better add that.

## Adding an Input Form

Because filling in form fields is a pain, we're going to use Capybara to fill in the fields and submit the form, and verify that the page contains the new idea.

We need a couple more gems in the test group:

```ruby
gem 'capybara', require: false
gem 'minitest-capybara', require: false
```

Bundle.

Create a new directory:

```plain
test/acceptance/
```

Add a new file:

```plain
test/acceptance/idea_management_test.rb
```

```ruby
require './test/test_helper'
require 'bundler'
Bundler.require
require 'rack/test'
require 'capybara'
require 'capybara/dsl'

require './lib/app'

Capybara.app = IdeaboxApp

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :headers =>  { 'User-Agent' => 'Capybara' })
end

class IdeaManagementTest < Minitest::Test
  include Capybara::DSL

  def teardown
    IdeaStore.delete_all
  end

  def test_manage_ideas
    IdeaStore.save Idea.new("eat", "chocolate chip cookies")
    visit '/'
    assert page.has_content?("chocolate chip cookies")
  end
end
```

This test doesn't do anything interesting, it just verifies that our current index view is working as expected.

If the test suite blows up saying that it doesn't know anything about `Minitest::Test`, take a look at the version of minitest in your Gemfile.lock file.

It turns out that `minitest-capybara` has specified that it will only work with minitest v4.x, which is the old-school version.

To fix this, change `Minitest::Test` to `MiniTest::Unit::TestCase` everywhere.

Since we've managed to wire together Capybara and Minitest successfully, go ahead and commit your changes.

### Implementing a Real Acceptance Test

Capybara tests are end-to-end tests. They'll test an entire happy path of one feature. They're more like sagas than stories. Epic tails of resounding success. Failures should be tested in lower-level tests.

```ruby
def test_manage_ideas
  # Create an idea

  # Edit the idea

  # Delete the idea

end
```

We'll simulate a user who creates, edits, and deletes an idea.

This is the first part of the test:

```ruby
def test_manage_ideas
  # Create an idea
  visit '/'
  fill_in 'title', :with => 'eat'
  fill_in 'description', :with => 'chocolate chip cookies'
  click_button 'Save'
  assert page.has_content?("chocolate chip cookies"), "Idea is not on page"

  # Edit the idea

  # Delete the idea

end
```

To start making this pass we need to put a form in the `index.erb` page.

This is the updated index page:

```ruby
<html>
  <head>
    <title>IdeaBox</title>
  </head>
  <body>
    <h1>Add a new idea</h1>
    <form action='/' method='POST'>
      <input type='text' name='title'/><br/>
      <textarea name='description'></textarea><br/>
      <input type='submit' value="Save"/>
    </form>

    <h2>Your ideas</h2>
    <ul>
      <% ideas.each do |idea| %>
        <li><%= idea.title %> - <%= idea.description %></li>
      <% end %>
    </ul>
  </body>
</html>
```

That gets us half-way there, but when we click Save, we're stuck. We need a new endpoint in the application, `POST /`, and we don't want to be writing that without a controller test.

Put a `skip` in the capybara test, and go to the `app_test.rb` file.

```ruby
def test_create_idea
  post '/', title: 'costume', description: "scary vampire"

  assert_equal 1, IdeaStore.count

  idea = IdeaStore.all.first
  assert_equal "costume", idea.title
  assert_equal "scary vampire", idea.description
end
```

Make the test pass:

```ruby
post '/' do
  idea = Idea.new(params[:title], params[:description])
  IdeaStore.save(idea)
  redirect '/'
end
```

Now try unskipping the capybara test. It should pass.

Commit your changes.

### Editing Ideas

```ruby
def test_manage_ideas
  skip
  # Create a couple of decoys
  # This is so we know we're editing the right thing later
  IdeaStore.save Idea.new("laundry", "buy more socks")
  IdeaStore.save Idea.new("groceries", "macaroni, cheese")

  # Create an idea
  visit '/'
  # The decoys are there
  assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page"
  assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page"

  # Fill in the form
  fill_in 'title', :with => 'eat'
  fill_in 'description', :with => 'chocolate chip cookies'
  click_button 'Save'
  assert page.has_content?("chocolate chip cookies"), "Idea is not on page"

  # Find the idea - we need the ID to find
  # it on the page to edit it
  idea = IdeaStore.find_by_title('eat')

  # Edit the idea
  within("#idea_#{idea.id}") do
    click_link 'Edit'
  end

  assert_equal 'eat', find_field('title').value
  assert_equal 'chocolate chip cookies', find_field('description').value

  fill_in 'title', :with => 'eats'
  fill_in 'description', :with => 'chocolate chip oatmeal cookies'
  click_button 'Save'

  # Idea has been updated
  assert page.has_content?("chocolate chip oatmeal cookies"), "Updated idea is not on page"

  # Decoys are unchanged
  assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page"
  assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page"

  # Original idea (that got edited) is no longer there
  refute page.has_content?("chocolate chip cookies"), "Original idea is on page still"

  # Delete the idea

end
```

If you get stuck, try sticking `print page.html` at the place in your test where you're stuck.

Notice that we need an extra method on IdeaStore to get this working.

Add a test to the IdeaStoreTest:

```ruby
def test_find_by_title
  IdeaStore.save Idea.new("dance", "like it's the 80s")
  IdeaStore.save Idea.new("sleep", "like a baby")
  IdeaStore.save Idea.new("dream", "like anything is possible")

  idea = IdeaStore.find_by_title("sleep")

  assert_equal "like a baby", idea.description
end
```

Make it pass:

```ruby
def self.find_by_title(text)
  all.find do |idea|
    idea.title == text
  end
end
```

Then we need an edit link in the index page. Update the list of ideas:

```erb
<h2>Your ideas</h2>
 <ul>
   <% ideas.each do |idea| %>
     <li id="idea_<%= idea.id %>">
       <%= idea.title %> - <%= idea.description %>
       <a href="/<%= idea.id %>">Edit</a>
     </li>
   <% end %>
 </ul>
```

When we click Edit we need to go to a `GET /:id` url.

It doesn't have any fancy behavior, so let's create the endpoint for it in `app.rb`:

```ruby
get '/:id' do |id|
  idea = IdeaStore.find(id.to_i)
  erb :edit, locals: {idea: idea}
end
```

This requires an `edit.erb` view:

```erb
<html>
  <head>
    <title>IdeaBox</title>
  </head>
  <body>
    <h1>Edit your idea</h1>
    <form action="/<%= idea.id %>" method="POST">
      <input type="hidden" name="_method" value="PUT">
      <label for="title">Title</label>
      <input type='text' id="title" name="title" value="<%= idea.title %>"/><br/>
      <label for="description">Description</label>
      <textarea id="description" name="description"><%= idea.description %></textarea><br/>
      <input type='submit' value='Save'/>
    </form>
  </body>
</html>
```

At this point we can't get any further without a `PUT /:id` endpoint.

Since this has behavior we'll drop down into the `app_test.rb`.
Add a `skip` to the capybara test while we test drive the new behavior.

```ruby
def test_edit_idea
  id = IdeaStore.save Idea.new('sing', 'happy songs')

  put "/#{id}", {title: 'yodle', description: 'joyful songs'}

  assert_equal 302, last_response.status

  idea = IdeaStore.find(id)
  assert_equal 'yodle', idea.title
  assert_equal 'joyful songs', idea.description
end
```

Make it pass:

```ruby
put '/:id' do |id|
  idea = IdeaStore.find(id.to_i)
  idea.title = params[:title]
  idea.description = params[:description]
  IdeaStore.save(idea)
  redirect '/'
end
```

Now we have what we need to complete the capybara test. Unskip it.

It's still failing. We need to tell Sinatra that a parameter called `_method` is to be understood to be the HTTP verb so that it uses the `PUT /:id` endpoint to respond to the update form.

Add this inside the Sinatra app, right at the top:

```ruby
set :method_override, true
```

It now looks like this:

```ruby
class IdeaboxApp < Sinatra::Base
  set :method_override, true
  set :root, "./lib/app"

  # ...
end
```

### Deleting an idea

```ruby
def test_manage_ideas
  skip
  # Create a couple of decoys
  # This is so we know we're editing the right thing later
  IdeaStore.save Idea.new("laundry", "buy more socks")
  IdeaStore.save Idea.new("groceries", "macaroni, cheese")

  # Create an idea
  visit '/'
  # The decoys are there
  assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page"
  assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page"

  # Fill in the form
  fill_in 'title', :with => 'eat'
  fill_in 'description', :with => 'chocolate chip cookies'
  click_button 'Save'
  assert page.has_content?("chocolate chip cookies"), "Idea is not on page"

  # Find the idea - we need the ID to find
  # it on the page to edit it
  idea = IdeaStore.find_by_title('eat')

  # Edit the idea
  within("#idea_#{idea.id}") do
    click_link 'Edit'
  end

  assert_equal 'eat', find_field('title').value
  assert_equal 'chocolate chip cookies', find_field('description').value

  fill_in 'title', :with => 'eats'
  fill_in 'description', :with => 'chocolate chip oatmeal cookies'
  click_button 'Save'

  # Idea has been updated
  assert page.has_content?("chocolate chip oatmeal cookies"), "Updated idea is not on page"

  # Decoys are unchanged
  assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page after update"
  assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page after update"

  # Original idea (that got edited) is no longer there
  refute page.has_content?("chocolate chip cookies"), "Original idea is on page still"

  # Delete the idea
  within("#idea_#{idea.id}") do
    click_button 'Delete'
  end

  refute page.has_content?("chocolate chip oatmeal cookies"), "Updated idea is not on page"

  # Decoys are untouched
  assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page after delete"
  assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page after delete"

end
```

We need a delete button in the `index.erb`:

```erb
<h2>Your ideas</h2>
<ul>
  <% ideas.each do |idea| %>
    <li id="idea_<%= idea.id %>">
      <%= idea.title %> - <%= idea.description %>
      <a href="/<%= idea.id %>">Edit</a>
      <form action='/<%= idea.id %>' method='POST'>
        <input type="hidden" name="_method" value="DELETE">
        <input type='submit' value="Delete"/>
      </form>
    </li>
  <% end %>
</ul>
```

Once again, we need an endpoint that does more than render a view. Add a skip to the capybara test, and drop down to `app_test.rb`:

```ruby
def test_delete_idea
  id = IdeaStore.save Idea.new('breathe', 'fresh air in the mountains')

  assert_equal 1, IdeaStore.count

  delete "/#{id}"

  assert_equal 302, last_response.status
  assert_equal 0, IdeaStore.count
end
```

Make it pass:

```ruby
delete '/:id' do |id|
  IdeaStore.delete(id.to_i)
  redirect '/'
end
```

Unskip the capybara test.

It should be passing.

Commit your changes.

### Liking!

Add a new capybara test that clicks `+1` a number of times on different ideas and then verifies that the ideas are sorted in the expected order.

You will need to drop down to the `app_test.rb` to test drive the `like` endpoint in the sinatra application.

Here's the test I wrote:

```ruby
def test_ranking_ideas
  id1 = IdeaStore.save Idea.new("fun", "ride horses")
  id2 = IdeaStore.save Idea.new("vacation", "camping in the mountains")
  id3 = IdeaStore.save Idea.new("write", "a book about being brave")

  visit '/'

  idea = IdeaStore.all[1]
  idea.like!
  idea.like!
  idea.like!
  idea.like!
  idea.like!
  IdeaStore.save(idea)

  within("#idea_#{id2}") do
    3.times do
      click_button '+'
    end
  end

  within("#idea_#{id3}") do
    click_button '+'
  end

  # now check that the order is correct
  ideas = page.all('li')
  assert_match /camping in the mountains/, ideas[0].text
  assert_match /a book about being brave/, ideas[1].text
  assert_match /ride horses/, ideas[2].text
end
```

I had to add another button form on the index page:

```erb
<h2>Your ideas</h2>
<ul>
  <% ideas.each do |idea| %>
    <li id="idea_<%= idea.id %>">
      <%= idea.rank %>: <%= idea.title %> - <%= idea.description %>
      <a href="/<%= idea.id %>">Edit</a>
      <form action='/<%= idea.id %>' method='POST'>
        <input type="hidden" name="_method" value="DELETE">
        <input type='submit' value="Delete"/>
      </form>
      <form action='/<%= idea.id %>/like' method='POST' style="display: inline">
        <input type='submit' value="+"/>
      </form>
    </li>
  <% end %>
</ul>
```

Then I had to send a sorted list of ideas to the index page from the controller:

```ruby
erb :index, locals: {ideas: IdeaStore.all.sort.reverse}
```

Refactor where appropriate.

### Next Up:

Start using a `YAML::Store` so that your ideas persist when you shut down your server. You shouldn't have to change any tests.

You'll need a different database file for the test environment and the development environment.

