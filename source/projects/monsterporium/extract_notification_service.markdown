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

Before we get to work we need to setup a few pieces. We're assuming that you [already have Ruby 1.9.3 or 2.0]({% page_url environment %}).

#### Redis

You'll need Redis installed and running on your system. On OS X with homebrew, it's as easy as:

{% terminal %}
$ brew install redis
{% endterminal %}

Then test it by starting up the redis command line interface:

{% terminal %}
$ redis-cli
redis 127.0.0.1:6379> exit
{% endterminal %}

#### Redis Gem

Install the Redis gem from Rubygems:

{% terminal %}
$ gem install redis
{% endterminal %}

Then test it from IRB:

{% terminal %}
$ irb
001 > require 'redis'
 => true 
002 > r = Redis.new
 => #<Redis client v3.0.4 for redis://127.0.0.1:6379/0> 
003 > r.set("hello", "world")
 => "OK" 
004 > r.get("hello")
 => "world" 
005 > exit
{% endterminal %}

#### Clone the Monsterporium

You can see the [store_demo repository on Github](https://github.com/jumpstartlab/store_demo) and clone it like this:

{% terminal %}
$ git clone git@github.com:JumpstartLab/store_demo.git
{% endterminal %}

Then hop in and get ready to go:

{% terminal %}
$ cd store_demo
$ bundle
$ rake db:migrate db:test:prepare
$ rake
{% endterminal %}

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

Open `spec/mailers/mailer_spec.rb` and add this before block:

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

The first step is to open `mailer_spec` and change the `sends a welcome email` spec. We can still create a user with the factory, but instead of passing that object into `welcome_email`, send a hash with the two necessary.

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
       undefined method `email' for {:full_name=>"Alice Smith", :email=>"alice@example.com"}:Hash
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

```plain
# config/redis/development.conf
daemonize yes
port 6382
logfile ./log/redis_development.log
dbfilename ./db/development.rdb
```

```plain
# config/redis/test.conf
daemonize yes
port 6383
logfile ./log/redis_test.log
dbfilename ./db/test.rdb
```

#### Redis within Rails

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

#### Checking It Out

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

#### A Temporary Listener

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

#### Sending a Message

Publish the email data to the notification channel in `PurchaseConfirmation.create`.

```ruby
message = {"type" => "purchase_confirmation", "data" => data}
$redis.publish("email_notifications", message.to_json)
```

Run `orders_controller_spec.rb` and make sure that:

1. mailcatcher receives all the emails
2. the subscriber in IRB receives the messages

#### Then `SignupConfirmation`

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

#### Sending Emails from the Listener

In that listener, instead of a meaningless `puts` statement, it's time to actually send the emails.

* Fetch the body of the message
* Parse the body from JSON into a Ruby hash
* Determine what kind of email needs to be sent
* Call the appropriate `Mailer` method and send in the data

#### Double-Sending Email

Run `rspec spec/controllers/orders_controller_spec.rb`

Did you get four emails in mailcatcher? If so, that's working.

Run `rspec spec/controllers/users_controller_spec.rb`

Did you get two more emails? Then you're ready to move on.

#### Removing the Direct Email

Comment out the line in `PurchaseConfirmation` and `SignupConfirmation` that triggers the email delivery. 

Run `rspec spec/controllers` and verify that they all pass and a total of only *three* emails are delivered.

Then delete the commented out lines in the `Confirmation` classes.

## Writing a stand-alone notification service

We don't need all of rails to send emails. We can create a small, stand-alone
Ruby project that listens to the Redis channel and sends emails when events
arrive.

### Project Structure

We'll just call this project `notifications`, but in real life we
would probably be named by going to [wordoid.com](http://wordoid.com) and
finding something clever-sounding.

We'll start with an idiomatic ruby project
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
    ├── notifications
    └── test_helper.rb
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

#### Setup for Testing

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
that we will be getting from redis, and sends an email using Pony.

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
    assert_equal "some subject", Notifications::Email.new(data).subject
  end

  def test_body
    assert_equal "some body", Notifications::Email.new(data).body
  end

  def test_ship_it
    Notifications::Email.new(data).ship # verify in mailcatcher
  end
end
```

In order to get it to pass, you'll need to add some require statements to
`lib/notifications.rb`:

```ruby
require 'pony'
require 'notifications/email'
```

The `ship` method in `Email` looks like this:

```ruby
def ship
  Pony.mail(to: to, subject: subject, body: body)
end
```

We're going to want to use templates for the body. In order to keep each email
as a separate thing, we're going to inherit from the Email class and override
what we need.

At the top of the test class, add this:

```ruby
class FakeEmail < Notifications::Email
  def stuff
    @data["stuff"]
  end

  def subject
    "Fake stuff"
  end

  def template_name
    'fake'
  end

  def template_dir
    './test/fixtures'
  end
end
```

Create a directory `./test/fixtures` and add a template called `fake.erb`:

```erb
Oh, look: <%= stuff %>!
```

Also, add a key "stuff" to the data hash in the tests:

```ruby
def data
  {
    "name" => "Alice Smith",
    "email" => "alice@example.com",
    "stuff" => "KITTENS",
  }
end
```

Change the expectations to use the FakeEmail class:

```ruby
def test_subject
  assert_equal "Fake stuff", FakeEmail.new(data).subject
end

def test_body
  assert_equal "Oh, look: KITTENS!".chomp, FakeEmail.new(data).body.chomp
end

def test_ship_it
  FakeEmail.new(data).ship # verify in mailcatcher
end
```

To get this to pass, add the following code to `lib/notifications/email.rb`

```ruby
def body
  ERB.new(template).result binding
end

def template
  File.read(template_path)
end

def template_path
  File.join(template_dir, "#{template_name}.erb")
end
```

### Cleaning up after ourselves

The base email class is missing two methods that we put in the FakeEmail
class: `template_dir` and `template_name`.

The `template_name` and subject are going to vary for every email that gets
implemented. Let's make Email blow up if someone sends either of those
messages to it directly:

```ruby
module Notifications
  class SubclassMustOverride < StandardError; end

  class Email
    # ...
    def subject
      raise SubclassMustOverride.new("Implement `template_name`, please.")
    end

    def template_name
      raise SubclassMustOverride.new("Implement `template_name`, please.")
    end
  end
end
```

### Implementing the purchase confirmation email

Create a new test, `test/notifications/email/purchase_confirmation.rb`:

```ruby
require './test/test_helper'

class PurchaseConfirmationTest < Minitest::Test

  def data
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


  3 x Li Hing Mui Lollypops


We've processed your payment for $12.00.

We hope you stop by again!
Frank's Monsterporium
    BODY
    assert_equal body.chomp, email.body.chomp
  end
end
```

Make a directory `lib/notifications/email/templates`.

Copy `app/views/mailer/order_confirmation.html.erb` from the primary project
to `lib/notifications/email/templates/purchase_confirmation.erb`.

Convert the template to plain text, we're not going to worry about HTML.

You'll need to add a require statement and a `template_dir` method to the `lib/notifications/email.rb` file:

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

Implement PurchaseConfirmation so that the tests pass.

#### Implementing the signup confirmation email

The signup email is the same deal. Make it work.

### Listen to Redis

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

Run the order controller tests and the user controller tests in the primary
app. You should see the messages in the output from your listener.

#### Sending the emails

Update `lib/listener.rb`:

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

Make sure the script in the primary app is **not** running, and that your
stand-alone listener _is_ running.

Run the orders controller / users controller tests.

If you see the emails in mailcatcher, you're done.

Well, almost done! There's a bunch of code we don't need in the primary app:

### Deleting code!

Delete:

* `lib/notifications.rb`
* `app/mailers/mailer.rb`
* `app/views/mailers/order_confirmation.html.erb`
* `app/views/mailers/welcome_email.html.erb`
