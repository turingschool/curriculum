---
layout: page
title: Intro to CSV - Level III
sidebar: true
---

This tutorial builds on concepts developed in
[Intro to CSV - Level I](/academy/workshops/csv/i.html) and
[Intro to CSV - Level II](/academy/workshops/csv/ii.html).

We will use the [csv-exercises](https://github.com/JumpstartLab/csv-exercises)
repository to practice using test-driven development and working with objects.

There are five exercises, and this tutorial guides you through the process of
solving the first one.

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

Then check out a new branch to work on the `level-iii` exercises:

{% terminal %}
$ git checkout -b level-iii
{% endterminal %}

Go to the `level-iii` directory:

{% terminal %}
$ cd level-iii
{% endterminal %}

We'll be working on the Phone Book exercise, so change directories to
`phone_book`:

{% terminal %}
cd phone_book
{% endterminal %}

## Phone Book

For our electronic telephone directory listing service we want to be able to
look people up by their last name, or by their first and last name. Also, we
want to provide a reverse lookup, where we input a number, and get back the
name of the person who owns it, along with any contact information that we
have for them.

### Inspecting the Data

If you open up the `./data` directory you'll see two files:

{% terminal %}
./data/
├── people.csv
└── phone_numbers.csv
{% endterminal %}

We have many people, each of whom are identified by a unique identifier in the
`people.csv` file. Each person can have multiple phone numbers. The phone
numbers are listed in the `phone_numbers.csv`, and are connected to the person
via the same unique identifier.

The phone book does not expose this unique identifier to the outside world,
it's just an internal accounting system so that it can keep people straight,
and distinguish between all the various Bob Joneses (or whoever) that we have
in the system.

### Designing the Interface

We have three ways of looking up data in our telephone directory listing:

```ruby
# By last name
phone_book.lookup('Smith')
# By first and last name
phone_book.lookup('Smith, Alice')
# By number
phone_book.reverse_lookup('123-555-1234')
```

Since each person may have many numbers, the result of each search will be an
array of phone book entries, where each entry contains the person's name, and
a list of all their phone numbers.

The reverse lookup could potentially result in multiple entries, since
people living together might share a number, and this number would be
registered to each person separately.

### Knowing When We're Done

When developing a product, it's easy to get carried away as each feature leads
to more and more features. We'll define a single, automated test that will
tell us when our Minimum Usable Product is complete.

The minimal usuable product will be a single pass through the application,
exposing just the first of the lookup methods: `phone_book.lookup('Smith')`.

This will use the real data, and all the real code, as though it were being
used in production. There are many names for tests like these: end-to-end
tests, acceptance tests, feature tests, or integration tests.

For simplicity, let's just choose one of these names and call it an
_integration test_.

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
**Mueller**, you should get 2 names: Justina Mueller and Sharon Mueller.

We don't want to enforce any sort of ordering of the search results, so before
we make the assertions, we'll sort what came back. Then we need to prove that
we got the right names and that the numbers are associated to the correct
person.

Here's what I came up with:

```ruby
class IntegrationTest < Minitest::Test
  def test_lookup_by_last_name
    phone_book = PhoneBook.new
    entries = phone_book.lookup('Mueller').sort_by {|e| e.first_name}
    assert_equal 2, entries.length
    e1, e2 = entries
    assert_equal "Justina Mueller", e1.name
    assert_equal "Sharon Mueller", e2.name
    assert_equal ["(433) 346-3946"], e1.numbers
    assert_equal ["(296) 580-0926", "(484) 305-0295", "(836) 069-1792"], e2.numbers.sort
  end
end
```

### Driving Development with the Integration Test

This integration test is going to be failing until the very end. We will use
the test in the following way:

First, we need to distinguish between **errors** and **failures**.

An **error** means that the code cannot even run. There's a missing file, a
class hasn't been defined, or we're calling a method that does not exist.

A **failure** is a missed expectation. We wanted chocolate cake, but were
given oatmeal cookies with raisins. It's not broken, it's just a
disappointment.

We will use the integration test to fix errors. If the integration test blows
up because we don't have a file, we'll create the file.

However, once the integration test complains that it expected one thing, but
got something else, that will be our signal to drop to a lower level in the
application, abandon the integration test for a while, and develop the
necessary code using more fine-grained tests.

When the fine-grained tests are passing, then we will pop back up to the
integration test, work through any errors, and then use the next failure to
guide us towards the next tests we need to write.

### Handling the First Errors

Run the integration test:

{% terminal %}
$ ruby test/integration_test.rb
{% endterminal %}

The first error is a missing file:

```plain
test/integration_test.rb:4:in `require_relative': cannot load such file -- /Users/you/csv-exercises/level-iii/phone_book/lib/phone_book (LoadError)
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
    /Users/you/csv-exercises/level-iii/phone_book/lib/phone_book.rb:2:in `lookup'
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
IntegrationTest#test_lookup_by_last_and_first_name [test/integration_test.rb:10]:
Expected: 2
  Actual: 0
```

### Driving a Feature with Lower-Level Tests

We're getting a failure because we expect to get 2 results back from the
lookup method, but we're hard-coding an empty array.

We need a phone book that, given a bunch of entries, will find the right ones
for us. Let's defer having to know about how entries are getting out of the
CSV files, and just talk to an `EntryRepository` who just handles that for us.

So let's punt.

We'll create a test that just says that phone book talks to the entry
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

### Mocking an Interaction

A mock expectation goes like this:

1. set up the expectation
2. do work
3. check that while work was being done, the right things happened

Suppose that you have some code that is very polite. When you say be polite it
does a number of things, such as say thank you and hello. We'll make an
expectation that being polite includes saying `hello`:

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

Run the test again, and get a failure:

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

### Where to Go Next

Right off the bat, we get an error:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (0 for 1)
    /Users/you/csv-exercises/level-iii/phone_book/lib/phone_book.rb:4:in `initialize'
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
    /Users/you/csv-exercises/level-iii/phone_book/lib/phone_book.rb:4:in `initialize'
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
    /Users/you/csv-exercises/level-iii/phone_book/lib/phone_book.rb:6:in `initialize'
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
    /Users/you/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:2:in `in'
    /Users/you/csv-exercises/level-iii/phone_book/lib/phone_book.rb:6:in `initialize'
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
    /Users/you/csv-exercises/level-iii/phone_book/lib/phone_book.rb:11:in `lookup'
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
    /Users/you/csv-exercises/level-iii/phone_book/lib/phone_book.rb:11:in `lookup'
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
    /Users/you/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:6:in `find_by_last_name'
    /Users/you/csv-exercises/level-iii/phone_book/lib/phone_book.rb:11:in `lookup'
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
IntegrationTest#test_lookup_by_last_and_first_name [test/integration_test.rb:10]:
Expected: 2
  Actual: 0
```

Run the `test/phone_book_test.rb` to make sure we haven't broken anything
while wiring up the integration test. It should still be passing.

### Moving On

The failure that we're getting is telling us that we're not getting any
results from `find_by_last_name` in the `EntryRepository`.

We know that `EntryRepository` needs to handle two different CSV files, and we
can assume that it will handle both of them very similarly. Let's put off
having to actually read CSV files for a while, and just assume that the entry
repository is given two sets of data: one for people and one for phone
numbers.

We're going to need to look up multiple entries by last name, so our fake data
should have two matches and one non-match to ensure that we correctly exclude
people with a different last name.

Also, since people can have more than one number, we should make sure that one
of the fake entries has more than one phone number, to make sure that we don't
just return the first number for each person.

Here's a simple test:

```ruby
class EntryRepositoryTest < Minitest::Test
  def people
    [
      { id: "1", first_name: "Alice", last_name: "Smith" },
      { id: "2", first_name: "Bob", last_name: "Smith" },
      { id: "3", first_name: "Charlie", last_name: "Jones" }
    ]
  end

  def phone_numbers
    [
      { person_id: "1", phone_number: "111.111.1111" },
      { person_id: "1", phone_number: "111.111.2222" },
      { person_id: "2", phone_number: "222-222-1111" }
    ]
  end

  def repository
    @repository ||= EntryRepository.new(:people => people, :phone_numbers => phone_numbers)
  end

  def test_find_by_last_name
    entries = repository.find_by_last_name("Smith").sort_by {|e| e.first_name}
    assert_equal 2, entries.length
    alice, bob = entries
    assert_equal "Alice Smith", alice.name
    assert_equal ["111.111.1111", "111.111.2222"], alice.numbers
    assert_equal "Bob Smith", bob.name
    assert_equal ["222-222-1111"], bob.numbers
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
people and phone numbers to the new repository as an options hash.

Make the `initialize` method explicit, and define a paramater for it:

```ruby
class EntryRepository
  def self.in(dir)
    new
  end

  def initialize(data)
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

We're going to need to do some real programming to get this to pass. Since the
data is in a hash we can use enumerable methods to filter the data set:

```ruby
def find_by_last_name(name)
  people.select {|person| person[:last_name] == name}
end
```

Run the tests. We haven't quite connected the dots:

```plain
  1) Error:
EntryRepositoryTest#test_find_by_last_name:
NoMethodError: undefined method `first_name' for {:id=>"1", :first_name=>"Alice", :last_name=>"Smith"}:Hash
    test/entry_repository_test.rb:28:in `block in test_find_by_last_name'
    test/entry_repository_test.rb:28:in `each'
    test/entry_repository_test.rb:28:in `sort_by'
    test/entry_repository_test.rb:28:in `test_find_by_last_name'
```

The test expects to get back actual objects that have a `first_name` method.
The object represents an entry in the phone directory listing, so we'll call
the object `entry`.

Create the file:

{% terminal %}
$ touch lib/entry.rb
{% endterminal %}

We'll use a simple struct for now, and we won't bother testing it directly.
Perhaps later, if it attracts more behavior, we will make it a more
sophisticated class and give it its own tests.

```ruby
Entry = Struct.new(:first_name, :last_name)
```

We need to wrap the raw data in the `people` hash in an `Entry` object. In the
`EntryRepository` map through the filtered results and create an `Entry` for
each one.

```ruby
def find_by_last_name(name)
  people.select {|person|
    person[:last_name] == name
  }.map {|person|
    Entry.new(person[:first_name], person[:last_name])
  }
end
```

** FROM HERE **

```plain
  1) Error:
EntryRepositoryTest#test_find_by_last_name:
NameError: uninitialized constant EntryRepository::Entry
    /Users/you/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:17:in `block in find_by_last_name'
    /Users/you/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:14:in `map'
    /Users/you/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:14:in `find_by_last_name'
    test/entry_repository_test.rb:28:in `test_find_by_last_name'
```

Require the new entry file:

```ruby
require_relative 'entry'

class EntryRepository
  # ...
end
```

```plain
  1) Error:
EntryRepositoryTest#test_find_by_last_name:
NoMethodError: undefined method `name' for #<struct Entry first_name="Alice", last_name="Smith">
    test/entry_repository_test.rb:32:in `test_find_by_last_name'
```

Add a name method to `Entry`:

```ruby
Entry = Struct.new(:first_name, :last_name) do
  def name
    "#{first_name} #{last_name}"
  end
end
```

```plain
  1) Error:
EntryRepositoryTest#test_find_by_last_name:
NoMethodError: undefined method `numbers' for #<struct Entry first_name="Alice", last_name="Smith">
    test/entry_repository_test.rb:33:in `test_find_by_last_name'
```

Oh. I forgot about numbers. OK, we need numbers in `Entry`:

```ruby
Entry = Struct.new(:first_name, :last_name, :numbers) do
  def name
    "#{first_name} #{last_name}"
  end
end
```

To get them into the entry we need to actually put them there when we search
for the person:

```ruby
def find_by_last_name(name)
  people.select {|person|
    person[:last_name] == name
  }.map {|person|
    numbers = phone_numbers.select {|number|
      number[:person_id] == person[:id]
    }.map {|number|
      number[:phone_number]
    }
    Entry.new(person[:first_name], person[:last_name], numbers)
  }
end
```

That passes the test, but this is getting pretty hairy.

Let's step back and think about this for a bit.

Here's the code I wish I could write:

```ruby
people.find_by(:last_name, name).map { |person|
  numbers = phone_numbers.find_by(:person_id, person.id)
  Entry.new(person.first_name, person.last_name, numbers)
}
```

This would mean that `people` and `phone_numbers` are not arrays, but actual
objects. Maybe each CSV file becomes a small database object that can provide
a nice search interface.

Let's test-drive a small CSV database object, and then we can refactor the
`EntryRepository` class to use it.

### CSV Database

First, we're going to need a small fixture file. It doesn't matter what fields
it has, this CSV database should be able to handle any fields.

Create an empty CSV file in `test/fixtures`:

{% terminal %}
$ touch test/fixtures/things.csv
{% endterminal %}

Add some data to it. We want at least two fields, one should be an `id` field,
and we should be able to handle duplicate data with different `id`s:

```csv
id,name
1,popsicle
2,tire
3,tire
```

```ruby
require_relative 'entry'
require_relative 'db'

class EntryRepository
  # ...
end
```

All the usual complaints.

Create an empty file

{% terminal %}
$ touch lib/db.rb
{% endterminal %}

Follow the trail of complaints:

- add empty class DB
- add a class method `read` that takes a paramater `filename`
- return `new`
- add a `find_by` method that takes a `field` and a `value`
- return an empty array from the `find_by` method


```ruby
class DB
  def self.read(filename)
    new
  end

  def find_by(field, value)
    []
  end
end
```

Now we have a failure. We need actual data, instead of an empty array.

```ruby
def self.read(filename)
  new CSV.open(filename, headers: true, header_converters: :symbol).to_a
end
```

```plain
NameError: uninitialized constant DB::CSV
```

Require 'csv' from the standard library:

```ruby
require 'csv'

class DB
  # ...
end
```

```plain
ArgumentError: wrong number of arguments(1 for 0)
    /Users/you/csv-exercises/level-iii/phone_book/lib/db.rb:3:in `initialize'
```

Make it pass:

```ruby
class DB
  def self.read(filename)
    new CSV.open(filename, headers: true, header_converters: :symbol)
  end

  attr_reader :rows

  def initialize(rows)
    @rows = rows
  end

  def find_by(field, value)
    rows.select {|row| row[field] == value}
  end
end
```

### Using the DB in EntryRepository

Inside the `entry_repository_test` we have a method `people` that returns the
hashes representing CSV rows.

Rename that method to `people_data`, and create a new method `people` that
returns a database using those rows:

```ruby
class EntryRepositoryTest < Minitest::Test
  def people_data
    [
      { id: "1", first_name: "Alice", last_name: "Smith" },
      { id: "2", first_name: "Bob", last_name: "Smith" },
      { id: "3", first_name: "Charlie", last_name: "Jones" }
    ]
  end

  def people
    DB.new(people_data)
  end
  # ...
end
```

Do the same for the `phone_numbers`.

```plain
NameError: uninitialized constant EntryRepositoryTest::DB
```

Require the file.

```plain
  1) Error:
  EntryRepositoryTest#test_find_by_last_name:
  NoMethodError: private method `select' called for #<DB:0x007fc572a37250>
```

Change the `find_by_last_name` method to use the new databases:

```ruby
def find_by_last_name(name)
  people.find_by(:last_name, name).map {|person|
    numbers = phone_numbers.find_by(:person_id, person[:id]).map {|number|
      number[:phone_number]
    }
    Entry.new(person[:first_name], person[:last_name], numbers)
  }
end
```

### Pop back up. Status?

Run the integration test again to figure out where we need to go next.

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (0 for 1)
    /Users/you/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:10:in `initialize'
    /Users/you/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:5:in `new'
    /Users/you/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:5:in `in'
    /Users/you/csv-exercises/level-iii/phone_book/lib/phone_book.rb:6:in `initialize'
    test/integration_test.rb:8:in `new'
    test/integration_test.rb:8:in `phone_book'
    test/integration_test.rb:12:in `test_lookup_by_last_name'

```

We're calling the `EntryRepository.new` wrong.

The test calls `PhoneBook.new` which uses the default value for the
repository, which is `EntryRepository.in('./data')`. The `in` method looks
like this:

```ruby
def self.in(dir)
  new
end
```

But `initialize` needs an options hash that takes both the person database and
the phone number database. Rather than add a method specifically for the
factory method, let's just let the integration test prove it for us:

```ruby
def self.in(dir)
  people = DB.new(File.join(dir, 'people.csv'))
  phone_numbers = DB.new(File.join(dir, 'phone_numbers.csv'))
  new(people: people, phone_numbers: phone_numbers)
end
```

If we've done everything right, this should just work.

Run the integration tests:

```plain
  1) Failure:
IntegrationTest#test_lookup_by_last_name [test/integration_test.rb:17]:
Expected: ["(433) 346-3946"]
  Actual: ["433-346-3946"]
```

Close. We forgot about formatting the phone numbers.

Let's add that in the entry repository. Tweak the assertions so that they expect
the new format. Don't change the test data.

```plain
  1) Failure:
EntryRepositoryTest#test_find_by_last_name [test/entry_repository_test.rb:42]:
--- expected
+++ actual
@@ -1 +1 @@
-["(111) 111-1111", "(111) 111-2222"]
+["111.111.1111", "111.111.2222"]
```

Make the entry repository format the number:

```ruby
def find_by_last_name(name)
  people.find_by(:last_name, name).map {|person|
    numbers = phone_numbers.find_by(:person_id, person[:id]).map {|number|
      format number[:phone_number]
    }
    Entry.new(person[:first_name], person[:last_name], numbers)
  }
end

def format(number)
  digits = number.delete("-.")
  area_code = digits[0..2]
  exchange = digits[3..5]
  subscriber = digits[-4..-1]

  "(%s) %s-%s" % [area_code, exchange, subscriber]
end
```

This gets the integration test passing!

The entry repository is pretty gross, though. `format` has nothing to do with
dealing with persistence of phone book entries.

Also, the wishful thinking code that I wrote earlier looked like this:

```ruby
people.find_by(:last_name, name).map { |person|
  numbers = phone_numbers.find_by(:person_id, person.id)
  Entry.new(person.first_name, person.last_name, numbers)
}
```

But the actual code looks like this:

```ruby
people.find_by(:last_name, name).map {|person|
  numbers = phone_numbers.find_by(:person_id, person[:id]).map {|number|
    format number[:phone_number]
  }
  Entry.new(person[:first_name], person[:last_name], numbers)
}
```

The biggest difference is that we're mucking about with hashes in the current
code, whereas in the aspirational code we have objects that respond to things
like `first_name` and `last_name`.

Let's refactor so that we have a `Person` class and a `PhoneNumber` class.
This will also allow us to move all the formatting into `PhoneNumber`.

### Little Objects

This will have to change in several places. First, our DB will need to
instantiate objects rather than just passing back rows, to do this, we'll need
a Person object and a PhoneNumber object.

Let's start with Person.

in `test/person_test.rb`:

```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/person'

class PersonTest < Minitest::Test
  def test_first_name
    person = Person.new(first_name: 'Alice')
    assert_equal 'Alice', person.first_name
  end
end
```

To get the test to pass we need a very simple Person class:

```ruby
class Person
  attr_reader :first_name
  def initialize(data)
    @first_name = data[:first_name]
  end
end
```

Let's add a test for last name:

```ruby
def test_last_name
  person = Person.new(last_name: 'Smith')
  assert_equal 'Smith', person.last_name
end
```

Make it pass.

```ruby
class Person
  attr_reader :last_name, :first_name
  def initialize(data)
    @first_name = data[:first_name]
    @last_name = data[:last_name]
  end
end
```

Finally, let's add a test for the `id`:

```ruby
def test_id
  person = Person.new(id: "1")
  assert_equal "1", person.id
end
```

Make it pass:

```ruby
class Person
  attr_reader :id, :last_name, :first_name
  def initialize(data)
    @id = data[:id].to_i
    @last_name = data[:last_name]
    @first_name = data[:first_name]
  end
end
```

We could have used a struct for this, but these are value objects. Once the
values have been set, we don't want anyone to be changing any of the fields,
and if this were a struct, the fields would all accessible from the outside.

Now do the same for phone number.

```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/phone_number'

class PersonTest < Minitest::Test
  def test_id
    number = PhoneNumber.new(person_id: "1")
    assert_equal 1, number.person_id
  end

  def test_number_with_dashes
    number = PhoneNumber.new(phone_number: '123-456-7890')
    assert_equal "(123) 456-7890", number.to_s
  end

  def test_number_with_dots
    number = PhoneNumber.new(phone_number: '123.456.7890')
    assert_equal "(123) 456-7890", number.to_s
  end
end
```

Make it pass.

```ruby
class PhoneNumber
  attr_reader :person_id

  def initialize(data)
    @person_id = data[:person_id].to_i
    @input = data[:phone_number]
  end

  def to_s
    "(%s) %s-%s" % [area_code, exchange, subscriber]
  end

  private

  def digits
    @input.delete(".-")
  end

  def area_code
    digits[0..2]
  end

  def exchange
    digits[3..5]
  end

  def subscriber
    digits[-4..-1]
  end
end
```

OK, so now we have little phone number and person objects, we need the
database to actually return these objects instead of csv rows/hashes.

Add a `Thing` class in the `DBTest` which we'll use to wrap the rows of
thing data:

```ruby
class DBTest < Minitest::Test
  class Thing
    attr_reader :id, :name
    def initialize(data)
      @id = data[:id]
      @name = data[:name]
    end
  end

  # ...
end
```

Then tweak the assertions to send messages to the object instead of
referencing hash keys.

```ruby
def test_find_by_id
  # ...
  assert_equal "popsicle", things.first.name
end

def test_find_by_name
  # ...
  assert_equal ["2", "3"], things.map(&:id)
end
```

That breaks everything. We need to be able to tell the `DB.read` file what
object to create:

```ruby
class DBTest < Minitest::Test
  # ...

  def db
    @db ||= DB.read(filename, Thing)
  end

  # ...
end
```

This necessitates two changes in the `db` file.

First, the `read` method needs to loop through the csv data to create the
objects:

```ruby
def self.read(filename, klass)
  rows = CSV.open(filename, headers: true, header_converters: :symbol)
  objects = rows.map { |row|
    klass.new(row)
  }
  new(objects)
end
```

And then we need to send a message instead of referencing the hash:

```ruby
def find_by(field, value)
  rows.select {|row| row.send(attribute) == value}
end
```

The name `rows` is also not correct. Let's use `objects`, leaving us with the
following code for the `DB` class:

```ruby
class DB
  def self.read(filename, klass)
    rows = CSV.open(filename, headers: true, header_converters: :symbol)
    objects = rows.map { |row|
      klass.new(row)
    }
    new(objects)
  end

  attr_reader :objects

  def initialize(objects)
    @objects = objects
  end

  def find_by(field, value)
    objects.select {|object| object.send(field) == value}
  end
end
```

Also, `field` seems wrong. Let's call it an attribute:

```ruby
def find_by(attribute, value)
  objects.select {|object| object.send(attribute) == value}
end
```

We're done with the `DB`, let's pop back to the `entry_repository_test` and
see how bad the carnage is.

```plain
NoMethodError: undefined method `last_name' for {:id=>"1", :first_name=>"Alice", :last_name=>"Smith"}:Hash
```

That makes sense. We need to make objects.

First, include the `person` and `phone_number` classes in the entry repository
test:

```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/person'
require_relative '../lib/phone_number'
require_relative '../lib/db'
require_relative '../lib/entry'
require_relative '../lib/entry_repository'

class EntryRepositoryTest < Minitest::Test
end
```

Then change the `people_data` so that it creates objects:

```ruby
def people_data
  [
    { id: "1", first_name: "Alice", last_name: "Smith" },
    { id: "2", first_name: "Bob", last_name: "Smith" },
    { id: "3", first_name: "Charlie", last_name: "Jones" }
  ].map {|row| Person.new(row)}
end
```

Fix `phone_number_data` similarly.

Then tweak the `entry_repository`

```ruby
def find_by_last_name(name)
  people.find_by(:last_name, name).map {|person|
    numbers = phone_numbers.find_by(:person_id, person.id).map(&:to_s)
    Entry.new(person.first_name, person.last_name, numbers)
  }
end
```

Delete the `format` method.

Next, pop back up to the `test/phone_book_test.rb`, which still passes.

Now try the `test/integration_test.rb` again

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (1 for 2)
    /Users/you/csv-exercises/level-iii/phone_book/lib/db.rb:4:in `read'
    /Users/you/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:6:in `in'
    /Users/you/csv-exercises/level-iii/phone_book/lib/phone_book.rb:6:in `initialize'
    test/integration_test.rb:8:in `new'
    test/integration_test.rb:8:in `phone_book'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

We haven't fixed the `DB.read` methods in `EntryRepository.in`.

```ruby
def self.in(dir)
  people = DB.read(File.join(dir, 'people.csv'), Person)
  phone_numbers = DB.read(File.join(dir, 'phone_numbers.csv'), PhoneNumber)
  new(people: people, phone_numbers: phone_numbers)
end
```

Then we're missing some constants. Add all the necessary requires to
`lib/phone_book.rb`.

**TODO**: Move all require statements into `lib/phone_number` and into the tests.

**TODO**: remove references to `you` etc.

### Run all the tests

Create a `Rakefile`, and put this in it:

```ruby
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

task default: :test
```

Now you can say `rake` to run all the tests in the entire project all at once.

The test suite is pretty slow at about a 10th of a second. Let's use fixtures
for the integration test instead of going against production data.

### Speeding up integration test

Add a minimal `test/fixtures/people.csv` file:

```csv
id,last_name,first_name
1,Smith,Alice
2,Smith,Bob
3,Jones,Charlie
```

And a minimal `test/fixtures/phone_numbers.csv` file.

```csv
person_id,phone_number
1,111.111.1111
1,111.111.2222
2,222-222-1111
```

Update the test to use the new data:

```ruby
def test_lookup_by_last_name
  entries = phone_book.lookup('Smith').sort_by {|e| e.first_name}
  assert_equal 2, entries.length
  e1, e2 = entries
  assert_equal "Alice Smith", e1.name
  assert_equal "Bob Smith", e2.name
  assert_equal ["(111) 111-1111", "(111) 111-2222"], e1.numbers
  assert_equal ["(222) 222-1111"], e2.numbers.sort
end
```

That should cut the time it takes for the test suite to run from about 100 ms
to about 15 ms.

### More features

Look up by first and last name.

Add more test fixtures. We need two people with the same first and last name,
as well as someone with the same last name but different first name, so that
we make sure that this person doesn't get included.

Update the fixture:

```csv
id,last_name,first_name
1,Smith,Alice
2,Smith,Bob
3,Jones,Charlie
4,Jones,Charlie
5,Jones,David
```

The jonses will need phone numbers:

```csv
person_id,phone_number
1,111.111.1111
1,111.111.2222
2,222-222-1111
3,333-333-1111
3,333-333-2222
4,444-444-1111
5,555-555-1111
```

```ruby
def test_lookup_by_last_and_first_name
  entries = phone_book.lookup('Jones, Charlie').sort_by {|e| e.numbers.length }
  assert_equal 2, entries.length
  e1, e2 = entries
  assert_equal ['444-444-1111'], e1.numbers.sort
  assert_equal ['333-333-1111', '333-333-2222'], e2.numbers.sort
end
```

Make it pass.

Then do reverse lookup.

```ruby
def test_reverse_lookup
  entries = phone_book.reverse_lookup("(111) 111-1111")
  assert_equal 1, entries.length
  entry = entries.first
  assert_equal "Alice Smith", entry.name
  assert_equal ["(111) 111-1111", "(111) 111-2222"], entry.numbers.sort
end
```

## Practice More

You're on your own for these.

### Calendar

People have a birthday, each day might have multiple birthdays on it.

### Doctor's Office

Patients can have many appointments.

### Report Card

Students have many subjects, and a grade in each subject

### Shopping List

Products have a name and a unit price.
There are many stores.

A store can have many products (all priced the same across all stores).

