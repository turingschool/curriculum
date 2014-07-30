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
