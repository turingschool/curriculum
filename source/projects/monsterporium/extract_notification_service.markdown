---
layout: page
title: Extract Notification Service
sidebar: true
---

## Introduction

We'll take an existing project, the Monsterporium store, and extract the notification system to an external, asyncronous service.

### Goals

Through this extraction process you'll learn:

* How Pub/Sub messaging is used to communicate across applications
* A model for writing a service in plain Ruby
* How to semi-automatically test emails with Mailcatcher
* How to refactor and build while keeping the tests green

### Setup

If you don't already have the Monsterporium and Redis installed, hop over to [the installation instructions]({% page_url projects/monsterporium/setup %}).

## Getting Started with The Monsterporium

The Monsterporium is a student project written by students in our gSchool course for their [StoreEngine project assignment](http://tutorials.jumpstartlab.com/projects/store_engine.html). It's an online store that supports listing products and placing orders. Along the way it sends a few emails.

### Where Emails Come From

There are two emails that get sent to customers, both defined in
`app/mailers/mailer.rb`. They're called from:

* `UsersController#create`
* `OrdersController#create`
* `OrdersController#buy_now`

When creating a `User` or `Order` resource...

* The request comes in from the client with the necessary data in the request parameters
* The `User` or `Order` is created
* The email is sent
* The HTTP response is sent back to the user

The problem here is that sending the email is unnecessarily slowing down the request/response cycle. Instead, the app should post a **message** telling the email service that an email needs to be sent.

### Where We're Going

When we we finish the extraction the system will work like this:

#### In the Primary Application

* The request comes in from the user
* The resource is created
* A message is posted to the message channel (Redis)
* The creation-successful response is sent back to the user

#### In the Secondary Application

* The listener waits until it sees a message on the channel
* When a message is found, it
  * pulls in and parses the data
  * dispatches the email

## Characterizing Functionality

We'll use a semi-automated test harness to check that emails are actually
sent, and that they have the right contents.

### Running Existing Tests

Run the tests to make sure everything starts out green:

{% terminal %}
$ rake
{% endterminal %}

### Breaking the Mailer Tests

Open `app/mailers/mailer.rb` and:

* On line 5, change `@user = user` to `@user = User.new(:full_name => "John Doe")`
* On line 11, change `@order = order` to `@order = Order.new`

Now re-run the tests. Which examples fail?

Unfortunately the failures don't tell us what's actually *wrong* with the emails, and
don't even tell us if the emails were sent.

We need better tests!

### Introducing Mailcatcher

Mailcatcher is a great little app that acts as an SMTP host, the protocol used to send email. It offers a web app that makes it easy to see what emails were "sent" (and really caught) by our tests.

We don't need to put it in the Gemfile, just install the gem from the terminal and start it up:

{% terminal %}
$ gem install mailcatcher
$ mailcatcher
{% endterminal %}

### Configuring Action Mailer

Action Mailer is the component of Rails that handles email. We need to configure it to use mailcatcher as the SMTP server.

In *both* `config/environments/development.rb` and `config/environments/test.rb`, add the following lines inside the `do`/`end` block:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = { :address => "127.0.0.1", :port => 1025 }
```

That *should* work, but unfortunately when running the test suite Action Mailer overrides the `delivery_method`, despite it being defined in the test environment file.

We need to override the override.

### `mailer_spec.rb`

#### Overriding the `delivery_method`

Open `spec/mailers/mailer_spec.rb` and add this before block after the ```describe Mailer do``` line:

```ruby
before(:each) do
  ActionMailer::Base.delivery_method = :smtp
end
```

#### Expectations

Since we're going to manually inspect the emails, the specs in this file should not have any expectations -- they'll never fail.

Delete the `expect` line from both specs.

### Tests & Results

Now everything is in place.

* Run the tests from the terminal
* Open the [mailcatcher web interface at http://localhost:1080](http://localhost:1080)
* Eyeball the caught emails and you should see the problems we intentionally introduced earlier
* Revert the changes in `mailer.rb` so the emails will now work properly
* Clear the messages in mailcatcher (button in the top right of the web interface)
* Run the specs again

### Emails in OrdersController Specs

Let's also capture the emails that get sent during integration tests.

Open `spec/controllers/orders_controller_spec.rb`. There are two specs that send out email:

* `create fails to create an order...`
* `buy_now fails to create an order...`

Use the same technique we did the the mailer spec to send these emails to mailcatcher. There are no expectations here about email, so don't delete the expectations that are there.

### Testing the Welcome Email

There are currently no controller tests that create a user and trigger the welcome email. In general, running feature specs is very slow. So instead of changing
`spec/features/anon_user_creates_account_spec.rb` to deliver to mailcatcher,
let's create a controller spec that triggers the email.

In `spec/controllers/users_controller_spec.rb` add this spec:

```ruby
describe "#create" do
  it "sends an email" do
    data = {
      full_name: 'Alice Smith',
      email: 'alice@example.com',
      display_name: 'alice',
      password: 'poet',
      password_confirmation: 'poet'
    }
    post :create, user: data
  end
end
```

Confusingly, we don't need to override `ActionMailer::Base.delivery_method` here. In controller specs, Rails respects the settings in the environment file.

### Putting It All Together

Now re-run the whole test suite, pop open mailcatcher, and you should see ten emails appear. Verify their contents.

We've successfully "characterized" the existing functionality and can begin refactoring.

## Pushing Logic Down the Stack

To get ready to extract the service we need to improve the structure of the code itself. When MVC is well implemented, it's easy. But the current app has some issues that are common in Rails applications:

### Simplifying `Mailer#order_confirmation`

Open `mailer.rb` and look at the `order_confirmation` method. Right now it takes two distinct parameters: `user` and `order`. But `order` is related to `user` through an ActiveRecord relationship.

* Change the mailer to access the user through the order
* Remove the user parameter
* Remove `current_user` from the mailer calls on `OrdersController` lines 23 and 37
* Remove `user` from `mailer_spec` line 17

Run the specs and confirm that things are still passing and the emails show up in mailcatcher.

### Decoupling the Controllers and Mailers

Currently the controllers communicate with the mailers by sending rich objects.

In general, software components should send and receive as little data as possible to get their jobs done. This is especially true as we move towards services which will use JSON to serialize and deserialize data.

But *where* in the application will we pull out the relevant pieces of data from the objects? In the middle of a controller? That's no good as controller methods often grow out of control. In the mailer? That's too late, the big object has already been passed in.

We need a layer between the controller and mailer which is responsible for pulling the necessary data and sending it into the mailer. Think of it as a proxy or shim. Let's build those new objects into the system.

#### Creating `PurchaseConfirmation`

Let's create a new class in `app/models/purchase_confirmation.rb`:

```ruby
class PurchaseConfirmation
  def self.create(order)
    Mailer.order_confirmation(order).deliver
  end
end
```

#### Using `PurchaseConfirmation` in `OrdersController`

Change `OrdersController` to use `PurchaseConfirmation.create` instead of talking to `Mailer` directly.

#### Creating `SignupConfirmation`

Create a new class in `app/models/signup_confirmation.rb`:

```ruby
class SignupConfirmation
  def self.create(user)
    Mailer.welcome_email(user).deliver
  end
end
```

#### Using `SignupConfirmation` in `UsersController`

Change `UsersController` to use `SignupConfirmation.create`.

#### Verify

Clear mailcatcher, then run the specs and make sure everything still works.

### Refactoring the Welcome Email

Look at `Mailer#welcome_email`. It takes in a user object, but what data does it actually *use*? Look both in the method body and the associated `welcome_email.html.erb`.

Rather than send in the whole object, the method could work just as well with a hash that contains the two key/value pairs.

#### Changing the Spec

The first step is to open `mailer_spec` and change the `sends a welcome email` spec. We can still create a user with the factory, but instead of passing that object into `welcome_email`, send a hash with the data that the mailer needs.

Open up the view template for the welcome email. What data does the template need? Then take a look at the `Mailer` itself. What does the mailer require?

The hash might look like this:

```ruby
{name: "John Doe", email: "john@example.com"}
```

Run just that spec and see it fail:

{% terminal %}
$ rspec spec/mailers/mailer_spec.rb
Run options: exclude {:acceptance=>true, :performance=>true}

Mailer
  sends a welcome email (FAILED - 1)
  sends an order confirmation email

Failures:

  1) Mailer sends a welcome email
     Failure/Error: email = Mailer.welcome_email(params).deliver
     NoMethodError:
       undefined method `email' for {:name=>"John Doe", :email=>"john@example.com"}:Hash
     # ./app/mailers/mailer.rb:6:in `welcome_email'
     # ./spec/mailers/mailer_spec.rb:12:in `block (2 levels) in <top (required)>'

Finished in 0.91668 seconds
2 examples, 1 failure

Failed examples:

rspec ./spec/mailers/mailer_spec.rb:9 # Mailer sends a welcome email
{% endterminal %}

#### Changing `Mailer#welcome_email`

Now go to the `welcome_email` method and rewrite it to expect a hash coming in with keys `"name"` and `"email"`. Remember to rework the view template, too.

**Note**: Pretty soon that hash is going to be going through a JSON parsing. When it comes back from the JSON library, the keys will all be strings. So we might as well use strings for the keys now to avoid surprises later.

Run the spec, but it should still be failing.

#### Changing `SignupConfirmation`

We don't need to change anything about `UsersController`, which is the point of having the layer of abstraction between the mailer and the controller.

Instead, we just need to make a change to `SignupConfirmation`. Within the `create` method, construct a hash with the `"name"` and `"email"` keys. Then pass that hash into the mailer.

Run the spec and make sure it's back to passing. Run the whole suite and it should be passing, too.

**Tip:** If you're running into failures because of calling `titleize` on `nil`, your name is not getting through to the view template. Make sure that you used the string hash keys everywhere, including the spec.

### Refactoring the Purchase Confirmation Email

Go through nearly the same process to rework the email sent when a purchase is confirmed.

* Revise the spec in `mailer_spec.rb` to create a hash and pass it into the mailer. Here's one option for building the hash:

```
data = {
  "name" => "Alice Smith",
  "email" => "alice@example.com",
  "items" => [
    {
      "title" => "Li Hing Mui Lollypops",
      "quantity" => 3
    }
  ],
  "total" => 12.00
}
```

* Run the spec and see it fail
* Rework `Mailer#order_confirmation` and the view template
* Run the mailer spec and see it pass
* Run the full suite and it should fail:

```plain
Failures:

  1) OrdersController create fails to create an order without a stripeToken
     Failure/Error: post :create
     ActionView::Template::Error:
       undefined method `each' for nil:NilClass
     # ./app/views/mailer/order_confirmation.html.erb:6:in `_app_views_mailer_order_confirmation_html_erb___162722226973004525_70262093155400'
     # ./app/mailers/mailer.rb:11:in `order_confirmation'
     # ./app/controllers/orders_controller.rb:23:in `create'
     # ./spec/controllers/orders_controller_spec.rb:10:in `block (3 levels) in <top (required)>'

  2) OrdersController buy_now fails to create an order without a stripeToken
     Failure/Error: post :buy_now, order: product.id
     ActionView::Template::Error:
       undefined method `each' for nil:NilClass
     # ./app/views/mailer/order_confirmation.html.erb:6:in `_app_views_mailer_order_confirmation_html_erb___162722226973004525_70262093155400'
     # ./app/mailers/mailer.rb:11:in `order_confirmation'
     # ./app/controllers/orders_controller.rb:37:in `buy_now'
     # ./spec/controllers/orders_controller_spec.rb:20:in `block (3 levels) in <top (required)>'
```

* The `OrdersController` is still accessing `Mailer` directly. Change it to use `PurchaseConfirmation` in two places.
* Run that `orders_controller_spec.rb` and it'll still fail
* Build the data hash in `PurchaseConfirmation.create` and pass it in to the mailer
* Run the controller spec and it should pass
* Clear mailcatcher's queue
* Run the full suite and it should pass
* Check the emails in mailcatcher and see that they're ok

## Working with the Pub/Sub Channel

### Configuring Redis

We want to run separate Redis databases for development, test, and production.

Create a directory `config/redis`. We'll add two configuration files for Redis itself:

For the development environment add the following to `config/redis/development.conf`:

```plain
# config/redis/development.conf
daemonize yes
port 6382
logfile ./log/redis_development.log
dbfilename ./db/development.rdb
```

For the test environment add the following to `config/redis/test.conf`:

```plain
daemonize yes
port 6383
logfile ./log/redis_test.log
dbfilename ./db/test.rdb
```

### Redis within Rails

Include the `redis` gem in the `Gemfile`, and bundle install.

We need to get Rails to start redis. Create an initializer file in `config/initializers/redis.rb`:

```ruby
file = File.join("config", "redis", "#{Rails.env}.conf")
path = Rails.root.join(file)
config = File.read(path)

`redis-server #{path}`

running = `ps aux | grep [r]edis-server.*#{file}`

if running.empty?
  raise "Could not start redis"
end

port = config[/port.(\d+)/, 1]
$redis = Redis.new(:port => port)
```

### Checking It Out

First, start a rails console, and call `$redis.inspect`. It should give you back a reference to the Redis instance.

Then, open IRB in a second terminal window and subscribe to a test channel:

{% terminal %}
$ require 'redis'
$ redis = Redis.new(port: 6382)
$ redis.subscribe("test_channel") do |event|
    event.message do |channel, body|
      puts "I heard [#{body}] on channel [#{channel}]"
    end
  end
{% endterminal %}

In the Rails console, publish a message:

{% terminal %}
$ $redis.publish("test_channel", "the message")
{% endterminal %}

### Publish the Email Message

The actual messaging will take place in the `PurchaseConfirmation` and `SignupConfirmation` objects. We'll set it up so that:

* When an email needs to be sent, publish a message to Redis
* The existing `Mailer` functionality remains

We'll use a channel named `"email_notifications"`. 

### A Temporary Listener

Open up IRB and subscribe to the channel on the port we configured for the test environment:

{% terminal %}
$ require 'redis'
$ redis = Redis.new(port: 6383)
$ redis.subscribe("email_notifications") do |event|
    event.message do |channel, body|
      puts "[#{channel}] #{body}"
    end
  end
{% endterminal %}

### Sending a Message

Publish the email data to the notification channel in `PurchaseConfirmation.create`.

```ruby
message = {"type" => "purchase_confirmation", "data" => data}
$redis.publish("email_notifications", message.to_json)
```

Run `orders_controller_spec.rb` and make sure that:

1. mailcatcher receives all the emails
2. the subscriber in IRB receives the messages

#### Messages from `SignupConfirmation`

Now implement the message posting in the `SignupConfirmation` object, then run the tests and confirm both the messages are posted and the emails delivered.

### In-App Listener

Now let's build a `lib/notifications.rb` with that same listener code:

```ruby
require 'redis'
redis = Redis.new(port: 6383)
redis.subscribe("email_notifications") do |event|
  event.message do |channel, body|
    puts "[#{channel}] #{body}"
  end
end
```

Then start the file with `rails runner lib/notifications.rb`. We'll use the `runner` command for now to load all the dependencies for us.

Run the controller tests and verify both the output of the listener and the emails in mailcatcher.

### Sending Emails from the Listener

In that listener, instead of a meaningless `puts` statement, it's time to actually send the emails.

* Fetch the body of the message
* Parse the body from JSON into a Ruby hash
* Determine what kind of email needs to be sent
* Call the appropriate `Mailer` method and send in the data

#### Double-Sending Email

Run `rspec spec/controllers/orders_controller_spec.rb`

Did you get **four emails** in mailcatcher? If so, that's working.

Run `rspec spec/controllers/users_controller_spec.rb`

Did you get **two more emails**? Then you're ready to move on.

#### Removing the Direct Email

Comment out the line in `PurchaseConfirmation` and `SignupConfirmation` that triggers the email delivery. 

Run `rspec spec/controllers` and verify that they all pass and a total of only *three* emails are delivered.

Then delete the commented out lines in the `Confirmation` classes.

## Writing a Stand-Alone Notification Service

We don't need all of Rails to send emails. We can create a small, stand-alone
Ruby project that listens to the Redis channel and sends emails when events
arrive.

### Project Structure

We'll call this project `notifications`, but in real life we
would probably be named by going to [wordoid.com](http://wordoid.com) and
finding something clever-sounding.

We'll start with an idiomatic Ruby project
structure where any real library code will end up namespaced under
`Notifications`.

{% terminal %}
$ tree notifications
notifications/
├── Gemfile
├── README.md
├── Rakefile
├── lib
│   ├── notifications
│   └── notifications.rb
└── test
.   ├── notifications
.   └── test_helper.rb
{% endterminal %}

### Dependencies

We're going to use...

* `pony` to send emails
* `redis` to subscribe to the messages from the primary application
* `minitest` for testing

#### Creating a Gemfile

The `Gemfile` looks like this:

```ruby
source 'https://rubygems.org'

gem 'pony'
gem 'redis'

group :test do
  gem 'minitest', require: false
end
```

With that in place, run `bundle`.

### Setup for Testing

Let's create a rake task that will run all our tests. In the `Rakefile` in the project root:

```ruby
$:.unshift File.expand_path("./../lib", __FILE__)

require 'rake/testtask'

Rake::TestTask.new do |t|
  require 'bundler'
  Bundler.require
  t.pattern = "test/**/*_test.rb"
end

task default: :test
```

### Getting Everything Wired Together

Create a `test/notifications_test.rb` and add the following:

```ruby
require './test/test_helper'

class NotificationsTest < Minitest::Test
  def test_wired_together
    assert_equal 42, Notifications.answer
  end
end
```

#### First Try

Run the test with `rake`.

You'll probably get a NameError `uninitialized constant`.

Open up `test/test_helper.rb` and add:

```ruby
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride' # optional, but makes everything better
```

The `gem 'minitest'` line tells the code to use the minitest gem rather than
the minitest that is in the Ruby standard library. The gem version is newer and better.

#### Second Try

Run `rake` again, and you'll get another NameError: `uninitialized constant
NotificationsTest::Notifications`.

Open up `lib/notifications.rb` and create a `module` named `Notifications`.

#### Third Try

Run `rake` again.

We've forgotten to require the file we need in the test.
Let's just require the whole `notifications` library. It's going to be tiny.

Add the following to the `test/test_helper.rb`:

```ruby
require 'notifications'
```

#### Fourth Try

Run `rake`.

It complains that it can't find the file. Put the following line at
the top of the test helper to put `lib` on the load path:

```ruby
$:.unshift File.expand_path("./../../lib", __FILE__)
```

#### Fifth Try

Run `rake` again, and finally we get the correct error: _undefined method
'answer'_.

Make the test pass.

We'll delete it later, when we have some real code and tests.

### Creating Emails

Let's start by creating a very simple email class that takes the data
that we will be getting from redis, and sends an email using Pony. Pony is a lightweight alternative to ActionMailer that's great for sending mail from non-Rails applications.

#### Test-Driving Email

For the moment, we will not worry about sending production emails, we'll
configure the entire project to send to mailcatcher.

Add this to `lib/notifications.rb`:

```ruby
Pony.options = {
  :from => 'noreply@example.com',
  :via => :smtp,
  :via_options => {:address => "localhost", :port => 1025}
}
```

First we'll create a light wrapper around Pony called `Email`.

Here's `test/notifications/email_test.rb`:

```ruby
require './test/test_helper'

class EmailTest < Minitest::Test
  def data
    {
      "name" => "Alice Smith",
      "email" => "alice@example.com"
    }
  end

  def test_recipient
    assert_equal "alice@example.com", Notifications::Email.new(data).to
  end

  def test_subject
    assert_equal "Fake Subject", Notifications::Email.new(data).subject
  end

  def test_body
    assert_equal "Fake Body", Notifications::Email.new(data).body
  end

  def test_ship_it
    Notifications::Email.new(data).ship # verify in mailcatcher
  end
end
```

In order to get it to pass, you'll need to create a `lib/notifications/email.rb` file, and add some require statements to `lib/notifications.rb`:

```ruby
require 'pony'
require 'notifications/email'
```

Then fill in Email until the tests pass. The `ship` method is what actually
delegates to `Pony`. It looks like this:

```ruby
def ship
  Pony.mail(to: to, subject: subject, body: body)
end
```

Once a proper email arrives in `mailcatcher`, it's time to flesh out the
actual emails.

#### A Model for Mail

All emails are going to have different subjects and different bodies. Right
now we've hard-coded "Fake Subject" and "Fake Body" into the Email class,
which isn't a very helpful solution.

We want all the common behavior to be defined in Email, and we want to
override this behavior in each of the specific emails.

We'll use inheritance for this.

#### Inheriting Common Behavior

The common behavior is currently:

* the email address that the email will be shipped to
* the `ship` method that actually dispatches the email

We're going to need a `FakeEmail` class that inherits from Email. Stick it at
the top of the test file, since no other code in the project needs it.

At the top of the test file, add this:

```ruby
class FakeEmail < Notifications::Email
end
```

Now change the assertion for the `to` method to look like this:

```ruby
assert_equal "alice@example.com", FakeEmail.new(data).to
```

The test should pass.

Change the test that sends an email to mailcatcher to also use this new
FakeEmail:

```ruby
FakeEmail.new(data).ship # verify in mailcatcher
```

It should still work.

#### The Email Subject

Rather than hard-coding fake behavior into Email, let's change the test to
expect an exception to be raised if someone calls `subject` without first
overriding the behavior:

```ruby
def test_subject_must_be_overridden
  assert_raises Notifications::SubclassMustOverride do
    Notifications::Email.new({}).subject
  end
end
```

Define a custom Error in `lib/notifications/email.rb`:

```ruby
module Notifications
  class SubclassMustOverride < StandardError; end

  class Email
    # ...
  end
end
```

Then, to get the test to pass, replace the hard-coded subject with an
exception:

```ruby
module Notifications
  class Email
    # ...
    def subject
      raise SubclassMustOverride.new("Implement `subject` in the subclass, please.")
    end
    # ...
  end
end
```

Create a new test for the subject of the FakeEmail:

```ruby
def test_subject
  assert_equal "Fake stuff", FakeEmail.new(data).subject
end
```

Run the test, and you'll get an error asking you to implement `subject`.

Do so:

```ruby
class FakeEmail < Notifications::Email
  def subject
    "Fake stuff"
  end
end
```

#### The Email Body

The body is more complicated. We don't want a hard-coded string, we want to
evaluate an ERB template.

Create a fake template in `test/fixtures/fake.erb`:

```erb
Oh, look: KITTENS!
```

Now change the `test_body` to call the `FakeEmail` rather than the
`Notifications::Email`:

```ruby
def test_body
  assert_equal "Oh, look: KITTENS!", FakeEmail.new(data).body
end
```

And now, here's the code that will make this work:

```ruby
class FakeEmail
  # ...
  def body
    ERB.new(template).result binding
  end

  def template
    File.read(template_path)
  end

  def template_path
    File.join("./test/fixtures/fake.erb")
  end
end
```

The test is **almost** passing. The whitespace at the end of the template
doesn't matter, let's just get rid of it:

```ruby
def test_body
  assert_equal "Oh, look: KITTENS!".chomp, FakeEmail.new(data).body.chomp
end
```

And with that, the email should pass.

#### Moving the common behavior into `Email`

We don't want to have to implement all the ERB rendering for every email that
we implement.

What is custom to the Fake email?

* the template name `fake.erb`
  ... or at least the `fake` part.
* the template location `./test/fixtures`
  production emails will be in some default location

So let's separate out those pieces of information:

```ruby
class FakeEmail
  # ...
  def body
    ERB.new(template).result binding
  end

  def template
    File.read(template_path)
  end

  def template_path
    File.join(template_dir, "#{template_name}.erb")
  end

  def template_dir
    "./test/fixtures"
  end

  def template_name
    "fake"
  end
end
```

The test should still be passing. Now we can move the common behavior into the
Email class itself.

The FakeEmail keeps the `template_dir` and the `template_name`:

```ruby
class FakeEmail
  # ...
  def template_dir
    "./test/fixtures"
  end

  def template_name
    "fake"
  end
end
```

The Email class gets `body`, `template`, and `template_path`:

```ruby
class Email
  # ...
  def body
    ERB.new(template).result binding
  end

  def template
    File.read(template_path)
  end

  def template_path
    File.join(template_dir, "#{template_name}.erb")
  end
end
```

Now FakeEmail has two methods that Email doesn't have:

* template_name
* template_dir

#### Overriding Template Name

All emails need a custom template name, but if we subclass Email and forget to
implement `template_name` the error message that we'll get is not very
helpful: a `NoMethodError`.

It would be more helpful if the Email class raised an exception saying that
the subclass has to implement it:

```ruby
def test_template_name_must_be_overridden
  assert_raises Notifications::SubclassMustOverride do
    Notifications::Email.new({}).template_name
  end
end
```

The code to get this to pass is similar to the one for `subject`:

```ruby
def template_name
  raise SubclassMustOverride.new("Implement `template_name` in the subclass, please.")
end
```

#### Providing a default `template_dir`

We don't yet know what the production directory for templates is.

Add an empty `template_dir` in the `Email` class for now, and we'll get back
to it.

#### Custom Data in the Templates

We can't just have hard-coded templates, we want to be able to interpolate
things like the customer's name and the things that they've purchased.

Change the `test/fixtures/fake.erb` to send the message `stuff`:

```erb
Oh, look: <%= stuff %>!
```

The value for `stuff` will need to come from the `data` hash that the email
gets initialized with. Add a key `"stuff"` to the `data` hash in the tests:

```ruby
def data
  {
    "name" => "Alice Smith",
    "email" => "alice@example.com",
    "stuff" => "KITTENS",
  }
end
```

Only the `FakeEmail` class knows about this custom data. Create a method that
reads it from the data hash:

```ruby
class FakeEmail
  def stuff
    data["stuff"]
  end
end
```

We are assuming that the original hash gets stored in the initialize method of
`Email` as `@data` and is exposed with an `attr_reader`.

The test should still pass.

## Implementing the Purchase Confirmation Email

Now that `Email` has all of the common setup, creating the Purchase
Confirmation email will be a lot more straight-forward.

### Writing the Tests

Create a new test, `test/notifications/email/purchase_confirmation.rb`, and repeat some of the same patterns as above:

```ruby
require './test/test_helper'

class PurchaseConfirmationTest < Minitest::Test
  def data
    {
      "name" => "Alice Smith",
      "email" => "alice@example.com",
      "items" => [
        {
          "title" => "Li Hing Mui Lollypop",
          "quantity" => 3
        }
      ],
      "total" => 12.00
    }
  end

  attr_reader :email
  def setup
    @email = Notifications::PurchaseConfirmation.new(data)
  end

  def test_subject
    assert_equal "Thanks for your purchase!", email.subject
  end

  def test_body
    body = <<-BODY
Dear Alice Smith,

Thanks so much for your purchase of:


  3 x Li Hing Mui Lollypop


We've processed your payment for $12.00.

We hope you stop by again!
Frank's Monsterporium
    BODY
    assert_equal body.chomp, email.body.chomp
  end
end
```

The `.chomp` helps us ignore a bit of whitespace sensitivity between the rendered view template and the "heredoc" in the tests.

### Building the Template

First, make a directory `lib/notifications/email/templates`.

Then copy `app/views/mailer/order_confirmation.html.erb` from the *primary project*
to `lib/notifications/email/templates/purchase_confirmation.erb`. Strip out the HTML from the template so we're just dealing with plain text for now.

In `lib/notifications/email.rb` file, define a `template_dir` method as well as a `require` statement to load the `PurchaseConfirmation`:

```ruby
module Notifications
  class SubclassMustOverride < StandardError; end

  class Email
    # ...

    def template_dir
      './lib/notifications/email/templates'
    end
  end
end

require 'notifications/email/purchase_confirmation'
```

### Implementing `PuchaseConfirmation` Model

With all the wiring in place, open create a `PurchaseConfirmation` that passes all the tests.

## Building the Signup Confirmation Email

Go through the same process for the signup confirmation email:

* Write tests to define your expectations
* Build the email template
* Implement the model

This time around, consider definining the expected email in an external text file rather that in the test directly. Figure out how to load the body of the file from the test and compare it with the template's output.

## Listening to Redis

Our email system is built, now we need to watch the message channel.

### A Stub Listener

Create a new file `lib/listener.rb`:

```ruby
require 'redis'
redis = Redis.new(port: 6383)

redis.subscribe("email_notifications") do |event|
  event.message do |channel, body|
    puts "[#{channel}] #{body}"
  end
end
```

Run it with `ruby lib/listener.rb`

For the moment we're hard-coding the port. Later we would want to be able to
pass the port when we start the file.

`ruby lib/listener.rb -p 6382`

Run the order controller tests and the user controller tests in the *primary
app*. You should see the Redis messages in the output from your listener.

### Listener Sends Emails

In the `listener.rb`, we need to implement JSON parsing and a bit of switching depending on what kind of email is being sent:

```ruby
$:.unshift File.expand_path("./../../lib", __FILE__)
require 'notifications'
require 'json'
require 'redis'
redis = Redis.new(port: 6383)

redis.subscribe("email_notifications") do |event|
  event.message do |channel, body|
    puts body
    body = JSON.parse(body)
    case body["type"]
    when "purchase_confirmation"
      Notifications::PurchaseConfirmation.new(body["data"]).ship
    when "signup_confirmation"
      Notifications::SignupConfirmation.new(body["data"]).ship
    end
  end
end
```

* Double-check that the listeners in the *primary app* are **not** running anymore. Then fire this one up with `ruby lib/listener.rb`.
* Run the orders controller / users controller tests in the primary app
* Check mailcatcher for the emails and, if they show up, you're in business!

## Deleting Code!

Perhaps the most fun part of the whole exercise, in the primary app you can now delete:

* `lib/notifications.rb`
* `app/mailers/mailer.rb`
* `app/views/mailers/order_confirmation.html.erb`
* `app/views/mailers/welcome_email.html.erb`

In the end we have a more focused external application with significantly better test coverage and depth, fewer dependencies, and a more focused scope.
