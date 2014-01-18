---
layout: page
title: TDD with MiniTest and EventManager
---

Let's go back to [EventManager]({% page_url projects/eventmanager %}) and rebuild it using automated testing.

## Getting Started

While TDD has its haters and its believers, we can all agree that it takes a bit of tedius up-front setup. Let's get it started right:

### File Structure

Setup a new project with the following folders and files:

```
event_manager_minitest
 `-- [lib]
 `-- [test]
 |   `-- event_manager_test.rb
 `-- event_manager.rb
 `-- Rakefile
```

Where `lib` and `test` are directories, the others are files.

### Install MiniTest

A version of MiniTest is built into Ruby 1.9, but let's get the latest version from Rubygems along with Rake:

```
gem install minitest rake
```

### Setup Rake

We'll use the tool Rake to actually run the tests. Open the `Rakefile` in your project directory and add the following:

```ruby
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end
```

This tells Rake that our tests will be in the directory named `test` and the file names will end in `_test.rb`.

Save the Rakefile, then try running the tests from your project directory:

```
$ rake test
```

### Writing a First Test

Open your `test/event_manager_test.rb` and start with this:

```ruby
require 'minitest/autorun'

class EventManagerTest < MiniTest::Unit::TestCase

  def test_it_exists
    em = EventManager.new
    assert_kind_of EventManager, em
  end
end
```

Notice that the name of the method is prefixed with `test_`. The class can have other methods in it, for example to set things up for your tests, or helper methods. The prefix `test_` is how MiniTest identifies a test that needs to be run.

What's the point of this test? It's just a quick way to verify that our parts are hooked together properly.

Run the test with `rake test` and you'll find that it fails. The test isn't able to find an `EventManager` class.

#### Requiring Files

The test needs to load our `event_manager.rb` using `require`. 

Do we require `event_manager`, maybe `../event_manager`? Neither will work. You're running `rake` from the root of the project, so any paths you express must be relative to that folder. The `event_manager.rb` is in the same root directory, so we need:

```ruby
require './event_manager'
```

Run the `rake test` again, and there's still an error about `EventManager` because the file doesn't actually define the class.

### A Stub Class

Open `event_manager.rb` and define a simplistic class:

```ruby
class EventManager

end
```

Save it, run `rake test`, and you should finally be passing. Now just do programming!

## Building Functionality

Some things are easy to test, some things are hard to test. Most of the time, if testing a feature is difficult it means the feature is poorly concieved.

The user interacts with the program through reading prompts and entering commands. But testing things that use `gets` and `puts` are difficult.

Tests, especially "unit tests" like we're writing today, help you understand and design the objects in your system.

### Thinking in Objects

What's the core object of EventManager? It's not the script runner, it's not the prompt or command switching, nor the telephone numbers or zipcodes. EventManager is about people. In this problem domain they're called attendees.

Let's design an `Attendee` object using tests.

### `attendee_test.rb`

Create a file `test/attendee_test.rb` like this:

```ruby
require 'minitest/autorun'

class AttendeeTest < MiniTest::Unit::TestCase

  def test_it_exists
    attendee = Attendee.new
    assert_kind_of Attendee, attendee
  end
end
```

Run your tests and that'll fail because it can't find an `Attendee` class.

### Using `lib`

Before you jump to creating a new object in your root directory, let's talk about `lib`. The lib folder is the place where most of your functional code should live. Let's create `lib/attendee.rb` with this starter:

```ruby
class Attendee

end
```

Then at the top of your `attendee_test`:

```ruby
require './lib/attendee'
```

Run your tests and everything should be passing.

### How Should An Attendee Be Created?

We know we've got a CSV of attendees. We'll want to create one `Attendee` instance per line of the CSV. CSV rows work like hashes. So let's model an `Attendee` instance being created by a hash of data:

```ruby
  def test_it_is_initialized_from_a_hash_of_data
    data = {:first_name => 'George', :last_name => 'Washington', :phone_number => '2024556677'}
    attendee = Attendee.new(data)
    assert_equal data[:first_name], attendee.first_name
    assert_equal data[:last_name], attendee.last_name
    assert_equal data[:phone_number], attendee.phone_number
  end
```

There are a few things to notice. I arbitrarily chose first name, last name, and phone number as the fields I'd like to deal with first. I *did not* care what the actual headers are in the CSV. In fact, that CSV has awful inconsistencies in the headers.

TDD is about building software the way you want to use it. I want to create attendees with nicely formatted, reasonable hash keys, so I do it. I accept that, somewhere in the future, I'll need to create a translator object that can convert the crap headers from the CSV into the hash object I'm expecting here. That's ok.

Also notice that this test has three assertions. In general, that's not a good idea -- a single test should have a single assertion. But I'll deal with that in the refactor step.

Run the test and it fails with the following:

```
  1) Error:
test_it_is_initialized_from_a_hash_of_data(AttendeeTest):
ArgumentError: wrong number of arguments(1 for 0)
```

"1 for 0" means I'm supplying one and the object is expecting zero. When you call `.new` on a class it is actually running two things under the hood: allocating memory and the object's initializer, if there is one. When we want to affect how an object is created, we override the `initialize` method, like this:

```ruby
class Attendee
  def initialize(input)

  end
end
```

Run that and...uh-oh. Two failures:

```
  1) Error:
test_it_exists(AttendeeTest):
ArgumentError: wrong number of arguments (0 for 1)
    /Users/jcasimir/Dropbox/Projects/event_manager_test/lib/attendee.rb:2:in `initialize'
    /Users/jcasimir/Dropbox/Projects/event_manager_test/test/attendee_test.rb:7:in `new'
    /Users/jcasimir/Dropbox/Projects/event_manager_test/test/attendee_test.rb:7:in `test_it_exists'

  2) Error:
test_it_is_initialized_from_a_hash_of_data(AttendeeTest):
NoMethodError: undefined method `first_name' for #<Attendee:0x007fd729999d70>
    /Users/jcasimir/Dropbox/Projects/event_manager_test/test/attendee_test.rb:14:in `test_it_is_initialized_from_a_hash_of_data'
```

The first one looks like the failure we got before, but look closely. It's now "0 for 1" and the failure is coming from a different test, the "it exists" test. Now I have a question:

Is it the case that (A) the "it exists" test is now outdated and should be deleted entirely, (B) should be updated to pass in a hash (possibly blank), or (C) should we change the `Attendee` class to allow calling `.new` without a parameter?

This kind of decision makes some developers feel frustrated with TDD. "I just want to write features!" Though it seems small, this question is important. It may significantly affect how `Attendee` instances are created in the future. Our TDD process is forcing us to make the decision consciously now, rather that implicitly later.

We decide (C), that it should be valid to create blank attendees with no parameter. Let's make `input` an option parameter in `Attendee`:

```ruby
  def initialize(input = nil)

  end
```

Run the tests and we're down to one failure:

```
  1) Error:
test_it_is_initialized_from_a_hash_of_data(AttendeeTest):
NoMethodError: undefined method `first_name' for #<Attendee:0x007fecfa8f22a0>
    /Users/jcasimir/Dropbox/Projects/event_manager_test/test/attendee_test.rb:14:in `test_it_is_initialized_from_a_hash_of_data'
```

An attendee doesn't have a `first_name` method. We can do the simplest thing that could possibly work and add one:

```ruby
class Attendee
  def initialize(input = nil)
  end

  def first_name
  end
end
```

Run the tests and get this:

```
  1) Failure:
test_it_is_initialized_from_a_hash_of_data(AttendeeTest) [/Users/jcasimir/Dropbox/Projects/event_manager_test/test/attendee_test.rb:14]:
Expected: "George"
  Actual: nil
```

I see an easy fix:

```ruby
  def first_name
    "George"
  end
```

Run the tests again and get the similar failure:

```
  1) Error:
test_it_is_initialized_from_a_hash_of_data(AttendeeTest):
NoMethodError: undefined method `last_name' for #<Attendee:0x007f8858db9fb0>
    /Users/jcasimir/Dropbox/Projects/event_manager_test/test/attendee_test.rb:15:in `test_it_is_initialized_from_a_hash_of_data'
```

And follow a similar pattern for `last_name` and `phone_number`:

```ruby
class Attendee
  def initialize(input = nil)
  end

  def first_name
    "George"
  end

  def last_name
    "Washington"
  end

  def phone_number
    "2024556677"
  end
end
```

Run the tests and everything passes. Hooray what a sweet class we have!

At this point you have to resist the urge to make a better implementation. Should this class be using `attr_accessor`? I think so. But the tests haven't *driven* us to that implemention yet.

Let's write a new one:

```ruby
  def test_it_can_change_first_names
    data = {:first_name => "George"}
    attendee = Attendee.new(data)
    assert_equal data[:first_name], attendee.first_name
    attendee.first_name = "Thomas"
    assert_equal "Thomas", attendee.first_name
  end
```

Run the test and it fails:

```
  1) Error:
test_it_can_change_first_names(AttendeeTest):
NoMethodError: undefined method `first_name=' for #<Attendee:0x007fc6e32c6648>
    /Users/jcasimir/Dropbox/Projects/event_manager_test/test/attendee_test.rb:23:in `test_it_can_change_first_names'
```

Now, we could go and implement a `first_name=` method which sets an instance variable and refactor the `first_name` method to return that variable. But we're not trying to do the most simplistic thing (IE: use as "dumb" of features as possible), we're trying to do the simplest thing (easy to program). Let's create an `attr_accessor` for the first name and get rid of the previously implemented method:

```ruby
class Attendee
  attr_accessor :first_name

  def initialize(input = nil)
  end

  def last_name
    "Washington"
  end

  def phone_number
    "2024556677"
  end
end
```

Run the tests and we see a regression. That test which sends in the hash of data and checks that each field is properly set is now failing. We need to actually use the `input` hash in the `initialize`:

```ruby
  def initialize(input = nil)
    @first_name = input[:first_name]
  end
```

Run it and, boom, another regression. You can't call `[:first_name]` in the scenario when no parameter was passed in and `input` got the default of `nil`. We can change the default value to the empty hash `{}` instead of `nil` to get around the issue:

```ruby
  def initialize(input = {})
    @first_name = input[:first_name]
  end
```

Run that and all four tests pass. Write two further tests to drive the addition of `last_name` and `phone_number` to the `attr_accessor` call.

### Cleaning Phone Numbers

From inspecting the data (and/or building the project before), we know there are issues with the phone numbers. Many have non-numeric characters like spaces, hyphes, or periods. A handful have an unnecessary leading zero. Others are too short and can't be repaired. Let's use tests to guide us through implementing a cleaner.

#### Focusing on How You Want To *Use* It

If we're thinking ahead, we've probably realized there will be something like a "clean phone number" method -- but resist that thinking. Instead, how do we want to use it. I want the cleaning to be done automatically, like this:

```ruby
def test_it_cleans_up_phone_numbers_with_periods_and_hyphens
  attendee = Attendee.new(:phone_number => "202.444-9382")
  assert_equal "2024449382", attendee.phone_number
end
```

I run the test and see this failure:

```
  1) Failure:
test_it_cleans_up_phone_numbers_with_periods_and_hyphens(AttendeeTest) [/Users/jcasimir/Dropbox/Projects/event_manager_test/test/attendee_test.rb:45]:
Expected: "2024449382"
  Actual: "202.444-9382"
```

Great! Now I can do a simplistic cleaning in the initializer:

```ruby
  def initialize(input = {})
    @first_name   = input[:first_name]
    @last_name    = input[:last_name]
    @phone_number = input[:phone_number].gsub(".", "").gsub("-","")
  end
```

Run the tests and...that cleanup test passes but others have broken. 

#### Introducing Regressions

When no phone number is passed in, `input[:phone_number]` is `nil`. Then calling `gsub` on `nil` blows up. Ugh, let's add a little guard:

```ruby
def initialize(input = {})
  @first_name   = input[:first_name]
  @last_name    = input[:last_name]

  if input[:phone_number]
    @phone_number = input[:phone_number].gsub(".", "").gsub("-","")
  end
end
```

Run the tests and we're passing. 

I look at that implementation and know it's limited. I see we're not guarding against spaces, commas, parentheses, or other characters that might come up. While it's impossible to come up with an exhaustive list of everything that could be done wrong, this is totally reasonable:

```ruby
  def test_it_cleans_up_phone_numbers_with_spaces_and_parentheses
    attendee = Attendee.new(:phone_number => "(202) 444 9382")
    assert_equal "2024449382", attendee.phone_number
  end
```

Run it, see it fail, then go back and add to my implementation:

```ruby
  def initialize(input = {})
    @first_name   = input[:first_name]
    @last_name    = input[:last_name]

    if input[:phone_number]
      @phone_number = input[:phone_number].gsub(".", "").gsub("-","").gsub(" ", "").gsub("(", "").gsub(")", "")
    end
  end
```

It passes the tests, but fails Ruby decency standards. We can enter the refactoring process: cleaning up code while trying to avoid adding any new significant functionality.

#### Refactoring Away From `.gsub`

I think it'd work to use a regular expression and `.scan` like this:

```ruby
@phone_number = input[:phone_number].scan /[0-9]/
```

Run the tests and I remember that scan returns an array of strings, not a single string, so my tests are failing. Add on a `.join` and everything is cool:

```ruby
if input[:phone_number]
  @phone_number = input[:phone_number].scan(/[0-9]/).join
end
```

#### Dealing with Leading Zeros

Some phone numbers in the data are 11 digits and start with a 1. We can safely cut off that one to normalize the number. Starting with a test...

```ruby
def test_it_removes_leading_one_from_an_eleven_digit_phone_number
  attendee = Attendee.new(:phone_number => "12024449382")
  assert_equal "2024449382", attendee.phone_number
end
```

Run it and, of course, it fails. I implement the easiest idea I can think of inside the `initialize` method:

```ruby
if input[:phone_number]
  @phone_number = input[:phone_number].scan(/[0-9]/).join
  if @phone_number.length == 11 && @phone_number.start_with?("1")
    @phone_number = @phone_number[1..-1]
  end
end
```

Run the tests and it passes.

#### Dealing with Too Short or Too Long Numbers

If, after the previous cleanings, a phone number is not 10 digits, I need to throw it away.

```ruby
def test_it_throws_away_phone_numbers_that_are_too_long
  attendee = Attendee.new(:phone_number => "23334445555")
  assert_equal "0000000000", attendee.phone_number
end

def test_it_throws_away_phone_numbers_that_are_too_short
  attendee = Attendee.new(:phone_number => "222333444")
  assert_equal "0000000000", attendee.phone_number
end
```

Run them, they fail, then add even more code to this `initialize`:

```ruby
if input[:phone_number]
  @phone_number = input[:phone_number].scan(/[0-9]/).join
  if @phone_number.length == 11 && @phone_number.start_with?("1")
    @phone_number = @phone_number[1..-1]
  end
  if @phone_number.length != 10
    @phone_number = "0000000000"
  end
end
```

Run the tests and they pass.

#### Refactoring Under Test

That's all the functionality we're expecting out of number sanitizing, so we can stop writing tests.

But the code...ick. We need to first get it out of the `Attendee#initialize` method. Our test harness allows us to do this with confidence:

```ruby
class Attendee
  attr_accessor :first_name, :last_name, :phone_number

  def initialize(input = {})
    @first_name   = input[:first_name]
    @last_name    = input[:last_name]
    @phone_number = clean_phone_number(input[:phone_number])
  end

  def clean_phone_number(number)
    if number
      number = number.scan(/[0-9]/).join
      if number.length == 11 && number.start_with?("1")
        number = number[1..-1]
      end
      if number.length != 10
        number = "0000000000"
      end

      return number
    end
  end
end
```

The `clean_phone_number` method is still pretty ugly, but it's abstracted out from `initialize` which is now looking good. Before we try to simplify the `clean_phone_number` method, we have to ask an important question:

**What does cleaning a phone number have to do with the idea of an `Attendee`?**

It doesn't. This functionality doesn't belong in the `Attendee` class. It belongs in a `PhoneNumber` class.

#### Applying Your Learning

* Create a `phone_number.rb` and accompanying `phone_number_test.rb`
* Move or create tests in `phone_number_test.rb` which exercise the class with all these same formatting fixes
* Use that class from the `attendee.rb`
* Verify that all tests are passing.
* Once you feel good about `PhoneNumber`, you can reduce the number of tests about phone numbers in `attendee_test.rb`

#### Next Steps

* Apply this same pattern to dealing with the zipcodes
* Grab the actual CSV header names, and write an adapter/translator that can take in the CSV row objects and create the `Attendee` objects
* Write a `Representative` object which, supplied a zipcode, can supply all the information needed for the Congressional Lookup iteration

## References

* MiniTest on GitHub: https://github.com/seattlerb/minitest
* MiniTest Quick Reference: http://www.mattsears.com/articles/2011/12/10/minitest-quick-reference
* Most common assertions:
  * `assert`
  * `assert_equal`
  * `assert_includes`
  * `assert_nil`
  * `assert_raises`
