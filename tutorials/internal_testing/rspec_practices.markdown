# RSpec Practices

[PENDING]

( Yes Exercises )

## Before and After

Before(:all) are not rolled back after tests

## Describe & Context

### Use a '.' for class methods and '#' for instance methods

### Contexts for execution paths through a method, start names with 'when'

## Let

## Subject

describe DemoMan do
  before(:all) do
    @demo_man = DemoMan.new
  end
 
  subject { @demo_man }
 
  it { should respond_to :name   }
  it { should respond_to :gender }
  it { should respond_to :age    }
end


## Special Matchers

### should_not be_nil to should be
### lambda{}.should raise_error to expect{}.to raise_error

## Looking at Output
rspec spec/controllers/posts_controller_spec.rb --format documentation

## Database Cleaner

https://github.com/bmabey/database_cleaner

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
