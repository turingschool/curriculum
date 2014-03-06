---
layout: page
title: Intro to CSV - Level II
sidebar: true
---

We will use the [csv-exercises](https://github.com/JumpstartLab/csv-exercises)
repository to practice using test-driven development and working with objects.

This tutorial builds on concepts developed in
[Intro to CSV - Level I](/academy/workshops/csv/i.html).

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

Then check out a new branch to work on the `level-ii` exercises:

{% terminal %}
$ git checkout -b level-ii
{% endterminal %}

Go to the `level-ii` directory:

{% terminal %}
$ cd level-ii
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
name of the person who owns it, along with any contact information that we
have for them.

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

## Designing the Interface

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

## Knowing When We're Done

We will develop a _minimum usable product_ using an integration test, which
will be failing until we've achieved a working feature.

### A Quick Refresher on Errors vs Failures

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

## Writing a Failing Test

Create an empty file called `test/integration_test.rb`. We're going to start
by adding the usual testing boilerplate to it:

```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/phone_book'

class IntegrationTest < Minitest::Test
end
```

We're going to write a single test that pretends it is in production (no
fakes or mocks or fixtures). This test will prove that we can look people up
by last name.

If you open up the file and manually count the people with last name
**Mueller**, you should get 2 names: Justina Mueller and Sharon Mueller.

We don't want to enforce any sort of ordering of the search results, so before
we make the assertions, we'll sort what came back. Then we need to prove that
we got the right names and that the numbers are associated to the correct
person.

Here's the test I came up with:

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

## Handling the First Errors

There are a number of wiring issues, which are exposed by this test:

* We don't have a file called `phone_book.rb`
* We don't have a `PhoneBook` class
* We don't have a method `lookup` for the `PhoneBook` instance
* The `lookup` method needs to return something that responds to `sort_by`,
  such as an array

Fixing all of these errors results in the following code:

```ruby
class PhoneBook
  def lookup(name)
    []
  end
end
```

At this point the test produces a failure rather than an error:

```plain
  1) Failure:
IntegrationTest#test_lookup_by_last_name [test/integration_test.rb:10]:
Expected: 2
  Actual: 0
```

## Driving a Feature with Lower-Level Tests

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

In the `test/phone_book_test.rb` add the following test:

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

We are making sure that it calls the method with the right arguments
("Smith"), and we're faking out the return value to be an empty array.

We get a couple of straight-forward errors:

* `PhoneBook` needs an `initialize` that takes a repository.
* `lookup` needs to delegate to the `repository`

This gives us the following code:

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

The test is passing.

Now we need to go back to the integration test, fix any errors, and then let
the failure tell us where to go next.

## Where to Go Next

Now our integration test is giving errors again rather than failures.

The first error is complaining about how we create a new `PhoneBook` instance:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (0 for 1)
    /Users/you/csv-exercises/level-ii/phone_book/lib/phone_book.rb:4:in `initialize'
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

Follow the trail of no such files, constants, and methods, until the
integration test is producting an assertion failure rather than errors.

Remember that in the integration test you should have a single `require`
statement that has anything to do with the application:

```ruby
require './lib/phone_book'
```

If the app needs to load files to get the integration test to pass, put those
require statements inside the `lib/phone_book.rb` file.

All tests for anything other than the `lib/phone_book` class should put
require statements in the test file.

You'll have something to this effect:

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

The failing integration is back to the usual:

```plain
  1) Failure:
IntegrationTest#test_lookup_by_last_name [test/integration_test.rb:10]:
Expected: 2
  Actual: 0
```

Run the `test/phone_book_test.rb` to make sure we haven't broken anything
while wiring up the integration test. It should still be passing.

## Moving On

The failure that we're getting is telling us that we're not getting any
real results from `find_by_last_name` in the `EntryRepository`. This makes
sense, since we're hard-coding an empty array.

We know that `EntryRepository` needs to handle two different CSV files, and we
can assume that it will handle both of them very similarly. Let's put off
having to actually read CSV files for a while, and just assume that the entry
repository is given two sets of data: one for people and one for phone
numbers.

We're going to need to look up multiple entries by last name, so our fake data
should have two matches and one non-match to ensure that we correctly
**include** people with the right last name and correctly **exclude** people
with a different last name.

Also, since people can have more than one number, we should make sure that one
of the fake entries has more than one phone number, to make sure that we don't
just return the first number for each person.

Building on what we learned working through CSV-I, we'll make it so that
`EntryRepository` returns objects. Since the data is spread out across two
files, we'll want an object that represents the combined records for a single
person. Let's call it `Entry`.

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
    @repository ||= EntryRepository.new(people, phone_numbers)
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
actually integrating with real data. Provided that the repository has data, we
should be able to get a subset of that data.

There are a number of good reasons why our test is blowing up. The first is
that we need to give the `EntryRepository` an `initialize` method that takes
the data hashes:

```ruby
class EntryRepository
  def self.in(dir)
    new
  end

  def initialize(people, phone_numbers)
  end

  def find_by_last_name(name)
    []
  end
end
```

Next, we need an `Entry` object.

We'll use a simple struct for now, and we won't bother testing it directly.
Perhaps later, if it attracts more behavior, we will make it a more
sophisticated class and give it its own tests.

```ruby
# lib/entry.rb
Entry = Struct.new(:first_name, :last_name, :numbers)
```

It also needs to have a `:name` method:

```ruby
Entry = Struct.new(:first_name, :last_name, :numbers) do
  def name
    "#{first_name} #{last_name}"
  end
end
```

OK. Where were we?

The `EntryRepository#find_by_last_name` is returning a hard-coded empty array,
but our test is expecting two entries.

We need to find the right people to return:

```ruby
class EntryRepository
  def self.in(dir)
    new
  end

  attr_reader :people, :phone_numbers
  def initialize(people, phone_numbers)
    @people = people
    @phone_numbers = phone_numbers
  end

  def find_by_last_name(name)
    people.select {|person|
      person[:last_name] == name
    }
  end
end
```

This, of course, returns a hash, not an Entry, so we need to plug the data
into the object:

```ruby
def find_by_last_name(name)
  people.select {|person|
    person[:last_name] == name
  }.map {|data|
    Entry.new(data[:first_name], data[:last_name])
  }
end
```

This gets us past the first assertion, since we have the right name, but now
we need to associate the correct phone numbers with this data.

Here's what I came up with:

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

That passes the test, but this is getting pretty hairy. Let's step back and
think about this for a bit.

## Programming by Wishful Thinking

Here's the code I wish I could write:

```ruby
people.find_by(:last_name, name).map { |person|
  numbers = phone_numbers.find_by(:person_id, person.id)
  Entry.new(person[:first_name], person[:last_name], numbers)
}
```

This would mean that `people` and `phone_numbers` are not arrays, but actual
objects. Maybe each CSV file could be read into a small database object that
can provide a nice search interface like `find_by`.

## Test-Driving a CSV Wrapper

We'll write some tests to drive out the design of a simple object that reads
data from a CSV file and provides a search interface to those objects.

Once we have that working, we can refactor the `EntryRepository` to use it.

First, we're going to need a small fixture file. We could use something that
looks like our people or phone number CSV file, but really it shouldn't matter
what fields are in the file -- the wrapper should handle any existing fields
seamlessly.

The customary location for support files like this is a directory within
`test` called `fixtures`.

Create an empty file `test/fixtures/things.csv`:

{% terminal %}
$ touch test/fixtures/things.csv
{% endterminal %}

We want at least two fields. Keeping it simple, let's go with `id` and `name`.

```csv
id,name
1,popsicle
2,tire
3,tire
```

### Writing a Failing Test

We want to tell the database where to find the CSV file, but it would also be
very handy to be able to create a database just by giving it arrays of hashes
representing the CSV data.

It's considered good form to do as little work as possible within the
`initialize` method, so we'll use `initialize` to assign rows of data.

```ruby
db = DB.new(rows)
```

Then we'll add an extra class method that will read from the file system:

```ruby
db = DB.read('path/to/file.csv')
```

The test looks like this:

```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/db'

class DBTest < Minitest::Test
  def filename
    @filename ||= File.absolute_path("../fixtures/things.csv", __FILE__)
  end

  def db
    DB.read(filename)
  end

  def test_find_by_name
    things = db.find_by(:name, "tire")
    assert_equal 2, things.size
    assert_equal ["2", "3"], things.map {|thing| thing[:id]}
  end
end
```

Running the test gives us all the usual complaints.

Follow the trail:

* create an empty file
* add empty class DB
* add a class method `read`
* ... that takes a paramater `filename`
* return `new` from the `read` method
* add an instance method called `find_by` method
* ... that takes a `field` and a `value`
* return an empty array from the `find_by` method

That should give you the following code:

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

We now have a real failure.

```plain
  1) Failure:
DBTest#test_find_by_name [db_test.rb:14]:
Expected: 2
  Actual: 0
```

We need to return actual data from the `find_by` method.

Let's read the CSV file, and convert the rows to an array, passing it to `new`:

```ruby
def self.read(filename)
  new CSV.open(filename, headers: true, header_converters: :symbol).to_a
end
```

Run the test, which will fail because it doesn't know about a `CSV` class.

```plain
NameError: uninitialized constant DB::CSV
```

The CSV library ships with Ruby, but it is in the Standard Library, not in
Core, so we have to explicitly say that we want to use it.

Require 'csv' from the standard library in the test file:

```ruby
require 'csv'
```

Run the test again.

```plain
ArgumentError: wrong number of arguments(1 for 0)
    /Users/you/csv-exercises/level-ii/phone_book/lib/db.rb:3:in `initialize'
```

We're passing an argument to `initialize`, but the default initialize method
doesn't accept any arguments.

Add the initialize method, and expose the incoming rows using an
`attr_reader`.

```ruby
class DB
  def self.read(filename)
    new CSV.open(filename, headers: true, header_converters: :symbol).to_a
  end

  attr_reader :data

  def initialize(data)
    @data = data
  end

  def find_by(field, value)
    []
  end
end
```

The test is failing, but finally have what we need to make it pass. Loop
through the rows to find the ones you need:

```ruby
def find_by(field, value)
  data.select {|datum| datum[field] == value}
end
```

This gets the test passing.

### Modifying `EntryRepository` to use the DB

Inside the `entry_repository_test` we have a method `people` that returns the
hashes representing CSV rows. We need to provide a `DB` object that is holding
onto the rows rather than the rows themselves.

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

The tests blow up, because they don't know about the `DB` constant.

```plain
NameError: uninitialized constant EntryRepositoryTest::DB
```

Require the `db` file from within the test suite, and run the test again.

```plain
1) Error:
  EntryRepositoryTest#test_find_by_last_name:
  NoMethodError: private method `select' called for #<DB:0x007fc572a37250>
```

This error is fairly cryptic. It says that we're calling `select` on the `DB`
instance. We never created a method named `select` on `DB`, but apparently
there's a method named `select` that `DB` inherited from someone -- probably
`Object`.

We're calling `select` in order to filter the rows, but what we really want to
do is use the new `find_by` method:

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

This gets the `entry_repository_test.rb` passing. In fact, at the moment,
`db_test.rb`, `entry_repository_test.rb` and `phone_book_test.rb` are all
passing, so we need to go back to the integration test to figure out what our
next step is.

## What's Next?

The integration test is not happy. It's throwing an `ArgumentError`:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (0 for 1)
    /Users/you/csv-exercises/level-ii/phone_book/lib/entry_repository.rb:10:in `initialize'
    /Users/you/csv-exercises/level-ii/phone_book/lib/entry_repository.rb:5:in `new'
    /Users/you/csv-exercises/level-ii/phone_book/lib/entry_repository.rb:5:in `in'
    /Users/you/csv-exercises/level-ii/phone_book/lib/phone_book.rb:6:in `initialize'
    test/integration_test.rb:8:in `new'
    test/integration_test.rb:8:in `phone_book'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

Somewhere in this mess, we're calling the `EntryRepository.new` wrong. Tracing
through the stacktrace suggests that it all starts when we call
`PhoneBook.new` without any parameters. This uses the default value for the
repository, which is `EntryRepository.in('./data')`.

The `in` method looks like this:

```ruby
def self.in(dir)
  new
end
```

So we're basically calling `EntryRepository.new` without any parameters, but
we changed `EntryRepository#initialize` to take an options hash that provides
the two CSV database wrapper objects: `people` and `phone_numbers`.

We need to create those two database objects and pass them to the new
instance:

```ruby
def self.in(dir)
  people = DB.read(File.join(dir, 'people.csv'))
  phone_numbers = DB.read(File.join(dir, 'phone_numbers.csv'))
  new(people, phone_numbers)
end
```

We have wiring problems.

* Require './lib/db' at the top of `./lib/phone_book.rb`
* Require 'csv' at the top of `./lib/phone_book.rb`
* Require './lib/entry' at the top of `./lib/phone_book.rb`

If we've done everything right, this should just work. It's not.
We're getting a failure:

```plain
  1) Failure:
IntegrationTest#test_lookup_by_last_name [test/integration_test.rb:17]:
Expected: ["(433) 346-3946"]
  Actual: ["433-346-3946"]
```

We're very close, but we forgot about formatting the phone numbers.

The bit where we are getting phone numbers is within the `find_by_last_name`
method, and the relevant lines of code look like this:

```ruby
numbers = phone_numbers.find_by(:person_id, person[:id]).map {|number|
  number[:phone_number]
}
```

We're returning whatever was stored in the CSV file, but phone numbers in the
file are formatted in a couple different ways. We need to normalize it.

Open up the test suite for `EntryRepository`. We've got assertions that expect
the unformated phone numbers. Tweak the assertions to expect the correct
format, and rerun the test.

This gives us a failure that we can work with:

```plain
  1) Failure:
EntryRepositoryTest#test_find_by_last_name [test/entry_repository_test.rb:42]:
--- expected
+++ actual
@@ -1 +1 @@
-["(111) 111-1111", "(111) 111-2222"]
+["111.111.1111", "111.111.2222"]
```

The simplest thing we can do to make this pass is to format the number before
we return it:

```ruby
def find_by_last_name(name)
  people.find_by(:last_name, name).map {|person|
    numbers = phone_numbers.find_by(:person_id, person[:id]).map {|number|
      format number[:phone_number]
    }
    Entry.new(person[:first_name], person[:last_name], numbers)
  }
end
```

We don't have a format method, so we need to add it.

```ruby
private

def format(number)
  digits = number.delete("-.")
  area_code = digits[0..2]
  exchange = digits[3..5]
  subscriber = digits[-4..-1]

  "(%s) %s-%s" % [area_code, exchange, subscriber]
end
```

This gets the entry repository test passing.

Pop back up and run the integration test.

It's passing as well!

## Red, Green... Refactor

The entry repository is getting pretty gross. `format` has nothing to do with
dealing with persistence of phone book entries.

Let's refactor so that we have a `Person` class and a `PhoneNumber` class.
This will allow us to move all the formatting into `PhoneNumber`.

### Updating the DB to use the little objects

Now we have little phone number and person objects, we need the
database to actually return these objects instead of csv rows/hashes.

Start by changing the test to match the new expectations. First, add a
`Thing` class in the `DBTest`.

We can use the `Thing` to wrap the rows of thing data.

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

Tweak the assertions to send messages to the object instead of referencing
hash keys:

```ruby
def test_find_by_name
  # ...
  assert_equal ["2", "3"], things.map(&:id)
end
```

Well! That breaks everything.

`DB.read` is still passing rows of CSV data, and we need to send objects, not
data to the `initialize` method.

Start by telling `read` what sort of object it should wrap each row in.

```ruby
class DBTest < Minitest::Test
  # ...

  def db
    @db ||= DB.read(filename, Thing)
  end

  # ...
end
```

This requires three changes in the `db` file.

First, the `read` method needs to take a second parameter. I'm calling it
`klass`.

Next, the `read` method needs to loop through the csv data to create the
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

And then we need to send a message in `find_by` rather than referencing the
hash key:

```ruby
def find_by(field, value)
  data.select {|datum| datum.send(field) == value}
end
```

The name `data` is no longer correct. Let's use `objects`. I also don't like
`field` for an object, so I'm swapping it out with `attribute`.

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

  def find_by(attribute, value)
    objects.select {|object| object.send(attribute) == value}
  end
end
```

We're done with the `DB`, let's pop back to the `entry_repository_test` and
see how bad the carnage is.

```plain
NoMethodError: undefined method `last_name' for {:id=>"1", :first_name=>"Alice", :last_name=>"Smith"}:Hash
```

That makes sense. We need to make objects.

### Creating Little Objects

Let's start with Person.

Create a new file, `test/person_test.rb`, and add the usual boilerplate:

```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/person'

class PersonTest < Minitest::Test
end
```

Write a test that proves that the hash data gets wrapped in a method:

```ruby
def test_attributes
  person = Person.new(first_name: 'Alice')
  assert_equal 'Alice', person.first_name
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

Expand the test to include a last name:

```ruby
def test_attributes
  person = Person.new(first_name: 'Alice', last_name: 'Smith')
  assert_equal 'Alice', person.first_name
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

Finally, let's add an assertion for the `id`:

```ruby
def test_attributes
  person = Person.new(id: "1", first_name: 'Alice', last_name: 'Smith')
  assert_equal "1", person.id
  assert_equal 'Alice', person.first_name
  assert_equal 'Smith', person.last_name
end
```

Make the test pass:

```ruby
class Person
  attr_reader :id, :last_name, :first_name
  def initialize(data)
    @id = data[:id]
    @last_name = data[:last_name]
    @first_name = data[:first_name]
  end
end
```

We've got a working `Person`, let's create a `PhoneNumber`.

```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/phone_number'

class PhoneNumberTest < Minitest::Test
  def test_person_id
    number = PhoneNumber.new(person_id: "1")
    assert_equal "1", number.person_id
  end
end
```

Make the test pass, then add another test for formatting the number:

```ruby
def test_format
  assert_equal "(123) 456-7890", PhoneNumber.new(phone_number: '123-456-7890').to_s
  assert_equal "(123) 456-7890", PhoneNumber.new(phone_number: '123.456.7890').to_s
end
```

Make the assertions pass, by borrowing the code from the
`EntryRepository#format` method.

The final code looks like this:

```ruby
class PhoneNumber
  attr_reader :person_id

  def initialize(data)
    @person_id = data[:person_id]
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

Once both the `Person` and `PhoneNumber` tests are passing, we can pop back
over to the test for the `EntryRepository`. We need to require the `person`
and `phone_number` files.

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

Finally tweak the `entry_repository`:

```ruby
def find_by_last_name(name)
  people.find_by(:last_name, name).map {|person|
    numbers = phone_numbers.find_by(:person_id, person.id).map(&:to_s)
    Entry.new(person.first_name, person.last_name, numbers)
  }
end
```

The test is passing. Go ahead and delete the `format` method.

Next, pop back up to the `test/phone_book_test.rb`. It still passes.

Now try the `test/integration_test.rb` again:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (1 for 2)
    /Users/you/csv-exercises/level-ii/phone_book/lib/db.rb:4:in `read'
    /Users/you/csv-exercises/level-ii/phone_book/lib/entry_repository.rb:6:in `in'
    /Users/you/csv-exercises/level-ii/phone_book/lib/phone_book.rb:6:in `initialize'
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
`lib/phone_book.rb`, and the integration test should finally pass.

## Running the entire test suite

It's getting a bit tedious to run each of the test files to make sure that a
change in one place doesn't affect any of the other parts of the code. We can
create a rake task to run all the tests at once.

Create a `Rakefile`, with the following code:

```ruby
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

task default: :test
```

Now you can say `rake` to run all the tests in the entire project all at once.

## Speeding up integration test

Run the entire test suite, and take note of the time that it takes to
complete.

On my laptop, it's about a 10th of a second. That's incredibly slow. Most of
the time is spent running the integration test, because it loads the entire
production database... and we haven't even added the two other features yet!

Let's create a minimal CSV fixture file to stand in for each of the production
files.

For the `test/fixtures/people.csv` file, we need at least two people with the
same last name, and one person with a different last name:

```csv
id,last_name,first_name
1,Smith,Alice
2,Smith,Bob
3,Jones,Charlie
```

We'll give one of the people two phone numbers to make sure that we're loading
all the data correctly. The other user only needs 1 number.

Add this to the `test/fixtures/phone_numbers.csv` file:

```csv
person_id,phone_number
1,111-000-1234
2,222.000.1234
2,222.001.1234
```

Give the `PhoneBook` a repository in the `test/fixtures/` directory and update
the assertions in the test to match the new expections.

```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/phone_book'

class IntegrationTest < Minitest::Test
  def test_lookup_by_last_name
    repository = EntryRepository.in('./test/fixtures')
    phone_book = PhoneBook.new(repository)
    entries = phone_book.lookup('Smith').sort_by {|e| e.first_name}
    assert_equal 2, entries.length
    e1, e2 = entries
    assert_equal "Alice Smith", e1.name
    assert_equal "Bob Smith", e2.name
    assert_equal ["(111) 000-1234"], e1.numbers
    assert_equal ["(222) 000-1234", "(222) 001-1234"], e2.numbers.sort
  end
end
```

That should cut the time it takes for the test suite to run from about 100 ms
to about 5 ms, which is **much** more reasonable.

We've completed an entire feature, which put most of the code we need in
place. The next feature will be a lot easier to add.

## Looking Up By First and Last Name

For this feature we need to add some data to the test fixture. We need two
people with the same first and last name, as well as someone with the same
last name but different first name, so that we make sure that this person
doesn't get included. Because we are using the Smiths to test the last name,
we'll use the Joneses to test this new feature.

Update the fixture to look like this:

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
1,111-000-1234
2,222.000.1234
2,222.001.1234
3,333-000-1234
3,333.001.1234
4,444.000.1234
5,555-000-1234
```

The test looks a lot like the previous one:

```ruby
def test_lookup_by_last_and_first_name
  repository = EntryRepository.in('./test/fixtures')
  phone_book = PhoneBook.new(repository)
  entries = phone_book.lookup('Jones, Charlie').sort_by {|e| e.numbers.length }
  assert_equal 2, entries.length
  e1, e2 = entries
  assert_equal ['(444) 444-1111'], e1.numbers
  assert_equal ['(333) 333-1111', '(333) 333-2222'], e2.numbers.sort
end
```

To make the test pass you will need to drop down to the `phone_book_test.rb`
and make a test that mocks out the interaction between `PhoneBook` and the
repository:

```ruby
def test_lookup_by_first_and_last_name
  phone_book = PhoneBook.new(repository)
  repository.expect(:find_by_first_and_last_name, [], ["Alice", "Smith"])
  phone_book.lookup('Smith, Alice')
  repository.verify
end
```

Again, we're using a mock. This time we call the same method (`lookup`), but
we expect to delegate to a different method on the `EntryRepository` instance,
and we expect it to receive two arguments ("Alice", and "Smith") rather than
just one, like in the previous test.

In order to get the test to pass, split the name on the comma, and then call
the correct method on the repository:

```ruby
def lookup(name)
  last, first = name.split(', ')

  if first
    repository.find_by_first_and_last_name(first, last)
  else
    repository.find_by_last_name(last)
  end
end
```

The `PhoneBook` test is passing. Now go back to the integration test and see
if the feature is complete.

It's not.

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_and_first_name:
NoMethodError: undefined method `find_by_first_and_last_name' for #<EntryRepository:0x007fc0f0b74798>
    /Users/you/csv-exercises/level-ii/phone_book/lib/phone_book.rb:17:in `lookup'
    /Users/you/csv-exercises/level-ii/phone_book/test/integration_test.rb:22:in `test_lookup_by_last_and_first_name'
```

We still need to add the correct functionality to the `EntryRepository`.

Add more fake data to the entry repository test:

```ruby
def people_data
  [
    { id: "1", first_name: "Alice", last_name: "Smith" },
    { id: "2", first_name: "Bob", last_name: "Smith" },
    { id: "3", first_name: "Charlie", last_name: "Jones" },
    { id: "4", first_name: "Charlie", last_name: "Jones" },
    { id: "5", first_name: "David", last_name: "Jones" }
  ].map {|row| Person.new(row)}
end
```

```ruby
def phone_numbers_data
  [
    { person_id: "1", phone_number: "111.111.1111" },
    { person_id: "1", phone_number: "111.111.2222" },
    { person_id: "2", phone_number: "222-222-1111" },
    { person_id: "3", phone_number: "333-333-1111" },
    { person_id: "3", phone_number: "333-333-2222" },
    { person_id: "4", phone_number: "444-444-1111" }
  ].map {|row| PhoneNumber.new(row)}
end
```

Add a test:

```ruby
def test_find_by_first_and_last_name
  entries = repository.find_by_first_and_last_name("Charlie", "Jones").sort_by {|e| e.numbers.length}
  assert_equal 2, entries.length
  e1, e2 = entries
  assert_equal ["(444) 444-1111"], e1.numbers
  assert_equal ["(333) 333-1111", "(333) 333-2222"], e2.numbers.sort
end
```

And make it pass:

```ruby
def find_by_first_and_last_name(first, last)
  (people.find_by(:first_name, first) & people.find_by(:last_name, last)).map {|person|
    numbers = phone_numbers.find_by(:person_id, person.id).map(&:to_s)
    Entry.new(person.first_name, person.last_name, numbers)
  }
end
```

Once the `entry_repository_test.rb` is passing, run the entire test suite
again.

The integration test should also be passing. We have a bit of duplication in the integration test. Before moving on, let's extract `repository` and `phone_book` into a setup method.

```ruby
class IntegrationTest < Minitest::Test
  attr_reader :repository, :phone_book

  def setup
    @repository = EntryRepository.in('./test/fixtures')
    @phone_book = PhoneBook.new(repository)
  end

  def test_lookup_by_last_name
    entries = phone_book.lookup('Smith').sort_by {|e| e.first_name}
    assert_equal 2, entries.length
    e1, e2 = entries
    assert_equal "Alice Smith", e1.name
    assert_equal "Bob Smith", e2.name
    assert_equal ["(111) 000-1234"], e1.numbers
    assert_equal ["(222) 000-1234", "(222) 001-1234"], e2.numbers.sort
  end

  def test_lookup_by_last_and_first_name
    entries = phone_book.lookup('Jones, Charlie').sort_by {|e| e.numbers.length }
    assert_equal 2, entries.length
    e1, e2 = entries
    assert_equal ['(444) 000-1234'], e1.numbers
    assert_equal ['(333) 000-1234', '(333) 001-1234'], e2.numbers.sort
  end
end
```

## Adding Reverse Lookup

The final feature is doing a reverse lookup.

As before we'll start with an integration test, and then use failures there to
guide our way down through the application.

We can test the number against the fixture data that we have, but we'll add a
twist: Let's give David Jones one of Charlie Jones' numbers, as well.

```plain
person_id,phone_number
1,111-000-1234
2,222.000.1234
2,222.001.1234
3,333-000-1234
3,333.001.1234
4,444.000.1234
5,555-000-1234
5,333.001.1234
```

Then write the integration test.

```ruby
def test_reverse_lookup
  entries = phone_book.reverse_lookup('(333) 001-1234').sort_by {|e| e.name }
  assert_equal 2, entries.length
  e1, e2 = entries
  assert_equal "Charlie Jones", e1.name
  assert_equal ["(333) 000-1234", "(333) 001-1234"], e1.numbers.sort
  assert_equal "David Jones", e2.name
  assert_equal ["(333) 001-1234", "(555) 000-1234"], e2.numbers.sort
end
```

Drop down to the phone book test.

```ruby
def test_reverse_lookup
  phone_book = PhoneBook.new(repository)
  repository.expect(:find_by_number, [], ["(123) 123-1234"])
  phone_book.reverse_lookup('(123) 123-1234')
  repository.verify
end
```

Make it pass by delegating to the repository.

```ruby
def reverse_lookup(number)
  repository.find_by_number(number)
end
```

Run the integration test, which tells us that we need to drop down to the entry repository.

This time, let's add Alice's first number to David's account in the test data in `test/entry_repository_test.rb`.

```ruby
def phone_numbers_data
  [
    { person_id: "1", phone_number: "111.111.1111" },
    { person_id: "1", phone_number: "111.111.2222" },
    { person_id: "2", phone_number: "222-222-1111" },
    { person_id: "3", phone_number: "333-333-1111" },
    { person_id: "3", phone_number: "333-333-2222" },
    { person_id: "4", phone_number: "444-444-1111" },
    { person_id: "5", phone_number: "111-111-1111" },
    { person_id: "5", phone_number: "555-555-1111" }
  ].map {|row| PhoneNumber.new(row)}
end
```

```ruby
def test_reverse_lookup
  entries = repository.find_by_number("(111) 111-1111").sort_by {|e| e.first_name}
  assert_equal 2, entries.length
  e1, e2 = entries
  assert_equal "Alice Smith", e1.name
  assert_equal ["(111) 111-1111", "(111) 111-2222"], e1.numbers.sort
  assert_equal "David Jones", e2.name
  assert_equal ["(111) 111-1111", "(555) 555-1111"], e2.numbers.sort
end
```

Get the test passing:

```ruby
def find_by_number(number)
  phone_numbers.find_by(:to_s, number).map {|number|
    people.find_by(:id, number.person_id).map {|person|
      numbers = phone_numbers.find_by(:person_id, person.id).map(&:to_s)
      Entry.new(person.first_name, person.last_name, numbers)
    }
  }.flatten
end
```

Run the entire test suite, and everything passes.

## Refactor the Entry Repository

The entry repository gets the job done, but it has a fair amount of
duplication.

These two lines occur in every method:

```ruby
numbers = phone_numbers.find_by(:person_id, person.id).map(&:to_s)
Entry.new(person.first_name, person.last_name, numbers)
```

We can extract that into a method:

```ruby
def entry_for(person)
  numbers = phone_numbers.find_by(:person_id, person.id).map(&:to_s)
  Entry.new(person.first_name, person.last_name, numbers)
end
```

Now this method replace the duplicated code in each of the finders:

```ruby
def find_by_last_name(name)
  people.find_by(:last_name, name).map {|person|
    entry_for(person)
  }
end

def find_by_first_and_last_name(first, last)
  (people.find_by(:first_name, first) & people.find_by(:last_name, last)).map {|person|
    entry_for(person)
  }
end

def find_by_number(number)
  phone_numbers.find_by(:to_s, number).map {|number|
    people.find_by(:id, number.person_id).map {|person|
      entry_for(person)
    }
  }.flatten
end
```

## Done!

That's it. We have a fully functional directory listing.

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

## Layering on CLI

If you have completed the [Intro to CLI](http://tutorials.jumpstartlab.com/topics/cli.html) tutorial, use `aruba` to test drive a command-line interface to the behavior in each exercise.

You can also get the `level-ii-solution` branch in the [csv-exercises repository](https://github.com/JumpstartLab/csv-exercises/tree/level-ii-solution). **NOTE: Only phone_book has a solution in the repository right now**

### Phone Book

Support the following commands:

- look up by last name (e.g. "Smith")
- look up by last name, first name (e.g. "Smith, Alice")
- reverse lookup (e.g. "(111) 555-1234")

```bash
$ lookup Champlin
$ lookup "Hudson, Clara"
$ lookup -r "(577) 491-0484"
```

### Calendar

TODO: Make something up.

### Doctor's Office

TODO: Make something up.

### Report Card

TODO: make something up.

### Shopping List

TODO: make something up.
