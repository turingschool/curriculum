---
layout: page
title: PhoneBook - Level I
sidebar: true
---

## Get Ready

### Prerequisites

Before starting this tutorial, you should have a basic understanding of

* topics covered in [Ruby in 100 Minutes](http://tutorials.jumpstartlab.com/projects/ruby_in_100_minutes.html)
* TDD (Test-Driven Development) using Minitest
* what a CSV is and how to manipulate

### Learning Goals

After completing this tutorial, you should be able to:

* create objects from CSV data
* create three classes that interact with each other
* find objects based on an attribute
* use Minitest::Mock to test mock method calls during testing

### What We're Doing in This Tutorial

We'll be implementing a phone book that can lookup an entry by last name, a combination
of first and last name, or phone number. The data for our entries will come
from a CSV file.

## Getting Started


We will use this [repository](https://github.com/JumpstartLab/csv-exercises)
to practice using test-driven development and working with objects. Start by
cloning it in Terminal, then changing into the `level-i/phone_book` directory.

{% terminal %}
$ git clone git@github.com:JumpstartLab/csv-exercises.git
$ cd csv-exercises
$ cd level-i/phone_book
{% endterminal %}

Check out a new branch to work on the `level-i` exercises:

{% terminal %}
$ git checkout -b level-i
{% endterminal %}

## Inspecting the Data

If you open up the `./data` directory you'll see one file:

{% terminal %}
./data/
├── people.csv
{% endterminal %}

Look at the data in this file. We have many people, and each person has a phone
number. This is a CSV (comma-separated value) file.

## Designing the Interface

We want our program to be able to look up entries in three ways:

```ruby
# By last name
phone_book.lookup('Smith')
# By first and last name
phone_book.lookup('Smith, Alice')
# By number
phone_book.reverse_lookup('(123) 555-1234')
```

## Writing a "Final Product" Test

When developing a product, it's easy to get carried away as each feature leads
to more and more features. We'll define a single, automated test that will
tell us when our Minimum Usable Product is complete.

In this case, let's have our Minimal Usable Product do just the first of
the lookup methods: `phone_book.lookup('Smith')`.

This will use the real data, and all the real code, as though it were being
used in production. This kind of "Final Product" test has many different names:
* end-to-end tests
* acceptance tests
* feature tests
* integration tests

For simplicity we've arbitrarily chosen to call this an _integration test_.

Create an empty file called `test/integration_test.rb`. We're going to start
by adding the usual testing boilerplate to it:

```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
```

Then we'll need to require the application.

```ruby
require_relative '../lib/phone_book'
```

(Eventually, `phone_book.rb` will contain and require the necessary code
to run the application.)

Finally, we need to define the test suite where our integration test will live:

```ruby
class IntegrationTest < Minitest::Test
end
```

Since we're starting with a single feature (`phone_book.lookup(name)`), we're
only going to write a single test that proves that we can look people up by last name.

If you open up the file and manually count the people with last name
**Parker**, you should get 3 entries: Agnes, Craig, and Mohamed.

So our phone book should return an array of 3 entries. Before we make the assertions,
we'll sort what came back by first name. Then we need to prove that
we got the right names and that the numbers are associated to the correct
person.

Let's write the integration test to see if our phone book finds the correct people:

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

Before we run the test, let's review some important things:

Our integration test assumes that these assertions are what our finished product
will do, so it will be failing until the very end. And that's ok!

We also need to distinguish between **errors** and **failures**.

An **error** means that the code cannot even run. There's a missing file, a
class hasn't been defined, or we're calling a method that does not exist.

A **failure** is a missed expectation. We wanted chocolate cake, but were
given oatmeal cookies with raisins. It's not broken, it's just a
disappointment.

We will use the integration test to fix errors, so if the integration test
blows up because we don't have a file, we'll create the file.

However, once the integration test **fails**, meaning that it complains that it
expected one thing, but got something else, that will be our signal to drop to a
lower level in the application, abandon the integration test for a while,
and develop the necessary code using tests for those lower levels.

When the lower-level tests are passing, then we will pop back up to the
integration test, work through any errors, and then use the next failure to
guide us towards the next tests we need to write.

## Handling the First Errors

Now let's run the integration test:

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
NoMethodError: undefined method 'sort_by' for nil:NilClass
    test/integration_test.rb:12:in 'test_lookup_by_last_name'
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

Now that we have a failure, let's think about how we want to structure the rest
of our application so that eventually we can get our integration test to pass.

* At the highest level, we will have a PhoneBook, which will take care of accepting
a name and returning entries.
* At the lowest level, we will need an Entry that will represent a person
and their phone number.
* In between the PhoneBook and the Entry, we'll need a place to store all of these
entries -- let's call this an EntryRepository.

Let's start with the lowest level first: Entry. Create a file `test/entry_test.rb`.
Prepare the file with our boilerplate:
```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
```

What are some things we could test about an entry?
* an entry should have a `first_name`, `last_name`, and `phone_number`
* an entry should also have a method `name` which returns the full name
of the person

Our test for entry will not test importing data from a CSV. Instead, we will pass
in a hash of data and check that the entry can find the first_name, last_name, and
phone_number.

```ruby
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

Run that test. You should see this error:

{% terminal %}
  1) Error:
EntryTest#test_entry_attributes:
NameError: uninitialized constant EntryTest::Entry
    test/entry_test.rb:12:in `test_entry_attributes'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

We have an uninitialized constant Entry. In this case, we know that's because
our test calls `Entry.new`, but we haven't defined that. So let's require the
`entry.rb` file.

```ruby
require_relative '../lib/entry'
```
Run the test again. A new error!

{% terminal %}
test/entry_test.rb:4:in `require_relative': cannot load such file -- /Users/student/Desktop/csv-exercises/level-i/phone_book/lib/entry (LoadError)
	from test/entry_test.rb:4:in `<main>'
{% endterminal %}

Ok, so we haven't made `entry.rb`. Go ahead and create that in the `lib` folder,
then run the test again.

{% terminal %}
  1) Error:
EntryTest#test_entry_attributes:
NameError: uninitialized constant EntryTest::Entry
    test/entry_test.rb:13:in `test_entry_attributes'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

Back to the uninitialized constant. Make a class for Entry:

```ruby
class Entry

end
```
Run the test, and you'll see that we have an Argument Error.

{% terminal %}
  1) Error:
EntryTest#test_entry_attributes:
ArgumentError: wrong number of arguments(1 for 0)
    test/entry_test.rb:13:in `initialize'
    test/entry_test.rb:13:in `new'
    test/entry_test.rb:13:in `test_entry_attributes'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

In our test, we passed one argument to `Entry.new`, but we haven't accounted for
that in our Entry class. Let's do that:

```ruby
class Entry
  def initialize(data)
  end
end
```

Run the test.

{% terminal %}
  1) Error:
EntryTest#test_entry_attributes:
NoMethodError: undefined method `first_name' for #<Entry:0x007f803a230de0>
    test/entry_test.rb:15:in `test_entry_attributes'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

We need to create a method for `first_name`.

```ruby
class Entry
  def initialize(data)
  end

  def first_name
  end
end
```

Run the test. We finally have a failure instead of an error!

{% terminal %}
  1) Failure:
EntryTest#test_entry_attributes [test/entry_test.rb:15]:
Expected: "Alice"
  Actual: nil

1 runs, 1 assertions, 1 failures, 0 errors, 0 skips
{% endterminal %}

What does this mean? Well, when we called `entry.first_name` in our test, we
expected it to return Alice. Instead, it's returning nil. Why? Our `first_name`
method does not do anything right now.

### Extracting Data to Instance Variables

We could hardcode in "Alice" for the first name, but ultimately that won't solve
anything because we will just end up deleting it later. Instead, let's extract the
first name, last name, and phone number from the hash of data that we pass in.
We will also return the `@first_name` instance variable within the `first_name`
method.


```ruby
class Entry
  def initialize(data)
    @first_name = data[:first_name]
    @last_name = data[:last_name]
    @phone_number = data[:phone_number]
  end

  def first_name
    @first_name
  end
end
```

Run the test. We have an error, and this time it's an undefined method.

{% terminal %}
  1) Error:
EntryTest#test_entry_attributes:
NoMethodError: undefined method `last_name' for #<Entry:0x007fd432b084f8>
    test/entry_test.rb:16:in `test_entry_attributes'

1 runs, 1 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

Let's get this passing by adding a method for `last_name` and returning the
instance variable `@last_name` within the method:

```ruby
  def last_name
    @last_name
  end
```
Run the test again. This time it's complaining about an undefined method `name`.

{% terminal %}
  1) Error:
EntryTest#test_entry_attributes:
NoMethodError: undefined method `name' for #<Entry:0x007f81b40b7718>
    test/entry_test.rb:17:in `test_entry_attributes'

1 runs, 2 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

What is name? If we look back at the test, the `name` method should return a string
of the first name and last name. We can do that by defining a `name` method that
returns the interpolated `@first_name` and `@last_name`.

```ruby
  def name
    "#{@first_name} #{@last_name}"
  end
```
Run the test.

{% terminal %}
  1) Error:
EntryTest#test_entry_attributes:
NoMethodError: undefined method `phone_number' for #<Entry:0x007fd65a38c5b0>
    test/entry_test.rb:18:in `test_entry_attributes'

1 runs, 3 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

Undefined method `phone_number` for an instance of Entry. Go ahead and define the
phone_number method and make it return the instance variable for `@phone_number`.


```ruby
  def phone_number
    @phone_number
  end
```
Run the test again... and we're passing!

{% terminal %}
Run options: --seed 38426

Running:

.

Fabulous run in 0.002120s, 471.6981 runs/s, 1886.7925 assertions/s.

1 runs, 4 assertions, 0 failures, 0 errors, 0 skips
{% endterminal %}

Our code for `entry.rb` currently looks like this:

```ruby
class Entry
  def initialize(data)
    @first_name = data[:first_name]
    @last_name = data[:last_name]
    @phone_number = data[:phone_number]
  end

  def first_name
    @first_name
  end

  def last_name
    @last_name
  end

  def name
    "#{@first_name} #{@last_name}"
  end

  def phone_number
    @phone_number
  end
end
```

### Red, Green, Refactor

We have a passing test, so this is a great time to refactor a few things. If you
look closely, you'll see that the `first_name`, `last_name`, and `phone_number`
methods are just returning the instance variable that holds that value.

We can refactor these into `attr_reader` methods:

```ruby
class Entry
  attr_reader :first_name, :last_name, :phone_number
  def initialize(data)
    @first_name = data[:first_name]
    @last_name = data[:last_name]
    @phone_number = data[:phone_number]
  end

  def name
    "#{@first_name} #{@last_name}"
  end
end
```

Run the test again to make sure everything is still passing. It should be.

## Creating a Repository for Entries

We have our Entry class working. Now where should we store our entries? We'll create
an Entry Repository class.

In Terminal, create a test file for our repository by typing `touch test/entry_repository_test.rb`.
Load it with the boilerplate:
```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
```
We know that we'll need to require an `entry_repository.rb` file, so let's put
that in now as well:

```ruby
require_relative '../lib/entry_repository'
```
Create your class to test the Entry Repository:

```ruby
class EntryRepositoryTest < Minitest::Test
end
```

What should we test? Well, let's think about what the EntryRepository should do.
* an entry repository should be initialized with entries (we'll assume these entries
are coming in as an array)
* an entry repository should have a method `find_by_last_name` which can find all
of the entries with that last name

Let's write a test for this.

```ruby
class EntryRepositoryTest < Minitest::Test
  def test_retrieve_by_last_name
    entries = [
      { first_name: 'Alice', last_name: 'Smith', phone_number: '111.111.1111' },
      { first_name: 'Bob', last_name: 'Smith', phone_number: '222.222.2222' },
      { first_name: 'Cindy', last_name: 'Johnson', phone_number: '333.333.3333' }
    ]

    repository = EntryRepository.new(entries)
    entries = repository.find_by_last_name("Smith").sort_by { |e| e.first_name }
    assert_equal 2, entries.length

    alice, bob = entries

    assert_equal "Alice Smith", alice.name
    assert_equal "111.111.1111", alice.phone_number
    assert_equal "Bob Smith", bob.name
    assert_equal "222.222.2222", bob.phone_number
  end
end
```
Why did we create a variable `entries` that is an array of hashes? We could use
the real data, but that would require us to create entry objects for **all** of
the people in `people.csv`, and that seems unnecessary just to run a test. Additionally,
our integration test will use the real data anyway, so that's going to be tested
at the end point.

So we'll use the fake data in the `entries` variable for this test.

Let's run the test. We get a load error:

{% terminal %}
test/entry_repository_test.rb:4:in `require_relative': cannot load such file -- /Users/student/Desktop/csv-exercises/level-i/phone_book/lib/entry_repository (LoadError)
	from test/entry_repository_test.rb:4:in `<main>'
{% endterminal %}

We'll fix this with `touch lib/entry_repository.rb`. Run the test again.

{% terminal %}
  1) Error:
EntryRepositoryTest#test_retrieve_by_last_name:
NameError: uninitialized constant EntryRepositoryTest::EntryRepository
    test/entry_repository_test.rb:14:in `test_retrieve_by_last_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

We have an uninitialized constant because we haven't defined the class in our
`entry_repository.rb` file.

```ruby
class EntryRepository
end
```
Run the test.

{% terminal %}
  1) Error:
EntryRepositoryTest#test_retrieve_by_last_name:
ArgumentError: wrong number of arguments(1 for 0)
    test/entry_repository_test.rb:14:in `initialize'
    test/entry_repository_test.rb:14:in `new'
    test/entry_repository_test.rb:14:in `test_retrieve_by_last_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

Our test passes in an argument (`entries`) to initialize a new EntryRepository.
Let's implement that:

```ruby
class EntryRepository
  def initialize(entries)
  end
end
```

Run the test again. Now we have an undefined method:

{% terminal %}
  1) Error:
EntryRepositoryTest#test_retrieve_by_last_name:
NoMethodError: undefined method `find_by_last_name' for #<EntryRepository:0x007f8be1a60198>
    test/entry_repository_test.rb:15:in `test_retrieve_by_last_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

Let's create that method. We know it accepts an argument of `name`, so we'll account
for that:

```ruby
def find_by_last_name(name)
end
```

Running the test again yields a new error:

{% terminal %}
  1) Error:
EntryRepositoryTest#test_retrieve_by_last_name:
NoMethodError: undefined method `sort_by' for nil:NilClass
    test/entry_repository_test.rb:15:in `test_retrieve_by_last_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

What does this mean? Whatever `sort_by` is being called on is returning nil. We
can see that is happening in our test on this line:

```ruby
entries = repository.find_by_last_name("Smith").sort_by { |e| e.first_name }
```

So from this, we know that the `find_by_last_name` method is returning nil.
Looking at the implementation code, it's obvious why: our method is empty!
Put an empty array in there so that `sort_by` can be called on something instead
of nil -- even if it is just an empty array.

```ruby
def find_by_last_name(name)
  []
end
```
Now running the tests gives us a failure. Finally.

{% terminal %}
  1) Failure:
EntryRepositoryTest#test_retrieve_by_last_name [test/entry_repository_test.rb:16]:
Expected: 2
  Actual: 0

1 runs, 1 assertions, 1 failures, 0 errors, 0 skips
{% endterminal %}

We're getting 0 entries because we hard-coded an empty array. Let's implement some
actual functionality in `entry_repository.rb`.

### Bringing in Entry Objects to the Entry Repository

Our initialize method needs to take an array of hashes and convert them to Entry
objects. We can do that by `map`ping over the entries and passing each hash to
`Entry.new`, like you see below. The array returned from `map` will be stored as
`@entries`, and we'll also create an `attr_reader` method for `:entries`.

```ruby
class EntryRepository
  attr_reader :entries

  def initialize(entries)
    @entries ||= entries.map { |entry| Entry.new(entry) }
  end
end
```

Run the test. Uh oh. We're back to an error.

{% terminal %}
  1) Error:
EntryRepositoryTest#test_retrieve_by_last_name:
NameError: uninitialized constant EntryRepository::Entry
    /Users/rwarbelow/Desktop/csv-exercises/level-i/phone_book/lib/entry_repository.rb:5:in `block in initialize'
    /Users/rwarbelow/Desktop/csv-exercises/level-i/phone_book/lib/entry_repository.rb:5:in `map'
    /Users/rwarbelow/Desktop/csv-exercises/level-i/phone_book/lib/entry_repository.rb:5:in `initialize'
    test/entry_repository_test.rb:14:in `new'
    test/entry_repository_test.rb:14:in `test_retrieve_by_last_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

The test doesn't know what an `Entry` is. Require the file
in `entry_repository_test.rb`:

```ruby
require_relative 'entry'
```

Now our test is failing for the same reason it was before, so let's work on
the `find_by_last_name` method.

Here's the pseudocode for what we'll need to do:
* take in a last name as a parameter
* search through all of the `@entries`
* `select` all entries where an entry's `last_name` is the same as the parameter
that was passed in.

And here's what it looks like in Ruby. Find the `find_by_last_name` method in
`entry_repository.rb` and replace the empty array with our `select` statement.

```ruby
  def find_by_last_name(name)
    entries.select { |entry| entry.last_name == name }
  end
```

Run the tests. We're passing!

{% terminal %}
Running:

.

Fabulous run in 0.001577s, 634.1154 runs/s, 3170.5770 assertions/s.

1 runs, 5 assertions, 0 failures, 0 errors, 0 skips
{% endterminal %}

Our code for `entry_repository.rb` so far should look like this:
```ruby
require_relative 'entry'

class EntryRepository
  attr_reader :entries

  def initialize(entries)
    @entries ||= entries.map { |e| Entry.new(e) }
  end

  def find_by_last_name(name)
    entries.select { |entry| entry.last_name == name }
  end
end
```

## Creating the Phone Book

You might be wondering how the phone book is different from the entry repository.
Well, the entry repository is responsible for looking things up, but the phone book
should be responsible for figuring out whether we're getting just a last name, or if
the user is passing in a last name **AND** a first name. So we're delegating
responsibilities to different classes here.

Create a test file for our phone book: `touch test/phone_book_test.rb`.

Then load the boilerplate. You'll notice that there is a new line requiring
`minitest/mock`.
```ruby
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/mock'
```
You can read more about MiniTest::Mock [here](http://ruby-doc.org/stdlib-1.9.3/libdoc/minitest/mock/rdoc/MiniTest/Mock.html).
Basically, `Minitest::Mock` allows us to test whether a method is being called,
without actually having to call the method.

Create your test class with the code that creates a mock for `repository`:

```ruby
class PhoneBookTest < Minitest::Test
  def test_lookup_by_last_name
    repository = Minitest::Mock.new
    phone_book = PhoneBook.new(repository)
    repository.expect(:find_by_last_name, [], ["Smith"])
    phone_book.lookup('Smith')
    repository.verify
  end
end
```

### Umm... So What's a Mock?

You'll notice that `repository` is not actually an instance of `EntryRepository`.
Instead, it's a mock -- it's fake! This will allow us to check that certain things
are happening to the repository when a method is called on the phone book.

What's that weird line `repository.expect(:find_by_last_name, [], ["Smith"])`?
In English, the first part of this line says "We expect that the method `find_by_last_name`
will be called on repository."

The empty array in the middle represents what we want to be returned. In
this case, we don't really care what's being returned -- right now, we just want to
verify that the method was **called**. We're not interested in messing with the
return value.

And finally, `["Smith"]` represents an array of what argument we
expect our method to be called with. We have to pass this in since `find_by_last_name`
requires one argument.

The next line, `phone_book.lookup('Smith')`, is what we're **actually** calling in
the test. And finally, `repository.verify` means "Got back and check to see that
the method we expected to be called on repository actually got called with the
argument(s) we specified."

Phew. That's a lot.

To sum up: We expect that `find_by_last_name` with the argument of `"Smith"`
will be called on the repository when `phone_book.lookup('Smith')` is called.

### Testing Our Mock

Ok, run the test. We get an error:

{% terminal %}
  1) Error:
PhoneBookTest#test_lookup_by_last_name:
NameError: uninitialized constant PhoneBookTest::PhoneBook
    test/phone_book_test.rb:10:in `test_lookup_by_last_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

Fix it by requiring the `phone_book.rb` file.

```ruby
require_relative '../lib/phone_book'
```

Run the test again. A new error!

{% terminal %}
  1) Error:
PhoneBookTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments(1 for 0)
    test/phone_book_test.rb:10:in `initialize'
    test/phone_book_test.rb:10:in `new'
    test/phone_book_test.rb:10:in `test_lookup_by_last_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

Ok, so our test says that a new `PhoneBook` needs to be passed a repository. Head
over to `phone_book.rb` and we'll fix that.

```ruby
class PhoneBook

  def initialize(repository)
  end

  def lookup(name)
    []
  end
end
```

Run the test.

{% terminal %}
  1) Error:
PhoneBookTest#test_lookup_by_last_name:
MockExpectationError: expected find_by_last_name("Smith") => [], got []
    test/phone_book_test.rb:13:in `test_lookup_by_last_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

We wanted `repository.find_by_last_name('Smith')` to be called when we call
`phone_book.lookup('Smith')`, but all the lookup method is returning right now
is that empty array. So let's modify our code so our lookup method invokes the call
on the repository:

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

Run the test. It passes!

So our `entry_test.rb`, `entry_repository_test.rb`, and `phone_book_test.rb` are
all passing. Let's go back to our Minimum Usable Product test.

### Back to the Integration Test

Run `integration_test.rb`. We've got an error:

{% terminal %}
  1) Error:
IntegrationTest#test_lookup_by_last_name:
ArgumentError: wrong number of arguments (0 for 1)
    /Users/rwarbelow/Desktop/csv-exercises/level-i/phone_book/lib/phone_book.rb:4:in `initialize'
    test/integration_test.rb:9:in `new'
    test/integration_test.rb:9:in `test_lookup_by_last_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

Wrong number of arguments 0 for 1? It looks like our integration test creates a
new phone book **without** any arguments in this line:

```ruby
    phone_book = PhoneBook.new
```

Hmm... that means that we should probably have a default in case no arguments are
passed in.

### Giving the Phone Book a Default Repository

The argument in `initialize` for a `PhoneBook` asks for a repository. We'll
modify that a bit so that we have a default value.

```ruby
class PhoneBook
  attr_reader :repository

  def initialize(repository = EntryRepository.load_entries('./data'))
    @repository = repository
  end

  def lookup(name)
    repository.find_by_last_name(name)
  end
end
```

So our default will be whatever gets returned from calling `EntryRepository.load_entries('./data')`.
We'll create that `load_entries` method in a minute. First, let's run the test.

We get an error:

{% terminal %}
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NameError: uninitialized constant PhoneBook::EntryRepository
    /Users/rwarbelow/Desktop/csv-exercises/level-i/phone_book/lib/phone_book.rb:7:in `initialize'
    test/integration_test.rb:9:in `new'
    test/integration_test.rb:9:in `test_lookup_by_last_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

We haven't required `entry_repository`. Add that:

```ruby
require_relative 'entry_repository'
```

Now run the test again.

{% terminal}
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NoMethodError: undefined method `load_entries' for EntryRepository:Class
    /Users/rwarbelow/Desktop/csv-exercises/level-i/phone_book/lib/phone_book.rb:7:in `initialize'
    test/integration_test.rb:9:in `new'
    test/integration_test.rb:9:in `test_lookup_by_last_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

Now we can address creating a `load_entries` method for the EntryRepository class
and modifying the `initialize` method.

```ruby
require_relative 'entry'

class EntryRepository
  attr_reader :entries

  def self.load_entries(directory)
    file = File.join(directory, 'people.csv')
    data = CSV.open(file, headers: true, header_converters: :symbol)
    rows = data.map do |row|
      Entry.new(row)
    end
    new(rows)
  end

  def initialize(entries)
    @entries = entries
  end

  def find_by_last_name(name)
    entries.select { |entry| entry.last_name == name }
  end
end
```
We're taking in a directory, joining that to the `people.csv` file, and then
opening a CSV using that file path. Then, we're taking the data from the CSV and
mapping over it to create a new `Entry` for each row. Finally, we're calling `new(rows)`
which is the same as writing `EntryRepository.new(rows)`.

Run the test.

{% terminal %}
  1) Error:
IntegrationTest#test_lookup_by_last_name:
NameError: uninitialized constant EntryRepository::CSV
    /Users/rwarbelow/Desktop/csv-exercises/level-i/phone_book/lib/entry_repository.rb:8:in `load_entries'
    /Users/rwarbelow/Desktop/csv-exercises/level-i/phone_book/lib/phone_book.rb:6:in `initialize'
    test/integration_test.rb:9:in `new'
    test/integration_test.rb:9:in `test_lookup_by_last_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

CSV is uninitialize. This is an easy error to fix. Require 'csv' at the top of
your `entry_repository.rb` file:

```ruby
require 'csv'
```

Run the integration test again. It passes!

{% terminal %}
  Running:

.

Fabulous run in 0.039609s, 25.2468 runs/s, 176.7275 assertions/s.

1 runs, 7 assertions, 0 failures, 0 errors, 0 skips
{% endterminal %}

## Checking for Damage

If we run our other tests, we'll find that we only broke one of them in the process:
`entry_repository_test.rb`.

{% terminal %}
  1) Error:
EntryRepositoryTest#test_retrieve_by_last_name:
NoMethodError: undefined method `last_name' for #<Hash:0x007f95da99ed10>
    /Users/rwarbelow/Desktop/csv-exercises/level-i/phone_book/lib/entry_repository.rb:21:in `block in find_by_last_name'
    /Users/rwarbelow/Desktop/csv-exercises/level-i/phone_book/lib/entry_repository.rb:21:in `select'
    /Users/rwarbelow/Desktop/csv-exercises/level-i/phone_book/lib/entry_repository.rb:21:in `find_by_last_name'
    test/entry_repository_test.rb:15:in `test_retrieve_by_last_name'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
{% endterminal %}

We're getting an undefined method `last_name` for a Hash. As it turns out, since we changed our
initialize method in EntryRepository, we'll need to update our test `entry_repository_test.rb`:

```ruby
    entries = [
      { first_name: 'Alice', last_name: 'Smith', phone_number: '111.111.1111' },
      { first_name: 'Bob', last_name: 'Smith', phone_number: '222.222.2222' },
      { first_name: 'Cindy', last_name: 'Johnson', phone_number: '333.333.3333' }
    ].map { |row| Entry.new(row) }
```
What we're doing now is `map`ping our array of hashes to create new Entry objects
in the test instead of relying on the initialize method to do that for us. We changed
that method when we created the `load_entries` method.

Double check that all of your other test files are still passing, then
commit your changes.

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
  repository.expect(:find_by_first_and_last_name, [], ["Alice","Smith"])
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
  entries.select { |entry| entry.first_name == first}.select { |entry| entry.last_name == last }
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
