---
layout: page
title: Objects and Methods
---

We will use the [ruby-exercises (objects-and-methods)](https://github.com/JumpstartLab/ruby-exercises)
repository to practice writing objects that have methods and that interact
with each other.

## Getting Started

Start by cloning the repository:

{% terminal %}
$ git clone git@github.com:JumpstartLab/ruby-exercises.git
$ cd ruby-exercises/objects-and-methods
{% endterminal %}

## Exercise 1

Go to exercise-1:

{% terminal %}
$ cd exercise-1
{% endterminal %}

You will have a test directory with several files in it.

### Implementing `Candy`

Start by running the tests for `Candy`:

{% terminal %}
$ ruby test/candy_test.rb
{% endterminal %}

What is does the error message say?

The most important part of the error message is this:

{% terminal %}
cannot load such file -- ./lib/candy (LoadError)
{% endterminal %}

The way to fix it is to create a directory named `lib` (if it doesn't exist), and add an empty file called `candy.rb` to it:

{% terminal %}
$ mkdir lib
$ touch lib/candy.rb
{% endterminal %}

Run the tests again, and now the error message has changed:

{% terminal %}
NameError: uninitialized constant CandyTest::Candy
{% endterminal %}

It's looking for the constant `Candy`. First it looks inside of `CandyTest`,
which is what `CandyTest::Candy` means. Next it looks outside of that class
(just `Candy`). It only reports the first error, though.

We don't want `Candy` to live inside of `CandyTest`. Define the `Candy` class
inside of `lib/candy.rb`.

```ruby
class Candy
end
```

Run the tests again, you will get an `ArgumentError`:

{% terminal %}
ArgumentError: wrong number of arguments(1 for 0)
    test/candy_test.rb:8:in `initialize'
{% endterminal %}

Implement the initialize method in `Candy` so that it takes an argument.

Run the tests.

{% terminal %}
NoMethodError: undefined method `type' for #&lt;Candy:0x007f93099f98d8&gt;
{% endterminal %}

Add an empty method named `type` to the Candy class.

Run the tests, and you'll finally get a failure rather than an error:

{% terminal %}
Expected: nil
  Actual: "Skittles"
{% endterminal %}

Make the test pass, and then remove the `skip` from the next test, and make
that one pass as well.

### Implementing `Bag`

Next run the tests for the `Bag` class:

{% terminal %}
ruby test/bag_test.rb
{% endterminal %}

Follow the error messages to get the first test passing. Just do the simplest
thing that could possibly work. The next tests should force the code to do
whatever it needs to do.

Unskip the next test. It gives you a `NoMethodError` that looks like this:

{% terminal %}
NoMethodError: undefined method `count' for #&lt;Bag:0x007f96f3144ec0&gt;
{% endterminal %}

That's a familiar error message. Create an empty method named `count`, and run
the tests again. Fix the failure.

Unskip the next test. The error message complains about another
`NoMethodError`:

{% terminal %}
NoMethodError: undefined method `candies' for #&lt;Bag:0x007fd0618d04f8&gt;
{% endterminal %}

Again, make the test pass in the simplest way possible.

Unskip the next test. Now you'll get a `NoMethodError` that looks like this:

{% terminal %}
NoMethodError: undefined method `<<' for #&lt;Bag:0x007ff73c8a1fe8&gt;
{% endterminal %}

Really? A method named `<<`? Well, that's what it says. Let's fix it the way
we fixed the previous `NoMethodError`. Inside of the `Bag` class, define this
method:

```ruby
def <<
end
```

Run the tests again, and the error message changes:

{% terminal %}
ArgumentError: wrong number of arguments (1 for 0)
    /Users/username/code/halloween/lib/bag.rb:10:in `<<'
{% endterminal %}

We need an argument for the `<<` method, but what should the argument be?

The test says:

```ruby
bag << candy
```

So I guess we're putting a candy in the bag. Let's call the argument `candy`:

```ruby
def <<(candy)
end
```

Run the tests again, and now we get a failure:

{% terminal %}
BagTest#test_put_candy_in_the_bag [test/bag_test.rb:24]:
--- expected
+++ actual
@@ -1 +1 @@
-[#&lt;Candy:0xXXXXXX @type="Sour frogs"&gt;]
+[]
{% endterminal %}

Eew.

OK, let's pick that apart.

The first line tells us that the failing test is in the `BagTest` test suite.
No surprise there.

Then it says the failing test is named `test_put_candy_in_the_bag`,
which makes sense, because that's the test we're working on at the moment.

It gives us the file name (`test/bag_test.rb`). Again, this is no
surprise, since that's the file we're running to get this error.

Finally, it tells us which line the failing assertion is on (`test/bag_test.rb:24`, so line 24).

Next it gives us some instructions. It says it's going to show us some output,
and it will prefix the line with `+++` if it got something it didn't expect,
and it will prefix the line with `---` if it is missing something.

In other words, it expected to get an array with an instance of Candy in it,
but it actually got an empty array.

What do we have on line 24?

```ruby
assert_equal [candy], bag.candies
```

We expected to get an array with an instance of candy in it (`[candy]`), but
`bag.candies` returns an empty array. At least that's what I'm getting,
because I hard-coded the response to the `candies` method to return an empty
array.

We need to start implementing some actual logic here.

What is the test actually doing?

```ruby
def test_put_candy_in_the_bag
  bag = Bag.new
  candy = Candy.new("Sour frogs")
  bag << candy
  assert_equal [candy], bag.candies
end
```

It is:

* creating a new bag
* creating a piece of candy
* putting the candy in the bag
* asserting that that particular candy is in the bag's array of `candies`.

So we need to do something smarter in the `<<` method.

We have a method named `candies`, but that is a `reader` method, which is
intended to just read data, not change data. Since we want to change the
`candies` array, let's change the underlying instance variable named
`@candies`.

```ruby
def <<(candy)
  @candies << candy
end
```

Run the tests again.

{% terminal %}
NoMethodError: undefined method `<<' for nil:NilClass
    /Users/username/code/halloween/lib/bag.rb:15:in `<<'
{% endterminal %}

OK, it doesn't like that we're trying to shovel something into nil on line 15.

Line 15 says:

```ruby
@candies << candy
```

So `@candies` is nil. That makes sense, because we never defined it anywhere.

We can define it in the `initialize` method, since we always want to have it
available inside the bag.

Wait. What `initialize` method? We don't have one.

Well, we kind of have one. An empty class gets an empty initialize
method for free whether it's explicitly there or not.

So if we want to have something other than an empty initialize method,
we need to create it explicitly:

```ruby
def initialize
  @candies = []
end
```

That fixes the complaint about shoveling into nil, but our `[candy]` array is
still empty.

Take a look at how the `candies` method is defined inside `Bag`. It's still
hard-coding the empty array. If you return the instance variable `@candies`
instead, then this will now pass.

Unskip the next test. Mine fails because it expects the bag to not be empty
anymore since we put candy in it. But the bag says that it's still empty.

That's because I hard-coded `empty?` on the `Bag` to return `true`. Make the
`empty?` method check if the `candies` array is empty:

```ruby
def empty?
  candies.empty?
end
```

That makes the test pass. Unskip the next one.

{% terminal %}
BagTest#test_bag_counts_candies [test/bag_test.rb:36]:
Expected: 1
  Actual: 0
{% endterminal %}

This test is failing because of a hard-coded value, too. I hard-coded the count as `0`.

`candies` is an Array, and Ruby Arrays have a lot of methods defined on them by
default. You can see the full list [here](http://ruby-doc.org/core-2.0.0/Array.html). We need a method that will tell us how many elements are in the array.

The documentation says this:

> Arrays keep track of their own length at all times.
> To query an array about the number of elements it contains, use
> length, count or size.

So it doesn't seem to matter which one we choose. Let's use `count`.

```ruby
def count
  candies.count
end
```

This can seem confusing. We've got two methods named count, one within the other. What's going on here?

The first one is a method defined on an instance of Bag:

```ruby
class Bag
  def count
  end
end
```

The second one is a message that the bag sends to the array of candies:

```ruby
candies.count
```

Run the tests -- they should now be passing. Unskip the next test.
This one should pass straight off the bat.

Make sure that you understand what it is doing.

Unskip the last test.

We get a `NoMethodError`:

{% terminal %}
NoMethodError: undefined method `contains?' for #&lt;Bag:0x007ff13b22ed98&gt;
{% endterminal %}

Define the method and run the test again. Fix the `ArgumentError` by giving it
a parameter.

The failure we get is a failed assertion, but the error message isn't very
helpful, we need to check what it's actually trying to prove:

This is the code:

```ruby
bag = Bag.new
bag << Candy.new("Lindt chocolate")

assert bag.contains?("Lindt chocolate")
```

`assert` will pass if whatever it is given evaluates to `true`. It will fail if it is `nil` or `false`.

We need `bag.contains?("Lindt chocolate")` to return true.

How are we going to know if the bag contains a candy with a type of "Lindt chocolate"?

We need to ask each candy what type it is. We can do that, because we have access to all the candies via the `candies` method.

```ruby
def contains?(type)
  candies.any? do |candy|
    candy.type == type
  end
end
```

Now all the `Bag` tests should pass.

### Implementing Costume

Run the `test/costume_test.rb` file, and implement `Costume`. It's very
similar to `Candy`.

### Implementing Trick-Or-Treater

This is where it gets interesting.

The first times you run the tests you'll get the usual errors:

* `LoadError` -- create the missing file.
* `NameError` -- create the missing class.
* `ArgumentError` -- add an initialize method that takes a parameter

The parameter should be named `costume` since that is what we're passing into
the new `TrickOrTreat` instance in the test:

```ruby
# in the test
costume = Costume.new("Cowboy")
trick_or_treater = TrickOrTreater.new(costume)
```

The `TrickOrTreat` class now looks like this:

```ruby
class TrickOrTreater
  def initialize(costume)
  end
end
```

We're not doing anything with the costume yet.

The next error message that we get is:

{% terminal %}
NoMethodError: undefined method `dressed_up_as' for #&lt;TrickOrTreater:0x007fe0418b2d50&gt;
{% endterminal %}

Define the empty method, and we get a failed expectation:

{% terminal %}
Expected: "Cowboy"
  Actual: nil
{% endterminal %}

Make it pass by hard-coding the expected value, and then unskip the next test.

This test is going to force us to be smarter in the `dressed_up_as` method.
The failure says:

{% terminal %}
Expected: "Pony"
  Actual: "Cowboy"
{% endterminal %}

Where do the values `"Pony"` and `"Cowboy"` come from? They are the style of
the costume.

So `dressed_up_as` needs to ask the costume what style it is, and return that value to the test.

To do that we need to save the costume so that we can access it in the
initialize method:

```ruby
def initialize(costume)
  @costume = costume
end
```

Then we can fix `dressed_up_as`:

```ruby
def dressed_up_as
  @costume.style
end
```

That gets the tests passing. Unskip the next one:

{% terminal %}
NoMethodError: undefined method `bag' for #&lt;TrickOrTreater:0x007f8a7916aa20&gt;
{% endterminal %}

Define an empty method for `bag`. Next the test gives us a `NoMethodError`:

{% terminal %}
NoMethodError: undefined method `empty?' for nil:NilClass
    test/trick_or_treater_test.rb:24:in `test_has_an_empty_bag_by_default'
{% endterminal %}

We need to look at line 24 of the test file to figure out what's going on:

```ruby
assert trick_or_treater.bag.empty?
```

We're assuming that the `bag` method returns a `Bag` object, and then we're
calling `empty?` on it.

So let's give the Trick-or-Treater object a `Bag` object that it can return to us:

```ruby
class TrickOrTreater
  def initialize(costume)
    @costume = costume
    @bag = Bag.new
  end

  def bag
    @bag
  end

  def dressed_up_as
    @costume.style
  end
end
```

That gets the tests passing.

Notice that we now have references to two objects inside our Trick-or-Treater: a Bag and a Costume. Any messages that we sent to Bag in the `bag_test.rb` are fair game from inside the Trick-or-Treater. The same goes for Costume, though admittedly Costume doesn't do much of anything.

Unskip the next test. Yet another `NoMethodError`:

{% terminal %}
NoMethodError: undefined method `has_candy?' for #&lt;TrickOrTreater:0x007fd20b993d58&gt;
{% endterminal %}

The test states that when we have an empty bag, we don't have candy.

Create the method `has_candy?`, run the test again. It passes, because the empty method is returning nil, which is good enough when we need a `false`.

Moving on: unskip the next test.

Here, we're putting something in the bag, and now the Trick-or-Treater
*should* have candy, but the `has_candy?` method has no implementation,
which means that it's returning `nil` rather than `true`.

From inside `has_candy?` the Trick-or-Treater has access to the instance of
`Bag` with all of its methods. Since we defined a method on `Bag` called `empty?`
we can call it from inside the `has_candy?` method.

```ruby
def has_candy?
  !bag.empty?
end
```

We can't just say that the Trick-or-Treater has candy if the bag is empty, though, we need the opposite: The Trick-or-Treater has candy if the bag is **not** empty. Hence the bang (programmers like to call exclamation marks _bang_. Don't ask me why).

Unskip the next test, and get a `NoMethodError`. Define the method.

Next time we run the test we get a failed expectation: `nil` instead of 0.
Go ahead and return `0` from the `candy_count` method.

Run the tests, and the same test is failing, because after adding candy to the
bag it expects the candy count to be 1.

The bag knows how much candy it contains, so the Trick-or-Treater object can ask the bag for its count:

```ruby
def candy_count
  bag.count
end
```

Unskip the last method and run the tests. Fix the `NoMethodError` by defining
the missing method.

Run the tests again -- now we're getting a failure.

Apparently if the Trick-or-Treater eats a piece of candy, the candy-count
decreases.

The candy count is based on how many candies are in the bag, so we'll need to actually take a candy out of the bag for the count to decreas.

Inside the bag, the candies are stored in an Array. Array has a handy method named `pop` which will pop off the last item in the array and give it back to you. We don't need to do anything with that piece of candy yet, so we can just pop it off and leave it at that:

```ruby
def eat
  bag.candies.pop
end
```

And that's it. This is the code that I ended up with:

```ruby
class TrickOrTreater
  attr_reader :bag
  def initialize(costume)
    @costume = costume
    @bag = Bag.new
  end

  def dressed_up_as
    @costume.style
  end

  def has_candy?
    !bag.empty?
  end

  def candy_count
    bag.count
  end

  def eat
    bag.candies.pop
  end
end
```

## Now do it again

Blow away all your changes and start over, this time without looking at the
tutorial so closely.

The easiest way to throw away changes is to run the following commands:

{% terminal %}
$ git reset .
$ git checkout .
{% endterminal %}

Do this until you can write the production code to pass the tests without
referencing the tutorial, then go to the exercise-2 directory and make those
tests pass as well:

{% terminal %}
$ cd ../exercise-2
{% endterminal %}
