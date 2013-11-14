---
layout: page
title: Intro to CSV - Level II
sidebar: true
---

This exercise builds on [Intro to CSV - Level I](/academy/workshops/csv/i.html).

We will use the [csv-exercises](https://github.com/JumpstartLab/csv-exercises)
repository to practice using test-driven development and working with objects.

There are five exercises, each one leaves more and more up to you.

## Getting Started

If you do not have the repository on your local machine, start by cloning it:

{% terminal %}
$ git clone git@github.com:JumpstartLab/csv-exercises.git
$ cd csv-exercises
{% endterminal %}

If you do have it, then you're fine. Make sure that you've committed any
changes, so that your working directory is clean.

Fetch the latest changes from the upstream repository:

{% terminal %}
$ git fetch origin
{% endterminal %}

Then check out the `level-ii` branch from origin, where the exercises for
Level II are defined:

{% terminal %}
$ git checkout -t origin/level-ii
{% endterminal %}

## Phonebook

Change directories into the `phone_book` directory:

{% terminal %}
cd phone_book
{% endterminal %}

We're starting from scratch, but this time we've written the test suite for
you.

Each row in the CSV file represents a single person, and since this is the
smallest piece of functionality that we can work on all by itself, that's
where we'll begin.

Run the person tests:

{% terminal %}
ruby test/person_test.rb
{% endterminal %}

We get a `LoadError`, saying that it `cannot load such file`, meaning the
`lib/person.rb` file:

{% terminal %}
test/person_test.rb:4:in `require_relative': cannot load such file -- /Users/you/projects/csv-exercises/phone_book/lib/person (LoadError)
{% endterminal %}

Create an empty file:

{% terminal %}
touch lib/person.rb
{% endterminal %}

Run the tests again.

The next complaint is that we don't have a `Person` class.

{% terminal %}
NameError: uninitialized constant PersonTest::Person
{% endterminal %}

Create an empty `Person` class in the `lib/person.rb` file.

Next, we need to make sure that `Person` can accept the correct arguments in
the `initialize` method:

{% terminal %}
ArgumentError: wrong number of arguments(1 for 0)
{% endterminal %}

The way that the test creates a new person is like this:

```ruby
Person.new(first_name: "Alice")
```

So the argument is a hash. We'll call it `data`:

```ruby
class Person
  def initialize(data)
  end
end
```

Next the test blows up because we don't have a `first_name` method:

{% terminal %}
NoMethodError: undefined method `first_name' for #&lt;Person:0x007fc76a02a448&gt;
{% endterminal %}

Create an `attr_reader` for `:first_name`.

This gives us a proper failure:

{% terminal %}
PersonTest#test_first_name [test/person_test.rb:9]:
Expected: "Alice"
  Actual: nil
{% endterminal %}

We need to get the name out of the `data` hash, and assign it to an instance
variable `@first_name` in the `initialize` method:

```ruby
class Person
  attr_reader :first_name
  def initialize(data)
    @first_name = data[:first_name]
  end
end
```

This gets the first test passing.

Delete the `skip` from the second test, and rerun the test suite.

We're missing a method `last_name`. Add the `attr_reader` for it, and run the
tests again. Now store the `@last_name` in the initialize method.

`Person` now looks like this:

```ruby
class Person
  attr_reader :first_name, :last_name
  def initialize(data)
    @first_name = data[:first_name]
    @last_name = data[:last_name]
  end
end
```

Delete the next `skip` in the test suite.

We're getting a `NoMethodError`:

{% terminal %}
NoMethodError: undefined method `name'
{% endterminal %}

Change the error message by adding an empty method:

```ruby
class Person
  # ...

  def name
  end
end
```

Then we get a real failure:

{% terminal %}
Expected: "Bob Jones"
  Actual: nil
{% endterminal %}

We already have access to both the first and last names, we just need to put
them together:

```ruby
def name
  "#{first_name} #{last_name}"
end
```

This gets the test passing.

The next test is `test_formatted_phone_number`. We're going to need to do some
work on the phone number to get it formatted properly, but this doesn't really
have anything to do with a person.

Let's leave the `person_test.rb` alone for now, and develop the phone number
object independently of the person.

Run the phone number test:

{% terminal %}
$ ruby test/phone_number_test.rb
{% endterminal %}

It complains that it `cannot load such file`, and this time the missing file
is `lib/phone_number.rb`.

Create an empty file:

{% terminal %}
touch lib/phone_number.rb
{% endterminal %}

Next it complains that there is no `PhoneNumber` class.

Create the empty class in the `phone_number.rb` file.

Next, it tells us that we're trying to create a phone number by giving it
data, but the class doesn't accept any input:

{% terminal %}
ArgumentError: wrong number of arguments(1 for 0)
  test/phone_number_test.rb:8:in `initialize'
{% endterminal %}

In the test suite we create a new phone number like this:

```ruby
PhoneNumber.new("123-456-0123")
```

So the parameter to initialize represents an actual phone number. Since we're
in a class named `PhoneNumber` it doesn't really make sense to call it
`phone_number`. Let's just go with the utterly generic name `input`:

```ruby
class PhoneNumber
  def initialize(input)
  end
end
```

The test suite complains that we're missing an `input` method:

{% terminal %}
NoMethodError: undefined method `input' for #&lt;PhoneNumber:0x007f89e3b1dcc0&gt;
{% endterminal %}

Create it with an `attr_reader`. Then, when the test fails, assign the
parameter to an instance variable:

```ruby
class PhoneNumber
  attr_reader :input
  def initialize(input)
    @input = input
  end
end
```

Delete the `skip` from the next test, and run the test suite.

It is missing the method `digits`.

{% terminal %}
NoMethodError: undefined method `digits' for #&lt;PhoneNumber:0x007f878915c0a8 @input="234-567-1234"&gt;
{% endterminal %}

Add an empty method named `digits`:

```ruby
def digits
end
```

This gives us a failure:

{% terminal %}
PhoneNumberTest#test_digits [test/phone_number_test.rb:15]:
Expected: "2345671234"
  Actual: nil
{% endterminal %}

We need to remove the hyphens and dots in from the input in order to get the
digits.

To remove unwanted things from a string, you can use `String#gsub`.

If you want to get fancy, figure out what the regex is for _everything that is
not a number_, since `gsub` accepts regexes. A great website for experimenting
with regexes is [Rubular](http://rubular.com/).

Here's one way of getting it to pass:

```ruby
def digits
  input.gsub(/[-\.]/, '')
end
```

Delete the next skip.

Fix the error by defining an empty method named `area_code`.

The area code is the first three digits.

We need to split the strings apart. There are many ways to do that.

Here's one:

```ruby
"hello"[0,3]
# => "hel"
"hello"[2,3]
# => "llo"
```

You can also look up `String#slice`, `String#scan`, and `String#split`.

Here's one way to get the test to pass:

```ruby
def area_code
  digits[0..2]
end
```

Next we need the `exchange` method. This represents the _exchange code_, also
known as the _central office code_.

```ruby
def exchange
end
```

These are the next three digits after the input:

```ruby
def exchange
  digits[3..5]
end
```

Run the tests again. They should be passing. Delete the next skip.

Make the test pass by providing a method named `subscriber` which returns the
last four digits of the phone number.

Delete the next `skip`.

This test forces us to override `to_s` on phone number class. This is a fairly
idiomatic thing to do in Ruby. `to_s` is a method that provides a _default
string representation of the object_. It seems reasonable that the default
string representation of a phone number is a number that is nicely formatted.

We can use the existing methods for `area_code`, `exchange`, and `subscriber`
to define our `to_s` method:

```ruby
def to_s
  "(%s) %s-%s" % [area_code, exchange, subscriber]
end
```

Delete the next `skip`. The test is expecting a method called `sum` which adds
together the value of all the digits.

Here's the pattern for that using each:

```ruby
sum = 0
[1, 2, 3, 4, 5].each do |number|
  sum = sum + number
end
sum
# => 15
```

You can use the [`Enumerable#reduce`](http://ruby-doc.org/core-2.0.0/Enumerable.html#method-i-reduce)
method (or its alias `inject`) like this:

```ruby
[1, 2, 3, 4, 5].reduce(0) do |sum, number|
  sum + number
end
# => 15
```

Here's an implementation using reduce that gets the test passing:

```ruby
def sum
  digits.chars.reduce(0) do |sum, digit|
    sum + digit.to_i
  end
end
```

That's it -- we're done with phone number. Now we can jump back and finish
implementing `Person`.

Run the person tests:

{% terminal %}
ruby test/person_test.rb
{% endterminal %}

There are no failures. Delete the next skip, as well as the now-irrelevant
comments, then run the tests again.

{% terminal %}
NoMethodError: undefined method `number'
{% endterminal %}

We can't just solve this in the same way as `first_name` and `last_name`.
We're getting some input that isn't properly formatted, and the `number` is
the correctly formatted output. We need more than an `attr_reader` here.

Create an empty method called `number`:

```ruby
def number
end
```

The test fails:

{% terminal %}
Expected: "(123) 555-2345"
  Actual: nil
{% endterminal %}

We need to:

1. Take the raw input
2. Give it to a new `PhoneNumber` instance
3. Call `to_s` on that instance

```ruby
def initialize(data)
  @first_name = data[:first_name]
  @last_name = data[:last_name]
  @phone_number = data[:phone_number]
end
```

That's not quite right. We need a phone number _object_ not just the string.
Create a new object in the initialize method:

```ruby
def initialize(data)
  @first_name = data[:first_name]
  @last_name = data[:last_name]
  @phone_number = PhoneNumber.new(data[:phone_number])
end
```

Then, inside of `number` call `to_s` on the phone number object:

```ruby
def number
  phone_number.to_s
end
```

This blows up:

{% terminal %}
NameError: uninitialized constant Person::PhoneNumber
{% endterminal %}

We don't have access to the `PhoneNumber` class from `Person`.

Add a require statement for `phone_number` at the top of the test suite:

```ruby
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/person'
require_relative '../lib/phone_number'

class PersonTest < Minitest::Test
  # ...
end
```

It's now complaining that there's no `phone_number` method. We can create one
by adding an `attr_reader`:

```ruby
attr_reader :first_name, :last_name, :phone_number
```

That gets the test passing. Delete the next skip, run the tests, and define an
empty method `score` on `Person`.

The score is the sum of the digits in the phone number:

```ruby
def score
  phone_number.sum
end
```

Delete the `skip` on the last test, which is about creating a default string
representation of a person.

We need to override `to_s`:

```ruby
def to_s
  "%s, %s: %s" % [last_name, first_name, phone_number]
end
```

Ok, that's it. Person is complete. On to the actually directory of people.

### PhoneBook

Run the test suite for `PhoneBook`:

{% terminal %}
ruby test/phone_book_test.rb
{% endterminal %}

The first error is, as usual, a complaint that the file doesn't exist:

{% terminal %}
cannot load such file -- lib/phone_book (LoadError)
{% endterminal %}

Create the file:

{% terminal %}
touch lib/phone_book.rb
{% endterminal %}

Next, it complains that the class PhoneBook is not defined:

{% terminal %}
NameError: uninitialized constant PhoneBookTest::PhoneBook
{% endterminal %}

It's still not happy:

{% terminal %}
ArgumentError: wrong number of arguments(1 for 0)
{% endterminal %}

This is how we're instantiating the `PhoneNumber`:

```ruby
PhoneBook.new(filename)
```

We need to change the `initialize` method so it accepts a `filename`:

```ruby
class PhoneBook
  attr_reader :filename
  def initialize(filename)
    @filename = filename
  end
end
```

The test still isn't passing, this time because we're sending a message
`entries` which has not been defined.

{% terminal %}
NoMethodError: undefined method `entries'
{% endterminal %}

Work through making it pass step-by-step. There is a detailed explanation of
this process in the [Level I tutorial](/academy/workshops/csv/i.html).

This is one way to get the test passing:

```ruby
require 'csv'
require_relative 'person'
require_relative 'phone_number'

class PhoneBook
  attr_reader :filename
  def initialize(filename)
    @filename = filename
  end

  def entries
    @entries ||= build_people
  end

  private

  def build_people
    data.map do |row|
      Person.new(row)
    end
  end

  def data
    CSV.open(filename, headers: true, header_converters: :symbol)
  end
end
```

Delete the next `skip` and run the tests again.

{% terminal %}
NoMethodError: undefined method `find_by_first_name' for #&lt;PhoneBook:0x007f8f39357418&gt;
{% endterminal %}

We need a method:

```ruby
def find_by_first_name
end
```

And the method needs an argument:

{% terminal %}
ArgumentError: wrong number of arguments (1 for 0)
{% endterminal %}

We could name the argument `first_name` but that would give us a bit of an
echo (_find by first name first name_), which is awkward. Let's just go with
`s`, which is an idiomatic name for a local variable in a very small scope.

```ruby
def find_by_first_name(s)
end
```

That gives us a very odd message:

{% terminal %}
NoMethodError: undefined method `size' for nil:NilClass
{% endterminal %}

What is this `size`?

The test says:

```ruby
assert_equal 4, people.size
```

And `people` is the result of searching:

```ruby
people = phone_book.find_by_first_name("Rickie")
```

So until we actually return a collection from the `find_by_first_name` method,
we're going to get that unhelpful message.

So we need to actually search. There are a number of ways this can be solved.
The most basic approach uses the mother of all enumerable methods, `each`.

Assume for a moment that we need to find all the even numbers in the list
`[1, 2, 3, 4, 5]`.

First, set up an array to hold all the things that match the criteria:

```ruby
selected = []
```

Next we're going to loop through the list:

```ruby
selected = []
[1, 2, 3, 4, 5].each do |number|
  # do work here
end
```

The work we need to do is to figure out if the number is even or not:

```ruby
selected = []
[1, 2, 3, 4, 5].each do |number|
  if number.even?
    # do something
  end
end
```

And finally, if the number is even, we need to stick it in the array that
holds our results:

```ruby
selected = []
[1, 2, 3, 4, 5].each do |number|
  if number.even?
    selected << number
  end
end
```

Actually, that's not the last thing. If we leave it at this, we'll get back
`[1, 2, 3, 4, 5]`, not `[2, 4]`. That's because the return value of `each` is
_the collection that you're iterating over_... not the result of whatever
happened in the block.

We need to return the results array:

```ruby
selected = []
[1, 2, 3, 4, 5].each do |number|
  if number.even?
    selected << number
  end
end
selected
```

This gives us back `[2, 4]` as expected.

`Enumerable#each` is the most generic way of solving this... but filtering a
collection is something that we do so often that Ruby has a custom
special-order method that simplifies things:

[`Enumerable#select`](http://ruby-doc.org/core-2.0.0/Enumerable.html#method-i-select)
method, or its alias `find_all`, does all the same work, but with less
boilerplate:

```ruby
[1, 2, 3, 4, 5].select do |number|
  number.even?
end
# => [2, 4]
```

The reason this works is that the result of the `select` method is the subset
 of the collection consisting of only the elements where the block evaluated
 to `true`.

Given all of that, here is some code that gets the test passing:

```ruby
def find_by_first_name(s)
  entries.select do |person|
    person.first_name == s
  end
end
```

Delete the next `skip` and run the tests.

{% terminal %}
NoMethodError: undefined method `find_by_last_name' for #&lt;PhoneBook:0x007ff5911a9440&gt;
{% endterminal %}

This looks familiar. It's basically the same as the previous method, except
we're searching by last name, rather than first name. Go through each step of
changing the method. You'll end up with something like this:

```ruby
def find_by_last_name(s)
  entries.select do |person|
    person.last_name == s
  end
end
```

This duplication should make you a little bit uncomfortable, but just keep
going for now. We'll refactor before we're done.

Unskip the next test.

{% terminal %}
NoMethodError: undefined method `find_by_score' for #&lt;PhoneBook:0x007fa6adb85500&gt;
{% endterminal %}

Again! Really? Yes, really. Go ahead and add even more duplicate-looking code:

```ruby
def find_by_score(i)
  entries.select do |person|
    person.score == i
  end
end
```

Delete the final `skip`.

{% terminal %}
NoMethodError: undefined method `n_lowest_scorers' for #&lt;PhoneBook:0x007fd0610137c0&gt;
{% endterminal %}

This is not the same thing as before. Let's add an empty method and see where
it takes us next.

```ruby
def n_lowest_scorers
end
```

We get an error, not a failure:

{% terminal %}
ArgumentError: wrong number of arguments (1 for 0)
  lib/phone_book.rb:33:in `n_lowest_scorers'
{% endterminal %}

We need to add an argument.

```ruby
def n_lowest_scorers(n)
end
```

And that gives us a failure. We need to sort the people by score, and then
grab the first `n` matches.

`Enumerable` has a custom method for sorting, `sort_by`:

```ruby
def n_lowest_scorers(n)
  entries.sort_by do |person|
    person.score
  end.first(n)
end
```

And that gets everything passing.

This is the final code:

```ruby
require 'csv'
require_relative 'person'
require_relative 'phone_number'

class PhoneBook
  attr_reader :filename
  def initialize(filename)
    @filename = filename
  end

  def entries
    @entries ||= build_people
  end

  def find_by_first_name(s)
    entries.select do |person|
      person.first_name == s
    end
  end

  def find_by_last_name(s)
    entries.select do |person|
      person.last_name == s
    end
  end

  def find_by_score(i)
    entries.select do |person|
      person.score == i
    end
  end

  def n_lowest_scorers(n)
    entries.sort_by do |person|
      person.score
    end.first(n)
  end

  private

  def build_people
    data.map do |row|
      Person.new(row)
    end
  end

  def data
    CSV.open(filename, headers: true, header_converters: :symbol)
  end
end
```

It's time to deal with that duplication. We have three methods that are very,
very similar:

```ruby
def find_by_thing(term)
  entries.select do |person|
    person.thing == term
  end
end
```

The only problem is that `thing` is different every time. We can send messages
to objects using the `send` method:

```ruby
"hello".upcase
# => "HELLO"
"hello".send :upcase
# => "HELLO"
```

So we can rewrite the `find_by_thing` method:

```ruby
def find_by_thing(term)
  entries.select do |person|
    person.send(:thing) == term
  end
end
```

Now we can send `thing` in to the method as a parameter:


```ruby
def find_by(thing, term)
  entries.select do |person|
    person.send(thing) == term
  end
end
```

To sound a bit more grown-up, we can call it `attribute` instead of thing`.

```ruby
def find_by(attribute, term)
  entries.select do |person|
    person.send(attribute) == term
  end
end
```

Then we can call the new `find_by` method from each of the three other
methods:

```ruby
def find_by_first_name(s)
  find_by(:first_name, s)
end

def find_by_last_name(s)
  find_by(:last_name, s)
end

def find_by_score(i)
  find_by(:score, i)
end

private

def find_by(attribute, value)
  entries.select do |person|
    person.send(attribute) == value
  end
end
```

That's it. Commit your changes.

## The Shopping List

### `Item`

Run the `item_test.rb` test suite.

You need to:

* provide methods to access the data that the `Item` is initialized with
(`name`, `quantity`, `unit_price`).
* calculate `price` and `tax`.

### `ShoppingList`

Run the `shopping_list_test.rb` test suite.

You need to

* load the data
* create `Item` objects for each row
* implement search methods: `cheaper_than` and `more_expensive_than`

A couple things that will help you along the way:

* [`String#to_i`](http://ruby-doc.org/core-2.0.0/String.html#method-i-to_i)
* [`String#to_f`](http://ruby-doc.org/core-2.0.0/String.html#method-i-to_f)

## `DoctorsOffice`

### `Appointment`

Implement the tests in `appointment_test.rb`.

The CSV file provides the patient name, and the date and time of their
appointment.

Make sure that you can access the time and the date of the appointment as
actual `Date` and `Time` objects.

There are conversion methods from `Date` to `Time`, and from `Time` to `Date`.

Also, you may want to look at `Time#strptime`, and the handy website [For a
Good Strftime](http://foragoodstrftime.com).

## `ReportCard`

The `Grade` class now implements not only a percentage, but also converts that
percentage to a letter grade and a grade point.

The `ReportCard` class loads the CSV data, creates the students, and also
provides a mechanism to find:

* all the grades for a given student
* all the grades for a particular subject

In addition, it calculates

* the grade point average for a student
* the average score for a subject

## `Calendar`

You're pretty much on your own on this one.

Create a test suite for `Birthday`, which has two attributes: `name` and
`date_of_birth`.

Then implement the following functionality:

* Get birthday as a Date object
* Calculate age
* Calculate gigasecond (assume born at midnight, just get the date)

To create a ruby Date object from a String, try this:

```ruby
require 'date'
Date.strptime('1987', "%Y-%m-%d")
```

A gigasecond is 1 billion seconds. Don't worry about getting the exact moment,
just assume that the person is born at midnight, and calculate the day on
which they turn 1 gigasecond old.

Implement the calendar class to manage the collection of birthdays.

Once you have the basic functionality that loads the CSV data and creates the
birthday objects, add the following functionality:

* Find everyone who is a certain age
* Find everyone who has a birthday on a certain date (regardless of year)
* Given two names, figure out who is older
* Given two names, figure out who has a birthday earlier in the year than the other

