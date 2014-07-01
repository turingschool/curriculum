---
layout: page
title: IdeaBox TDD
---

Intermediate [Minitest](https://github.com/seattlerb/minitest) techniques (written as of v5.3.5)

This material is accompanied by a suite of tests that you will work through.
Go clone [minitest_playground(https://github.com/turingschool/minitest_playground)
so you can complete the **YOUR TURN** portions.

### Foundational Information

* Files typically go in `test` dir.
* Common setup in `test/test_helper.rb` then you can require that at the top of any test file that needs the common setup
* Load up and run minitest by requiring "minitest/autorun" (probably put this at the top of `test_helper.rb`)
* The default way to add a suite of tests is to make a class that inherits from `Minitest::Test`
* The default way to add a test to a suite is to define a method that begins with `test_`
* The default way to assert that code does what you want is `assert(boolean_value)`
* **YOUR TURN:** Create a test suite named `SimpleTest` in `test/simple_test.rb` with two tests, one of which passes, the other fails.
* You can reproduce the random order with the command line arguments `--seed <value>`, minitest tells you what seed it is using at the top of every run.
* **YOUR TURN:** Reproduce the intermittent failure in `test/seed_test.rb
* You can run a specific test with `--name test_name`
* You can run tests that match a regular expression with `--name '/address/'`
* **YOUR TURN:** Filter the tests that run in `test/filtering_test.rb`
* Each test method is invoked on a unique instance of the class (i.e. for each test method, instantiate the class and then invoke the method)
* **YOUR TURN:** Prove to yourself that each test runs on its own instance in `test/each_test_runs_in_its_own_instance_test.rb`
* Often you need support code. You could put it all in the test helper, but that would get big, and require every test that loads the helper to load that code,
  whether they need it or not (scome code is expensive to load). A common pattern is to put it in a `test/support/` directory.
* **YOUR TURN** Move the support code from the test helper to the support dir and show that `test/uses_support_test.rb` still works
* Some tests just aren't ready yet, to bypass them, invoke the `skip` method
* **YOUR TURN** Skip the unfinished feature in `test/skip_test.rb`
* if you want to capture strings that were printed to standard output and standard error, you can run use `capture_io`
  ```ruby
  out, err = capture_io do
    puts "hello"
    $stderr.puts "world"
  end
  out # => "hello\n"
  err # => "world\n"
  ```
* **YOUR TURN** Go capture the output from `test/capture_output_test.rb`

### Nesting

Sometimes you want to a test suite within a test suite. For example, if I have several things I want to test about one method.
The best way to do this is to define the inner test suite within the outer one, and then inherit from it.

```ruby
class ParentSuite < Minitest::Test

  # No tests in here, just helper methods
  def some_helper_method
    true
  end

  # Nested suite inherits from parent suite
  class NestedSuite < TestUsername
    def test_something
      # I can call assertion helpers because I get them from ParentSuite
      # Which gets them from Minitest::Test
      # Which gets them from Minitest::Assertions
      #
      # And I can call the helper method because
      # I inherit from ParentSuite, where it is defined
      assert some_helper_method
    end
  end
end
```

**YOUR TURN** Go implement the nested test suites in `test/nesting_test.rb`


### Asssertions

While the basic `assert` method is all you technically need, it's not very descriptive or informative.
There are a variety of more interesting and useful assertions.

Anything method asserting that a statment is truthful begins with `assert_` and
anything asserting that a statement is not truthful begins with `refute_`

**YOUR TURN** There is a test suite around several of these
in `test/assertions_test.rb` go update the methods to use the fancy assertions.
