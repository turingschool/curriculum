---
layout: page
title: JSContact
sidebar: true
---

In this advanced Rails project, you'll create a contact manager. The tools that you will use include the following:

* Testing with "RSpec":http://relishapp.com/rspec/ to drive your development
* Creating view templates with "HAML":http://haml-lang.com/ and "SASS":http://sass-lang.com/
* Generating code with "Nifty Generators":http://github.com/ryanb/nifty-generators
* Building complex forms with "Simple Form":http://github.com/plataformatec/simple_form
* Building Rails3/AREL queries and scopes
* Handling file attachments with "Carrierwave":http://github.com/jnicklas/carrierwave
* Building reusable view code with helpers and partials
* Refactoring
* Managing authentication and authorization
* Server and client-side validations
* Deployment and monitoring

This project assumes you have already completed the "general Ruby setup":http://jumpstartlab.com/resources/general/environment/ and I'm using *Ruby 1.9.2*. We'll rely on the Bundler system to install other gems for us along the way.

In addition, I recommend you use the Sublime Text 2 IDE available "here":http://www.sublimetext.com/2.

We'll use an iterative approach to develop one feature at a time. Here goes!

## I0: Up and Running

Let's lay the groundwork for our project. In your terminal, switch to the directory where you'd like your project to be stored. I'll use `~/Projects`.

Run the `rails -v` command and you should see your current Rails version, mine is *3.2.2*. If Rails is not installed, run `sudo gem install rails`. You can check that it installed correctly by reviewing your `gem list` and/or using `rails -v`.

Let's create a new Rails project:

```bash
  rails new js_contact
```

Then `cd` into your project directory and open the project in your editor of choice. 

### Veering Off the "Golden Path" with RSpec

With our project created, we will veer off the Rails defaults for both the testing and JavaScript libraries. First, let's setup RSpec as our testing framework. Open your project's `Gemfile` and add this dependency:

```ruby
  gem 'rspec-rails'
```

Then, in your terminal window that's in the project directory, run bundle:

```bash
  bundle
```

Now rspec-rails is available, but we still need to do some setup to make it all work. Running this generator will perform the setup for you:

```bash
  rails generate rspec:install
```

You should see output like this:

```bash
  create  .rspec
  create  spec
  create  spec/spec_helper.rb
```

Now your project is set to use RSpec and the generators will use RSpec by default. You still have Rails' default `test` folder hanging around -- let's delete that with:

```bash
  rm -rf test
```

Or on Windows try:

```bash
  rd /r test
```

Now you're free of `Test::Unit` and ready to rock with RSpec.


### jQuery Setup 

Open `/app/assets/javascripts/application.js` and uncomment these lines:

```ruby
  = require jquery
  = require jquery_ujs
```

### Startup Your Local Server

Open a second terminal window, `cd` into your project directory, then start your server with:

```bash
  rails server
```

This will, by default, use the Webrick server which is slow as molasses. Hit Ctrl-C to stop it. Some of the alternative servers are *mongrel* and *unicorn*. Here's how to setup unicorn.

Add this the dependency to your `Gemfile`:

```ruby
  gem 'unicorn'
```

Run `bundle` from your project directory and wait for the installation to complete. Start the server like this:

```bash
  unicorn
```

Load "http://0.0.0.0:8080":http://0.0.0.0:8080 in your browser and you should see the Rails splash screen. Click the "About Your Application" link and you should see all your library versions. If your database were not installed properly or inaccessible, you'd see an error here.

### Setup Git Repository

I'll assume that you've already setup Git on your system. From within your project directory, create a new repository with:

```bash
  git init .
```

Then add all of the files in your current working directory to the repository and commit it:

```bash
  git add .
  git commit -m "Initial project generated"
```

At this point if you're using GitHub, you could add that remote and push to it. For purposes of this tutorial, we'll just manage the code locally.

### Ship It

Next let's integrate "Heroku":http://www.heroku.com/. 

If you don't already have one, you'll need to create a Heroku account. The `heroku` gem will ask for your username and password the first time you run `heroku create`, but after that you'll be using an SSH key for authentication.

Open up that `Gemfile` and add this dependency:

```ruby
  gem 'heroku'
```

Remove `gem 'sqlite3'` and replace it with the PostgreSQL gem. 

```ruby
  gem 'pg'
```

Run the `bundle` command again and now you'll have command-line access to Heroku.

```bash
  heroku create --stack cedar
```

After running that command, you'll get back the URL where the app is accessible. Try loading the URL in your browser and you'll see the generic Heroku splash screen. It's not running your code yet so push your project up like this:

```bash
  git push heroku master
```

It'll take a minute, then you should see a message that your application was successfully deployed like this:

```bash
  -----> Launching... done
         http://jscontact.heroku.com deployed to Heroku
```

Refresh your browser and you should see the Rails splash screen. Click "About your application's environment" again, and...wait, what happened?  When your app is running on Heroku it's in *production* mode, so you'll see a default error message. Don't worry, everything should be running fine.

### Dependency Cleanup

We've added several gems to our `Gemfile`, but several of them are only useful for development or testing. It doesn't make sense, then, to have Heroku install and load them in production. It costs RAM and slows down our deployment. The Bundler system can handle this with environment blocks. I also like to remove all the comments from the `Gemfile`, leaving me with just this:

```ruby
  source 'http://rubygems.org'

  gem 'rails', '3.2.2'
  gem 'pg'

  group :development, :test do
    gem 'rspec-rails'
    gem 'jquery-rails'
    gem 'heroku'
    gem 'unicorn'
    gem 'sqlite3'

  end
```

Now the RSpec, Heroku, SQLite, and Unicorn gems will only be loaded in development and test environments. If you're wondering, the jQuery gem doesn't have any role in production because we've already stored the jQuery JavaScript files into our `public` directory using the generator. Similarly, though we're deploying to Heroku, the `heroku` gem is only used during development. Save your new Gemfile and ship it:

```bash
  git add .
  git commit -m "Added dev and test blocks to Gemfile"
  git push heroku master
```

Now we're ready to actually build our app!

## I1: Building People

We're building a contact manager, so let's start with modeling people. Since this is an advanced tutorial we won't slog through the details of implementing a Person model, controller, and views. Instead we'll take advantage of scaffolding tools.

### A Feature Branch

But first, let's make a feature branch in git:

```bash
  git branch build_people
  git checkout build_people
```

Now all our changes will be made on the `build_people` branch. As we finish the iteration we'll merge the changes back into master and ship it.

### Nifty Scaffold

I want to use the scaffold generator to create a model named `Person`, but I don't care for some of the conventions used in the default Rails scaffold generator. Instead, I prefer the `nifty-generators` created by "RailsCasts author Ryan Bates":http://railscasts.com.

In the development section of your `Gemfile`, add a dependency for `"nifty-generators"`, run `bundle` from the command prompt, then run this generator, answering `yes` to the conflict:

```bash
  rails generate nifty:layout
```

That sets us up to use Ryan's "nifty" scaffolding. Let's then generate a scaffolded model named `Person` that just has a `first_name` and `last_name`:

```bash
  rails generate nifty:scaffold Person first_name:string last_name:string
```

The first line of the output shows Ryan sneaking the `"mocha"` gem into our Gemfile. To clean things up, let's move the gem dependency into the development/test block we already have. By doing this, you can remove `group: :test` from the `gem "mocha"` line. Run `bundle` and then run the migration with `rake db:migrate`.

The generators created test-related files for us. They saw that we're using RSpec and created corresponding controller and model test files. Let's run those tests now:

```bash
  rake
```

Whoa! Two tests don't pass right off the bat. Let's fix these. 

Both of them have the same underlying problem - they're not rendering correctly. This is because the default mock framework is rspec, but the nifty generator requires mocha to render mocks.

Fix this by going into your `spec_helper.rb` and uncommenting the `# config.mock_with :mocha` line. Re-run `rake` and all your tests should pass.

If all your tests pass, use `git add .` to add all current changes to your repository and commit them with a short and descriptive message like `git commit -m "Setup nifty_scaffold and used it to generate Person model"`

Try creating a few sample people at `http://localhost:8080/people` through your browser.

### Starting with Testing

Models are the place to start your testing. The model is the application's representation of the data layer, the foundation of any functionality. In the same way we'll build low-level tests on the models which will be the foundation of our test suite.

Open `spec/models/person_spec.rb` and you'll see this:

```ruby
require File.dirname(__FILE__) + '/../spec_helper'

describe Person do
  it "should be valid" do
    Person.new.should be_valid
  end
end
```

The `describe` block will wrap all of our tests (also called examples) in RSpec parlance. Each `it` block is an example. Add a second like this:

```ruby
  require File.dirname(__FILE__) + '/../spec_helper'

  describe Person do
    it "should be valid" do
      Person.new.should be_valid
    end

    it "should not be valid without a first name"
  end
```

Now go to your terminal, enter the command `rake`, and you should see output like this:

```bash
  ..........*

  Pending:
    Person should not be valid without a first name
      # Not yet implemented
      # ./spec/models/person_spec.rb:8

  Finished in 0.23891 seconds
  11 examples, 0 failures, 1 pending
```

Awesome! We can see that it found the spec we wrote, `"should not be valid without a first_name"`, tried to execute it, and found that the test wasn't yet implemented. In the person_spec, we have one example, zero failures, and one implementation pending. We're ready to start testing!

### Testing for Data Presence

First we'll implement the existing example to actually check that `first_name` can't be blank. Make your `person_spec.rb` look like this:

```ruby
  it "should not be valid without a first name" do
    person = Person.new(first_name: nil)
    person.should_not be_valid
  end
```

Run your tests with `rake` and you should now get this:

```bash
..........F

Failures:

  1) Person should not be valid without a first name
     Failure/Error: person.should_not be_valid
       expected valid? to return false, got true
     # ./spec/models/person_spec.rb:10:in `block (2 levels) in <top (required)>'

Finished in 0.23345 seconds
11 examples, 1 failure
```

The test failed because it expected a person with no first name to be invalid, but instead it *was* valid. We can fix that by adding a validation for first name inside the model:

```ruby
  class Person < ActiveRecord::Base
    attr_accessible :first_name, :last_name

    validates :first_name, presence: true
  end  
```

If you run `rake` here you'll see that we still have a failing test. Look closely at the failed test, though. 
```bash
.........F.

Failures:

  1) Person should be valid
     Failure/Error: Person.new.should be_valid
       expected valid? to return true, got false
     # ./spec/models/person_spec.rb:5:in `block (2 levels) in <top (required)>'

Finished in 0.13955 seconds
11 examples, 1 failure
```  

It's the other test! Now the first test fails because the blank `Person` isn't valid. Rewrite the test like this:

```ruby
it "should be valid" do
  person = Person.new(first_name: "Sample", last_name: "Person")
  person.should be_valid
end
```

Following that example for `:first_name`, let's add a validation for `:last_name` to the model then write a test checking that a person is not valid without a last name.

Run `rake` and make sure you get `0 failures`.

### Experimenting with Our Tests

Go into the `person.rb` model and temporarily remove `:last_name` from the `validates_presence_of` line. Run your tests with `rake`. What happened?

This is what's called a false positive. The `is not valid without a last_name` test is passing, but not for the right reason. Even though we're not validating `last_name`, the test is passing because the model it's building doesn't have a valid `first_name` either. That causes the validation to fail and our test to pass. We need to improve the Person object created in the tests so that only the attribute being tested is invalid. Let's refactor.

First, just below the `describe` line of our `person_spec`, let's add this code which will get executed before `each` of our examples:

```ruby
  before(:each) do
    @person = Person.new(first_name: "John", last_name: "Doe")
  end
```

Then update your first name and last name tests to a format like this:

```ruby
  it "is not valid without a first_name" do
    @person.first_name = nil
    @person.should_not be_valid
  end
```

Run your tests and now the `is not valid without a last name` test should fail. Read the output that RSpec gives you to help find the problem. In this case, it's easy -- just add `:last_name` back where you removed it from the validation in `person.rb`.

### Checking the Checkers

The `before(:each)` clause we wrote will make writing test examples a lot easier, but we had better have a test to ensure that what we're calling `@person` is actually valid!  You can do this by modifying your first test from:

```ruby
  it "should be valid" do
    person = Person.new(first_name: "Sample", last_name: "Person")
    person.should be_valid
  end
 ```
 
 to

```ruby
  it "should be valid" do
    @person.should be_valid
  end
 ```

Run the tests to make sure they work and you should now have 3 examples, 0 failures.

### Ship It

Hop over to your command prompt and let's work with git. First, ensure that everything is committed on our branch:

```bash
  git status
  git add .
  git commit -m "Finished implementing basic person functionality"
```

Then this branch is done. Let's go back to the master branch and merge it in:

```bash
  git checkout master
  git merge build_people
```

Now it's ready to send to Heroku and run our migrations:

```bash
  git push heroku master
  heroku run rake db:migrate
```

Open up your production app in your browser and you should be able to create sample people like you did on your development server.

## I2: Phone Numbers

We've created a few tests to demonstrate the validations we already had in place. We wrote the validations first then the tests second. This process is better than no testing, but it isn't Test Driven Development. Now we'll experiment with writing the tests first, then writing just enough code to make the tests pass.

### A Feature Branch

Let's again make a feature branch in git:

```bash
  git branch build_phone_numbers
  git checkout build_phone_numbers
```

Now all our changes will be made on the `build_phone_numbers` branch. As we finish the iteration we'll merge the changes back into master and ship it.

### Modeling The Objects

First, let's think about the data relationship. A person is going to have multiple phone numbers, and a phone number is going to attach to one person. In the database world, this is a one-to-many relationship, one person has many phone numbers.

#### One-to-Many Relationship

The way this is traditionally implemented in a relational database is that the "many" table (the phone number table, in this case) holds a unique identifier, called a foreign key, pointing back to the row from the "one" (person) table that it belongs to. For example, we might have a person with ID number 6. That person would have phone numbers that would each have a foreign key `person_id` with the value 6.

#### Test First: A Person Should Have Phone Numbers

With that understanding, let's write a test. We just want to check that a person is capable of having phone numbers. In your `person_spec.rb` let's add this test:

```ruby
  it "should have an array of phone numbers" do
    @person.phone_numbers.class.should == Array    
  end
```

Run `rake` and make sure the test fails with `undefined method 'phone_numbers'`. Now we're ready to create a `PhoneNumber` model and corresponding association in the `Person` model.

#### Scaffolding the Phone Number Model

We'll use the `nifty_scaffold` generator again to save us a little time. For now we'll keep the phone number simple, it'll just have a `number` column that holds the number and a `person_id` column that refers to the owning person model. Generate it with this command at the terminal:

```bash
rails generate nifty:scaffold PhoneNumber number:string person_id:integer
```

This will generate a new `/spec/controllers/phone_number_spec.rb` which you should comment out.

Run `rake db:migrate` to execute the generated migration. Run `rake` again and make sure the test isn't passing yet.

#### Setting Relationships

Next open the `person.rb` model and add the association `has_many :phone_numbers`. Run `rake` and your tests should all pass.

Try it out yourself by going into the console via `rails console` and adding a phone number manually:

```bash
p = Person.first
p.phone_numbers.create(number: '2024605555')  
```

#### Validating Phone Numbers

Right now the phone number is just stored as a string, so maybe the user enters a good-looking one like "2024600772" or maybe they enter "please-don't-call-me". Let's add some validations to make sure the phone number can't be blank.

Go into `phone_number_spec.rb` and mimic some of the same things we did in `person_spec`. We can start off by writing a `before(:each)` block to setup our `PhoneNumber` object. Enter this just below the `describe` line:

```ruby
  before(:each) do
    @phone_number = PhoneNumber.new()
  end
```

Let's also change the `"should be valid"` test to use the ``phone_number` variable:

```ruby
  it "should be valid" do
    @phone_number.should be_valid
  end
```

Then write a test ensuring that a `PhoneNumber` is connected to a `Person`:

```ruby
  it "should be associated with a person" do
    @phone_number.should respond_to(:person)
  end
```

Run your tests with `rake` and that last one will *fail*. 

Go into the `phone_number.rb` model and add the relationship `belongs_to :person`. Run `rake` again and they they should all pass. 

We want to start working on valid formats for a phone number, so let's write a failing test first that checks if a phone number can be blank:

```ruby
  it "should not be valid without a number" do
    @phone_number.number = nil
    @phone_number.should_not be_valid
  end
```

Run `rake` and you should have one failing test. Once you see red, go into the `phone_number.rb` model and add a validation checking the existence of the `number`, run your tests again, and make sure they're green.

A `PhoneNumber` shouldn't be allowed to float out in space, so let's require that it be attached to a `Person`:

```ruby
  it "should not be valid without a person" do
    @phone_number.person = nil
    @phone_number.should_not be_valid
  end
```

Run `rake` and your new test should fail. Add a validation that checks the presence of `person`. Then run `rake`.

Still have one test failing? Look carefully at *which* test is failing. It's now the `"should_be_valid"` test. We need to modify our `before` block to actually make a valid `PhoneNumber`. Try this:

```ruby
  before(:each) do
    @person = Person.create(first_name: "Sample", last_name: "Name")
    @phone_number = @person.phone_numbers.create(number: "2024605555")
  end
```

A lot of work for two validations, but these are an important part of our testing base. If somehow one of the validations got deleted accidentally, we'd know it right away.

#### Commit

Since your tests are passing it's a good time to commit your changes to the git repository:

```bash
  git add .
  git commit -m "Built phone numbers with simple validations"
```

### Building a Web Display

We can create phone numbers in the console but that's not very useful, let's work on the views and forms. We'll make use of the simpleform gem to help our forms.

Visit `localhost:8080/people` and you'll see any sample people you've created so far. Let's add a column that displays their phone numbers. Open the `app/views/people/index.html.erb` view. In that view:

* Add another `th` header with the text "Phone Numbers"
* Add another `td` where we'll display the numbers
* To output the actual numbers we'll use a helper like this: `print_numbers person.phone_numbers` 

Refresh your browser and it should give you an error message about the undefined helper method `print_numbers`. 

#### When do we write helpers?

We should write a helper to encapsulate view-related code that involves logic. A partial template is for reusing view chunks that are mostly HTML, helpers are useful for view chunks that are mostly computation.

We want to output a comma-separated list of the person's phone numbers. It's a perfect candidate for a helper.

#### Testing Helpers

Many developers don't test helpers, but I find they're one of the most common failure points in production applications. Devs don'think they need to write tests for them because they're "just little presentation methods" but then you see weird presentation artifacts in the application as the helpers get changed.

Writing tests for helpers is super easy, here's how we can do it.

First, create a folder `/spec/helpers/`. Within that folder, create a file named `phone_numbers_helper_spec.rb` and open it. Start off with this frame:

```ruby
  require 'spec_helper'

  describe PhoneNumbersHelper do
  end
```

Run `rake` and, if you look closely you'll see your new helper spec file in the executed command.

When we wrote our model spec, it made sense to drop right into an `it` example. There was a clear "it", the model. In the helper spec, though, we want to set a context of an individual method named "print_numbers". Then within that context we'll write examples of how the method should operation.

We add the context by nesting another `describe` block inside the existing one like this:

```ruby
  require 'spec_helper'

  describe PhoneNumbersHelper do
    describe "print_numbers" do
      # Examples go here
    end
  end
```

Now, inside the inner `describe` block, let's write an example. Name it `outputs a comma-separated list of phone numbers`. Within that example, make two `PhoneNumber` objects, pass them as an array into `print_numbers` and check that the output is the first number, a comma, a space, then the second number. Or, in code...

```ruby
describe "print_numbers" do
  it "should output a comma-separated list of phone numbers" do
    number_a = PhoneNumber.new(number: "1234567")
    number_b = PhoneNumber.new(number: "7654321")
    phone_numbers = [number_a, number_b]
    print_numbers(phone_numbers).should == "1234567, 7654321"
  end
end
```

Run `rake` and the example will fail complaining that the method `print_numbers` doesn't exist. Now you get to implement it!

#### Writing the `print_numbers` helper

This next piece is a bit more challenging: Open the `/app/helpers/phone_numbers_helper.rb` file and add a method named `print_numbers`. It should take in one parameter which is an array of `PhoneNumber` objects, then use `collect` to gather the `number` from each of them. Finally, join the collected numbers by a comma and a space, returning the result.

When you've finished your method, run `rake` and your example should pass.

#### Considering other cases for `print_numbers`

One of the common visual defects on many websites is unnecessary trailing commas. In this example, if we pass an array with just one `PhoneNumber`, will we get back "thenumber" or "thenumber,"?  It had better be the first one, so let's write a test!

Write an example named `"should output just a phone number"` and call `print_numbers`. Your example should include an array of just a single number. Run `rake` and it should succeed. Awesome!

There's a documentation issue, though. The `"should output just a single number"` name only makes sense in the *context* of only one `PhoneNumber` object. It's time to nest a context within your `describe` block.

Refactor your examples to express more reasonable contexts. Here is the final structure with the actual test bodies removed (so you can figure that part on your own):

```ruby
  require 'spec_helper'

  describe PhoneNumbersHelper do
    describe "print_numbers" do
      describe "when there is more than one phone number" do

        it "should output a comma-separated list of phone numbers" do
        end
      end

      context "when there is only one phone number" do

        it "should output a just the phone number" do
        end
      end
    end
  end
```

#### Why Devs Hate Testing Helpers

The presentation layer is probably the most likely to change while an application is being built. We've written great tests that exercise a simple helper, then requirements change.

Now, instead of just a comma separated list, we need to implement an unordered (bullet) list where each number is its own bullet.

Let's start with the tests. In the `"when there is more than one phone number"` context the `before` block still makes sense. The only thing that needs to change is the `.should==` , we need it to equal `"<ul><li>thenumber</li><li>secondnumber</li></ul>"` where `firstnumber` and `secondnumber` are your sample values.

Once that test fails for the right reason, you can try changing the helper itself. Use the `content_tag` helper to generate your `ul` and `li` elements. For example `content_tag :li, "Number1"` would output `<li>Number1</li>`. If you see that your strings are getting escaped, try tacking `.html_safe` onto the end.

Once it's working for the first test you need to deal with the `"should output just the phone number"` test. What should you see when there's just one number?  Implement the test and verify it works.

This process is probably *very frustrating* and that's ok. When you have a robust test suite it can exercise your app better than a full-time QA person. But building them up is not easy.

#### Commit

Your tests should all be passing, so check-in those changes!

### Building a Web-based Workflow

Up to this point we've created phone numbers through the console. Let's build up a web-based workflow.

#### What You Got From Scaffolding

When the scaffold generator ran it gave us a controller and some view templates. Check out the *new* form by loading up `/phone_numbers/new` in your browser.

It's not that bad, but it's not good enough. 

#### Person-centric Workflow

Here's what the customer wants:

_"When I am looking at a single person's page, I click an add link that takes me to the page where I enter the phone number. I click save, then I see the person and their updated information"_

Go back to a person's show page like `/people/1`. Our show page doesn't even list the existing phone numbers. Let's add that in real quick. Use your existing `print_numbers` helper to output the bullet list of the person's numbers.

Then add a link under the list that says *Add a Phone Number* and points to the `new_phone_number_path`. See that the link displays in your browser and try clicking it.

#### Passing in the Person

When you look at the form you'll see the *Person* text field, expecting the user to add the `person_id` manually. Obviously that's ridiculous, let's pass it in from the previous link.

When you write a path like `new_phone_number_path()` you can pass in extra data. Anything you put into the parentheses will be sent as GET-style parameters in the URL. Back on the person's `show` page, let's change the link to it includes the person's ID:

```ruby
<%= link_to "Add a New Phone Number", new_phone_number_path(person_id: @person.id ) %>
```

Go back to the show page in your browser, refresh, and click the link. See how the `person_id` is now embedded in the URL?  We're part way there, but the value isn't in the "Person" text box yet.

#### Utilizing the Person ID Parameter

To make this work, we need to open `app/controllers/phone_numbers_controller.rb` and find the `new` action. By default it's just creating a blank `PhoneNumber` by calling `PhoneNumber.new`. Instead, rewrite the method like this:

```ruby
  def new
    @phone_number = PhoneNumber.new(person_id: params[:person_id])
  end
```

Then refresh your form and the `person_id` should be filled in.

#### Hiding the Person ID Input

Since our user doesn't need to change the `person_id`, we should make it hidden. Open `app/views/phone_numbers/_form.html.haml`. Change the `:person_id` from using `text_field` to `hidden_field`. Refresh the form and the text box will disappear.

You can then rip out the `label` and the paragraph tags.

#### Processing the Form Data

Fill in the form with a phone number and click the save button. It should save then take you to the `PhoneNumber` show page. That's the default scaffold behavior, but our customer wanted to return to the phone number's person's page. Open up `/app/controllers/phone_numbers_controller.rb` and look at the `create` action. When the phone number successfully saves, redirect to the phone number's attached person.

Go back to the form, make another phone number, and you should end up on the person's show page. Test the whole work-flow from clicking the link, entering the number, and arriving back on the show page.

#### Commit

Check those changes into the git repository.

### Editing Numbers

We all make mistakes -- let's make those numbers editable. We can insert a simple edit link next to each number in the bullet list. Should we dive into the helper?

#### Helper vs. Partial

Let's imagine what this helper is going to output when we add the links. It'll have a wrapping UL, then LIs for each phone number which contain both the phone number itself and a link.

We said that helpers are good for computation-style tasks. We're not doing any computation here, and as we add more markup with the links it becomes a bigger and bigger pain to write the helper and the tests.

It's time to pull our helper and replace it with a partial. We'll need a new approach to testing. Let's open the `phone_numbers_helper_spec.rb` and comment the whole thing out. Then go into `phone_numbers_helper.rb` and comment it out too. On a real project, I'd delete each.

#### How do you test partials?

We don't want to lose the value of testing, so we need a way to test the person's show view. We want to see that the rendered HTML has edit links for each phone number along with the number itself.

When we want to test the output HTML we're talking about an *integration test*. My favorite way to build those is using the Capybara gem with RSpec. Let's get Capybara setup by opening your `Gemfile` and adding this line:

```ruby
  gem "capybara"
```

Then run `bundle` from your command line and it'll install the gem.

#### Setup an Integration Test

Create a new folder named `/spec/integration/`. In that folder let's make a file named `people_views_spec.rb`. Then here's how I'd write the examples:

```ruby
  require 'spec_helper'
  require 'capybara/rspec'

  describe "the views for people", type: :request do
    before(:all) do
      @person = Person.create(first_name: "John", last_name: "Doe")
      number_a = @person.phone_numbers.create(number: "1234567")
      number_b = @person.phone_numbers.create(number: "7654321")
    end

    describe "when looking at a single person" do
      before(:all) do
        visit person_path(@person)
      end

      it "should have edit links for each phone number" do        
        @person.phone_numbers.each do |phone_number|
          page.should have_link("edit", href: edit_phone_number_path(phone_number))
        end
      end
    end
  end
```

With that in place, run `rake` and the example should fail as the edit links aren't present.

#### Replacing the Helper with a Partial

Open the `/views/people/show.html.erb` template and replace...

```ruby
  <%= print_numbers(@person.phone_numbers) %>
```

With a call to `render` and a partial...

```ruby
  <%= render partial: 'phone_numbers' %>
```

If you refresh your browser it'll crash because there is no partial named "phone_numbers".

#### Writing a Phone Numbers Partial

Now create a file named `/views/people/_phone_numbers.html.erb`. In that template, render a UL tags that contain LIs for each phone number attached to `person`. The LI should contain the number and a link that has the text "edit" and points to the `edit_phone_number_path` for that phone number.

Check it out in your browser and, when you think it's right, run `rake` and your integration tests should pass.

#### Editing Workflow

Click one of the edit links and you'll jump to the edit form. This form is simplified to just the number because it uses the `/view/phone_numbers/_form.html.erb` that we modified previously.

Change the phone number, click the update button, and the processing will work fine. But it redirects you to the phone number's `show` page. Instead, modify the `phone_numbers_controller.rb` so it redirect's you to that phone number's person's `show` page.

#### Fixing the Index

We were using that helper on the index view, too. Open up `/views/people/index.html.erb` and replace the call to the helper with a call to `render`.

Open the index page in the browser and boom, it'll crash. The partial is expecting to access a session variable `@person`, but that doesn't exist in the index view.

Instead we need to pass in the phone numbers, just like we did with the helper. Here's the Rails 3 way to do it:

```ruby
  <%= render partial: 'phone_numbers', object: person.phone_numbers %>
```

Whatever you pass in as the `object` argument will get assigned to the local variable with the same name as the partial itself. Then in the partial change the iteration line to use that local like this...

```ruby
  <% phone_numbers.each do |phone_number| %>
```

Now the *index* works fine, but the show will be broken. Make similar changes to the `render` call in the *show* template to pass in the phone numbers. Then they should both work.

#### Commit

Check those changes into the git repository.

### Destroying Phone Numbers

Lastly the customer wants a delete link for each phone number. Follow a similar process to...

* Write an example that looks for a delete link for each phone number
* Modify the partial to have that link
* Try it in your browser and destroy a phone number
* Fix the controller to redirect to the phone number's person after destroy

Then, if that's too easy try this *challenge*:

Write an integration test that destroys one of the phone numbers then ensure's that it's really gone from the database. You'll need to use Capybara features like...

* `page.click_link` to activate the destroy link
* `current_path.should ==` to ensure you arrive at the show page
* then check that the object is gone (one idea: verify that there is *no* delete link)

### Phone Numbers are Done...For Now!

Wow, that was a lot of work, right?  Just to list some phone numbers?  Test-Driven Development (TDD) is really slow when you first get started, but after a few years you'll have the hang of it!  I wish I was joking.

#### Let's Ship

Hop over to your command prompt and let's work with git. First, ensure that everything is committed on our branch:

```bash
  git status
  git add .
  git commit -m "Finished implementing phone number functionality"
```

Then this branch is done. Let's go back to the master branch and merge it in:

```bash
  git checkout master
  git merge build_phone_numbers
```

Now it's ready to send to Heroku and run our migrations:

```bash
  git push heroku master
  heroku rake db:migrate
```

Open up your production app in your browser and it should be rockin'!


## I3: Email Addresses

What good is a contact manager that doesn't track email addresses?  We can take most of the ideas from `PhoneNumber` and apply them to `EmailAddress`. This iteration is going to be largely independent because you've seen it all before.

### Start a Feature Branch

Let's practice good source control and start a feature branch:

```bash
  git branch create_email_addresses
  git checkout create_email_addresses
```

Now we're ready to work!

### Writing a Test: A Contact Has Many Email Addresses

In your `person_spec.rb` refer to the existing example "should have an array of phone numbers" and create a similar example for email addresses. Verify that the test fails when you run `rake`.

### Creating the Model

Use the `nifty:scaffold` generator to scaffold a model named `EmailAddress` which has a string field named `address` and an integer field named `person_id`.

By the way, whenever you use the `rails generate` command and mess up, just go up a line in your terminal and change `rails generate` to `rails destroy`, leaving all the other parameters. The files previously generated will be removed.

*Remember* how earlier we commented out the generated `phone_numbers_controller_spec.rb`?  Let's do the same thing with `email_addresses_controller_spec.rb`.

Run `rake db:migrate` then ensure that your test still isn't passing with `rake`.

### Setting Relationships

Open the `Person` model and declare a `has_many` relationship for `email_addresses`. Open the `EmailAddress` model and declare a `belongs_to` relationship with `Person`. 

Now run your tests with `rake` and they should all pass. Since you're green it be a good time to *commit your changes*.

### Adding Model Tests and Validations for Email Addresses

Let's add some quality controls to our `EmailAddress` model.

* Open the `email_address_spec.rb`
* Add a `before` block to create a variable named `@email_address` like we did for `PhoneNumber`
* Modify the example "should be valid" to check that `@email_address` is valid
* Look at the example "is not valid without a first_name" in `person_spec.rb` and create a similar example in `email_address_spec` which makes sure an `EmailAddress` is not valid without an address
* Run rake and make sure it *fails*
* Add a `validates_presence_of` validation for the `address` attribute `EmailAddress`
* Run rake and make sure it *passes*
* Write a test to check that an `EmailAddress` isn't valid unless it has a `person_id`
* Modify your `before` block so it builds off a `Person` object like we did in `phone_number_spec`
* Run rake and make sure it *fails*
* Add a `validates_presence_of` for `:person_id` to the `EmailAddress` model
* Run rake and make sure it *passes*

If you're green, go ahead and check in those changes.

### Completing Email Addresses

Now let's shift over to the integration tests.

#### Displaying Email Addresses

Before you play with displaying addresses, create a few of them manually in the console.

* Open the `people_views_spec.rb`
* Within the single person context, write a test named `"should display each of the email addresses"` that looks for a UL with LIs for each address. Try using this:
```ruby
  page.should have_selector('li', text: email_address.address)
```
* Make sure the test *fails*. If it passes unexpectedly, make sure that your person has one or more email addresses.
* Add a paragraph to the person's `show` template that renders a partial named `email_addresses` which, like `phone_numbers`, renders a UL with LIs for each `EmailAddress`

Tests should be green here, so check in your changes. Then continue...

* Add a new `describe` block to our `people_views_spec` which loads the `index` view
* Write a test checking that the email addresses are displayed
* Verify that it's *failing*
* Render the partial `email_addresses` in the `index` template
* Verify that it's passing

Check in your changes.

#### Create Email Address Link

* Within the single person context, write a test named `"should have an add email address link"` that looks for a link with ID `new_email_address`
* Verify that it *fails*
* Add the link to the `show`
* Verify that it *passes*
* Write a test the clicks the add link, and make sure it goes to the `new_email_address_path`

#### Email Address Creation Workflow

* Create a new integration test file for email addresses. Create a sample person in a `before(:all)` block
* Write a `describe` block for the new email address form
* Visit the new email address form for that person 
* Change the `person_id` field to a `hidden_field`
* Write a test that fills in the form with an address, submits it, and validates that...
  * It gets redirected to the person's show page
  * The show page contains the new email address
  * Verify that it *fails*, then make it *pass*!
  * *TIPS*: Remember to tweak the controller's `new` action to build the new email address with the parameter and the `create` action to redirect to the person's show page

When you're green, check in your changes.

#### Email Address Editing Workflow

Try writing a similar test sequence to exercise the edit functionality:

* Write a new `describe` block for the edit page
* Visit that page
* Change the value in the address field
* Submit it
* Verify that...
  * You get redirected to the person's show page
  * The page displays the edited address

Make it green, then check it in.

#### Email Address Deletion Workflow

Then, finally, deletion:

* In the `describe` block for the show page, write a test proving that there is a delete link for each email address
* See it *fail*, then add the links to the partial and see it *pass*
* Write a test showing that when you click the delete link you end up on the person's `show` page and the email address is gone.
* See it *fail*, then make it *pass*

When you're green, check it in.

### Ship it!

Let's ship this feature:

* Switch back to your master branch with `git checkout master`
* Merge in the feature branch with `git merge create_email_addresses`
* Throw it on Heroku with `git push heroku master`
* Run your migrations with `heroku rake db:migrate`

## I4: Tracking Companies

Our app can track people just fine, but what about companies?  What's the difference between a company and person?  The main one, for now, is that a person has a first name and last name, while a company will just have one name.

### Thinking about the Model

As you start to think about the model, it might trigger your instinct for inheritance. The most common inheritance style in Single Table Inheritance (STI) where you would store both people and companies into a table named *contacts*, then have a model for each that stores data in that table.

STI has always been controversal, and every time I've used it, I've regretted it. For that reason, I ban STI!

Instead we'll build up companies in the most simplistic way: duplicating a lot of code. Once we see where things are duplicated, we'll extract them out and get the code DRY. A robust test suite will permit us be aggressive in our refactoring.

In the end, we'll have clean, simple code that follows _The Ruby Way_.

### Start a Feature Branch

It's always a good practice to develop on a branch:

* `git branch create_companies`
* `git checkout create_companies`

### Starting up the Company Model

Use the `nifty:scaffold` generator to create a `Company` that just has the attribute `name`. After you run the generator, *remember* to comment out or delete the controller tests.

Run `rake db:migrate` to update your database.

Run `rake` to make sure your tests are green, then check your code into git.

### Company Phone Numbers

Then we want to add phone numbers to the companies. We already have a `PhoneNumber` model, a form, and some views. We can reuse much of this...with one problem.

Let's think about the implementation *second* though. Write your tests first.

#### Starting with Model

Open up the `company_spec.rb` and you'll see the generated `"should be valid"` example. Take inspiration from the `person_spec.rb` and...

* Write a `before` block that sets up a `Company`
* Refactor the `"should be valid"` example to test the object created in the `before` block
* Make sure the examples are still passing
* Write an example checking that a `Company` is not valid without a name
* See that it *fails*
* Implement the validation
* See that it *passes*

#### Moving Towards Phone Numbers

Now we're rolling with some tests, so we should just bring *everything* over from *person_spec* to *company_spec*, right?  I wouldn't.

Just bring over and adapt the `"should have an array of phone numbers"` example. Run it and it'll fail.

*Now* we get to think about implementation. To solve this for `Person`, we said that the `PhoneNumber` would `belongs_to` a `Person` and the `Person` would `has_many :phone_numbers`. Try it again here:

* Express the `has_many :phone_numbers` in the `Company` model
* Add a `belongs_to :company` in the `PhoneNumber` model
* Run your examples and they'll *pass*

So we're good -- a `Company` has a method named `phone_numbers` and it returns an array.

#### Wait a Minute...

It should feel like something's not right here. Let's write a new spec that better exercises the relationship.

```ruby
  it "should respond with its phone numbers after they're created" do
    phone_number = @company.phone_numbers.build(number: "2223334444")
    @company.phone_numbers.should include(phone_number)
  end
```

Run that example and it will *fail*, thankfully. The `phone_numbers` method will not find the phone number because the relationships are lying.

When we say that a `PhoneNumber` `belongs_to :company` we imply that the `phone_numbers` table has a column named `company_id`. This is not the case, it has a `person_id` but no `company_id`.

We could add another column for `company_id`, but that would imply that a single number could be attached to one `Person` *and* one `Company`. That doesn't make sense for our contact manager.

What we want to do is to abstract the relationship. We'll say that a `PhoneNumber` `belongs_to` a _contact_, and that _contact_ could be a `Person` or a `Company`.

#### Setup for Polymorphism

Our tests are still red so we're allowed to write code. To implement a polymorphic join, the `phone_numbers` table needs to have the column `person_id` replaced with `contact_id`. Then we need a second column named `contact_type` where Rails will store the class name of the associated contact.

We need a migration. Use `rails generate migration` to create a migration that does the following to the `phone_numbers` table:

* destroy all the existing `PhoneNumbers` with `PhoneNumber.destroy_all`
 * remove the column `person_id`
* add a column named `contact_id` that is an `:integer`
* add a column named `contact_type` that is a `:string`
* in the `down` method, `raise ActiveRecord::IrreversibleMigration`

Then run the migration. Bye-bye, sample phone number data!

#### Build the Polymorphic Relationship

Run your tests and feel comforted by them *BLOWING UP*! If you significantly change your database structure like this and you don't cause a bunch of tests to fail, be concerned about your test coverage.

Let's start with the `Person` model, since that had passing tests before the migration. The current relationship says...

```ruby
  has_many :phone_numbers    
```

We just need to tell the relationship which "polymorphic interface" to use:

```ruby
  has_many :phone_numbers, as: :contact    
```

The tests aren't any better. We need to tell the `PhoneNumber` about the polymorphism too. Change these:

```ruby
  belongs_to :person
  belongs_to :company
```

To this:

```ruby
  belongs_to :contact, polymorphic: true
```

Now the models are properly associated, but my tests still look terrible. Maybe they need some revision.

#### Revising Phone Number Tests

Looking at the `phone_number_spec.rb`, you'll see many references to `Person`. They likely need some tweaking.

I have an example `"should not be valid without a person"` example. That should be rebuilt like this:

```ruby
  it "should not be valid without a contact" do
    @phone_number.contact = nil
    @phone_number.should_not be_valid
  end
```

It still fails because the `validates_presence_of` is looking for a `:person`. Change it to `:contact` and see where the tests stand.

I'm back to almost all green with just two failing tests.

#### Fixing a Person/PhoneNumber Integration Test

I have one integration test failing when it tries to exercise the delete functionality from the person's `show` page. It's failing with...

```bash
  NoMethodError: undefined method `person' for #<PhoneNumber:0x000001046a4000>
  ./app/controllers/phone_numbers_controller.rb:39:in `destroy'  
```

Open up the controller and I find it's the redirect that's crashing. I currently have this:

```ruby
  redirect_to @phone_number.person, notice: "Successfully destroyed phone number."
```

This kind of issue is *why we do TDD*. A human tester is unlikely to have caught this crash, but the automated tests save our butts. It's a simple fix, thanks to Rails' built in redirect intelligence:

```ruby
  redirect_to @phone_number.contact, notice: "Successfully destroyed phone number."
```

Rails will _automatically_ figure out what class type `contact` is and go to the appropriate `show` page for that object.

#### And Finally, Company Phone Numbers

Now there's just one red test, the one that set us down this path: `"Company should respond with its phone numbers after they're created"`.

Open up the `Company` model and change the `has_many :phone_numbers` to reflect the polymorphism.

See *green*, breathe a sigh of relief, and *check-in* your code.

### Integration tests for People

Check out the `people_views_spec.rb` and there are several examples that would apply to companies, too.

Create a `companies_views_spec.rb` and bring over anything related to phone numbers. Refactor the `before` block and copied tests to reflect companies.

#### Implementing Lists, Links, and Partials

After brining over the tests and updating them to exercise `@company`, I have two failures:

* `"the views for companies when looking at a single company should have delete links for each phone number"`
* `"the views for companies when looking at a single company should show the person after deleting a phone number"`

I peek at the web interface, and that's not nearly enough. Other things I'm missing and don't have examples for:

* `"the views for companies when looking at a single company should have an add phone number link"`
* `"the views for companies when looking at a single company should display each of the phone numbers"`

You've got this. Use your existing examples and code to guide you, write these two additional tests, and make all four pass!

And when it's feeling easy...

* `"the views for companies when looking at a single company should show the person including the new number after creating a phone number"`
* `"the views for companies when looking at a single company should show the person including the updated number after editing a phone number"`

You'll need to rebuild the `new` action in `PhoneNumbersController`. Here's how I'd do it:

```ruby
  def new
    if params[:person_id]
      contact = Person.find params[:person_id]
    else
      contact = Company.find params[:company_id]
    end
    @phone_number = contact.phone_numbers.new
  end
```

You'll also run into a *gotcha* with the `PhoneNumber` model. Change the `attr_accesible` line from:

```ruby
  attr_accessible :number, :person_id
```

To this: 

```ruby
  attr_accessible :number, :contact_id, :contact_type
```

That will allow the contact attributes to be set by mass assignment, like we use in the `create` action for `PhoneNumber`.

#### Check It In!

When you've got everything passing and feel good about your coverage, check your code into the git repository.

### Companies and Email Addresses

At this point you should feel comfortable writing both model specs and integration tests. Take the same approach you just used to write model specs for the `Company` related to email addresses.

Implement the polymorphism for `EmailAddress` to make it work, cleaning up any `EmailAddress` tests along the way.

Once you're green, add integration tests for the company's show page to exercise email address functionality. Edit and add to the views and controllers to make it all work.

Here are the steps I took:

* Write specs in `company_spec` to check for the `email_addresses` method and to make sure a newly inserted email address is included in the list -- Result: *2 red*
* Add the `has_many` relationship for `:email_addresses` to `Company` -- Result: *green*??
* Added a line to my `"should respond with its email addresses after they're created"`: `@company.should be_valid` -- Result: *1 red*
* Generate a migration `change_email_addresses_to_relate_to_polymorphic_contacts`
* Edit the migration to look almost exactly like the one for phone numbers, then `rake db:migrate` -- Result: *14 red*
* Open `EmailAddress` and change the `attr_accessible`, `belongs_to` and `validates_presence_of` to reflect `contact` -- Result: *14 red*
* Refactor `"should not be valid without a person"` in `email_address_spec` to `"should not be valid without a contact"` -- Result: *13 red*
* Open `person.rb` and update the `has_many :email_addresses` for the polymorphism -- Result: *5 red*
* Switch the `before` block in `company_spec.rb` to use `create` so it'll have an ID to help with associated objects -- Result: *4 red*
* Update `/app/views/email_addresses/_form.html.erb` to use the `contact_id` and `contact_type` -- Result: *3 red*
* Change the redirect in `email_addresses_controller#destroy` from `@email_address.person` to `@email_address.contact` -- Result: *2 red*
* Do the same thing in `email_addresses_controller#update` -- Result: *1 red*
* Rebuild the `email_addresses_controller#new` to handle both `person_id` and `company_id` parameters, like we did in `phone_numbers_controller#new` -- Result: *1 red*
* Change the redirect in `phone_numbers_controller#create` to go to the `contact` -- Result: *green*

That's TDD for you. Now before you take a nap, take a look at the web interface. Specifically the `show` view of a company. More work to do...

* Open `companies_views_spec.rb` and uncomment/adapt the email address tests I had brought over from `person_views_spec.rb` -- Result: *6 red*
* Create a partial `/app/views/companies/_email_addresses.html.erb`, copy everything from the similar partial under `people` -- Result: *6 red*
* Create an email display block in `views/companies/show.html.erb` rendering that partial -- Result: *3 red*
* Create the new email link on the company show page -- Result: *1 red*
* Open `views/companies/index.html.erb` and add a column for email addresses, rendering the same partial -- Result: *green*
* Realize there should be an integration test checking that the companies index lists the phone numbers, write it -- Result: *1 red*
* Edit the companies `index` view to display the `phone_numbers` partial -- Result: *green*
* In the end, I've got 42 green examples.

Poke around in the web interface and I think we've got everything working.

### Ship It

* You're green, so check in your code to the feature branch.
* Switch back to your master branch and merge in your feature branch. If your forget the branch's name, try `git branch` to list them.
* Push it to Heroku
* Run your migrations
* ...
* Profit!

## I5: Removing Code

Russ Olsen, in his book "Eloquent Ruby," has a great line: _"The code you don't write never stops working."_

Our app has entirely too much code. It works, so we can't call it "bad," but we can up the code quality and drop the maintenance load by refactoring.

*Refactoring* is the process of taking working code and making it work better. That might mean reducing complexity, isolating dependencies, removing duplication -- anything that leaves the external functionality the same while cleaning up the internals. In my opinion, the art of refactoring is the difference between people who write computer programs and people who are programmers. But there's a catch to refactoring...

_"Don't change anything that doesn't have [good test] coverage, otherwise you aren't refactoring -- you're just changing [stuff]."_

Our app has solid test coverage since most of it was written through TDD. That coverage gives us permission to refactor.

### Start a feature branch

You're on your `master` branch. Create an check out a branch named `removing_code` where we'll make all our changes.

### Helper Hitlist

Running the generators is great, but they create a lot of code. There are several files we can delete right away.

One thing you'll see in many Rails projects is a `helpers` folder full of blank files. One of the things I hate about helpers is the naming convention from the generators is to create one helper for each model. Instead, you most often want your helper files grouping related functions, like a `TimeAndDateHelper` or `CurrencyHelper`.

Many developers get tricked into thinking helper classes should be tied to models and every model should have a helper class. That's simply not true.

Look through the helpers folder and delete any that don't have any methods. Even the `PhoneNumbersHelper` with its `print_numbers` method -- we're not using the helper anymore so let's delete the whole file.

Run your tests and, if you're green, check in the changes. To make sure git removes deleted files, use this:

```bash
  git add -A .
```

### Revising Controllers

Open up the `phone_numbers_controller.rb`. There are all the default actions here. Do we ever `show` a single phone number?  Do we use the index to view all the phone numbers separate from their contacts?  No. So let's delete those actions.

#### Implementing a Before Filter

The remaining `edit`, `update`, and `destroy` methods all start with the same line. That's not very *DRY*. We can take advantage of Rails' `before_filter` system to execute a piece of code before each action is triggered.

There are a couple opinions on how to implement `before_filters`, here's the way I think you should do it. Up at the top of the controller, just after the `class` line, add this:

```ruby
  before_filter :lookup_phone_number
```

Then go down to the bottom of the controller file. We want to add a `private` method to the controller like this:

```ruby
  private
    def lookup_phone_number
      @phone_number = PhoneNumber.find(params[:id])
    end
```

Note that `private` doesn't have an `end` line. Any method defined after the `private` keyword in a Ruby class will be private to instances of that object. Then within the `lookup_phone_number` method we just have the same line that was common to the three actions. *Delete* the line from the three actions and run your tests.

Some of them should *fail*. Look at the error messages and backtrace to see the issue.

#### Scoping a Before Filter

This `lookup_phone_number` method is being run before every action in the controller, but we only removed the line from `update`, `edit`, and `destroy`. When the `new` action is executed this line is raising and exception because there is no `params[:id]` data.

We want this before filter to only run for certain actions. Go back to the top of the controller and change...

```ruby
  before_filter :lookup_phone_number
```

...to run only for the listed actions...

```ruby
  before_filter :lookup_phone_number, only: [:edit, :update, :destroy]
```

Or, you can even use the reverse logic:

```ruby
  before_filter :lookup_phone_number, except: [:new, :create]
```

Run your tests and they should be *passing*.

#### Continuing the Before Filters

You can use the exact same pattern to implement `before_filter` actions in...

* `companies_controller`
* `people_controller`
* `email_addresses_controller`

Go do those now and make sure your tests are still green. If the controller uses the `show` method, then it's probably much shorter to use the `except` syntax on the `before_filter`.

#### Removing Blank Controller Actions?

As you remove the lookup line from actions like `edit`, it's likely that your action is now totally blank. You can, then, remove the method from the controller. The `before_filter` will still be activated and the view template renders so things will work great.

But I don't think it's worth the developer cost. Not having the method in the file then having it work in the app is *confusing*. I'd recommend you just leave the stub.

#### Playing with `ApplicationController`

Did you notice that all those controllers inherit from `ApplicationController`?  We've now got a private method in each controller that's almost exactly the same. Could we condense them all into one method in the parent class?

Here's what the method would have to do:

* Figure out which controller called the method
* Figure out the model name for that controller
* Run the find action of that model
* Store it into an instance variable with the right name (like `@person` or `@company`)

It's a bit of metaprogramming that took me some experimenting, and here's what I ended up with in my `ApplicationController`:

```ruby
  def find_resource
    class_name = params[:controller].singularize
    klass = class_name.camelize.constantize
    self.instance_variable_set "@" + class_name, klass.find(params[:id])
  end
```

Then I call that method from `before_filter` lines in each controller. The `before_filter` call could be pulled up here, but I think that makes the individual controllers too opaque.

#### Removing Unused Views for EmailAddresses and PhoneNumbers

We pulled out controller methods for both our `phone_numbers` and `email_addresses` controllers, hop over to their view folders and delete any unnecessary views.

Run your tests and make sure they're still passing. If you're green, *check in your code*. 

### Removing Model Duplication

If you look at the `Person` and `Company` models you'll see there are two lines exactly duplicated in each:

```ruby
  has_many :phone_numbers, as: :contact  
  has_many :email_addresses, as: :contact  
```

Essentially each of these models shares the concept of a "contact," but we decided not to go down the dark road of STI. Instead, we should abstract their common code into a module. Right now it's only two lines, but over time the common code will likely increase. The module will be the place for common code to live.

There are many opinions about where modules should live in your application tree. In this case we're going to create a `Contact` module and it's almost like a model, so let's drop the file right into the models folder.

* Create a file `/app/models/contact.rb`
* In it, define a module like this:

```ruby
  module Contact
    
  end
```

* Move the two `has_many` lines from the `Person` model into that `module`
* In their place within the `Person`, add this line:

```ruby
  include Contact
```

Run your tests and everything will be broken. When we write a module we need to distinguish between three types of code:

* code that should be run in the containing class when the module is included
* methods that should be defined on the including class (like Person.first)
* methods that should be defined for instances of the including class (like Person.first.name)

The normal Ruby syntax to accomplish these jobs is a little ugly. In Rails 3 there's a new feature library that cleans up the implementation of modules. We use it like this:

```ruby
  module Contact
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
```

Any code defined inside the `included` block will be run on the class when the module is included. Any methods defined in the `ClassMethods` submodule will be defined on the including class. And methods defined in the `InstanceMethods` submodule will be attached to instances of the class.

Where should your two `has_many` lines go?  Figure it out on your own and use your tests to prove that it works. When you're *green*, check it in.

### Cutting Down View Redundancy

Do you remember copying and pasting some view code?  I told you to do it, so don't feel guilty. 

#### Relocating the Phone Numbers Partial

If you look in `views/companies/_phone_numbers.html.erb` you'll find the *exact* same code as in `views/people/_phone_numbers.html.erb`.

Here's how to remove the duplication:
* Move the phone numbers partial from the companies folder to the `views/phone_numbers/` folder
* Run your tests and they should freak out -- I had 14 examples go red
* Open both the `views/companies/index.html.erb` and `views/companies/show.html.erb`. Each of them renders the partial. You just need to change this:

```ruby
  <%= render partial: "phone_numbers", object: company.phone_numbers %>
```

To have the folder in the partial name like this:

```ruby
  <%= render partial: "phone_numbers/phone_numbers", object: company.phone_numbers %>
```

That should bring you back to green. Then...

* Delete the `_phone_numbers.html.erb` partial from the `people` folder
* See the tests go red
* Update the `render` calls in the `index` and `show` views
* See the tests go green

#### Relocating the Email Addresses Partial

Then repeat the exact same process for the email addresses partial.

#### Check It In

If your tests are green, check in the code and remember to use the `-A` flag on your `add` so git removes the deleted files.

### Simplifying Views

Our views have a ton of markup in them and the output is *ugly*!  Let's cut it down.

#### Companies & People Index

Open the `views/companies/index.html.erb` and...

* change the `<table>` tag to `<div class='companies'>`
* change the closing `table` tag to match the `div`
* delete the whole row with the headings
* The `for x in y` style of iteration is less preferred. Rewrite it with `companies.each do |company|`
* Change the `tr` open and close tags to div tags with the class name `"company"`
* Change the `td` surrounding the company name to an `h4`
* Remove the `td` tags around the two partials
* Turn the three `td` elements with the "Show", "Edit", and "Destroy" links into list items inside a `ul` with the class name `actions`
* Add the id `"new_company"` to the link for the new company page

Run your tests and everything should be green. We dramatically changed the markup, but our tests still run fine. Good integration tests aren't bound too closely to the HTML, they focus on content and functionality -- not tags.

Now go through the *same process* for `views/people/index.html.erb` just using the word `person` instead of `company` where appropriate. Also combine the first name and last name into a single `h4`.

If everything is green then check it in.

#### Company & Person Show

Let's make a similar set of changes to `views/companies/show.html.erb`...

* Change the `title` line so it uses the name of the company
* Remove the paragraph with the company name
* String the phone numbers paragraph down so it just renders the partial
* Do the same for the email addresses
* Change the actions so they're inside `li` tags inside a `ul` with the class name `"actions"`
* Wrap the whole view in a div with class name `"company"`

Run your tests and they should be green. Then, *repeat the process* for `views/people/show.html.erb`

When you're green, check it in.

#### Company & Person Edit

Just a few small changes to the `edit` template:

* Change the `title` so it uses the name of the company/person
* Change the links and the bottom to be wrapped in `li` tags inside a `ul` with classname `"actions"`

### PhoneNumber & Email Address New/Edit

Open the `email_addresses/new.html.erb` and change the `title` line from

```ruby
  <% title "New Email Address" %>
```

To this:

```ruby
  <% title "New Email Address for #{@email_address.contact}" %>
```

View it in your browser and...what is that?  You probably see something like this:

```bash
  New Email Address for #<Person:0x00000103226e70>
```

That person-like thing is what you get when you call the `to_s` method on an object that doesn't have a `to_s`. This is the version all objects inherit from the `Object` class.

#### Testing a `to_s` Method

We want to write some code in our models, but we don't have permission to do that without a failing test. Pop open the `person_spec.rb` file. Then add an example like this:

```ruby
  it "should convert to a string with last name, first name" do
    @person.to_s.should == "Doe, John"
  end  
```

The value on the right side will obviously depend on what value you setup in the `before` block. Run the test and it'll go red.

#### Implementing a `to_s`

Now you get to open `models/person.rb` and define a `to_s` method like this:

```ruby
  def to_s
    "#{last_name}, #{first_name}"
  end
```

That should make your test pass. Go through the same process writing a test for the `to_s` of `Company` then implementing the `to_s` method.

#### Did It Work?

Flip over to your browser and you'll see that the `title` on the new email address page should look much better. It isn't making a test go green, though, and that makes me feel guilty. We've knowingly spent time implementing untested code.

Let's write a quick integration test. In the `email_addresses_views_spec` we have a context `"when looking at the new email address form"`. Within that, add this example:

```ruby
  it "should show the contact's name in the title" do
    page.should have_selector("h1", text: "#{@person.last_name}, #{@person.first_name}")
  end
```

It'll pass because you've already implemented the `to_s` in `person.rb`. Try a little _"Comment Driven Development"_:

* Comment out the `to_s` method in `person.rb`
* Run the test and see it *fail*
* Un-comment the `to_s`
* See it *pass*!

Now in that same integration spec, you have a context named `"when looking at the edit email address form"`. Implement a similar example there checking for the contact's name in the `h1`, then change the view template to make it work.

#### More Form Tests & Tweaks

Implement the same technique on...

* the `new` template for phone numbers
* the `edit` template for phone numbers

You probably want to create a `phone_numbers_views_spec.rb` and write the integration tests there before changing the view templates.

While you're in there, I'm sure you'll be tempted to write more integration tests for your phone numbers. Use the "Comment Driven Development" style to create the red/green cycle.

#### Making Use of the `to_s` Method

Lastly, consider searching your other views and simplifying calls to `@company.name` or `@person.first_name` with `@person.last_name` to just use the implicit `to_s`.

### Write Less Markup

Writing HTML by hand is not so fun and mixing in ERB only makes it more frustrating. To be honest with you, I hate writing ERB. Let's check out an alternative templating language named HAML.

HAML was created as a response to this question: "If we adopt whitespace a significant and assume we're outputting HTML, what can we NOT write?"  HAML uses indentation hierarchy to substitute for open/close tags and generally means writing significantly fewer characters on each template.

#### Get HAML Installed

Open up your `Gemfile`, add the dependency on the `"haml"` gem, save it and run `bundle` from the command prompt. Restart your web server so it loads the new library.

#### Refactor a View

Let's see the difference by rebuilding an existing view. Open up your `views/companies/index.html.erb`. Create a second file in the same directory named `views/companies/index.html.haml`.

My ERB template looks like this:

```ruby
  <% title "Companies" %>

  <div class="companies">
    <% @companies.each do |company| %>
      <div class="company">
        <h4><%= company.name %></h4>
        <%= render partial: 'email_addresses/email_addresses', object: company.email_addresses %>
        <%= render partial: 'phone_numbers/phone_numbers', object: company.phone_numbers %>
        <ul class="actions">
          <%= link_to "Show", company %>
          <%= link_to "Edit", edit_company_path(company) %>
          <%= link_to "Destroy", company, confirm: 'Are you sure?', method: :delete %>
        </ul>
      </div>
    <% end %>
  </div>

  <p><%= link_to "New Company", new_company_path %></p>
```

Copy that code and paste it into your new `.haml` page and we'll strip it down. If your ERB template is properly indented like that, then the hard work is done for you. Here's how we manually convert it to HAML:

* Remove all close ERB tags `%>`
* Change all outputting ERB tags `<%=` to just `=`
* Change all non-printing ERB tags `<%` to just `-`
* Remove any lines that just contain a Ruby `end`
* Remove all closing HTML tags like `</ul>`, `</div>`, etc
* Change open HTML tags from using greater than and less than like `<h4>` to just a leading percent like `%h4`
* If those elements have a CSS class, write it in CSS style like `%div.companies`
* And `div` is the default tag, so you can write `<div class="companies">` as just `.companies`

Now you've got HAML!  Rewriting my template reduced it from 657 bytes to 540 bytes, from 71 words down to 53 words. That's a good savings since they output the exact same thing. Run your tests and everything should be cool.

Here's my completed `index.html.haml` for reference.

```ruby
  - title "Companies" 

  .companies
    - @companies.each do |company| 
      .company
        %h4= company.name
        = render partial: 'email_addresses/email_addresses', object: company.email_addresses 
        = render partial: 'phone_numbers/phone_numbers', object: company.phone_numbers 
        %ul.actions
          = link_to "Show", company 
          = link_to "Edit", edit_company_path(company) 
          = link_to "Destroy", company, confirm: 'Are you sure?', method: :delete 

  %p= link_to "New Company", new_company_path
```

Go ahead and *delete* the old ERB template. You don't have to rebuild existing templates unless you want to, but we'll build things in HAML moving forward.

### Ship It

We're done with this iteration and your tests are green -- it's time to ship it. 

Make sure everything's checked in on your feature branch, `checkout` master, `merge` in the branch, then `push` it to Heroku. Check out the results in your browser. Look at the beauty of those minus signs and many deleted files.

## I6: Supporting Users

What's the point of a web application if only one person can use it?  Let's make our system support multiple users. There are three pieces to making this happen:

* *Authentication* - Establish identity
* *Ownership* - Attach data records to user records
* *Authorization* - Control who is allowed to do what

### Background on Authentication

There have been about a dozen popular methods for authenticating Rails applications over the past five years. 

The most popular right now is "Devise":https://github.com/plataformatec/devise because it makes it very easy to get up and running quickly. The downside is that the implementation uses very aggressive Ruby and metaprogramming techniques which make it very challenging to customize.

In the past I've been a fan of "AuthLogic":https://github.com/binarylogic/authlogic because it takes a very straightforward model/view/controller approach, but it means you have to write a lot of code to get it up and running.

As we learn more about constructing web applications there is a greater emphasis on decoupling components. It makes a lot of sense to depend on an external service for our authentication, then that service can serve this application along with many others.

### Why OmniAuth?

The best application of this concept is the "OmniAuth":https://github.com/intridea/omniauth. It's popular because it allows you to use multiple third-party services to authenticate, but it is really a pattern for component-based authentication. You could let your users login with their Twitter account, but you could also build our own OmniAuth provider that authenticates all your companies apps. Maybe you can use the existing LDAP provider to hook into ActiveDirectory or OpenLDAP, or make use of the Google Apps interface?

Better yet, OmniAuth can handle multiple concurrent strategies, so you can offer users multiple ways to authenticate. Your app is just built against the OmniAuth interface, those external components can come and go.

### Starting a Feature Branch

Before we start writing code, let's create a branch in our repository. Here's a one-liner to create a branch and check it out:

```bash
  git checkout -b adding_authentication
```

Now you're ready to write code.

### Getting Started with OmniAuth

The first step is to add the dependency to your `Gemfile`:

```ruby
  gem "omniauth"
```

Then run `bundle` from your terminal.

OmniAuth runs as a "Rack Middleware" which means it's not really a part of our app, it's a thin layer between our app and the client. To instantiate and control the middleware, we need an initializer. Create a file `/config/initializers/omniauth.rb` and add the following:

```ruby
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :twitter, "EZYxQSqP0j35QWqoV0kUg", "IToKT8jdWZEhEH60wFL94HGf4uoGE1SqFUrZUR34M4"
  end
```

What is all that garbage?  Twitter, like many API-providing services, wants to track who's using it. They accomplish this by distributing API accounts. Specifically, they use the OAuth protocol which requires a "comsumer key" and a "consumer secret."  If you want to build an application using the Twitter API you'll need to "register and get your own credentials":https://dev.twitter.com/apps. For this tutorial, I've registered a sample application and given you my key/secret above.

### Trying It Out

You need to *restart your server* so the new library and initializer are picked up. In your browser go to `http://127.0.0.1:8080/auth/twitter` and, after a few seconds, you should see a Twitter login page. Login to Twitter using any account, then you should see a *Routing Error* from your application. If you've got that, then things are on the right track.

If you get to this point and encounter a *401 Unauthorized* message there is more work to do. You're probably using your own API key and secret. You need to go into the "settings on Twitter for your application":https://dev.twitter.com/apps/, and add `http://127.0.0.1` as a registered callback domain. I also add `http://0.0.0.0` and `http://localhost` while I'm in there. Now give it a try and you should get the *Routing Error*

### Handling the Callback

The way this authentication works is that your app redirects to the third party authenticator, the third party processes the authentication, then it sends the user back to your application at a "callback URL". Twitter is attempting to send the data back to your application, but your app isn't listening at the default OmniAuth callback address, `/auth/twitter/callback`. Let's add a route to listen for those requests.

Open `/app/config/routes.rb` and add this line:

```ruby
  match '/auth/:provider/callback', to: 'sessions#create'
``` 

Re-visit `http://localhost:8080/auth/twitter`, it will process your already-existing Twitter login, then redirect back to your application and give you *Uninitialized Constant SessionsController*. Our router is attempting to call the `create` action of the `SessionsController`, but that controller doesn't exist yet.

### Creating a Sessions Controller

Let's use a generator to create the controller from the command line:

```bash
  rails generate controller sessions
```

Then open up that controller file and add code so it looks like this:

```ruby
  class SessionsController < ApplicationController
    def create
      render text: debug request.env["omniauth.auth"]
      debugger
    end
  end
```

Revisit `/auth/twitter` and, once it redirects to your application, you should see a bunch of information provided by Twitter about the authenticated user!  Now we just need to figure out what to *do* with all that.

### Creating a User Model

Even though we're using an external service for authentication, we'll still need to keep track of user objects within our system. Let's create a model that will be responsible for that data. 

As you saw, Twitter gives us a ton of data about the user. What should we store in our database?  The minimum expectations for an OmniAuth provider are three things:

* *provider* - A string name uniquely identifying the provider service
* *uid* - An identifying string uniquely identifying the user within that provider
* *name* - Some kind of human-meaningful name for the user

Let's start with just those three in our model. From your terminal:

```bash
  rails generate model User provider:string uid:string name:string
```

Then update the database with `rake db:migrate`.

### Creating Actual Users

How you create users might vary depending on the application. For the purposes of our contact manager, we'll allow anyone to create an account automatically just by logging in with the third party service.

Hop back to the `SessionsController`. I believe strongly that the controller should have as little code as possible, so we'll proxy the User lookup/creation from the controller down to the model like this:

```ruby
  def create
    @user = User.find_or_create_by_auth(request.env["omniauth.auth"])
  end
```
 
Now the `User` model is responsible for figuring out what to do with that big hash of data from Twitter. Open that model file and add this method:

```ruby
  def self.find_or_create_by_auth(auth_data)
    user = self.find_or_create_by_provider_and_uid(auth_data["provider"], auth_data["uid"])
    if user.name != auth_data["user_info"]["name"]
      user.name = auth_data["user_info"]["name"]
      user.save
    end    
    return user
  end
```

To walk through that step by step...
* Look in the users table for a record with this provider and uid combination. If it's found, you'll get it back. If it's not found, a new record will be created and returned
* Compare the user's name and the name in the auth data. If they're different, either this is a new user and we want to store the name or they've changed their name on the external service and it should be updated here. Then save it.
* Either way, return the user

Now, back to `SessionsController`, let's add a redirect action to send them to the `companies_path` after login:

```ruby
  def create
    @user = User.find_or_create_by_auth(request.env["omniauth.auth"])
    redirect_to companies_path, notice: "Logged in as #{@user.name}"
  end
```

Now visit `/auth/twitter` and you should eventually be redirected to your Companies listing and the flash message at the top will show a message saying that you're logged in.

### UI for Login/Logout

That's exciting, but now we need links for login/logout that don't require manually manipulating URLs. Anything like login/logout that you want visible on every page goes in the layout.

Open `/app/views/layouts/application.html.erb` and you'll see the framing for all our view templates. Let's add in the following *just below the flash messages*:

```ruby
  <div id="account">
    <% if current_user %>
      <span>Welcome, <%= current_user.name %></span>
      <%= link_to "logout", logout_path, id: "login" %>
    <% else %>
      <%= link_to "login", login_path, id: "logout" %>
    <% end %>
  </div>
```

If you refresh your browser that will all crash for several reasons.

### Accessing the Current User

It's a convention that Rails authentication systems provide a `current_user` method to access the user. Let's create that in our `ApplicationController` with these steps:

* Underneath the `protect_from_forgery` line, add this: `helper_method :current_user`
* Just before the closing `end` of the class, add this:

```ruby
  private
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end  
```

By defining the `current_user` method as private in `ApplicationController`, that method will be available to all our controllers because they inherit from `ApplicationController`. In addition, the `helper_method` line makes the method available to all our views. Now we can access `current_user` from any controller and any view!

Refresh your page and you'll move on to the next error, `undefined local variable or method `login_path'`.

### Convenience Routes

Just because we're following the REST convention doesn't mean we can't also create our own named routes. The view snipped we wrote is attempting to link to `login_path` and `logout_path`, but our application doesn't yet know about those routes.

Open `/config/routes.rb` and add two custom routes:

```ruby
  match "/login" => redirect("/auth/twitter"), as: :login
  match "/logout" => "sessions#destroy", as: :logout  
```

The first line creates a path named `login` which just redirects to the static address `/auth/twitter` which will be intercepted by the OmniAuth middleware. The second line creates a `logout` path which will call the destroy action of our `SessionsController`.

With those in place, refresh your browser and it should load without error.

### Implementing Logout

Our login works great, but we can't logout!  When you click the logout link it's attempting to call the `destroy` action of `SessionsController`. Let's implement that.

* Open `SessionsController`
* Add a `destroy` method
* In the method, erase the session by setting `session[:user_id] = nil`
* Redirect them to the `root_path` with the notice `"Goodbye!"`
* Define a `root_path` in your router like this: `root to: "companies#index"`

Now try logging out and you'll probably end up looking at the Rails "Welcome Aboard" page. Why isn't your `root_path` taking affect?

If you have a file in `/public` that matches the requested URL, that will get served without ever triggering your router. Since Rails generated a `/public/index.html` file, that's getting served instead of our `root_path` route. Delete the `index.html` file from `public`, and refresh your browser.

*NOTE*: At this point I observed some strange errors from Twitter. Stopping and restarting my server, which clears the cached data, got it going again.

### Testing...?

We haven't written tests for login/logout. Here are some excuses:

* OmniAuth is tested already, so we don't need to test its functionality
* The code added to our app is relatively simple
* Handling the external service integration in our test suite is challenging

Let's make a mental note that we want to try writing tests for the authentication parts of our app later and move on. We'll get some pieces of it going in the next iteration.

### Ship It

Hop over to a terminal and `add` your files, `commit` your changes, `merge` the branch, and `push` it to Heroku.

## I7: Adding Ownership

We've got users, but they all share the same contacts. That, obviously, won't work. We need to rethink our data model to attach contacts to a `User`. It'd be tempting to add a `user_id` column to every table in our database, but let's see if that's really necessary.

### Back Into Testing

Let's start with some tests. Open up `user_spec.rb` and add this example:

```ruby
  it "should have associated people" do
    @user.people.should be_instance_of(Array)
  end  
```

If you run `rake` that test will fail because there is no `user` setup. We'll need a `before` block.

### Setting up a Factory

So far each of our test files has been making the objects it'll need for the tests. If now decide that a `Person` had a required attribute of `title`, we'd have to update several spec files to create the objects properly.

This duplication makes our tests more fragile than they should be. We need to introduce a factory.

The most common libraries for test factories are "FactoryGirl":https://github.com/thoughtbot/factory_girl and "Machinist":https://github.com/notahat/machinist. Each of them has hit a rough patch of maintenance, though, which guided me towards a third option.

Let's use "Fabrication":https://github.com/paulelliott/fabrication which is more actively maintained. Open up your `Gemfile` and add a dependency on `"fabrication"` in the test/development environment. Run `bundle` to install the gem.

We can also change the behavior of Rails generators to create fabrication patterns instead of normal fixtures. Open up `/config/application.rb`, scroll to the bottom, and just below the `javascript_expansions` add this block:

```ruby
  config.generators do |g|
    g.test_framework      :rspec, fixture: true
    g.fixture_replacement :fabrication
  end  
```

### Using Fabrication

Now we need to make our fabricator. Create a folder `/spec/fabricators/` and in it create a file named `user_fabricator.rb`. In that file add this definition:

```ruby
  Fabricator(:user) do
    name "Sample User"
    provider "twitter"
    uid {Fabricate.sequence(:uid)}
  end
```

Then go back to `user_spec.rb` and add this `before` block:

```ruby
  before(:each) do
    @user = Fabricate(:user)
  end
```

Now `rake` your tests and it should fail for the reason we want -- that `people` is undefined for a `User`.

### Testing Associations

Open your `User` model and express a `has_many` relationship to `people`. Run `rake` and your example will still fail because it's looking for a `user_id` column on the people table. We'll need to add that.

Generate a migration to add the integer column named "user_id" to the people table. Run the migration, run your examples again, and they should pass.

#### Working on the Person

Let's take a look at the `Person` side, so open the `person_spec.rb`. First, let's refactor the `before` block to use a Fabricator. Create the `/spec/fabricators/person_fabricator.rb` file and add this definition:

```ruby
  Fabricator(:person) do
    first_name "John"
    last_name "Doe"
  end  
```

Then in the `before` block of `person_spec`, use the fabricator like this:

```ruby
  before(:each) do
    @person = Fabricate(:person)
  end  
```

Run `rake` and make sure the examples are still passing.

#### Testing that a Person Belongs to a User

Add an example checking that the `@person` is the child of a `User`. Run `rake` and see it fail. 

Then add the `belongs_to` association in `Person`, run the tests, and see if they pass.

My test looks like this:

```ruby
  it "should be the child of a User" do
    @person.user.should be_instance_of(User)
  end
```

This is really testing two things: that the person responds to the method call `user` and that the response is a `User`. My test is failing because the response is `nil`.

#### Revising the Person Fabricator

We need to work more on the fabricator. When we create a `Person`, we need to attach it to a `User`. It's super easy because we've already got a fabricator for `User`. Open the `person_fabricator.rb` and add the line `user!` so you have this:

```ruby
  Fabricator(:person) do
    first_name "John"
    last_name "Doe"
    user!
  end
```

Now when a `Person` is fabricated it will automatically associate with a user. Run `rake` and your tests should pass.

#### More From the User Side

Let's check that when a `User` creates `People` they actually get associated. Try this example in `user_spec`:

```ruby
  it "should build associated people" do
    person_1 = Fabricate(:person)
    person_2 = Fabricate(:person)
    [person_1, person_2].each do |person|
      @user.people.should_not include(person)
      @user.people << person
      @user.people.should include(person)
    end
  end
```

Run `rake` and it'll pass because we're correctly setup the association on both sides.

#### Now for Companies

Write a similar test for companies:

```ruby
  it "should build associated companies" do
    company_1 = Fabricate(:company)
    company_2 = Fabricate(:company)
    [company_1, company_2].each do |company|
      @user.companies.should_not include(company)
      @user.companies << company
      @user.companies.should include(company)
    end
  end
```

Run `rake` and it'll fail for several reasons. Work through them one-by-one until it's passing. Here's how I did it:

* Create a `Fabricator` for `Company` similar to the one for `Person`
* Create a migration to add `user_id` to the companies table
* Add the `belongs_to :user` association for `Company`
* Add the `has_many :companies` association for `User`

With that, the tests should pass.

### Refactoring the Interface

The most important part of adding the `User` and associations is that when a `User` is logged in they should only see their own contacts. How can we ensure that?

#### Writing an Integration Test

Let's write integration tests to challenge this behavior. Create a new context within `"the views for people"` in `people_views_spec.rb` like this:

```ruby
  describe "when logged in as a user" do
    before(:all) do
      @user = Fabricate(:user)
    end
  end
```

Then within that context we can check that they see their people:

```ruby
  it "should display people associated with this user" do
    @person_1 = Fabricate(:person)
    @user.people << @person_1
    visit(people_path)
    page.should have_link(@person_1.to_s)
  end
```

Run that and it should pass.

#### The Negative Case

Now let's make sure they don't see other user's contacts. Here's an example that should work. 

```ruby
  it "should display not display people associated with another user" do
    @user_2 = Fabricate(:user)
    @person_2 = Fabricate(:person)
    @user_2.people << @person_2
    visit(people_path)
    page.should_not have_link(@person_2.to_s)
  end
```

We create a second user, attach them to a second person, then visit the listing. Run `rake` and this test will fail because the index is still showing *all* the people in the database.

#### Scoping to the Current User

Open up the `PeopleController` and look at the `index` action. It's querying for `Person.all`, but we want it to only display the people for `current_user`. Change the action so it looks like this:

```ruby
  def index
    @people = current_user.people
  end
```

Then run `rake` and you'll find your test is crashing because `current_user` is `nil`. Our tests aren't logging in, so there is no `current_user`.

#### Faking a Login

We need to have our tests "login" to the system. We don't want to actually connect to the login provider, we want to mock a request/response cycle. 

Here's one way to do it. Create a folder `/spec/support` if you don't have one already. In there create file named `omniauth.rb`. In this file we can define methods that will be available to all specs in the test suite. Here's how we can fake the login:

```ruby
  def login_as(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:twitter] = {
        "provider" => user.provider,
        "uid" => user.uid,
        "user_info" => {"name"=>user.name}
    }  
    visit(login_path)
  end
```

Now we can call the `login_as` method from any spec, passing in the desired `User` object, then the system will believe they have logged in.

#### Building More Fabricators

We're working towards a refactoring of the integration tests. Let's build up some fabricators that they'll use.

`email_address_fabricator.rb`

```ruby
  Fabricator(:email_address) do
    address "sample@sample.com"
  end
```

`phone_number_fabricator.rb`

```ruby
  Fabricator(:phone_number) do
    number "2223334444"
  end
```

`person_fabricator.rb`

```ruby
  Fabricator(:person) do
    first_name "John"
    last_name "Doe"
    user!
  end

  Fabricator(:person_with_details, from: :person) do
    email_addresses!(count: 2){|person, i| Fabricate(:email_address, address: "sample_#{i}@sample.com", contact: person)}
    phone_numbers!(count: 2){|person, i| Fabricate(:phone_number, number: "#{i.to_s*10}", contact: person)}
  end
```

`user_fabricator.rb`

```ruby
  Fabricator(:user) do
    name "Sample User"
    provider "twitter"
    uid {Fabricate.sequence(:uid)}
  end

  Fabricator(:user_with_people, from: :user) do
    people!(count: 3){|user, i| Fabricate(:person, first_name: "Sample", last_name: "Person #{i}", user: user) }
  end

  Fabricator(:user_with_people_with_details, from: :user) do
    people!(count: 3){|user, i| Fabricate(:person_with_details, first_name: "Sample", last_name: "Person #{i}", user: user) }
  end
```

#### Refactoring `people_views_spec`

Now that we want to scope down to just people attached to the current user we'll need to make some changes to `people_views_spec`. Here is the structure we want for these tests. I've removed the example bodies, but you have most of them built already. Reorganize them to fit into this structure.

```ruby
  require 'spec_helper'
  require 'capybara/rspec'

  describe "the views for people", type: :request do
    describe "when logged in as a user" do
      before(:all) do
        @user = Fabricate(:user_with_people_with_details)
        login_as(@user)
      end

      describe "when looking at the list of people" do
        before(:each) do
          visit people_path
        end

        it "should display people associated with this user"
        it "should not display people associated with another user"
      end

      describe "when looking at a single person" do
        before(:each) do
          @person = @user.people.first
          visit person_path(@person)
        end

        it "should have delete links for each email address"
        it "should have an add email address link"
        it "should go to the new email address form when the link is clicked"
        it "should display each of the email addresses"
        it "should have edit links for each phone number"
        it "should have delete links for each phone number"
        it "should show the person after deleting a phone number"
        it "should show the person after deleting an email address"
      end
    end
  end
```

### And Now, Companies

You've done good work on people, but now we need to scope companies down to just the logged in user and refactor the tests as necessary.

Follow the same processes and go to it!

### Breathe, Ship

That was a tough iteration but thinking about the tests helped up find the trouble spots. If your tests are *green*, check in your code, `checkout` the master branch, `merge` your feature branch, and ship it to Heroku!
