---
layout: page
title: Intro to CSV - Level III
sidebar: true
---

**Rough outline, needs prose.**

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

Go into the `level-iii` directory:

{% terminal %}
$ cd level-iii
{% endterminal %}

## Phone Book

Change directories into the `phone_book` directory:

{% terminal %}
cd phone_book
{% endterminal %}

### The Data

In the `data` directory there are two files, `people.csv`, and
`phone_numbers.csv`. Open these up and look at them.

There are a many people, and each person can have multiple phone numbers.

### The Interface

We'd like to be able to look up entries in the phone book by last name, or by
last and first name. Also, we want to provide a reverse lookup (by number).

```ruby
phone_book.lookup('Smith')
phone_book.lookup('Smith, Alice')
phone_book.reverse_lookup('123-555-1234')
```

The result will be an array of entries that match the search criteria. Each entry
has the person's name, as well as a list of their phone numbers.

The phone book does not expose the person's ID. That is an internal
implementation detail.

## An Integration Test

We will do one high-level integration test against the production data, which
will serve to tell us when we've got the whole thing working.

In `test/integration_test.rb`:

```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/phone_book'

class IntegrationTest < Minitest::Test
end
```

First, lookup by last name. We want to make sure it works if there are several
people with the same last name, and it looks like there are multiple entries
with the last name 'Mueller', so we'll use that.

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

Run the test:

{% terminal %}
$ ruby test/integration_test.rb
{% endterminal %}

```plain
test/integration_test.rb:4:in `require_relative': cannot load such file -- /Users/you/csv-exercises/level-iii/phone_book/lib/phone_book (LoadError)
	from test/integration_test.rb:4:in `<main>'
```

It's complaining about a missing file, so create that:

{% terminal %}
$ touch lib/phone_book.rb
{% endterminal %}

Run it again.

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NameError: uninitialized constant IntegrationTest::PhoneBook
    test/integration_test.rb:8:in `phone_book'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

Add the class in `lib/phone_book.rb`:

```ruby
class PhoneBook
end
```

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NoMethodError: undefined method `lookup' for #<PhoneBook:0x007ff7139be1e8>
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

Add an empty method:

```ruby
class PhoneBook
  def lookup
  end
end
```

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (1 for 0)
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/phone_book.rb:2:in `lookup'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

```ruby
class PhoneBook
  def lookup(name)
  end
end
```

```ruby
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NoMethodError: undefined method `sort_by' for nil:NilClass
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

```ruby
class PhoneBook
  def lookup(name)
    []
  end
end
```

Finally, we get a failure rather than an error.

### Dropping Down a Level

Create a file `test/phone_book_test.rb`. The phone book should not have to
know about how the data is stored, so let's just give it a repository object.

For now, the interaction is pretty straight forward, the phone book should
simply delegate to the repository:

```ruby
def lookup(name)
  repository.lookup_by_last_name(name)
end
```

We could give the phone book a fake repository with fake data, and then assert
that what we get back when we call `lookup(name)` is whatever the fake
repository returns for `lookup_by_last_name`, but that seems kind of
pointless.

Let's implement a mock assertion that the interaction is correct, and then
not worry about any data:

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

  def phone_book
    @phone_book ||= PhoneBook.new(repository)
  end

  def test_lookup_by_last_name
    repository.expect(:find_by_last_name, [], ["Smith"])
    phone_book.lookup('Smith')
    repository.verify
  end
end
```

`[]` is the stubbed return value, `["Smith"]` is the array of arguments that
will be passed to the `find_by_last_name` method.

```plain
  1) Error:
PhoneBookTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments(1 for 0)
    test/phone_book_test.rb:13:in `initialize'
    test/phone_book_test.rb:13:in `new'
    test/phone_book_test.rb:13:in `phone_book'
    test/phone_book_test.rb:18:in `test_lookup_by_last_name'
```

`PhoneBook` has a default initialize, which doesn't accept arguments. We need
to be able to inject the repository, so add an initialize method:

```ruby
class PhoneBook
  def initialize(repository)
  end

  def lookup(name)
    []
  end
end
```

Now we get the failed expectation:

```plain
  1) Error:
PhoneBookTest#test_lookup_by_last_name:
MockExpectationError: expected find_by_last_name() => "Smith", got []
    test/phone_book_test.rb:19:in `test_lookup_by_last_name'
```

Make it pass:

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

### Pop back up

Now run the integration test, to see what our next step should be:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (0 for 1)
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/phone_book.rb:4:in `initialize'
    test/integration_test.rb:8:in `new'
    test/integration_test.rb:8:in `phone_book'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

Now our phone book's initialize expects an argument, but in the integration
test we're assuming that we can just create a new phone book. Let's give the
phone book a default repository that it can fall back on in production.

```ruby
class PhoneBook
  attr_reader :repository

  def initialize(repository=EntryRepository.in('./data'))
    @repository = repository
  end

  # ...
end
```

This blows up, naturally:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NameError: uninitialized constant PhoneBook::EntryRepository
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/phone_book.rb:4:in `initialize'
    test/integration_test.rb:8:in `new'
    test/integration_test.rb:8:in `phone_book'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

Create a `lib/entry_repository.rb` file, create an empty class in it, and,
require it at the top of `lib/phone_book.rb`.

```ruby
require_relative 'entry_repository'

class PhoneBook
  # ...
end
```

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NoMethodError: undefined method `in' for EntryRepository:Class
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/phone_book.rb:6:in `initialize'
    test/integration_test.rb:8:in `new'
    test/integration_test.rb:8:in `phone_book'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

Create a class method:

```ruby
class EntryRepository
  def self.in
  end
end
```

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (1 for 0)
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:2:in `in'
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/phone_book.rb:6:in `initialize'
    test/integration_test.rb:8:in `new'
    test/integration_test.rb:8:in `phone_book'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

Give it a parameter:

```ruby
class EntryRepository
  def self.in(dir)
  end
end
```

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NoMethodError: undefined method `find_by_last_name' for nil:NilClass
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/phone_book.rb:11:in `lookup'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

The `in` method returns nil, we need it to return an instance of the
repository:

```ruby
class EntryRepository
  def self.in(dir)
    new
  end
end
```

We're missing a method:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NoMethodError: undefined method `find_by_last_name' for #<EntryRepository:0x007fad62928b98>
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/phone_book.rb:11:in `lookup'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

Add it:

```ruby
class EntryRepository
  def self.in(dir)
    new
  end

  def find_by_last_name
  end
end
```

It takes a parameter:

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (1 for 0)
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:6:in `find_by_last_name'
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/phone_book.rb:11:in `lookup'
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

```ruby
class EntryRepository
  def self.in(dir)
    new
  end

  def find_by_last_name(name)
  end
end
```

```plain
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NoMethodError: undefined method `sort_by' for nil:NilClass
    test/integration_test.rb:12:in `test_lookup_by_last_name'
```

It's expecting the method to return an array, so let's do that:

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

No more errors, we're back to a failure.

### Drop down, again

Now the `EntryRepository` needs some attention.

We know that it needs to handle two different CSV files, and we can assume
that it will handle both of them very similarly. Let's put off having to
actually read CSV files for a while, and just assume that the entry repository
is given two sets of data: one for people and one for phone numbers.

We're going to need to look up multiple entries by last name, so our fake data
should have two matches and one non-match, and one of the two matches should
have more than one phone number.

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

```plain
  1) Error:
EntryRepositoryTest#test_find_by_last_name:
ArgumentError: wrong number of arguments(1 for 0)
    test/entry_repository_test.rb:24:in `initialize'
    test/entry_repository_test.rb:24:in `new'
    test/entry_repository_test.rb:24:in `repository'
    test/entry_repository_test.rb:28:in `test_find_by_last_name'
```

Initialize needs help.

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

```plain
  1) Failure:
EntryRepositoryTest#test_find_by_last_name [test/entry_repository_test.rb:29]:
Expected: 2
  Actual: 0
```

First, let's just use some straight-up enumerable methods on the arrays that
got passed in, and see what happens.

```ruby
def find_by_last_name(name)
  people.select {|person| person[:last_name] == name}
end
```

That isn't quite what we need:

```plain
  1) Error:
EntryRepositoryTest#test_find_by_last_name:
NoMethodError: undefined method `first_name' for {:id=>"1", :first_name=>"Alice", :last_name=>"Smith"}:Hash
    test/entry_repository_test.rb:28:in `block in test_find_by_last_name'
    test/entry_repository_test.rb:28:in `each'
    test/entry_repository_test.rb:28:in `sort_by'
    test/entry_repository_test.rb:28:in `test_find_by_last_name'
```

The test wants actual objects with a `first_name` method. For now, let's just
create a simple `Entry` class that has the data we want:

{% terminal %}
$ touch lib/entry.rb
{% endterminal %}

```ruby
Entry = Struct.new(:first_name, :last_name)
```

```ruby
def find_by_last_name(name)
  people.select {|person|
    person[:last_name] == name
  }.map {|person|
    Entry.new(person[:first_name], person[:last_name])
  }
end
```

```plain
  1) Error:
EntryRepositoryTest#test_find_by_last_name:
NameError: uninitialized constant EntryRepository::Entry
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:17:in `block in find_by_last_name'
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:14:in `map'
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:14:in `find_by_last_name'
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
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/db.rb:3:in `initialize'
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
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:10:in `initialize'
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:5:in `new'
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:5:in `in'
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/phone_book.rb:6:in `initialize'
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
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/db.rb:4:in `read'
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/entry_repository.rb:6:in `in'
    /Users/kytrinyx/turing/csv-exercises/level-iii/phone_book/lib/phone_book.rb:6:in `initialize'
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

**TODO**: remove references to `kytrinyx/turing` etc.

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

