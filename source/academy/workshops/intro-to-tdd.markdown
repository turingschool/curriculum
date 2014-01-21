---
layout: page
title: Intro to TDD
sidebar: true
---

The Ruby community is healthily obsessed with testing. Let's look at how to get started with Test Driven Development (TDD).

## Learning Goals

* How to read basic Ruby error messages
* Understand assertions
* Know how to fix both error messages and failing assertions

We'll be implementing a small unicorn class using TDD. The basic requirements of this project are that unicorns have names, they are usually white (but can be any color), and that they say sparkly things.

## Setup

There are lots of libraries that help you write tests, and we're going to use one of the simplest ones: Minitest.

Minitest comes with Ruby by default, but we're going to go get the latest version by installing the gem manually:

{% terminal %}
$ gem install minitest
{% endterminal %}

We need a place to put our code while working. Create an empty directory, and change into it:

{% terminal %}
$ mkdir unicorn
$ cd unicorn
{% endterminal %}

## Experimenting with minitest

Create an empty file called `unicorn_test.rb`, and open it in your text
editor.

### Configuring Minitest

Because minitest is included with Ruby, we need a slightly unusual instruction to tell Ruby to use the gem version rather than the built in one. Stick this at the top of the
`unicorn_test.rb` file:

```ruby
gem 'minitest', '~> 5.0'
```

Now that we've told our code where to find minitest, we need to tell it to
actually load it:

```ruby
require 'minitest/autorun'
```

This next bit is not strictly necessary, but I TDD is way better with colors:

```ruby
require 'minitest/pride'
```

It gives you pretty colors in your terminal when you run your tests.

### Starting the Suite

A test suite is a collection of tests. Each test in the collection is an
example of using the code we write, and proves that -- for this particular
case -- the code works.

Still in `unicorn_test.rb`, we create a new test suite by defining a class that inherits from
`Minitest::Test`:

```ruby
class UnicornTest < Minitest::Test
end
```

To add a test inside the class, we add a method whose name starts with `test`:

```ruby
class UnicornTest < Minitest::Test
  def test_something
  end
end
```

### Running the Suite

Save the file and run it by executing the following command in your terminal
(you need to be in the same directory as the `unicorn_test.rb` file):

{% terminal %}
$ ruby unicorn_test.rb
{% endterminal %}

```plain
# Running:

.

Fabulous run in 0.003111s, 321.4401 runs/s, 0.0000 assertions/s.

1 runs, 0 assertions, 0 failures, 0 errors, 0 skips
```

When you run the test, you'll get a **dot** for each passing test. Let's add 
more tests:

```ruby
class UnicornTest < Minitest::Test
  def test_something
  end

  def test_something_else
  end

  def test_yet_another_thing
  end
end
```

Run the test suite again:

{% terminal %}
# Running:

...

Fabulous run in 0.001829s, 1640.2406 runs/s, 0.0000 assertions/s.

3 runs, 0 assertions, 0 failures, 0 errors, 0 skips
{% endterminal %}

Three tests, three dots.

### Test Assertions

If you look at the bottom line, though, it says that it has 3 runs, but 0
assertions.

The dictionary says:

> assertion |əˈsəːʃ(ə)n|
> noun
> a confident and forceful statement of fact or belief

So while our test suite is passing, it's not making any confident and forceful
statements of fact or belief. In other words, the only reason it's currently
passing, is because it isn't failing. And the only reason it's not failing, is
because it's not even trying.

There's a moral lesson in there somewhere.

#### Adding Assertions

Let's give the test suite some work to do:

```ruby
class UnicornTest < Minitest::Test
  def test_something
    assert_equal 3, 1 + 1
  end

  def test_something_else
  end

  def test_yet_another_thing
  end
end
```

`assert_equal` is a method that comes with minitest. It takes two parameters,
the `expected` value first followed by the `actual` value.

In this test we're making a forceful statement of fact or belief that `1 + 1`
should equal 3.

Run the test again:

{% terminal %}
$ ruby unicorn_test.rb
{% endterminal %}

Unsurprisingly, the output tells you that the test is failing:

```plain
# Running:

.F.

Fabulous run in 0.035829s, 83.7311 runs/s, 27.9104 assertions/s.

  1) Failure:
UnicornTest#test_something [unicorn_test.rb:6]:
Expected: 3
  Actual: 2

3 runs, 1 assertions, 1 failures, 0 errors, 0 skips
```

Two dots, one `F`.

### Thinking About Order

Run the test suite a few times in a row, and look at the dots and the `F`:

```plain
F..
```

```plain
..F
```

```plain
..F
```

```plain
.F.
```

Minitest randomizes the order that your tests get run in. This ensures that
each test runs independently of each other. If they don't then your test suite
will fail... sometimes. That can be very frustrating.

### Reading the Failure

In addition to telling you that a test is failing, the output also tells us
quite a bit about the failure:

```plain
UnicornTest#test_something [unicorn_test.rb:6]:
```

The first part, `UnicornTest` tells you which test suite contains the
failure. Since we only have one test suite right now, that's always going to
be `UnicornTest`.

Then there's a pound sign and the name of the test that's
failing: `test_something`. Since we only have one test with assertions, this isn't very
surprising either.

Inside the square brackets, it tells us the name of the file that contains the
failing test: `unicorn_test.rb`. This is extremely helpful when you have a
project with hundreds of files with tests in it.

Next, it tells you exactly which line of code that is actually blowing up: `:6`.

### A Passing Test

Let's make the test pass:

```ruby
def test_something
  assert_equal 2, 1 + 1
end
```

```plain
# Running:

...

Fabulous run in 0.001997s, 500.7511 runs/s, 500.7511 assertions/s.

3 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

Take a look at the summary. We've got three runs (a.k.a. tests), one assertion, and zero failures.

```plain
3 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

We also have zero errors and zero skips.

### Errors Are Different

Let's introduce an error:

```ruby
class UnicornTest < Minitest::Test
  def test_something
    assert_equal 2, 1 + 1
  end

  def test_something_else
    assert_equal 1, nil - 1
  end

  def test_yet_another_thing
  end
end
```

If you run that, you'll get:

```plain
# Running:

.E.

Finished in 0.001890s, 1587.3016 runs/s, 529.1005 assertions/s.

  1) Error:
UnicornTest#test_something_else:
NoMethodError: undefined method `-' for nil:NilClass
    unicorn_test.rb:10:in `test_something_else'

3 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

2 dots, one `E`. The summary says we have one error, and the output tells us a
bit about it:

```plain
UnicornTest#test_something_else:
```

It's happening in the `UnicornTest` test suite, in a test named
`test_something_else`.

```plain
NoMethodError: undefined method `-' for nil:NilClass
```

It's a `NoMethodError`, and it's saying that we can't subtract from `nil`,
because `nil` doesn't have a minus method.

Then it tells us that it's blowing up on line 10 of the test suite:

```plain
unicorn_test.rb:10
```

### Skipping

Now add `skip` to the top of the test with the error in it:

```ruby
def test_something_else
  skip
  assert_equal 1, nil - 1
end
```

Run the test again:

```plain
# Running:

.S.

Finished in 0.003375s, 888.8889 runs/s, 296.2963 assertions/s.

3 runs, 1 assertions, 0 failures, 0 errors, 1 skips

You have skipped tests. Run with --verbose for details.
```

So `skip`ping a test means that it won't be reported as an error or failure.
This can be helpful if you have a lot of failures and want to focus on one at
a time -- just skip the ones you want to ignore for a while, and then delete
the `skip` in one test at a time.

#### Back to Passing

Now get the test passing by replacing `nil` with `2`:

```ruby
def test_something_else
  assert_equal 1, 2 - 1
end
```

OK, we're ready to start our Unicorn. Delete all the *something* tests from `unicorn_test.rb`

## A Unicorn Has a Name

Remember that a Unicorn:

* has a name.
* has a color, though it's normally white
* says sparkly things.

### Getting Started

Your `unicorn_test.rb` should currently look like this:

```ruby
gem 'minitest', '~> 5.0'
require 'minitest/autorun'
require 'minitest/pride'

class UnicornTest < Minitest::Test
end
```

### A First Test

Now, we'll create the first, empty test for the first requirement: Unicorns
have names.

```ruby
class UnicornTest < Minitest::Test
  def test_it_has_a_name
  end
end
```

And now, we're ready to make a bold statement about how unicorns are named.

### Writing the Assertion

We haven't written any implementation code, so we're going to do some wishful thinking. When
we create a new unicorn, we'll want to tell it what its name is like this:

```ruby
Unicorn.new("Robert")
```

Let's add some code to the test with that behavior:

```ruby
def test_it_has_a_name
  Unicorn.new("Robert")
end
```

#### Forceful Statement of Truth

This isn't a forceful statement of truth, this is creating a unicorn and then
not doing anything with it.

We need to make an assertion:

```ruby
def test_it_has_a_name
  Unicorn.new("Robert")
  assert_equal expected, actual
end
```

#### Expected Value

So what is `expected` here? Well, we called the unicorn "Robert", so that
would be the expected result:

```ruby
def test_it_has_a_name
  Unicorn.new("Robert")
  assert_equal "Robert", actual
end
```

#### Actual Value

Now, what is `actual`? How do we ask a unicorn about its name? Probably like this:

```ruby
unicorn.name
```

So in the test:

```ruby
def test_it_has_a_name
  Unicorn.new("Robert")
  assert_equal "Robert", unicorn.name
end
```

#### What is `unicorn`?

Better, but this isn't going to work, because we never defined `unicorn`. We
have to save our new unicorn to a local variable:

```ruby
def test_it_has_a_name
  unicorn = Unicorn.new("Robert")
  assert_equal "Robert", unicorn.name
end
```

#### Run the Test

Finally, we have made a forceful statement of fact about how unicorns are
named. With all of this in place, the test suite now looks like this:

```ruby
gem 'minitest', '~> 5.0'
require 'minitest/autorun'
require 'minitest/pride'

class UnicornTest < Minitest::Test
  def test_it_has_a_name
    unicorn = Unicorn.new("Robert")
    assert_equal "Robert", unicorn.name
  end
end
```

Run the tests:

{% terminal %}
$ ruby unicorn_test.rb
{% endterminal %}

```plain
# Running:

E

Fabulous run in 0.001640s, 609.7561 runs/s, 0.0000 assertions/s.

  1) Error:
UnicornTest#test_it_has_a_name:
NameError: uninitialized constant UnicornTest::Unicorn
    unicorn_test.rb:7:in `test_it_has_a_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
```

The lonely `E` means `error`, and the actual error that we received is a
`NameError`:

```plain
NameError: uninitialized constant UnicornTest::Unicorn
```

### Loading `Unicorn`

The test code uses `Unicorn.new`, but Ruby doesn't know about any class `Unicorn`. The
reason it says `UnicornTest::Unicorn` rather than just `Unicorn` is because
we're inside the `UnicornTest` class when we call `Unicorn.new`.

We're going to create a `Unicorn` and put it in its own file. So
lets pretend we have already created that and require it from the tests, right below
the `minitest/pride` line:

```ruby
require_relative 'unicorn'
```

`require_relative` means _look for a file named `unicorn.rb` in the directory
path relative to the current file that we're in_. So here we'll look for a
file named `unicorn.rb` in the same directory as `unicorn_test.rb`.

The test now looks like this:

```ruby
gem 'minitest', '~> 5.0'
require 'minitest/autorun'
require 'minitest/pride'
require_relative 'unicorn'

class UnicornTest < Minitest::Test
  def test_it_has_a_name
    unicorn = Unicorn.new("Robert")
    assert_equal "Robert", unicorn.name
  end
end
```

#### Did the Unicorn Magically Appear?

Running it blows up:

```plain
unicorn_test.rb:4:in `require_relative': cannot load such file -- /Users/you/code/unicorn/unicorn (LoadError)
	from unicorn_test.rb:4:in `<main>'
```

The error we're getting is `LoadError`, which is Ruby's way of saying that
it's trying to load a file but can't find it.

That's because it doesn't exist. 

#### Making a `unicorn.rb`

If we create an empty file, we'll fix
the `LoadError`:

```bash
$ touch unicorn.rb
```

Now we are back to the same error as before (`NameError`):

```plain
# Running:

E

Fabulous run in 0.001814s, 551.2679 runs/s, 0.0000 assertions/s.

  1) Error:
UnicornTest#test_it_has_a_name:
NameError: uninitialized constant UnicornTest::Unicorn
    unicorn_test.rb:8:in `test_it_has_a_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
```

#### Defining the `Unicorn` Class

We can fix the name error my creating an empty class inside the new
`unicorn.rb` file:

```ruby
class Unicorn
end
```

### Argument to Initialize

Run the tests again, and we get a new error:

```plain
# Running:

E

Fabulous run in 0.001844s, 542.2993 runs/s, 0.0000 assertions/s.

  1) Error:
UnicornTest#test_it_has_a_name:
ArgumentError: wrong number of arguments(1 for 0)
    unicorn_test.rb:8:in `initialize'
    unicorn_test.rb:8:in `new'
    unicorn_test.rb:8:in `test_it_has_a_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
```

An argument error means that we're calling a method wrong. In this case it's
in the `initialize` method that gets called when we call `new`.

#### The Default `initialize`

Our unicorn has an `initialize` method, even though it looks pretty empty right
now:

```ruby
class Unicorn
end
```

This is the same as:

```ruby
class Unicorn
  def initialize
  end
end
```

When we say: `Unicorn.new`, if `Unicorn` doesn't define an `initialize` method, then the `initialize` in the class `Object` is run. `Object` is the class that all other Ruby classes inherit from. But its `initialize` doesn't do anything. 

Back to the error message. It says:

```plain
ArgumentError: wrong number of arguments(1 for 0)
```

That means that our tests are calling `initialize` with one argument, but it doesn't
accept any arguments.

In other words, we're saying `Unicorn.new("Robert")`, but `initialize` is
defined like this:

```ruby
def initialize
end
```

We need to make it so `initialize` accepts the argument:

```ruby
class Unicorn
  def initialize(name)
  end
end
```

### What's in a `.name`?

Run the tests.

```plain
# Running:

E

Fabulous run in 0.003082s, 324.4646 runs/s, 0.0000 assertions/s.

  1) Error:
UnicornTest#test_it_has_a_name:
NoMethodError: undefined method `name' for #<Unicorn:0x007f85f9bddfb8>
    unicorn_test.rb:9:in `test_it_has_a_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
```

That gives us a new error message:

```plain
NoMethodError: undefined method `name'
```

A `NoMethodError` means that when we say `unicorn.name`, the unicorn tries to
find a method named `name` to run.

#### Adding a `name` method

Unicorn doesn't have a method called `name`. That's easy enough to fix, we'll
create one:

```ruby
class Unicorn
  def initialize(name)
  end

  def name
  end
end
```

Run the tests again.

```plain
# Running:

F

Fabulous run in 0.026091s, 38.3274 runs/s, 38.3274 assertions/s.

  1) Failure:
UnicornTest#test_it_has_a_name [unicorn_test.rb:9]:
Expected: "Robert"
  Actual: nil

1 runs, 1 assertions, 1 failures, 0 errors, 0 skips
```

#### The Dummy Implementation

Now, finally, instead of an error, we get a failure. We'll fix it, but only barely:

```ruby
class Unicorn
  def initialize(name)
  end

  def name
    "Robert"
  end
end
```

This won't work for all unicorns, but it should be good enough to get the test
passing:


```plain
# Running:

.

Fabulous run in 0.001872s, 534.1880 runs/s, 534.1880 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

#### Maybe All Unicorns Are Named "Robert"

Fine, the test is passing, but we have a problem. All unicorns are now named
Robert.

Try it in IRB:

{% irb %}
require './unicorn'
{% endirb %}

The `./` part means "Look in the current directory for a file named
`unicorn.rb`".

{% irb %}
Unicorn.new("Forrest").name
=> "Robert"
Unicorn.new("Damien").name
=> "Robert"
{% endirb %}

Our test suite needs to be smarter. It needs to force us into implementing a
more robust naming mechanism.

### Triangulation Tests

We'll create a second test to triangulate the behavior that we want.

```ruby
class UnicornTest < Minitest::Test
  def test_it_has_a_name
    unicorn = Unicorn.new("Robert")
    assert_equal "Robert", unicorn.name
  end

  def test_it_can_be_named_something_else
    unicorn = Unicorn.new("Joseph")
    assert_equal "Joseph", unicorn.name
  end
end
```

As expected, it fails.

```plain
# Running:

F.

Fabulous run in 0.026494s, 75.4888 runs/s, 75.4888 assertions/s.

  1) Failure:
UnicornTest#test_it_can_be_named_something_else [unicorn_test.rb:14]:
Expected: "Joseph"
  Actual: "Robert"

2 runs, 2 assertions, 1 failures, 0 errors, 0 skips
```

We are passing the name in when we call Unicorn.new, so our initialize method
is receiving it. We need a way to save it from the argument into the object.

#### Storing the Passed-In Name

We'll use an instance variable:

```ruby
class Unicorn
  def initialize(name)
    @name = name
  end

  def name
    @name
  end
end
```

That gets the test passing:

```plain
# Running:

..

Fabulous run in 0.001821s, 1098.2976 runs/s, 1098.2976 assertions/s.

2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

Our tests have guided us towards an implementation.

## Unicorns Are White

The next requirement says that unicorns are
usually white, but can be any color. That sounds like more than one
requirement, so let's focus on the first part.

### Testing Color

Let's see that a Unicorn is white when we haven't specified any other color:

```ruby
class UnicornTest < Minitest::Test
  def test_it_has_a_name
    # ...
  end

  def test_it_can_be_named_something_else
    # ...
  end

  def test_it_is_white_by_default
    unicorn = Unicorn.new("Margaret")
    assert_equal "white", unicorn.color
  end
end
```

### Unicorns Have No Color?

Running the test gives us an error:

```plain
# Running:

E..

Fabulous run in 0.002155s, 1392.1114 runs/s, 928.0742 assertions/s.

  1) Error:
UnicornTest#test_it_is_white_by_default:
NoMethodError: undefined method `color' for #<Unicorn:0x007f82ecc96cf8 @name="Margaret">
    unicorn_test.rb:19:in `test_it_is_white_by_default'

3 runs, 2 assertions, 0 failures, 1 errors, 0 skips
```

A `NoMethodError`. 

#### Splash of `color`

That's easy to fix, we'll just add a method `color`:

```ruby
class Unicorn
  def initialize(name)
    @name = name
  end

  def name
    @name
  end

  def color
  end
end
```

#### See the Output Change

It doesn't do anything yet, but it should be enough to change the output from
the test, and the new output from the test should tell us what to do next:

```plain
# Running:

.F.

Fabulous run in 0.025715s, 116.6634 runs/s, 116.6634 assertions/s.

  1) Failure:
UnicornTest#test_it_is_white_by_default [unicorn_test.rb:19]:
Expected: "white"
  Actual: nil

3 runs, 3 assertions, 1 failures, 0 errors, 0 skips
```

This is a failed expectation, meaning that our logic in the `color` method is
wrong. That makes sense, since the logic in the `color` method is missing entirely.

#### A Dummy Response

To get the test passing, we can hard-code "white" as the response:

```ruby
class Unicorn
  def initialize(name)
    @name = name
  end

  def name
    @name
  end

  def color
    "white"
  end
end
```

That gets the test passing.

```plain
# Running:

...

Fabulous run in 0.004366s, 687.1278 runs/s, 687.1278 assertions/s.

3 runs, 3 assertions, 0 failures, 0 errors, 0 skips
```

### A `white?` Method

In addition to asking the Unicorn what its color is, let's also make it so we
can ask it if it is white:

```ruby
unicorn.white?
# true or false
```

In Ruby a method can end with a question-mark, and that typically is used as a signal that this the method returns true or false.

The test looks like this:

```ruby
class UnicornTest < Minitest::Test
  def test_it_has_a_name
    # ...
  end

  def test_it_can_be_named_something_else
    # ...
  end

  def test_it_is_white_by_default
    # ...
  end

  def test_it_knows_if_it_is_white
    unicorn = Unicorn.new("Elisabeth")
    assert_equal true, unicorn.white?
  end
end
```

So the test will pass if `white?` returns true, and it will fail if it returns
false.

#### About `assert`

This is such a common test case, that minitest has a special method to assert
that the response should be `true`: `assert`, rather than `assert_equal`.

```ruby
def test_it_knows_if_it_is_white
  unicorn = Unicorn.new("Elisabeth")
  assert unicorn.white?
end
```

The test is going to blow up, of course, because we don't have code to support
the feature yet:

```plain
# Running:

...E

Fabulous run in 0.002220s, 1801.8018 runs/s, 1351.3514 assertions/s.

  1) Error:
UnicornTest#test_it_knows_if_it_is_white:
NoMethodError: undefined method `white?' for #<Unicorn:0x007f95749d0880 @name="Elisabeth", @color="white">
    unicorn_test.rb:24:in `test_it_knows_if_it_is_white'

4 runs, 3 assertions, 0 failures, 1 errors, 0 skips
```

### Implementing `white?`

As usual, we can fix a `NoMethodError` by defining the empty method:

```ruby
class Unicorn
  def initialize(name)
    @name = name
  end

  def name
    @name
  end

  def color
    "white"
  end

  def white?
  end
end
```

Running the test again gives us new output. A failure this time:

```plain
# Running:

.F..

Fabulous run in 0.002242s, 1784.1213 runs/s, 1784.1213 assertions/s.

  1) Failure:
UnicornTest#test_it_knows_if_it_is_white [unicorn_test.rb:24]:
Failed assertion, no message given.

4 runs, 4 assertions, 1 failures, 0 errors, 0 skips
```

When we were using `assert_equal` we got output that said:

```plain
Expected: "Robert"
  Actual: nil
```

Instead, it says:

```plain
Failed assertion, no message given.
```

#### Defining a Message for `assert`

The `Failed assertion` bit seems fairly straight-forward.

When we use `assert` rather than `assert_equal` the error message is
different. We know what the expected value is (true), and if it's not true,
then presumably it's `false`.

What about the `no message given` bit, though? What message is that?

Let's tweak the test a bit:

```ruby
def test_it_knows_if_it_is_white
  unicorn = Unicorn.new("Elisabeth")
  assert unicorn.white?, "Elisabeth should be white, but isn't."
end
```

Run the test again:

```plain
# Running:

F...

Fabulous run in 0.002331s, 1716.0017 runs/s, 1716.0017 assertions/s.

  1) Failure:
UnicornTest#test_it_knows_if_it_is_white [unicorn_test.rb:24]:
Elisabeth should be white, but isn't.

4 runs, 4 assertions, 1 failures, 0 errors, 0 skips
```

Now, instead of `Failed assertion, no message given.`, the failure output
says `Elisabeth should be white, but isn't`. This is a message to the
programmer. It has nothing to do with production code, it's just some helpful
context from your test to you.

#### Is `nil` the same as `false`?

OK, so back to the error message. The test will pass if `white?` returns true,
but the test is failing. What is `white?` returning? What does the method look
like?

```ruby
def white?
end
```

Wait, that's not returning `false`, it's returning `nil`.

In Ruby we talk about something being **truthy** or **falsy**, and there are
exactly two objects that are falsy: `nil`, and `false`. All other objects are
truthy. The string "hello". The number 39. An instance of `unicorn`. They're
all truthy.

So when we say `assert unicorn.white?` then as long as `white?` returns a
truthy value, the test will pass.

It's currently returning `nil`, which is falsy, so the test is failing.

#### Always True

Make it pass by hard-coding `true` as the return value:

```ruby
class Unicorn
  def initialize(name)
    @name = name
  end

  def name
    @name
  end

  def color
    "white"
  end

  def white?
    true
  end
end
```

Run the tests and they should pass.

```plain
# Running:

....

Fabulous run in 0.006829s, 585.7373 runs/s, 585.7373 assertions/s.

4 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### Purple Unicorns

OK, so we've got the name thing working. Unicorns are white by default (and
they know it). Let's make a purple unicorn:

```ruby
class UnicornTest < Minitest::Test
  def test_it_has_a_name
    # ...
  end

  def test_it_can_be_named_something_else
    # ...
  end

  def test_it_is_white_by_default
    # ...
  end

  def test_it_does_not_have_to_be_white
    unicorn = Unicorn.new("Barbara", "purple")
    assert_equal "purple", unicorn.color
  end
end
```

This blows up:

```plain
# Running:

..E.

Fabulous run in 0.003224s, 1240.6948 runs/s, 1550.8685 assertions/s.

  1) Error:
UnicornTest#test_it_does_not_have_to_be_white:
ArgumentError: wrong number of arguments (2 for 1)
    /Users/you/code/unicorn/unicorn.rb:2:in `initialize'
    unicorn_test.rb:25:in `new'
    unicorn_test.rb:25:in `test_it_does_not_have_to_be_white'

4 runs, 5 assertions, 0 failures, 1 errors, 0 skips
```

The error is an `ArgumentError`, which means that we're calling a method
wrong. Which method? `initialize`. Who calls `initialize`? `new` does.

The error says `2 for 1` meaning that we're giving it two arguments, but it
only takes one.

#### Multiple Arguments to `initialize`

What we gave it:

```ruby
Unicorn.new("Barbara", "purple")
```

What it expects:

```ruby
def initialize(name)
  # ...
end
```

Change the code so that the `initialize` method accepts two arguments, one for
name and one for color:

```ruby
class Unicorn
  def initialize(name, color)
    @name = name
  end

  def name
    @name
  end

  def color
    "white"
  end

  def white?
    true
  end
end
```

#### See the Results

Run the tests:

```plain
# Running:

EEFEE

Fabulous run in 0.043899s, 113.8978 runs/s, 22.7796 assertions/s.

  1) Error:
UnicornTest#test_it_can_be_named_something_else:
ArgumentError: wrong number of arguments (1 for 2)
    /Users/kytrinyx/gschool/here-comes-the-unicorn/unicorn.rb:4:in `initialize'
    unicorn_test.rb:13:in `new'
    unicorn_test.rb:13:in `test_it_can_be_named_something_else'


  2) Error:
UnicornTest#test_it_is_white_by_default:
ArgumentError: wrong number of arguments (1 for 2)
    /Users/kytrinyx/gschool/here-comes-the-unicorn/unicorn.rb:4:in `initialize'
    unicorn_test.rb:18:in `new'
    unicorn_test.rb:18:in `test_it_is_white_by_default'


  3) Failure:
UnicornTest#test_it_does_not_have_to_be_white [unicorn_test.rb:29]:
Expected: "purple"
  Actual: "white"


  4) Error:
UnicornTest#test_it_has_a_name:
ArgumentError: wrong number of arguments (1 for 2)
    /Users/kytrinyx/gschool/here-comes-the-unicorn/unicorn.rb:4:in `initialize'
    unicorn_test.rb:8:in `new'
    unicorn_test.rb:8:in `test_it_has_a_name'


  5) Error:
UnicornTest#test_it_knows_if_it_is_white:
ArgumentError: wrong number of arguments (1 for 2)
    /Users/kytrinyx/gschool/here-comes-the-unicorn/unicorn.rb:4:in `initialize'
    unicorn_test.rb:23:in `new'
    unicorn_test.rb:23:in `test_it_knows_if_it_is_white'

5 runs, 1 assertions, 1 failures, 4 errors, 0 skips
```

*What just happened?* Look at the summaries:

```plain
EEFEE
```

```plain
5 runs, 1 assertions, 1 failures, 4 errors, 0 skips
```

Not a single test is passing. Let's look at all those errors:

```plain
  1) Error:
ArgumentError: wrong number of arguments (1 for 2)

  2) Error:
ArgumentError: wrong number of arguments (1 for 2)

  4) Error:
ArgumentError: wrong number of arguments (1 for 2)

  5) Error:
ArgumentError: wrong number of arguments (1 for 2)
```

It's the same error four times.

It says we're sending one argument, but the method is defined to take two.

This is why:

```plain
# test 1
unicorn = Unicorn.new("Robert")

# test 2
unicorn = Unicorn.new("Joseph")

# test 3
unicorn = Unicorn.new("Margaret")

# test 4
unicorn = Unicorn.new("Elisabeth")
```

But we just changed the code to look like this:

```ruby
def initialize(name, color)
  @name = name
end
```

We're in a bit of a bind. Most of the tests need this:

```ruby
def initialize(name)
  @name = name
end
```

But one of the tests needs this:

```ruby
def initialize(name, color)
  @name = name
end
```

We could change all the other tests to take "white", but that would defeat the
purpose. The unicorn is white by *default*. That means we shouldn't have to
specify it.

#### A Default Argument

Ruby gives us a way to define a default value for an argument:

```ruby
class Unicorn
  def initialize(name, color="purple")
    @name = name
  end

  def name
    @name
  end

  def color
    "white"
  end

  def white?
    true
  end
end
```

Run the test, and all the tests should be back to passing. We still have a
single failure, and that's the test we're interested in:

```plain
# Running:

....F

Fabulous run in 0.029346s, 170.3810 runs/s, 170.3810 assertions/s.

  1) Failure:
UnicornTest#test_it_does_not_have_to_be_white [unicorn_test.rb:29]:
Expected: "purple"
  Actual: "white"

5 runs, 5 assertions, 1 failures, 0 errors, 0 skips
```

#### Purple != White

We want Barbara to be white, but she's purple.

The color gets passed in to initialize, so let's save it, the same way that we
do with name:

```ruby
class Unicorn
  def initialize(name, color="default color")
    @name = name
    @color = color
  end

  def name
    @name
  end

  def color
    @color
  end

  def white?
    true
  end
end
```

Now, run the tests, and we get a single failure:

```plain
# Running:

F....

Fabulous run in 0.032192s, 155.3181 runs/s, 155.3181 assertions/s.

  1) Failure:
UnicornTest#test_it_is_white_by_default [unicorn_test.rb:19]:
Expected: "white"
  Actual: "default color"

5 runs, 5 assertions, 1 failures, 0 errors, 0 skips
```

Which test? It's not the Barbara test, it's Margaret. She expects to be white,
but she's "default color". That's because she's getting the default value in
`initialize`.

#### Defaulting to White

Change the default to be "white":

```ruby
class Unicorn
  def initialize(name, color="white")
    @name = name
    @color = color
  end

  def name
    @name
  end

  def color
    @color
  end

  def white?
    true
  end
end
```

This gets all the tests passing.

```plain
# Running:

.....

Fabulous run in 0.002299s, 2174.8586 runs/s, 2174.8586 assertions/s.

5 runs, 5 assertions, 0 failures, 0 errors, 0 skips
```

### Returning to `white?`

We aren't quite done with the color requirement. The `white?` method is still
always going to return `true`. Add a test for a unicorn that is *not* white:

```plain
class UnicornTest < Minitest::Test
  def test_it_has_a_name
    # ..
  end

  def test_it_can_be_named_something_else
    # ..
  end

  def test_it_is_white_by_default
    # ..
  end

  def test_it_knows_if_it_is_white
    # ..
  end

  def test_it_does_not_have_to_be_white
    # ..
  end

  def test_it_knows_if_it_is_not_white
    unicorn = Unicorn.new("Roxanne", "green")
    assert_equal false, unicorn.white?
  end
end
```

#### Using `refute`

There's a short-hand for `assert_equal false, something`, and that's `refute`.

According to the dictionary, to 'refute' something is to deny or contradict
it. `refute` is the opposite of `assert`. Where a test with `assert` will pass
if the return value is `true`, a test with `refute` will pass if the return
value is false.

```ruby
def test_it_knows_if_it_is_not_white
  unicorn = Unicorn.new("Roxanne", "green")
  refute unicorn.white?
end
```

Run the tests, and the last one will fail:

```plain
# Running:

.F....

Fabulous run in 0.004108s, 1460.5648 runs/s, 1460.5648 assertions/s.

  1) Failure:
UnicornTest#test_it_knows_if_it_is_not_white [unicorn_test.rb:34]:
Failed refutation, no message given

6 runs, 6 assertions, 1 failures, 0 errors, 0 skips
```

#### Adding a Message

If we had been using `assert_equal`, the error message would have been:

```plain
Expected: false
  Actual: true
```

Now we have a message that says:

```plain
Failed refutation, no message given
```

It's expecting `white?` to return false, but the return value is hard-coded:

```ruby
def white?
  true
end
```

Clearly that's not going to work.

As with `assert`, we can also give it a message:

```ruby
def test_it_knows_if_it_is_not_white
  unicorn = Unicorn.new("Roxanne", "green")
  refute unicorn.white?, "I guess Roxanne thinks she's white, when really she is green."
end
```

Run it:

```plain
# Running:

..F...

Fabulous run in 0.004489s, 1336.6006 runs/s, 1336.6006 assertions/s.

  1) Failure:
UnicornTest#test_it_knows_if_it_is_not_white [unicorn_test.rb:34]:
I guess Roxanne thinks she's white, when really she is green.

6 runs, 6 assertions, 1 failures, 0 errors, 0 skips
```

The `Failed refutation, no message given` message has been
replaced with the one we just wrote.

#### Real Implementation of `white?`

We're not going to get away with hard-coding an answer anymore. We'll solve it
by comparing the actual color to the string "white":

```ruby
class Unicorn
  attr_reader :name

  def initialize(name, color="white")
    @name = name
    @color = color
  end

  def color
    @color
  end

  def white?
    color == "white"
  end
end
```

This gets the test passing:

```plain
# Running:

......

Fabulous run in 0.002240s, 2678.5714 runs/s, 2678.5714 assertions/s.

6 runs, 6 assertions, 0 failures, 0 errors, 0 skips
```

We've now gotten the first and second requirements taken care of. Unicorns
have names, and they're usually white, although they may be a different color.

## Unicorns Can Talk

The last requirement has to do with how unicorns speak. They say sparkly
things. 

It's not entirely clear from the requirements what that means. It kind
of sounds like unicorns are very optimistic, and only say positive ("sparkly")
things. We could create a `speak` method that chooses a random response from a
list of positive-sounding things, but that's going to be kind of hard to test,
and besides, it's boring if the unicorn is restricted to only saying a handful
of things.

### Talking with Sparkles

Instead, let's let the unicorn say anything, but make sure that whatever it is
they say it with ASCII sparkles:

```plain
class UnicornTest < Minitest::Test
  def test_it_has_a_name
    # ..
  end

  def test_it_can_be_named_something_else
    # ..
  end

  def test_it_is_white_by_default
    # ..
  end

  def test_it_knows_if_it_is_white
    # ..
  end

  def test_it_does_not_have_to_be_white
    # ..
  end

  def test_it_knows_if_it_is_not_white
    # ..
  end

  def test_unicorn_says_sparkly_stuff
    unicorn = Unicorn.new("Johnny")
    assert_equal "**;* Wonderful! **;*", unicorn.say("Wonderful!")
  end
end
```

#### Running the Tests

The test blows up:

```plain
# Running:

...E...

Fabulous run in 0.002682s, 2609.9925 runs/s, 2237.1365 assertions/s.

  1) Error:
UnicornTest#test_unicorn_says_sparkly_stuff:
NoMethodError: undefined method `say' for #<Unicorn:0x007ff5fa4103a0 @name="Johnny", @color="white">
    unicorn_test.rb:39:in `test_unicorn_says_sparkly_stuff'

7 runs, 6 assertions, 0 failures, 1 errors, 0 skips
```

We're missing the method `say` on unicorn. 

### Defining `.say`

That's easy enough to fix:

```ruby
class Unicorn
  attr_reader :name

  def initialize(name, color="white")
    @name = name
    @color = color
  end

  def color
    @color
  end

  def white?
    color == "white"
  end

  def say
  end
end
```

#### Adding the Parameter

The test still isn't happy, though:

```plain
# Running:

E......

Fabulous run in 0.002149s, 3257.3290 runs/s, 2791.9963 assertions/s.

  1) Error:
UnicornTest#test_unicorn_says_sparkly_stuff:
ArgumentError: wrong number of arguments (1 for 0)
    /Users/kytrinyx/gschool/here-comes-the-unicorn/unicorn.rb:17:in `say'
    unicorn_test.rb:39:in `test_unicorn_says_sparkly_stuff'

7 runs, 6 assertions, 0 failures, 1 errors, 0 skips
```

We're calling `say` wrong. Wrong number of arguments, `1 for 0`. That's
familiar. In the test we're calling `say` with an argument:

```ruby
unicorn.say("Wonderful!")
```

And here's how the `say` method is defined:

```ruby
def say
end
```

The test is right, the code is wrong. Let's make the `say` method accept an
argument:

```ruby
def say(something)
end
```

This changes the message of the test, but we're not passing yet:

```plain
# Running:

......F

Fabulous run in 0.033604s, 208.3085 runs/s, 208.3085 assertions/s.

  1) Failure:
UnicornTest#test_unicorn_says_sparkly_stuff [unicorn_test.rb:39]:
Expected: "**;* Wonderful! **;*"
  Actual: nil

7 runs, 7 assertions, 1 failures, 0 errors, 0 skips
```

### Returning Sparkles

No surprise there. The method is returning nil. Copy/paste from the error
message in the test into the method definition:

```ruby
def say(something)
  "**;* Wonderful! **;*"
end
```

Run the tests:

```plain
# Running:

.......

Fabulous run in 0.004330s, 1616.6282 runs/s, 1616.6282 assertions/s.

7 runs, 7 assertions, 0 failures, 0 errors, 0 skips
```

The test passes, but the implementation is kind of dumb. 

### Let's Go Deeper

Let's make a test that forces us to write better code:

```ruby
class UnicornTest < Minitest::Test
  def test_it_has_a_name
    # ..
  end

  def test_it_can_be_named_something_else
    # ..
  end

  def test_it_is_white_by_default
    # ..
  end

  def test_it_knows_if_it_is_white
    # ..
  end

  def test_it_does_not_have_to_be_white
    # ..
  end

  def test_it_knows_if_it_is_not_white
    # ..
  end

  def test_unicorn_says_sparkly_stuff
    # ..
  end

  def test_unicorn_says_different_sparkly_stuff
    unicorn = Unicorn.new("Francis")
    assert_equal "**;* I don't like you very much. **;*", unicorn.say("I don't like you very much.")
  end
end
```

Now we get a failing test, thankfully:

```plain
# Running:

......F.

Fabulous run in 0.042625s, 187.6833 runs/s, 187.6833 assertions/s.

  1) Failure:
UnicornTest#test_unicorn_says_different_sparkly_stuff [unicorn_test.rb:44]:
--- expected
+++ actual
@@ -1 +1 @@
-"**;* I don't like you very much. **;*"
+"**;* Wonderful! **;*"


8 runs, 8 assertions, 1 failures, 0 errors, 0 skips
```

### Using String Interpolation

We can make it pass by interpolating the argument into the string with the ASCII
sparkles:

```ruby
def say(something)
  "**;* #{something} **;*"
end
```

This gets the final test passing.

```plain
# Running:

........

Fabulous run in 0.003738s, 2140.1819 runs/s, 2140.1819 assertions/s.

8 runs, 8 assertions, 0 failures, 0 errors, 0 skips
```

## Final Results

That's it. We have fulfilled the original requirements.

This is the code we ended up with:

```ruby
class Unicorn
  attr_reader :name

  def initialize(name, color="white")
    @name = name
    @color = color
  end

  def color
    @color
  end

  def white?
    color == "white"
  end

  def say(something)
    "**;* #{something} **;*"
  end
end
```

And here is the full test suite that we wrote:

```ruby
gem 'minitest', '~> 5.0'
require 'minitest/autorun'
require 'minitest/pride'
require_relative 'unicorn'

class UnicornTest < Minitest::Test
  def test_it_has_a_name
    unicorn = Unicorn.new("Robert")
    assert_equal "Robert", unicorn.name
  end

  def test_it_can_be_named_something_else
    unicorn = Unicorn.new("Joseph")
    assert_equal "Joseph", unicorn.name
  end

  def test_it_is_white_by_default
    unicorn = Unicorn.new("Margaret")
    assert_equal "white", unicorn.color
  end

  def test_it_knows_if_it_is_white
    unicorn = Unicorn.new("Elisabeth")
    assert unicorn.white?, "Elisabeth should be white, but isn't."
  end

  def test_it_does_not_have_to_be_white
    unicorn = Unicorn.new("Barbara", "purple")
    assert_equal "purple", unicorn.color
  end

  def test_it_knows_if_it_is_not_white
    unicorn = Unicorn.new("Roxanne", "green")
    refute unicorn.white?, "I guess Roxanne thinks she's white, when really she is green."
  end

  def test_unicorn_says_sparkly_stuff
    unicorn = Unicorn.new("Johnny")
    assert_equal "**;* Wonderful! **;*", unicorn.say("Wonderful!")
  end

  def test_unicorn_says_different_sparkly_stuff
    unicorn = Unicorn.new("Francis")
    assert_equal "**;* I don't like you very much. **;*", unicorn.say("I don't like you very much.")
  end
end
```

