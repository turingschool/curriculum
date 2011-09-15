# RSpec Practices

[PENDING]

( Yes Exercises )

[TODO: Exercise Ideas]

RSpec focused exercises really could simply take all the outlined tools to refactor the test suite to be smaller, cleaner, less brittle, and faster.


## Before and After

Before(:all) are not rolled back after tests

[TODO: I would recommend that this section be placed within the describe & context section so that we can show the refactoring and saving of set up and tear down steps]

## Describe & Context

### Instance Methods

A common RSpec convention is to proceed instance methods with a pound (#) to represent that the test is exercising the method on the instance of the object.

```ruby
class DemoMan
  def initialize
    # ... initialization code ...
  end
end

```

```ruby
describe DemoMan do
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
class DemoMan
  def self.generate
    # ... generation code ...
  end
end

```

```ruby
describe DemoMan do
  describe '.generate' do
    it 'should return a valid DemoMan instance' do
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

Let's look at the following example:

```ruby
describe DemoMan do
  before(:all) do
    @demo_man = DemoMan.new
  end
 
  it { @demo_man.should respond_to :name   }
  it { @demo_man.should respond_to :gender }
  it { @demo_man.should respond_to :age    }
end
```

Here we saved ourselves the hassle of having to generate a `DemoMan` each and every execution, however, we still have the member variables `@demo_man` used throughout all of our test examples. In the event that we wanted to change the variable name we would need to do some find & replacing.

RSpec allows for you to be verbose in the right areas of your test suite. To assist with that, RSpec has the convention that when you call `should` without an _explicit receiver_ it is assumed that you mean to make an assertion against the `subject` under test. This is called [Implicit Receiver](https://www.relishapp.com/rspec/rspec-core/docs/subject/implicit-receiver).

Let us define a `subject` and allow for it to be the implicit receiver. 

Revisiting the previous example:

```ruby
describe DemoMan do
  before(:all) do
    @demo_man = DemoMan.new
  end
 
  subject { @demo_man }
 
  it { should respond_to :name   }
  it { should respond_to :gender }
  it { should respond_to :age    }
end
```

We were able to remove the use of the member variable `@demo_man` from all the test examples and place it within the `subject` helper. The result of which will be used implicitly everywhere we previously had used it. Saving us a lot of typing.

However, RSpec goes even further to make us faster and more effective test driven developers.

### [Implicit Subject](https://www.relishapp.com/rspec/rspec-core/docs/subject/implicit-subject)

Using the class name `DemoMan` in the outermost `describe` grants us the benefit of having an instance of object under test automatically available through the `subject` helper method.

Again returning to our previous example, we can remove our explicit declaration of the subject and rely on the RSpec framework.

```ruby
describe DemoMan do
  it { should respond_to :name   }
  it { should respond_to :gender }
  it { should respond_to :age    }
end
```

Or even more succinctly:

```ruby
describe DemoMan do
  [ :name, :gender, :age ].each do |attribute|
    it { should respond_to attribute }
  end
end
```

### its - [Attributes of Subject](https://www.relishapp.com/rspec/rspec-core/docs/subject/attribute-of-subject)

After asserting that a class responds to particular methods we may be interested in making assertions against default values. A great shorthand is the `its` keyword which provides a shortcut for the implicit subject's attributes.

If our example class had default values we could use the following to quickly make assertions:

```ruby
describe DemoMan do
  context "created with defaults" do
    its(:name) { should eq("") }
    its(:gender) { should eq(:male) }
    its(:age) { should eq(:21) }
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

### Spec Helper Files

### Share Context

[TODO](https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-context)

### Pending Examples

[TODO](https://www.relishapp.com/rspec/rspec-core/docs/pending/pending-examples)

## Special Matchers

[TODO: Need to get a list of all these matchers](https://www.relishapp.com/rspec/rspec-expectations)

### should_not be_nil to should be
### lambda{}.should raise_error to expect{}.to raise_error




## Looking at Output
`rspec spec/controllers/posts_controller_spec.rb --format documentation`

[TODO: Other command like parameters may be useful](https://www.relishapp.com/rspec/rspec-core/docs/command-line)

## Database Cleaner

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