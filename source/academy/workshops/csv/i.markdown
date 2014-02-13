---
layout: page
title: Intro to CSV - Level I
sidebar: true
---

We will use the [csv-exercises](https://github.com/JumpstartLab/csv-exercises)
repository to practice using test-driven development and working with objects.

There are five exercises, and this tutorial guides you through the process of
solving the first one, then provides hints for working through the remaining
exercises.

## Getting Started

If you do not have the repository on your local machine, start by cloning it:

{% terminal %}
$ git clone git@github.com:JumpstartLab/csv-exercises.git
$ cd csv-exercises
{% endterminal %}

If you do have it, then you're fine. Make sure that you've committed any
changes, so that your working directory is clean, and that you're on the
master branch.

Fetch the latest changes from the upstream repository, and ensure that your
master matches it:

{% terminal %}
$ git fetch origin
$ git reset --hard origin/master
{% endterminal %}

Then check out a new branch to work on the `level-i` exercises:

{% terminal %}
$ git checkout -b level-i
{% endterminal %}

Go to the `level-i` directory:

{% terminal %}
$ cd level-i
{% endterminal %}

We'll be working on the Phone Book exercise, so change directories to
`phone_book`:

{% terminal %}
cd phone_book
{% endterminal %}

## Inspecting the Data

For our electronic telephone directory listing service we want to be able to
look people up by their last name, or by their first and last name. Also, we
want to provide a reverse lookup, where we input a number, and get back the
name of the person who owns it.

If you open up the `./data` directory you'll see one file:

{% terminal %}
./data/
├── people.csv
{% endterminal %}

We have many people, and each person has a phone number.

## Designing the Interface

We have three ways of looking up data in our telephone directory listing:

```ruby
# By last name
phone_book.lookup('Smith')
# By first and last name
phone_book.lookup('Smith, Alice')
# By number
phone_book.reverse_lookup('(123) 555-1234')
```

## Knowing When We're Done

When developing a product, it's easy to get carried away as each feature leads
to more and more features. We'll define a single, automated test that will
tell us when our Minimum Usable Product is complete.

The minimal usuable product will be a single pass through the application,
exposing just the first of the lookup methods: `phone_book.lookup('Smith')`.

This will use the real data, and all the real code, as though it were being
used in production. There are many names for tests like these: end-to-end
tests, acceptance tests, feature tests, or integration tests.

For simplicity we've arbitrarily chosen to call this an _integration test_.

Create an empty file called `test/integration_test.rb`. We're going to start
by adding the usual testing boilerplate to it:

```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
```

Then we'll need to require the application, and the application will require
anything else that is needed:

```ruby
require_relative '../lib/phone_book'
```

Lastly, we need to define the test suite where our integration test will live:

```ruby
class IntegrationTest < Minitest::Test
end
```

Since we're starting with a single feature, we're only going to write a single
test that proves that we can look people up by last name.

If you open up the file and manually count the people with last name
**Parker**, you should get 3 entries: Agnes, Craig, and Mohamed.

We don't want to enforce any sort of ordering of the search results, so before
we make the assertions, we'll sort what came back. Then we need to prove that
we got the right names and that the numbers are associated to the correct
person.

Here's what I came up with:

```ruby
class IntegrationTest < Minitest::Test
  def test_lookup_by_last_name
    phone_book = PhoneBook.new
    entries = phone_book.lookup('Parker').sort_by {|e| e.first_name}

    assert_equal 3, entries.length
    e1, e2, e3 = entries

    assert_equal "Agnes Parker", e1.name
    assert_equal "758.942.6890", e1.phone_number

    assert_equal "Craig Parker", e2.name
    assert_equal "716-133-3210", e2.phone_number

    assert_equal "Mohamed Parker", e3.name
    assert_equal "701-655-6889", e3.phone_number
  end
end
```

## Driving Development with the Integration Test

This integration test is going to be failing until the very end. We will use
the test in the following way:

First, we need to distinguish between **errors** and **failures**.

An **error** means that the code cannot even run. There's a missing file, a
class hasn't been defined, or we're calling a method that does not exist.

A **failure** is a missed expectation. We wanted chocolate cake, but were
given oatmeal cookies with raisins. It's not broken, it's just a
disappointment.

We will use the integration test to fix errors, so if the integration test
blows up because we don't have a file, we'll create the file.

However, once the integration test complains that it expected one thing, but
got something else, that will be our signal to drop to a lower level in the
application, abandon the integration test for a while, and develop the
necessary code using more fine-grained tests.

When the fine-grained tests are passing, then we will pop back up to the
integration test, work through any errors, and then use the next failure to
guide us towards the next tests we need to write.

## Handling the First Errors

Run the integration test:

{% terminal %}
$ ruby test/integration_test.rb
{% endterminal %}

The first error is a missing file:

```plain
test/integration_test.rb:4:in `require_relative': cannot load such file -- /Users/you/csv-exercises/level-i/phone_book/lib/phone_book (LoadError)
	from test/integration_test.rb:4:in `<main>'
```

We can change the error message by creating the missing file:

{% terminal %}
$ touch lib/phone_book.rb
{% endterminal %}

Run the test again, and get another error:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NameError: uninitialized constant IntegrationTest::PhoneBook
    test/integration_test.rb:8:in `phone_book'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

In the `lib/phone_book.rb` file that we just created, add an empty class:

```ruby
class PhoneBook
end
```

Run the test to get the next step:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NoMethodError: undefined method `lookup' for #<PhoneBook:0x007ff7139be1e8>
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

The `NoMethodError` tells us we need to create a method named `lookup`:

```ruby
class PhoneBook
  def lookup
  end
end
```

Run the tests again, and you'll get a new error:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (1 for 0)
    /Users/you/csv-exercises/level-i/phone_book/lib/phone_book.rb:2:in `lookup'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

The lookup method takes an argument. Add a parameter to the method:

```ruby
class PhoneBook
  def lookup(name)
  end
end
```

Run the tests again. Another error:

```ruby
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NoMethodError: undefined method `sort_by' for nil:NilClass
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

Because the test is sorting what it gets back from `lookup`, we need to return
something that can be sorted. An empty array will do nicely:

```ruby
class PhoneBook
  def lookup(name)
    []
  end
end
```

Run the test again, and finally, you should get a failure rather than an
error.

```plain
  1) Failure:
IntegrationTest#test_lookup_by_last_name [test/integration_test.rb:14]:
Expected: 3
  Actual: 0
```

## Driving a Feature with Lower-Level Tests

We're getting a failure because we expect to get 3 results back from the
lookup method, but we're hard-coding an empty array.

We need a phone book that, given a bunch of entries, will find the right ones
for us. Let's defer having to know about how entries are getting out of the
CSV file, and just talk to an `EntryRepository` who handles that for us.

So let's punt.

We'll create a test that says that phone book talks to the entry
repository correctly.

What does _correctly_ mean? Well, we get to make that up.

The `lookup` method is going to have to either ask the repository to go fetch
people by last name, or by first and last name. Let's have explicit methods
for each of those:

```ruby
repository.find_by_last_name(name)
# and
repository.find_by_first_and_last_name(first_name, last_name)
```

We could give the phone book a fake repository with fake data, and then assert
that what we get back when we call `lookup(name)` is whatever the fake
repository returns for `find_by_last_name`, but that seems kind of pointless.

Instead we'll implement a mock assertion that the interaction is correct.

## Mocking an Interaction

A mock expectation goes like this:

1. set up the expectation
2. do work
3. check that while work was being done, the right things happened

Suppose that you have some code that is very polite. When you say _be polite_
it does a number of things, such as say _thank you_ and _hello_. We'll make
an expectation that being polite includes saying `hello`:

```ruby
something.expect(:hello)
something.be_polite
something.verify
```

Now, as long as within `be_polite` the `hello` method gets called on
`something`, the `verify` line (the assertion) will pass.

To do this for our directory listing, create a new file,
`test/phone_book_test.rb`, and add the following to it:

```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/mock'
require_relative '../lib/phone_book'

class PhoneBookTest < Minitest::Test
  def repository
    @repository ||= Minitest::Mock.new
  end

  def test_lookup_by_last_name
    phone_book = PhoneBook.new(repository)
    repository.expect(:find_by_last_name, [], ["Smith"])
    phone_book.lookup('Smith')
    repository.verify
  end
end
```

The expectation that we're defining is a bit more complicated than just saying
_it should call the `find_by_last_name` method_.

We want to make sure that it calls the method with the right arguments
("Smith"). In minitest, it also lets you fake out a return value. We don't
care what the return value is -- we're not using it for anything in our test.
We'll just use an empty array.

In other words, in this line of code:

```ruby
repository.expect(:find_by_last_name, [], ["Smith"])
```

* `[]` is the stubbed return value,
* `["Smith"]` is the array of arguments that gets passed to the method, which is named
* `:find_by_last_name`

Running the test gives us an error:

```plain
  1) Error:
PhoneBookTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments(1 for 0)
    test/phone_book_test.rb:13:in `initialize'
    test/phone_book_test.rb:13:in `new'
    test/phone_book_test.rb:13:in `phone_book'
    test/phone_book_test.rb:18:in `test_lookup_by_last_name'
```

Our current `PhoneBook` has not defined `initialize`, which means that it has
inherited the default `initialize`, and that method doesn't accept any
arguments.

Our test is calling:

```ruby
phone_book = PhoneBook.new(repository)
```

We need to define an `initialize` method that takes a parameter so that we can
pass it the repository:

```ruby
class PhoneBook
  def initialize(repository)
  end

  def lookup(name)
    []
  end
end
```

Run the test again, and get an error:

```plain
  1) Error:
PhoneBookTest#test_lookup_by_last_name:
MockExpectationError: expected find_by_last_name() => "Smith", got []
    test/phone_book_test.rb:19:in `test_lookup_by_last_name'
```

In order to make it pass, delegate to the repository in `lookup`:

```ruby
class PhoneBook
  attr_reader :repository

  def initialize(repository)
    @repository = repository
  end

  def lookup(name)
    repository.find_by_last_name(name)
  end
end
```

This gets the test passing. Now we need to go back to the integration test,
fix any errors, and then let the failure tell us where to go next.

## Where to Go Next

Right off the bat, we get an error:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (0 for 1)
    /Users/you/csv-exercises/level-i/phone_book/lib/phone_book.rb:4:in `initialize'
    test/integration_test.rb:8:in `new'
    test/integration_test.rb:8:in `phone_book'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

The test is calling `PhoneBook.new`, but now phone book's `initialize` expects an argument.

We don't want to have to tell the phone book where to find it's data, so let's
provide a default repository that it can use if nothing is passed in.

```ruby
class PhoneBook
  attr_reader :repository

  def initialize(repository=EntryRepository.in('./data'))
    @repository = repository
  end

  # ...
end
```

This blows up, naturally, since we just pulled the `EntryRepository` out of
thin air.

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NameError: uninitialized constant PhoneBook::EntryRepository
    /Users/you/csv-exercises/level-i/phone_book/lib/phone_book.rb:4:in `initialize'
    test/integration_test.rb:8:in `new'
    test/integration_test.rb:8:in `phone_book'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

Create a new file called `lib/entry_repository.rb`, and require it at the top
of `lib/phone_book.rb`:

```ruby
require_relative 'entry_repository'

class PhoneBook
  # ...
end
```

The integration test complains about an unknown constant `EntryRepository`.
Create the empty class.

This gives us a new error:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NoMethodError: undefined method `in' for EntryRepository:Class
    /Users/you/csv-exercises/level-i/phone_book/lib/phone_book.rb:6:in `initialize'
    test/integration_test.rb:8:in `new'
    test/integration_test.rb:8:in `phone_book'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

Notice that this is complaining about an undefined method on the
`EntryRepository` class, not on an instance of it.

Create a class method:

```ruby
class EntryRepository
  def self.in
  end
end
```

Running the tests gives us a new error, telling us that the `in` method needs
an argument:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (1 for 0)
    /Users/you/csv-exercises/level-i/phone_book/lib/entry_repository.rb:2:in `in'
    /Users/you/csv-exercises/level-i/phone_book/lib/phone_book.rb:6:in `initialize'
    test/integration_test.rb:8:in `new'
    test/integration_test.rb:8:in `phone_book'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

Define a parameter for `in`:

```ruby
class EntryRepository
  def self.in(dir)
  end
end
```

We're still not done. This time, the error says that we're calling a method on
`nil`. What `nil` is that, exactly?

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NoMethodError: undefined method `find_by_last_name' for nil:NilClass
    /Users/you/csv-exercises/level-i/phone_book/lib/phone_book.rb:11:in `lookup'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

It's the `nil` that gets returned from `in`.

If you look at the code in `phone_book.rb` it looks like what we want `in` to
return is an actual instance of `EntryRepository`. We can do that by calling
`new` from within `in`:

```ruby
class EntryRepository
  def self.in(dir)
    new
  end
end
```

Run the test again. It's still broken, rather than just plain disappointed.

We're missing a method:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NoMethodError: undefined method `find_by_last_name' for #<EntryRepository:0x007fad62928b98>
    /Users/you/csv-exercises/level-i/phone_book/lib/phone_book.rb:11:in `lookup'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

Define the empty `find_by_last_name` method:

```ruby
class EntryRepository
  def self.in(dir)
    new
  end

  def find_by_last_name
  end
end
```

Running the tests will tell you that it takes a parameter.

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (1 for 0)
    /Users/you/csv-exercises/level-i/phone_book/lib/entry_repository.rb:6:in `find_by_last_name'
    /Users/you/csv-exercises/level-i/phone_book/lib/phone_book.rb:11:in `lookup'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

Looking through the code should tell you that the parameter is `name`:

```ruby
class EntryRepository
  def self.in(dir)
    new
  end

  def find_by_last_name(name)
  end
end
```

We get a familiar error complaining that our results cannot be sorted:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NoMethodError: undefined method `sort_by' for nil:NilClass
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

This is because we removed the hard-coded empty array that we were returning
from `lookup`, and now we're returning the result of `find_by_last_name`,
which is `nil`.

Hard-code a return value for `find_by_last_name`:

```ruby
class EntryRepository
  def self.in(dir)
    new
  end

  def find_by_last_name(name)
    []
  end
end
```

And finally, we get a failure rather than an error.

```plain
  1) Failure:
IntegrationTest#test_lookup_by_last_and_first_name [test/integration_test.rb:14]:
Expected: 3
  Actual: 0
```

Run the `test/phone_book_test.rb` to make sure we haven't broken anything
while wiring up the integration test. It should still be passing.

## Moving On

The failure that we're getting is telling us that we're not getting any
results from `find_by_last_name` in the `EntryRepository`.

The `EntryRepository` needs to handle the rows of CSV data, and return a list
of `Entry` objects that match our search criteria.

Let's assume for now that all the actual CSV stuff happens in the
`EntryRepository.in` method, and that by the time we create an instance of the
repository, we have a collection of data.

Here's a simple test:

```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/entry_repository'

class EntryRepositoryTest < Minitest::Test
  def rows
    [
      { first_name: "Alice", last_name: "Smith", phone_number: "111.111.1111" },
      { first_name: "Bob", last_name: "Smith", phone_number: "222.222.2222" },
      { first_name: "Charlie", last_name: "Jones", phone_number: "333.333.3333" }
    ]
  end

  def repository
    @repository ||= EntryRepository.new(rows)
  end

  def test_find_by_last_name
    entries = repository.find_by_last_name("Smith").sort_by {|e| e.first_name}
    assert_equal 2, entries.length
    alice, bob = entries
    assert_equal "Alice Smith", alice.name
    assert_equal "111.111.1111", alice.phone_number
    assert_equal "Bob Smith", bob.name
    assert_equal "222.222.2222", bob.phone_number
  end
end
```

This is basically the same test as the integration test, except that we're not
actually integrating with anything. Given that the repository has data, we
should be able to get a subset of that data.

Run `test/entry_repository_test.rb`.

```plain
  1) Error:
EntryRepositoryTest#test_find_by_last_name:
ArgumentError: wrong number of arguments(1 for 0)
    test/entry_repository_test.rb:24:in `initialize'
    test/entry_repository_test.rb:24:in `new'
    test/entry_repository_test.rb:24:in `repository'
    test/entry_repository_test.rb:28:in `test_find_by_last_name'
```

We haven't explicitly defined an `initialize` method, and the test is passing
rows of data to the new repository as an options hash.

Make the `initialize` method explicit, and define a parameter for it:

```ruby
class EntryRepository
  def self.in(dir)
    new
  end

  def initialize(rows)
  end

  def find_by_last_name(name)
    []
  end
end
```

Now we're getting an actual failure, which looks exactly like the one we got
from the integration test.

```plain
  1) Failure:
EntryRepositoryTest#test_find_by_last_name [test/entry_repository_test.rb:29]:
Expected: 2
  Actual: 0
```

We need to save the `@rows` that comes into the initialize method, and then
create an `attr_reader`:

```ruby
class EntryRepository
  def self.in(dir)
    new
  end

  attr_reader :rows
  def initialize(rows)
    @rows = rows
  end

  def find_by_last_name(name)
    []
  end
end
```

Then we're going to need to do some real programming to get this to pass. Since
the data is in a hash we can use enumerable methods to filter the data set:

```ruby
def find_by_last_name(name)
  rows.select {|person| person[:last_name] == name}
end
```

Run the tests. We haven't quite connected the dots:

```plain
  1) Error:
EntryRepositoryTest#test_find_by_last_name:
NoMethodError: undefined method `first_name' for {:first_name=>"Alice", :last_name=>"Smith", :phone_number=>"111.111.1111"}:Hash
    test/entry_repository_test.rb:28:in `block in test_find_by_last_name'
    test/entry_repository_test.rb:28:in `each'
    test/entry_repository_test.rb:28:in `sort_by'
    test/entry_repository_test.rb:28:in `test_find_by_last_name'
```

The test expects to get back actual objects that have a `first_name` method.
The object represents an entry in the phone directory listing, so we'll call
the object `entry`.

### Test-Driving a Simple Entry Object

We need an object that has a name and a phone number. Here's a test suite that
gives us an example of what we need:

```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/entry'

class EntryTest < Minitest::Test
  def test_entry_attributes
    data = {
      first_name: 'Alice',
      last_name: 'Smith',
      phone_number: '111.111.1111'
    }
    entry = Entry.new(data)

    assert_equal 'Alice', entry.first_name
    assert_equal 'Smith', entry.last_name
    assert_equal 'Alice Smith', entry.name
    assert_equal '111.111.1111', entry.phone_number
  end
end
```

The test blows up, because we don't have an `entry.rb` file:

```plain
Press ENTER or type command to continue
test/entry_test.rb:4:in `require_relative': cannot load such file -- /Users/you/csv-exercises/level-i/phone_book/lib/entry (LoadError)
	from test/entry_test.rb:4:in `<main>'
```

Create the file:

{% terminal %}
$ touch lib/entry.rb
{% endterminal %}

Next, we're missing a constant:

```plain
  1) Error:
EntryTest#test_entry_attributes:
NameError: uninitialized constant EntryTest::Entry
    test/entry_test.rb:13:in `test_entry_attributes'
```

Define the class:

```ruby
class Entry
end
```

The test expects `Entry` to be initialized with an argument:

```plain
  1) Error:
EntryTest#test_entry_attributes:
ArgumentError: wrong number of arguments (1 for 0)
    test/entry_test.rb:13:in `initialize'
    test/entry_test.rb:13:in `new'
    test/entry_test.rb:13:in `test_entry_attributes'
```

Define the `initialize` method:

```ruby
class Entry
  def initialize(data)
  end
end
```

We're missing a method:

```plain
  1) Error:
EntryTest#test_entry_attributes:
NoMethodError: undefined method `first_name' for #<Entry:0x007fe2133a59b0>
    test/entry_test.rb:15:in `test_entry_attributes'
```

Define a `first_name` method:

```ruby
class Entry
  def initialize(data)
  end

  def first_name
  end
end
```

It's expecting to get an actual name back:

```plain
  1) Failure:
EntryTest#test_entry_attributes [test/entry_test.rb:15]:
Expected: "Alice"
  Actual: nil
```

The quickest way to get this passing is to hard-code the expected value:

```ruby
class Entry
  def initialize(data)
  end

  def first_name
    "Alice"
  end
end
```

Go through the same steps for `last_name`.

You can get `name` passing by combining the first and last names:

```ruby
def name
  "#{first_name} #{last_name}"
end
```

Then we're missing another method:

```plain
  1) Error:
EntryTest#test_entry_attributes:
NoMethodError: undefined method `phone_number' for #<Entry:0x007fa8aab2c0f0>
    test/entry_test.rb:16:in `test_entry_attributes'
```

Define an empty method:

```ruby
class Entry
  def initialize(data)
  end

  def first_name
    "Alice"
  end

  def last_name
    "Smith"
  end

  def name
    "#{first_name} #{last_name}"
  end

  def phone_number
  end
end
```

The test isn't happy yet:

```plain
  1) Failure:
EntryTest#test_entry_attributes [test/entry_test.rb:16]:
Expected: "111.111.1111"
  Actual: nil
```

Make the method pass by hard-coding the return value:

```ruby
def phone_number
  "111.111.1111"
end
```

The tests are passing, but the data is duplicated between the tests and the
implementation. We can fix that by using the data that gets passed into the
initialize method:

```ruby
class Entry
  attr_reader :first_name, :last_name, :phone_number
  def initialize(data)
    @first_name = data[:first_name]
    @last_name = data[:last_name]
    @phone_number = data[:phone_number]
  end

  def name
    "#{first_name} #{last_name}"
  end
end
```

Finally, we can go back to the entry repository.

### Where Were We?

The tests are failing with this error message:

```plain
NoMethodError: undefined method `first_name' for #<Hash:0x007fb37478dca8>
```

Our method is returning a Hash, but our tests expect an object:

```ruby
def find_by_last_name(name)
  rows.select {|row| row[:last_name] == name}
end
```

We need to change the method so that it creates objects for each of the rows:

```ruby
def find_by_last_name(name)
  rows.select {|row| row[:last_name] == name}.map {|row| Entry.new(row)}
end
```

This blows up. We haven't told the repository class where to find the `Entry`.

```plain
  1) Error:
EntryRepositoryTest#test_find_by_last_name:
NameError: uninitialized constant EntryRepository::Entry
    /Users/you/csv-exercises/level-i/phone_book/lib/entry_repository.rb:13:in `block in find_by_last_name'
    /Users/you/csv-exercises/level-i/phone_book/lib/entry_repository.rb:13:in `map'
    /Users/you/csv-exercises/level-i/phone_book/lib/entry_repository.rb:13:in `find_by_last_name'
    test/entry_repository_test.rb:20:in `test_find_by_last_name'
```

Since this isn't a top-level class, we'll require dependencies in the test
rather than the production code.

Require the new entry file in the `entry_repository_test.rb`:

```ruby
# ...
require_relative 'entry'

class EntryRepositoryTest < Minitest::Test
  # ...
end
```

The tests are passing, but now that I see the code in EntryRepository, I'm not
particularly happy about how it's put together.

Every time we search for Alice Smith, we'll make a new Entry object and pass
it back. It seems like maybe the repository should just hold on to a
collection of Entry objects, and if it does, it shouldn't be in charge of
making them in the first place.

Let's change the tests so that the `EntryRepository` is initialized with actual
`Entry` objects.

```ruby
class EntryRepositoryTest < Minitest::Test
  def entries
    [
      { first_name: "Alice", last_name: "Smith", phone_number: "111.111.1111" },
      { first_name: "Bob", last_name: "Smith", phone_number: "222.222.2222" },
      { first_name: "Charlie", last_name: "Jones", phone_number: "333.333.3333" }
    ].map {|row| Entry.new(row)}
  end

  def repository
    @repository ||= EntryRepository.new(entries)
  end
end
```

That breaks, since the code is still accessing its data as though it's a hash:

```plain
 1) Error:
EntryRepositoryTest#test_find_by_last_name:
NoMethodError: undefined method `[]' for #<Entry:0x007fdb491ef7b8>
    /Users/you/csv-exercises/level-i/phone_book/lib/entry_repository.rb:13:in `block in find_by_last_name'
    /Users/you/csv-exercises/level-i/phone_book/lib/entry_repository.rb:13:in `select'
    /Users/you/csv-exercises/level-i/phone_book/lib/entry_repository.rb:13:in `find_by_last_name'
    test/entry_repository_test.rb:21:in `test_find_by_last_name'
```


```ruby
def find_by_last_name(name)
  rows.select {|row| entry.last_name == name}
end
```

It seems odd to call it `rows`, now. They used to be rows of CSV data, but now
that they're real objects. Let's rename this to entries:

```ruby
class EntryRepository
  def self.in(dir)
    new
  end

  attr_reader :entries

  def initialize(entries)
    @entries = entries
  end

  def find_by_last_name(name)
    entries.select {|entry| entry.last_name == name}
  end
end
```

This isn't passing yet:

```plain
  1) Error:
NoMethodError: undefined method `last_name' for #<Entry:0x007fcab09da8f0>
```

Our entry doesn't have a last name method. Go back to the `entry_test.rb` and
add an assertion to the test:

```ruby
assert_equal 'Smith', entry.last_name
```

Get the test passing again:

```ruby
class Entry
  attr_reader :last_name, :name, :phone_number

  def initialize(data)
    @last_name = data[:last_name]
    @name = "#{data[:first_name]} #{last_name}"
    @phone_number = data[:phone_number]
  end
end
```

Pop back over to the `entry_repository_test.rb` and we get a new message:

```plain
NoMethodError: undefined method `first_name' for #<Entry:0x007f9f9b23d510>
```

Ok. Go back to the `entry_test.rb` and add an assertion for `first_name`, and
then make the test pass.

The code now looks like this:

```ruby
class Entry
  attr_reader :last_name, :first_name, :name, :phone_number

  def initialize(data)
    @last_name = data[:last_name]
    @first_name = data[:first_name]
    @name = "#{first_name} #{last_name}"
    @phone_number = data[:phone_number]
  end
end
```

The only line in `initialize` that isn't reading from `data` is `@name`. We
should probably move that out:

```ruby
class Entry
  attr_reader :last_name, :first_name, :phone_number

  def initialize(data)
    @last_name = data[:last_name]
    @first_name = data[:first_name]
    @phone_number = data[:phone_number]
  end

  def name
    "#{first_name} #{last_name}"
  end
end
```

Now both the `Entry` test and the `EntryRepository` test is passing.

It's time to see how our integration test is doing.

### Status?

The integration test is not passing yet, so we're not done.

Here's the first error we're getting:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (0 for 1)
    /Users/you/csv-exercises/level-i/phone_book/lib/entry_repository.rb:8:in `initialize'
    /Users/you/csv-exercises/level-i/phone_book/lib/entry_repository.rb:3:in `new'
    /Users/you/csv-exercises/level-i/phone_book/lib/entry_repository.rb:3:in `in'
    /Users/you/csv-exercises/level-i/phone_book/lib/phone_book.rb:6:in `initialize'
    test/integration_test.rb:8:in `new'
    test/integration_test.rb:8:in `phone_book'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

The problem is that `PhoneBook.new` is being called without any arguments.
This means that we're triggering the `EntryRepository.in` method, which simply
calls `new` to create a new instance of `EntryRepository`. But now
`EntryRepository` needs to be passed data -- the actual instances of all the
entries that represent the CSV file.

Since a test for just the `EntryRepository#in` method would essentially
duplicate the integration test, we'll use the integration test to verify it.

We need to:

* Read the CSV data
* Wrap each row in an Entry object
* call `new` with those Entry objects


```ruby
class EntryRepository
  def self.in(dir)
    file = File.join(dir, 'people.csv')
    data = CSV.open(file, headers: true, header_converters: :symbol)
    rows = data.map do |row|
      Entry.new(row)
    end
    new(rows)
  end
end
```

We're still missing some dependencies:

```plain
NameError: uninitialized constant EntryRepository::CSV
```

The CSV library ships with Ruby, but it is in the Standard Library, not in
Core, so we have to explicitly say that we want to use it.

We need to open up `lib/phone_book.rb` and add the following line at the top:

```ruby
require 'csv'
```

We're also missing the `Entry`:

```plain
NameError: uninitialized constant EntryRepository::Entry
```

Add `require_relative 'entry'` to `lib/phone_book.rb`.

This gets the tests passing.

Commit your changes.

## Adding The Next Features

We want to be able to look up by "Lastname, Firstname".

Add a test to the `integration_test.rb`:

```ruby
def test_lookup_by_last_and_first_name
  phone_book = PhoneBook.new
  entries = phone_book.lookup('Parker, Craig').sort_by {|e| e.first_name}
  assert_equal 1, entries.length
  entry = entries.first
  assert_equal "Craig Parker", entry.name
  assert_equal "716-133-3210", entry.phone_number
end
```

It fails. We need to improve the `PhoneBook#lookup` method. Go to the
`phone_book_test.rb`, add a test for looking up by first and last name:

```ruby
def test_lookup_by_last_name_first_name
  phone_book = PhoneBook.new(repository)
  repository.expect(:find_by_first_and_last_name, [], ["Alice",     "Smith"])
  phone_book.lookup('Smith, Alice')
  repository.verify
end
```

Update `PhoneBook#lookup`

```ruby
def lookup(name)
  lastname, firstname = name.split(', ')
  if firstname
    repository.find_by_first_and_last_name(firstname, lastname)
  else
    repository.find_by_last_name(name)
  end
end
```

Run the integration test again:

```plain
1) Error:
IntegrationTest#test_lookup_by_last_and_first_name:
NoMethodError: undefined method `find_by_first_and_last_name' for #<EntryRepository:0x007f842389f108>
/Users/kytrinyx/turing/csv-exercises/level-i/phone_book/lib/phone_book.rb:15:in `lookup'
  test/integration_test.rb:28:in `test_lookup_by_last_name'
```

We need a new method on entry repository.
In the test:

```ruby
def test_find_by_first_and_last_name
  entries = repository.find_by_first_and_last_name("Bob", "Smith")
  assert_equal 1, entries.length
  bob = entries.first
  assert_equal "Bob Smith", bob.name
  assert_equal "222.222.2222", bob.phone_number
end
```

In the EntryRepository:

```ruby
def find_by_first_and_last_name(first, last)
  entries.select {|entry|
    entry.first_name == first
  }.select {|entry|
    entry.last_name == last
  }
end
```

Run the integration test again. It passes.

Commit your changes.

We're ready to add the final feature, reverse lookup.

Create an integration test.

```ruby
def test_reverse_lookup
  phone_book = PhoneBook.new
  entries = phone_book.reverse_lookup("716-133-3210")

  assert_equal 1, entries.length
  entry = entries.first
  assert_equal "Craig Parker", entry.name
  assert_equal "716-133-3210", entry.phone_number
end
```

Then drop down to phone book test:

```ruby
def test_lookup_by_number
  phone_book = PhoneBook.new(repository)
  repository.expect(:find_by_number, [], ["(123) 123-1234"])
  phone_book.reverse_lookup('(123) 123-1234')
  repository.verify
end
```

Fix the NoMethodError by adding `reverse_lookup` to `PhoneBook`:

```ruby
def reverse_lookup(number)
end
```

This needs to delegate to the repository.

```ruby
def reverse_lookup(number)
  repository.find_by_number(number)
end
```

That gets the phone book test passing. Go back to the integration test.

Now it's complaining about a missing method on entry repository. Drop down to entry repository test and write a test for the missing method.

```ruby
def test_find_by_number
  entries = repository.find_by_number("222.222.2222")
  assert_equal 1, entries.length
  bob = entries.first
  assert_equal "Bob Smith", bob.name
  assert_equal "222.222.2222", bob.phone_number
end
```

Make it pass.

```ruby
def find_by_number(number)
  entries.select {|entry| entry.phone_number == number}
end
```

Go back to the integration test. It passes.

Commit your changes.


## Practice More

### `ReportCard`

The grade is defined by a percentage.

The `ReportCard` class loads the CSV data, creates the students, and also
provides a mechanism to find:

* all the grades for a given student
* all the grades for a particular subject

In addition, it can tell you:

* the average score for a given student
* the average score for a given subject

### The Shopping List

Create an `Item` class that is initialized with the CSV data (`name`,
`quantity`, `unit_price`). Calculate `price` and `tax`.

Implement search methods: `cheaper_than` and `more_expensive_than`.

A couple things that will help you along the way:

* [`String#to_i`](http://ruby-doc.org/core-2.0.0/String.html#method-i-to_i)
* [`String#to_f`](http://ruby-doc.org/core-2.0.0/String.html#method-i-to_f)

### `DoctorsOffice`

The CSV file provides the patient name, and the date and time of their
appointment as actual `Date` and `Time` objects.

There are conversion methods from `Date` to `Time`, and from `Time` to `Date`.

Also, you may want to look at `Time#strptime`, and the handy website [For a
Good Strftime](http://foragoodstrftime.com).

Provide a search method that allows you to find all the appointments for a
single day, or all the appointments for a given patient.

### `Calendar`

Create a test suite for `Birthday`, which has two attributes: `name` and
`date_of_birth`.

Then implement the following functionality:

* Get birthday as a Date object
* Calculate age
* Calculate gigasecond (assume that the person was born at midnight, and just
  get the date where the gigasecond falls).

To create a ruby Date object from a String, try this:

```ruby
require 'date'
Date.strptime('1987', "%Y-%m-%d")
```

A gigasecond is 1 billion seconds. Don't worry about getting the exact moment,
just assume that the person is born at midnight, and calculate the day on
which they turn 1 gigasecond old.

Implement the calendar class to manage the collection of birthdays.
People have a birthday, each day might have multiple birthdays on it.

Once you have the basic functionality that loads the CSV data and creates the
birthday objects, add the following functionality:

* Find everyone who is a certain age
* Find everyone who has a birthday on a certain date (regardless of year)
* Given two names, figure out who is older
* Given two names, figure out who has a birthday earlier in the year than the other

