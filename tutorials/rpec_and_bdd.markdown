# RSpec and BDD

The Ruby community loves testing. It's an area that's under constant evolution and "best practices" are always shifting. But there's a majority forming around RSpec. It's a great tool for implementing Test Driven Development (TDD) and Behavior Driven Development (BDD) 

## Behavior Driven Development

There are generally four tiers to testing practice: test last, test first, TDD, and BDD.

In *test last* development you write an automated test suite to exercise code that has already been written. This is the most common form of testing (across languages), but in the Ruby world it's considered "too little, too late." It is an incredibly difficult challenge to write a comprehensive test suite at this stage of development. More importantly, the design wins from using a test-first approach have already been missed.

*Test first* development is when we think about the details of an implementation first, write a test that exercises that implementation, then actually implement it. It follows the "red-green-refactor" cycle, but is kind of cheating since the test was only written to permit the implementation.

In true *TDD*, the test is the important thing. We don't think of the implementation then write a test, we write a test then figure out a possible implementation. We shift to a goal-oriented focus. When the test is written, the only thing that matters is making it pass. The implementation lives to serve the test.

Then at the highest level we push towards *BDD*. In testing behavior we focus on business value. TDD focuses on how something will work, BDD focuses on why we build it at all. BDD is a difficult science that we're still working out how to realize. RSpec along with tools like Capybara and Cucumber are pushing the envelope.

### Testing/Development Cycle

A good cycle to follow when attempting BDD is this:

1. Write a high-level business value example (using Cucumber or RSpec/Capybara) that goes red
2. Write a lower-level RSpec example for the first step of implementation that goes red
3. Implement the minimum code to pass that lower-level example, see it go green
4. Write the next lower-level RSpec example pushing towards passing #1
5. Repeat steps #3 and #4 until the high-level test (#1) goes green

During the process think of your red/green state as a permission status:

When your low-level tests are *green*, you have permission to write new examples or refactor existing implementation. You must not, in the context of that refactoring, add new functionality/flexibility.

When your low-level tests are *red*, you have permission to write or change implmentation code only for the purpose of making the existing tests go green. You must resist the urge to write the code to pass your _next_ test, which doesn't exist, or implement features you'll need "some day."

### High-Level Integration Testing

There are two popular approaches to high-level testing:

* User stories with Cucumber
* Integration tests with RSpec/Capybara

Each approach has it's fans and haters:

In my opinion, Cucumber is a great tool to use when you have a highly-technical client. If it's feasible that the client could write or co-author these user stories, then go for it!

Very rarely, however, have I worked on projects where that was true. Instead, with Cucumber, the developer often writes the user stories for their own consumption. They then write a set of natural language parsers (not fun) to turn these stories into runnable specs, then can actually run the code.

In the case where the developer is the only one who deals with the test suite, a better choice is to pair RSpec directly with Capybara. You can develop awesome user-stories-in-executable-code that are still readable and realize the goals of BDD.

We'll dedicate an entire unit to Capybara later: [/tutorials/capybara_with_rack_test/]

## Unit Testing

Once we have a failing integration test we have permission to write lower level examples. 

### Theory

This is where RSpec really shines. We should write examples that exercise the "happy path", examples that try the edge cases, and examples that test the exceptions. 

We should not write a line of executable implementation unless it is for the purpose of making a unit test go green. This means that each public method in a class should have at least one unit test.

As we look at code coverage later, our coverage is driven primarily by unit tests. In Ruby, it is reasonable to expect greater than 90% code coverage when following a BDD model.

### Structure

Unit tests should be collected by the Ruby class that they exercise. Those specs should be stored in a file `spec/models/modelname_spec.rb` such as `spec/models/article_spec.rb` for an `Article` class.

Typically the file will look like this:

```ruby
require 'spec_helper'

describe Article do
  # Your Examples Here
end
```

The `require 'spec_helper'` pulls in `spec/spec_helper.rb` where we can setup RSpec configuration information and any initialization code common to all our examples.

### Describe

The spec file begins with the `describe` method. Describe takes two parameters: the name of the class being exercised and a block containing the examples. We'll talk more about using multiple `describe` blocks in the [RSpec Practices](/tutorials/rspec_practices/) section.

### An Example

A typical example looks like this:

```ruby
  it "is not valid without a title" do
    article = Article.new(:title => nil)
    article.should_not be_valid
  end
```

The example starts with the `it` method that takes two parameters: a string naming the example and a block containing the code and matchers to execute.

Naming examples is a matter of style, but a good technique is to start with a present tense verb, completing the sentence after the word "it." Many Rubyists start all tests with "should", but this is redundant. "it should not be valid" can just be shortened to "it is not valid." As we being using nested contexts our names can get out of control if we don't emphasize simplicity.

### Expectation Expressions

An example often has a few steps of business logic, like this example creates and object and sets the title to nil. Then once the data is setup for examination, we start using expectations with matchers.

An RSpec expectation expression is made up of three parts: subject, expectation, and matcher. For instance:

```ruby
article.should_not be_valid
```

We have the subject `article`, the expectation `should_not`, and the matcher `be_valid`. 

#### Subject

We can setup whatever subject we want to examine in the lines before the expectation expression, in this example we built the blank article object.

#### Expectation

There are only two expectations that you need to know: `should` and `should_not`. They cooperate with a matcher. Matchers return true or false, so the expectations react to those return values. If `should` gets `true` from the matcher, the expectation passes. If it gets `false`, it fails. The reverse is true for `should_not`

#### Matchers

The matchers are where it gets interesting. There are dozens of matchers available to you out of the box, more available as RSpec addons, and you can write your own. A few of the most common include:

* `be` with no parameter passes when the subject is not nil 
* `be` with a parameter passes when the subject matches the param
* `be_true` and `be_false` look at the subject's value
* `be_instance_of` with a class as parameter check's the subject's type
* `be_xyz` calls `xyz?` on the subject, expecting true or false
* `include(value)` checks that `value` is in the subject collection

#### Exceptions

When you want to test that exceptions are raise you need to jump through some extra hoops. RSpec needs to wrap the execution in a `begin`/`rescue` block so it can evaluate the exception as opposed to letting the exception bubble up and stop your example's execution.

This is accomplished with the `expect` method:

```ruby
  it "raises an error when saving with no author" do
    article = Article.new(:author => nil)
    expect{ article.save! }.to raise_error
  end
```

You can also give `raise_error` parameters of a string to compare against the error's message and the error class to match like this:

```ruby
expect{ article.save! }.to raise_error(RecordInvalid, "article is not valid")
```

In general, matching the exception class is good enough, looking at the specific message is a bit too detailed unless the purpose of your example is to demonstrate customized error messages.

## Testing Controllers & Helpers

Writing unit tests with RSpec is awesome, but we shouldn't stop there. Unit tests tend to be clear in construction and intent because we're working with plain Ruby objects.

But what about testing further up the stack? 

### Controller Tests

A common feature of Rails projects that have gone wrong are heavyweight controllers. They have actions that are dozens or even hundreds of lines of business logic that should have been pushed down to the model layer, but it lives up in the controller. That's bad! Code stuck in a controller action can't reused. 

It's also more difficult to test. Let's check out a simple controller test:

```ruby
describe ArticlesController do
  it "renders the index template" do
    get :index
    response.should render_template("index")
  end
end
```

This example, in my opinion, is stupid. I hate controller tests because they give too much respect to an object that is, by design, just meant to connect our models to our views.

For this reason, I don't believe in testing controllers directly. Instead, as Nick Gauthier describes, use an "hourglass" approach to testing your stack. Tests heavily at the bottom model level, write a few tests for the controllers in the middle if they feel necessary, then heavily test the user interface with integration tests.

### Helper Tests

One area of the upper stack that's great to test are helpers. Typically a helper method takes in some domain data and performs a computation or formatting operation on it, returning a string.

These are just Ruby methods, we can test them just like our other unit tests. To test helpers in `ArticlesHelper`, we'd create `spec/helpers/articles_helpers_spec.rb` and frame it with this:

```ruby
require 'spec_helper'

describe ArticlesHelper do

end
```

We just use the helper module name as the parameter to `describe`. Now within the block we could test a helper named "article_tags" like this:

```ruby
require 'spec_helper'

describe ArticlesHelper do
  context ".article_tags" do
    it "should return a comma separated list of tag names" do
      article = Fabricate(:article)
      tags = [Fabricate(:tag), Fabricate(:tag)]
      article.tags << tags
      article_tags.should == "#{tags[0].name}, #{tags[1].name}"
    end
  end
end
```

Note in the last line how we can use `article_tags`, the helper method, just like we're operating inside a view. There's no magic! 