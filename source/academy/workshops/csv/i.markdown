---
layout: page
title: Intro to CSV - Level I
sidebar: true
---

We will use the [csv-exercises](https://github.com/JumpstartLab/csv-exercises)
repository to practice using test-driven development and working with objects.

There are five exercises, each one leaves more and more up to you.

## Getting Started

Start by cloning the repository:

{% terminal %}
$ git clone git@github.com:JumpstartLab/csv-exercises.git
$ cd csv-exercises
{% endterminal %}

Create a branch that tracks the level-i branch on origin:

{% terminal %}
$ git checkout -t origin/level-i
{% endterminal %}

## Exercise 1: PhoneBook

The phone book contains people. Each person has a first name, a last name, and
a phone number. The data is in the `test/fixtures/people.csv` file.

Go into the `phone_book` directory:

{% terminal %}
$ cd phone_book
{% endterminal %}

### Implementing a `Person`

Create an empty file `test/person_test.rb`, and add the `Minitest` boilerplate
to it:

```ruby
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
```

Add an empty test suite. We're going to create a `Person` class, so we'll call
the test suite `PersonTest`.

```ruby
class PersonTest < Minitest::Test
end
```

What are we going to test? What does a `Person` do?

A person doesn't *do* much, it's just a container to hold some data. What
data? For that we'll need to look at the csv file `test/fixtures/people.csv`:

```plain
first_name,last_name,phone_number
Alice,Smith,123-555-1111
Bob,Johnson,123-555-2222
# ...
```

So a `Person` has a first name, a last name, and a phone number.

When we parse CSV, each row is represented as a Ruby hash:

```ruby
{first_name: "Alice", last_name: "Smith", phone_number: "123-555-1111"}
```

So we need to instantiate a Person by giving it a hash of its data:

```ruby
Person.new(first_name: "Alice", last_name: "Smith", phone_number: "123-555-1111")
```

What do we want to test? Or rather, what do we want to **prove**?

The most important thing here is that when we say `Person.new` with some
attributes, that the person we get back has wired those attributes up
correctly:

```ruby
person.first_name
# => "Alice"
```

So let's prove that for each attribute.

The first attribute in the file is `first_name`. Write a test that proves that
a person's first name is wired up correctly:

```ruby
def test_first_name
  person = Person.new(first_name: "Alice")
  assert_equal "Alice", person.first_name
end
```

Run the test.

We get a `NameError`:

{% terminal %}
NameError: uninitialized constant PersonTest::Person
{% endterminal %}

That's because we haven't included the person class. Require the file
right after `require 'minitest/pride'`:

{% terminal %}
require_relative '../lib/person'
{% endterminal %}

Run the test again, and we get a new error:

{% terminal %}
cannot load such file -- /Users/kytrinyx/gschool/csv-exercises/phone_book/lib/person (LoadError)
{% endterminal %}

So we need a file `lib/person.rb`. Go ahead and create an empty file, and then run the tests again.

The error message is back to the `NameError`:

{% terminal %}
NameError: uninitialized constant PersonTest::Person
{% endterminal %}

Create an empty `Person` class in the `person.rb` file.

Run the tests.

{% terminal %}
ArgumentError: wrong number of arguments(1 for 0)
    test/person_test.rb:8:in `initialize'
{% endterminal %}

Implement an empty initialize method that takes one argument:

```ruby
class Person
  def initialize(attributes)
  end
end
```

Run the tests, and get a `NoMethodError`.

{% terminal %}
NoMethodError: undefined method `first_name' for #&lt;Person:0x007fca0a93b328&gt;
{% endterminal %}

Define an empty method `first_name` (or add an `attr_reader` for it), run the tests again, and finally we get a failure rather than an error:

{% terminal %}
PersonTest#test_first_name [test/person_test.rb:9]:
Expected: "Alice"
  Actual: nil
{% endterminal %}

To get the test passing, we need to pull the first name out of the attribute that gets passed into the initialize method:

```ruby
class Person
  attr_reader :first_name
  def initialize(attributes)
    @first_name = attributes[:first_name]
  end
end
```

This gets the first test passing.

Write a failing test for `last_name`:

```ruby
def test_last_name
  person = Person.new(last_name: "Smith")
  assert_equal "Smith", person.last_name
end
```

Run the tests, and you'll get a `NoMethodError`. Create the method (or `attr_reader`), and run the tests again. Now you get a failure, and can fix it in the same way that you fixed it for `first_name`.

Add a failing test for `phone_number`:

```ruby
def test_phone_number
  person = Person.new(phone_number: "123-555-1234")
  assert_equal "123-555-1234", person.phone_number
end
```

Make the test pass in the same way as the two previous ones.

At this point we're essentially done, but to drive the point home, let's write one last test that sets all the attributes from one hash of data:

```ruby
def test_all_the_things
  data = {first_name: "Bob", last_name: "Cook", phone_number: "123-555-6789"}
  person = Person.new(data)
  assert_equal "Bob", person.first_name
  assert_equal "Cook", person.last_name
  assert_equal "123-555-6789", person.phone_number
end
```

This should pass right off the bat. Slime the test by adding typos to the expected values to make sure that the test fails. When you see that the test is failing correctly, put the values back to where they should be.

### Implementing a `PhoneBook`

A phone book has people.

Start with an empty test suite:

```ruby
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'

class PhoneBookTest < Minitest::Test
end
```

The `PhoneBook` needs to load the CSV file, and to do so, we'll need to tell
it where to find it. Let's write a simple test to prove that the `PhoneBook`
knows where to look for the CSV data. It's not a very valuable test in the
long run, but it's simple, and it will help us wire together the `PhoneBook`
class.

Here's the test:

```ruby
def test_filename
  phone_book = PhoneBook.new("./test/fixtures/people.csv")
  assert_equal "./test/fixtures/people.csv", phone_book.filename
end
```

Go through the same song-and-dance that we did for the `Person` class:

* `NameError` - require the `../lib/phone_book` file.
* `LoadError` - create an empty `phone_book.rb` file.
* `NameError` (again) - create an empty PhoneBook class.
* `ArgumentError` - define `initialize` so it takes `filename` as an argument.
* `NoMethodError` - define the `filename` method.

Finally, you should get a failed expectation:

{% terminal %}
Expected: "./test/fixtures/people.csv"
  Actual: nil
{% endterminal %}

Make it pass by assigning the value in the initialize method.

```ruby
class PhoneBook
  attr_reader :filename
  def initialize(filename)
    @filename = filename
  end
end
```

The only method I ever want to call on a `PhoneBook` instance is `people`. I
don't care how the `PhoneBook` got those people, I just care that I can send
the message `:entries` to the instance of `PhoneBook` and get back something
that I can iterate over, and which contains instances of `Person`.

```ruby
phone_book = PhoneBook.new(some_csv_file)
phone_book.entries # gives me something I can iterate through
```

To get there the next test takes a fairly big leap: prove that the data gets
loaded and transformed into actual `Person` objects.

```ruby
def test_load_data
  phone_book = PhoneBook.new("./test/fixtures/people.csv")

  person = phone_book.entries.last
  assert_equal "Eve", person.first_name
  assert_equal "Parker", person.last_name
  assert_equal "123-555-5555", person.phone_number
end
```

To make this pass we have some work to do. The first error is
straight-forward:

{% terminal %}
NoMethodError: undefined method `entries' for #&lt;PhoneBook:0x007f92e9088170&gt;
{% endterminal %}

Define the method.

Then we get this:

{% terminal %}
NoMethodError: undefined method `last' for nil:NilClass
{% endterminal %}

That's because our test is saying `phone_book.entries.last`, and `entries` is
returning `nil` right now.

We need it to do a bunch of things:

* read the CSV file
* loop through each row of data
* instantiate a new `Person` with that row
* return the collection of `Person` instances

Let's just start at the top and start hacking:

```ruby
def entries
  CSV.open(filename, headers: true, header_converters: :symbol)
end
```

Run the tests, and we get this:

{% terminal %}
NameError: uninitialized constant PhoneBook::CSV
{% endterminal %}

At the top of the `phone_book.rb` file, require 'csv':

```ruby
require 'csv'

class PhoneBook
  # ...
end
```

Run the tests again, and get:

{% terminal %}
NoMethodError: undefined method `last' for #&lt;CSV:0x007ff5832480a8&gt;
{% endterminal %}

This is basically the same error message as last time, except instead of
calling `last` on `nil`, We're calling it on an instance of `CSV`.

Ok. Let's loop through that thing:

```ruby
def entries
  people = []
  CSV.open(filename, headers: true, header_converters: :symbol).each do |row|
    people << row
  end
  people
end
```

The error message says:

{% terminal %}
NoMethodError: undefined method `first_name' for #&lt;CSV::Row:0x007fac62a3ed30&gt;
{% endterminal %}

Now we're getting back something that responds to `last`, because we're
returning an array (`people`). We're not quite there yet, of course, because
instead of `Person` instances, that array contains `CSV::Row` objects.

We can give that `CSV::Row` object to a new `Person` instance:

```ruby
def entries
  people = []
  CSV.open(filename, headers: true, header_converters: :symbol).each do |row|
    people << Person.new(row)
  end
  people
end
```

Now we get a complaint about an unknown constant:

{% terminal %}
NameError: uninitialized constant PhoneBook::Person
{% endterminal %}

We need to require the `person.rb` file after the `require 'csv'`:

```ruby
require 'csv'
require_relative 'person'

class PhoneBook
  # ...
end
```

Finally, the tests pass.

### A Design Problem

Right now, the CSV data is getting called every single time we call the
`entries` method. That's not ideal. What if we have millions of rows? That's
going to be a huge performance problem.

To simulate that, let's slow down the process of loading data:

```ruby
def entries
  people = []
  sleep(2)
  CSV.open(filename, headers: true, header_converters: :symbol).each do |row|
    people << Person.new(row)
  end
  people
end
```

To demonstrate this, let's add a test:

```ruby
def test_slow_loading
  phone_book = PhoneBook.new("./test/fixtures/people.csv")

  phone_book.entries
  phone_book.entries
end
```

Run the test suite, and it will be maddeningly slow. It will take over
6 seconds to run (because the `entries` method is being called 3 times in the
test suite).

We should be able to cut that down to about 4 seconds by saving the result to
an instance variable the first time it gets called, and then returning the
value of that variable the second time it gets called by wrapping all the code
in the method in a block using `begin-end`:

```ruby
def entries
  begin
    # original code goes here
  end
end
```

This lets us assign the result of running the code to an instance variable:

```ruby
def entries
  @entries = begin
    # original code goes here
  end
end
```

Once we have an assignment to an instance variable we can _memoize_ it, which
means _the first time this is run, save the result, then just return the
previously computed result all the subsequent times that the method gets called_.

```ruby
def entries
  @entries ||= begin
    # original code goes here
  end
end
```

The new version of the method looks like this:

```ruby
def entries
  @entries ||= begin
    people = []
    sleep(2)
    CSV.open(filename, headers: true, header_converters: :symbol).each do |row|
      people << Person.new(row)
    end
    people
  end
end
```

That works. It's really ugly, though. Let's start extracting some private
methods.

First, let's extract the operation of actually loading the CSV data into
memory:

```ruby
def entries
  @entries ||= begin
    people = []
    puts "loading all the data"
    sleep(2)
    data.each do |row|
      people << Person.new(row)
    end
    people
  end
end

private

def data
  CSV.open(filename, headers: true, header_converters: :symbol)
end
```

The tests still pass, and they still take 4 seconds.

Now, instead of using `each` let's use `map`, which lets us get rid of the `people` variable and transform the array in place:

```ruby
def entries
  @entries ||= begin
    sleep(2)
    data.map do |row|
      Person.new(row)
    end
  end
end

private

def data
  CSV.open(filename, headers: true, header_converters: :symbol)
end
```

Finally, let's take the loop out of the `entries` method:

```ruby
def entries
  @entries ||= begin
    build_people
  end
end

private

def build_people
  sleep(2)
  data.map do |row|
    Person.new(row)
  end
end

def data
  CSV.open(filename, headers: true, header_converters: :symbol)
end
```

The tests still pass, and they still only take 4 seconds.

We don't need to do that funky `begin/end` thing, since we only have one line
inside it:

```ruby
def entries
  @entries ||= build_people
end
```

The tests still pass, and they still take 4 seconds.

Now delete the `sleep(2)` line, run the tests, and breathe a sigh of relief,
because now they take less than half a second.

The final version of this code is on a [separate branch](https://github.com/JumpstartLab/csv-exercises/tree/level-i-solution) on GitHub.

### The Final Code

This is what we ended up with:

```ruby
class Person
  attr_reader :last_name, :first_name, :phone_number
  def initialize(attributes)
    @last_name = attributes[:last_name]
    @first_name = attributes[:first_name]
    @phone_number = attributes[:phone_number]
  end
end
```

```ruby
require 'csv'
require_relative 'person'

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

### Food for thought

* What is the name of the CSV file?
* What are the names of our production classes?
* What is plural, what is singular? Does it matter?
* How does the CSV file relate to each of the production classes?
* What are the names of the test suites? Is it important?

## Exercises 2-5: Practicing this Pattern

There are four more exercises in the `csv-exercises` repository.

Go through each one in turn. We leave a little bit more to you each time:

* ShoppingList
* ReportCard
* DoctorsOffice
* Calendar

There are a few dates and timestamps in this data. Don't worry about parsing any of that yet.

## Next Steps

Commit all your changes:

```bash
git add .
git commit -m "Complete Level I"
```

Then move on to the [Level II exercises](/academy/workshops/csv/ii.html).

