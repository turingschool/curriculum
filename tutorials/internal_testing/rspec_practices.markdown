# RSpec Practices

[PENDING]

[TODO-EDIT: Verify that we are being consistent with the language of example or test]

( Yes Exercises )

[TODO: Possible Exercise Ideas]

RSpec focused exercises really could simply take all the outlined tools to refactor the test suite to be smaller, cleaner, less brittle, and faster.

Exercise - given existing spec files that could be cleaned up with the practices:

* Describe and context guidelines
* Employing before and after blocks
* Explicit/Implicit Subject
* Shared Examples

Exercise - given the name and purpose for a class generate:

* some of the test `describe` for the class
* some of the `contexts` for the class


## Setup and Teardown (before and after)

While writing examples which exercise your classes you will likely come across classes and states that you create and configure that is similar between multiple examples. For example:

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

In the above example we generate an new instance of `Client` before we make the assertion that it is responds to the particular methods. While the effort to test is commendable there are some drawbacks from this implementation:

* This is wasteful as we are repeating ourself several times within the tests.
* Maintaining the tests is tedious; for example, returning later to make a change to the initialize method to take a parameter would require a lot of work.
* Clarity of code about what is being tested.

Rspec, like other test frameworks, provides helper methods for test setup and test tear down for individual examples and groups of examples. These helper methods are named `before` and `after`. They both come in two variates: execution for each example `:each` or for all examples `:all`.

* before :all
* before :each
* after :each
* after :all


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

    NOTE: In this trivial example we could have used 'before :all' and set up our @client object once. It is important to know that changes made within a 'before :all' block will not be rolled back after tests. This makes a difference if you are creating examples that exercise database code.

You can define a `before` and `after` within each `describe` or `context` block. Allowing you to easily add setup and creation as necessary.

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

Execution of the following yields the following output:

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
 
## Remember it is still Ruby

RSpec may appear as if is a all together a different language that is allowing you to embed Ruby within it to exercise your code but it is not. It is Ruby and that means you can do things that you could do normally with Ruby.

We could even re-factor our previous example, our `Client` examples, even further:

```ruby
describe Client do

  before :each do
    @client = Client.new
  end
  
  [ :connect, :disconnect, :server_address ].each do |method|
  
    it "should respond #{method}" do
      @client.should respond_to(:connect)
    end
    
  end
  
end
```

Creating an array of our three methods `:connect`, `:disconnect`, and `server_address` and iterating over that array allow us to save the duplication of entries.

## Describe & Context

### Instance Methods

A common RSpec convention is to proceed instance methods with a pound (#) to represent that the test is exercising the method on the instance of the object.

```ruby
class Client
  def initialize
    # ... initialization code ...
  end
end

```

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

A common RSpec convention is to proceed class methods with a period (.) to represent that the test is exercising the method on the class of the object.

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

### Contexts 

While `describe` and `context` syntactically are not very different, save for the restriction that `context` cannot be used as a top level element within a spec file, it is often good to use `context` in situations where a group of tests are exercising particular paths through the method or illustrating a particular state.

```ruby
class Client

  # Connects to the specified server 
  def connect(server=@default_server)
    # ... performs connection to the server ...
  end
end
```

In the above situation our `Client` class has a `#connect` method which allows for a single input. 

The method accepts a server as a parameter or it defaults a sever value stored within the `Client` instance. Here, we have identified a context when the code is executed without a server specified and with a server specified.

As this is likely a client making a connection to a server it is possible that the server is not available. Again, we have identified a context when the code may generate a different result within the code.

An example outline of the resulting test file could look like the following:

```ruby
describe Client do
  describe '#connect' do
    context 'when the server value is not specified' do
      it 'should connect to the default server' do ; end
    end
    
    context 'when the server is not available' do
      it 'should raise an exception' do ; end
    end
  end
end
```

Each defined context here uses RSpec's `context` keyword with each description string starting with *when*. Again, this is a good practice as it makes it clear when what this context is attempting to describe.

## Subject

### [Explicit Subject](https://www.relishapp.com/rspec/rspec-core/docs/subject/explicit-subject)

Let's return to our previous example of the `Client` class:

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

Here we saved ourselves the hassle of having to generate a `Client` each and every execution, however, we still have the member variables `@client` used throughout all of our test examples. In the event that we wanted to change the variable name we would need to do some find & replacing.

RSpec allows for you to be verbose in the right areas of your test suite. To assist with that, RSpec has the convention that when you call `should` without an _explicit receiver_ it is assumed that you mean to make an assertion against the `subject` under test. This is called [Implicit Receiver](https://www.relishapp.com/rspec/rspec-core/docs/subject/implicit-receiver).

Let us define a `subject` and allow for it to be the implicit receiver. 

Revisiting the previous example:

```ruby
describe Client do
  before(:all) do
    @client = Client.new
  end
 
  subject { @client }
 
  it { should respond_to :connect   }
  it { should respond_to :disconnect }
  it { should respond_to :server_name }
end
```

We were able to remove the use of the member variable `@client` from all the test examples and place it within the `subject` helper. The result of which will be used implicitly everywhere we previously had used it. Saving us a lot of typing.

However, RSpec goes even further to make us faster and more effective test driven developers.

### [Implicit Subject](https://www.relishapp.com/rspec/rspec-core/docs/subject/implicit-subject)

Using the class name `Client` in the outermost `describe` grants us the benefit of having an instance of object under test automatically available through the `subject` helper method.

Again returning to our previous example, we can remove our explicit declaration of the subject and rely on the RSpec framework.

```ruby
describe Client do
  it { should respond_to :connect   }
  it { should respond_to :disconnect }
  it { should respond_to :server_name }
end
```

Or even more succinctly:

```ruby
describe Client do
  [ :connect, :disconnect, :server_name ].each do |method|
    it { method respond_to attribute }
  end
end
```

### its - [Attributes of Subject](https://www.relishapp.com/rspec/rspec-core/docs/subject/attribute-of-subject)

After asserting that a class responds to particular methods we may be interested in making assertions against default values. A great shorthand is the `its` keyword which provides a shortcut for the implicit subject's attributes.

If our example class had default values we could use the following to quickly make assertions:

```ruby
describe Client do
  context "created with defaults" do
    its(:server_name) { should eq("http://defaultserver.com") }
  end
end
```

## [Let](https://www.relishapp.com/rspec/rspec-core/docs/helper-methods/let-and-let)

RSpec's `let` defines a helper method. The value returned by the `let` block is cached for the entire execution of the example. Saving you the cost of re-calculation in the event that it is used again within the same example.

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

Here we see the benefit of the value being memoized, or cached, during the same execution of the example. First, our test does not have to return to the database to find the first customer multiple times. Second, we are protected if our database were to change who it thought the first customer was during the test (because of another concurrently executing test).

Alongside of the `let` there is the helper method `let!`. The difference is solely in the time when it caches in the information. In both of the above examples the value was loaded and saved on first use of the helper method (lazy initialization). When you use the helper `let!` the value is immediately cached at the beginning of the execution of the test.

## [Shared Examples](https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples)

Often times you will find that classes share similar functionality. Take for example the two models outlined:

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

Here an `Article` and a `Video` share some commonalities. Within your test suite you likely have tests for your `Article` that resemble the following:

```ruby
describe Article do
  [ :author, :publish_date, :featured ].each do |attribute|
    it { should respond_to attribute }
  end
end
```

It is often tempting to simply generate a nearly identical version for `Video`. The RSpec framework provides functionality to assist with sharing characteristics across different models through `shared_examples`

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
  it_should_behave_like "a published document"
end
```

Either `it_behaves_like` or `it_should_behave_like` work so select the one that best fits the name that you give the `shared_example`.

Often for clarity one class is kept in one file and has an adjoining test file. So it is not likely that you can use `shared_example` unless you start to place classes in the same test file. To overcome this obstacle you should employ the use of a common, shared file (spec_helper.rb) that both of these files will require during execution.

## [Special Matchers](https://www.relishapp.com/rspec/rspec-expectations)

### to `should be` or `should_not be_nil` that is the question...

RSpec has a number of great matchers available to you to help you make the assertions within your examples more clear. While you can use comparisons with `==` and write:

```ruby
nil_object.should == nil
object.should != nil
```

It is much more elegant to use some of the custom matchers provided by RSpec.

```ruby
nil_object.should be_nil
object.should be
```

And as always, try to make your assertions clear, stating them in the positive, preferring that an `object.should be` over an object `object.should_not be_nil`.

### lambda lambda lambda vs omega expect

[TODO: Bad Revenge of the Nerds! joke here!]

RSpec also introduces helper keywords that often make your examples more clear.

```ruby
lambda { Object.new.unknown_method }.should raise_error
```

More clearly could be stated as:

```ruby
expect { Object.new.unknown_method }.should raise_error
```

## Command Line Options

### Example execution by line

Most Ruby developers figure out that they can execute the RSpec test suite against a single file `rspec spec/model_spec.rb` and multiple files `rspec spec/**/*_spec.rb` it is also possible to execute the test suite against a specific example based on the line number.

    rspec spec/model_spec.rb:9
    
The following would execute the example found at that line number. This small trick may be extremely useful when you are looking to execute one particular example or example group isolated from the rest within a file.

This type of isolation is extremely useful to determine if setup, teardown, or other examples are causing conflicts with the given example you are executing.

### [Output Formats](https://www.relishapp.com/rspec/rspec-core/docs/command-line/format-option)

RSpec supports multiple different output formats, available to you when you execute `rspec --help`.

* Progress is the default and the most minimal simply drawing dots for passing examples and Fs for failed examples.
* documentation, `rspec -f d`, displays the text defined in your groups and examples giving you a richer, more human-readable output
* html, `rspec -f h`, displays the output to HTML. This format is usually accompanied with the results being sent to a file `rspec -f h spec/model_spec.rb -o model_spec.html`.

### Set up a Guard for yourself

While it is definitely preferred to setup tools for yourself like [guard](https://github.com/guard/guard) with [guard-rspec](https://github.com/guard/guard-rspec) to automatically execute your examples as you make changes

Add `guard` and `guard-rspec` to your Gemfile:

```ruby
# ... within your Gemfile

group :test, :development do
  gem 'guard'
  gem 'guard-rspec'
end
```

Install the gems through bundler, initialize guard and add the default Rspec file monitoring:

    $ bundle install
    $ guard init
    $ guard rspec

Editing the RSpec entry in the Guardfile to add color and documentation format:

```ruby
# ... within your Guardfile
guard 'rspec', :cli => "--color --format documentation" do
  # ...
end
```

Execution:

    $ guard
    

## Database Cleaner

[TODO: This needs the usual context and motivating paragraph]

https://github.com/bmabey/database_cleaner

```ruby
Spec::Runner.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
```