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

### How Should An Attendee Work?

We know we've got a CSV of attendees. We'll want to create one `Attendee` instance per line of the CSV.

