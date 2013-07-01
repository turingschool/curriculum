---
layout: page
title: RSpec Practices
---

Getting going with RSpec is one thing, but let's look at some techniques that can make your tests easier to write, more expressive to read, and easier to maintain.

## Setup and Teardown

While writing examples which exercise your classes you will likely come across classes and states that are similar between multiple examples. For example:

```ruby
describe Client do

  it "should respond to connect" do
    client = Client.new
    client.should respond_to(:connect)
  end

  it "should respond to disconnect" do
    client = Client.new
    client.should respond_to(:disconnect)
  end

  it "should respond to server_name" do
    client = Client.new
    client.should respond_to(:server_name)
  end

end
```

In the above example we generate a new instance of `Client` in each test before we make the assertion that it responds to the particular methods. There are some drawbacks to this implementation:

* This is wasteful as we are repeating ourself several times within the tests.
* Maintaining the tests is tedious; for example, returning later to make a change to the initialize method to take a parameter would require a lot of work.
* The initialization somewhat obfuscates what is actually being tested.

### `before` and `after`

RSpec, like other test frameworks, provides helper methods for test setup and test tear down for individual examples and groups of examples. These helper methods are named `before` and `after`. Both of them accept an `:each` parameter to run once before each example, or `:all` to run once before all the examples:

* `before :all`
* `before :each`
* `after :each`
* `after :all`

```ruby
describe Client do

  before :each do
    @client = Client.new
  end

  it "should respond to connect" do
    @client.should respond_to(:connect)
  end

  it "should respond to disconnect" do
    @client.should respond_to(:disconnect)
  end

  it "should respond to server_address" do
    @client.should respond_to(:server_address)
  end

end
```

Here `before :each` execute the code contained within the block `do...end` before the execution of each of the examples.

<div class="note">
<p>In this trivial example we could have used <code>before :all</code> and set up our <code>@client</code> object once. It is important to know that changes made within a <code>before :all</code> block will <strong>not</strong> be rolled back after tests.</p>
</div>

You can define a `before` and `after` within each `describe` or `context` block, allowing you to easily add setup and creation as necessary.

```ruby
describe "before/after example" do

  before :all do
    puts "before all"
  end

  before :each do
    puts "before each"
  end

  context "when we are in a context" do

    before :all do
      puts " - before all"
    end

    before :each do
      puts " - before each"
    end

    it "should" do
      true.should be_true
    end

    after :each do
      puts " - after each"
    end

    after :all do
      puts " - after all"
    end

  end

  after :each do
    puts "after each"
  end

  after :all do
    puts "after all"
  end

end
```

Execution yields the following output:

    before/after example
    before all
      when we are in a context
     - before all
    before each
     - before each
     - after each
    after each
        should
     - after all
    after all

Notice that both `before :all` helper methods executed prior each of the `before :each` helper methods. This is reverse for our `after` helper methods.

## It is still Ruby

RSpec may appear to be an altogether different language that is allowing you to embed Ruby within it to exercise your code, but it is not. It is just Ruby!

We could refactor our previous `Client` examples even further:

```ruby
describe Client do
  before :each do
    @client = Client.new
  end

  [ :connect, :disconnect, :server_address ].each do |method|
    it "should respond to #{method}" do
      @client.should respond_to(method)
    end
  end
end
```

Creating an array containing the three methods `:connect`, `:disconnect`, and `:server_address` and iterating over it allows us to avoid code duplication.

## `describe`

The method `describe` helps us to group a set of related examples.

### Instance Methods

Imagine we're trying to test this `initialize` method:

```ruby
class Client
  def initialize
    # ... initialization code ...
  end
end
```

Then, when we write examples about that method, we wrap them in a `describe` block with the name of the method prefixed with a `#` to indicate it is an instance method:

```ruby
describe Client do
  describe '#initialize' do
    it 'should respond with default values' do
      # ... arrange, act, assert ...
    end
  end
end
```

### Class Methods

Similarly, when testing class methods we'll prefix the name with a period (`.`):

```ruby
class Client
  def self.generate
    # ... generation code ...
  end
end
```

```ruby
describe Client do
  describe '.generate' do
    it 'should return a valid Client instance' do
      # ... arrange, act, assert ...
    end
  end
end
```

## Explicit Subject

Let's return to our previous example of the `Client` examples:

```ruby
describe Client do
  before(:all) do
    @client = Client.new
  end

  it { @client.should respond_to :connect }
  it { @client.should respond_to :disconnect }
  it { @client.should respond_to :server_name }
end
```

We saved ourselves the hassle of having to generate a `Client` each execution with the `before(:all)`, but we still have the instance variable `@client` throughout our examples.

RSpec has the convention that when you call `should` without an _explicit receiver_ it is assumed that you mean to make an assertion against the `subject` under test. This is called [Implicit Receiver](https://www.relishapp.com/rspec/rspec-core/docs/subject/implicit-receiver).

Let us define a `subject` and allow for it to be the implicit receiver.

Revisiting the previous example:

```ruby
describe Client do
  before(:all) do
    @client = Client.new
  end

  subject { @client }

  it { should respond_to :connect }
  it { should respond_to :disconnect }
  it { should respond_to :server_name }
end
```

We were able to remove the use of the member variable `@client` from all the test examples and place it within the `subject` helper. The result of which will be used implicitly everywhere we previously had used it. Saving us a lot of typing.

However, RSpec goes even further to make us faster and more effective test driven developers.

### [Implicit Subject](https://www.relishapp.com/rspec/rspec-core/docs/subject/implicit-subject)

Using the class name `Client` in the outermost `describe` grants us the benefit of having an instance of object under test automatically available through the `subject` helper method.

Again returning to our previous example, we can remove our explicit declaration of the subject and rely on the implicit subject:

```ruby
describe Client do
  it { should respond_to :connect }
  it { should respond_to :disconnect }
  it { should respond_to :server_name }
end
```

Or even more succinctly:

```ruby
describe Client do
  [ :connect, :disconnect, :server_name ].each do |attribute|
    it { should respond_to attribute }
  end
end
```

### `its`

After asserting that a class responds to particular methods we may be interested in making assertions about default values. A great shorthand is the `its` keyword which provides a shortcut for the implicit subject's attributes.

If our example class had default values we could use the following to quickly make assertions:

```ruby
describe Client do
  context "created with defaults" do
    its(:server_name) { should eq("http://defaultserver.com") }
  end
end
```

## `let`

RSpec's `let` defines a helper method. The value returned by the `let` block is cached for the execution of the single example.

```ruby
describe Square do
  let (:expected_area) { 10 * 10 }

  it 'should have the expected area' do
    subject.width = 10
    subject.area.should eq(expected_area)
    subject.height = 10
    subject.area.should eq(expected_area)
  end
end
```

During the test of our `Square` class we made an assertion that the area of the square class is equal to the `expected_area`. As a performance benefit this was only calculated once. This may appear trivial in the previous example, however, this proves useful if the data underneath you may change.

```ruby
describe Customer do

  let (:customer) { Customer.first }

  it 'should have a full name that is composed of their first name and last name' do
      customer.full_name.should eq("#{customer.first_name} #{customer.last_name}")
    end
  end
end
```

Here we see the benefit of the value being memoized, or cached, during the same execution of the example. Our example does not have to return to the database to find the first customer multiple times. Second, we are protected if our database were to change during the test because of another concurrently executing test.

Alongside `let` there is also `let!`. In both of the above examples the value was loaded and cached on first use (lazy initialization). With `let!` the value is *immediately* cached at the beginning of the execution of the example.

## Shared Examples

Often you will find that classes share similar functionality. Take for example the two models outlined:

```ruby
class Article
  # ... other code unique to an article ...
  attr_reader :author, :publish_date, :featured
end

class Video
  # ... other code unique to a video ...
  attr_reader :author, :publish_date, :featured
end
```

Within your test suite you likely have examples for your `Article` like this:

```ruby
describe Article do
  [ :author, :publish_date, :featured ].each do |attribute|
    it { should respond_to attribute }
  end
end
```

It is tempting to copy/paste the code to the `Video` examples. The RSpec framework provides functionality to assist with sharing characteristics across different models through `shared_examples`

```ruby
shared_examples "a published document" do
  [ :author, :publish_date, :featured ].each do |attribute|
    it { should respond_to attribute }
  end
end

describe Article do
  it_behaves_like "a published document"
end

describe Video do
  it_behaves_like "a published document"
end
```

To make the `shared_examples` available across multiple spec files, you'd need to define or load it in the common `spec_helper.rb`.

## Special Matchers

### to `should be` or `should_not be_nil` that is the question...

RSpec has a number of great matchers available to help make assertions more clear. You can use comparisons with `==` and write:

```ruby
nil_object.should == nil
object.should != nil
```

It is much more elegant to use the custom matchers provided by RSpec:

```ruby
nil_object.should be_nil
object.should be
```

Try to state your assertions in the positive, preferring that an `object.should be` over an `object.should_not be_nil`.

### Using lambdas

RSpec aliases Ruby's `lambda` to `expect`, allowing this:

```ruby
lambda { Object.new.unknown_method }.should raise_error(NoMethodError)
```

To be written:

```ruby
expect { Object.new.unknown_method }.should raise_error(NoMethodError)
```

However, when using the `expect` syntax, prefer `.to` over `.should`.

```ruby
expect { Object.new.unknown_method }.to raise_error(NoMethodError)
```

## Command Line Options

RSpec has many options that can be controlled from the command line.

### Example execution by line

You can execute a specific example based on the line number:

    bundle exec rspec spec/model_spec.rb:9

This type of isolation is extremely useful to determine if setup, teardown, or other examples are causing conflicts with the given example you are executing.

### Output Formats

RSpec supports multiple different output formats:

* progress is the default and the most minimal. It simply displays a dot for each passing example and an F for each failing example.
* documentation, `rspec -f d`, displays the text defined in your groups and examples, giving you a richer, more human-readable output.
* html, `rspec -f h`, displays the output to HTML. This format is usually accompanied with the results being sent to a file with the `-o` command like this:
  ```
  rspec spec -f h spec/model_spec.rb -o model_spec.html`.
  ```

### Guard

Guard is a system for executing actions when files in your application change. One common use is to run your test when a file being tested changes.

#### Setup

Add `guard` and `guard-rspec` to your Gemfile:

```ruby
group :test, :development do
  gem 'guard'
  gem 'guard-rspec'
end
```

Run `bundle`, then initialize guard and add the default RSpec file monitoring:

    $ bundle install
    $ guard init
    $ guard rspec

Editing the RSpec entry in the Guardfile to add color and documentation format:

```ruby
# ... within your Guardfile
guard 'rspec', cli: "--color --format documentation" do
  # ...
end
```

Execution:

    $ guard


## Database Cleaner

It's surprisingly easy to leave data hanging around your test database. The most common scenario is when using `before :all` blocks which aren't automatically rolled back when the tests are complete.

Having this data lingering around can lead to unexpected results in your examples.

The Database Cleaner gem takes care of maintaining your database for you.

### Clearing the Slate

Start by rebuilding your test database:

```ruby
rake db:test:prepare
```

### Gem Setup

Add `database_cleaner` to your `Gemfile` and run `bundle`.

### SpecHelper

Then, in your `spec_helper.rb`, add this config:

```ruby
Spec::Runner.configure do |config|

  config.use_transactional_fixtures = false
  config.before :suite do
    DatabaseCleaner.clean_with :truncation
  end

  config.before :each do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end
```

Now your database will be pristine between test runs!

## Exercises

{% include custom/sample_project.html %}

1. Write two examples for the `Article` class that use `before :each` to share common setup code.
2. Refactor those two examples to use the _implicit receiver_ where you use just `it` and a block.
3. Experimenting with Database Cleaner:
  * Write a `before :all` block that creates five articles in the database
  * Run the examples
  * Start a console attached to the test database with `rails console test`
  * Verify that the records are still sitting there in the database then exit the console
  * Clear the database with `rake db:test:prepare`
  * Setup Database Cleaner as described above
  * Run the examples
  * Re-open the console and verify that no records remain in the database
4. Use `expect` to check that a method does not raise an exception given invalid input.
5. Experiment with running RSpec with each format:
  * the default
  * documentation using `rspec -f d`
  * html output to a file like:
    ```
    rspec -f h spec/model_spec.rb -o model_spec.html
    ```

## References

* Explicit Subject (`it`): https://www.relishapp.com/rspec/rspec-core/docs/subject/explicit-subject
* Implicit Receiver : https://www.relishapp.com/rspec/rspec-core/docs/subject/implicit-receiver
* Attributes of Subject (`its`): https://www.relishapp.com/rspec/rspec-core/docs/subject/attribute-of-subject
* `let`: https://www.relishapp.com/rspec/rspec-core/docs/helper-methods/let-and-let
* Shared Examples: https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples
* Special Matchers: https://www.relishapp.com/rspec/rspec-expectations
* Output Formats: https://www.relishapp.com/rspec/rspec-core/docs/command-line/format-option
* Database Cleaner: https://github.com/bmabey/database_cleaner
* `expect`: https://www.relishapp.com/rspec/rspec-expectations/v/2-0/docs/matchers/expect-error
