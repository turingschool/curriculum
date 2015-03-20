---
layout: page
title: Extract Notification Service
sidebar: true
---

## Introduction

We'll take an existing project, the Monsterporium store, and extract the notification system to an external, asynchronous service.

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
$ rake db:migrate
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

### Characterizing Functionality

We'll use a semi-automated test harness to check that emails are actually
sent, and that they have the right contents.

#### Running Existing Tests

Run the tests to make sure everything starts out green:

{% terminal %}
$ rake
{% endterminal %}

#### Breaking the Mailer Tests

Open `app/mailers/mailer.rb` and:

* On line 5, change `@user = user` to `@user = User.new`
* On line 11, change `@order = order` to `@order = Order.new`

Now re-run the tests. Which examples fail?

Unfortunately the failures don't tell us what's actually *wrong* with the emails, and
don't even tell us if the emails were sent.

We need better tests!

#### Introducing Mailcatcher

Mailcatcher is a great little app that acts as an SMTP host, the protocol used to send email. It offers a web app that makes it easy to see what emails were "sent" (and really caught) by our tests.

We don't need to put it in the Gemfile, just install the gem from the terminal:

{% terminal %}
$ gem install mailcatcher
{% endterminal %}

#### Configuring Action Mailer

Action Mailer is the component of Rails that handles email. We need to configure it to use mailcatcher as the SMTP server.

In *both* `config/environments/development.rb` and `config/environments/test.rb`, add the following lines inside the `do`/`end` block:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = { :address => "127.0.0.1", :port => 1025 }
```

That *should* work, but unfortunately when running the test suite Action Mailer overrides the `delivery_method`, despite it being defined in the test environment file.

We need to override the override.

#### `mailer_spec.rb`

##### Overriding the `delivery_method`

Open `spec/mailers/mailer_spec.rb` and add this before block:

```ruby
before(:each) do
  ActionMailer::Base.delivery_method = :smtp
end
```

##### Expectations

Since we're going to manually inspect the emails, the specs in this file should not have any expectations -- they'll never fail.

Delete the `expect` line from both specs.

#### Tests & Results

Now everything is in place.

* Run the tests from the terminal
* Open the [mailcatcher web interface at http://localhost:1080](http://localhost:1080)
* Eyeball the caught emails and you should see the problems we intentionally introduced earlier

#### Emails in OrdersController Specs

Let's also capture the emails that get sent during integration tests.

Open `spec/controllers/orders_controller_spec.rb`. There are two specs that send out email:

* `create fails to create an order...`
* `buy_now fails to create an order...`

Use the same technique we did the the mailer spec to send these emails to mailcatcher. There are no expectations here about email, so don't delete the expectations that are there.

#### Testing the Welcome Email

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

#### Putting It All Together

Now re-run the whole test suite pop open mailcatcher, and you should see five emails appear. 

We've succesfully "characterized" the existing functionality and can begin refactoring.

### Pushing Logic Down the Stack

The controllers communicate with the mailers by sending objects.

We'll decouple the controllers from the mailers by inserting another object
between them. Then we'll change the mailers to accept a hash rather than
objects.

#### But first, refactor!

Before we get to that, let's simplify the order_confirmation mailer.

Right now it takes two parameters: user and order. The order has a user, so
change the mailer to get the user from the order.

Make sure both the mailer tests and the orders controller tests are passing,
and that the emails end up where expected.

#### Decoupling the controller from the mailer

Create a new file `app/models/purchase_confirmation.rb`:

```ruby
class PurchaseConfirmation
  def self.create(order)
    Mailer.order_confirmation(order).deliver
  end
end
```

Change the orders controller to send the `:create` message to
`PurchaseConfirmation`.

Create a new file `app/models/signup_confirmation.rb`:

```ruby
class SignupConfirmation
  def self.create(user)
    Mailer.welcome_email(user).deliver
  end
end
```

Change the orders controller to send the `:create` message to
`SignupConfirmation`.

Make sure the emails are still being sent.

#### Refactoring the Mailers

The welcome mailer currently takes a user object.

* What information does it actually need?

Change the spec to send a hash with just that information.
Change the welcome mailer to work with that information.
Change the controller to pass the correct information to the mailer.

Now do the same for the order confirmation email.

The hash should use strings rather than symbols as keys, because the hash is
going to make a round-trip through JSON before too long.

Here's what the data structure looks like:

```ruby
# signup confirmation
data = {
  "name" => "Alice Smith",
  "email" => "alice@example.com",
}

# purchase confirmation
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

Make sure all the emails are still being sent correctly.

### Working with the Pub/Sub Channel

#### Configuring Redis

Include the `redis` gem in the Gemfile, and bundle install.

Create a directory `config/redis`. We'll add two configuration files:

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

We need to get Rails to start redis. Create an init file in `config/initializers/redis.rb`:

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

Start the rails console, and inspect `$redis`.
Open IRB in a second terminal window, subscribe to a test channel:

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

#### Publish the email message

* When an email needs to be sent, send a message to Redis
* Leave the existing functionality in place

We'll use a channel called "email_notifications". Open up IRB and subscribe to
the channel on the port we configured for the test environment:

{% terminal %}
$ require 'redis'
$ redis = Redis.new(port: 6383)
$ redis.subscribe("email_notifications") do |event|
    event.message do |channel, body|
      puts "[#{channel}] #{body}"
    end
  end
{% endterminal %}

Publish the email data to the notification channel in `PurchaseConfirmation.create`.

```ruby
message = {"type" => "purchase_confirmation", "data" => data}
$redis.publish("email_notifications", message.to_json)
```

Run the orders controller tests and make sure that:

1. mailcatcher receives all the emails
2. the subscriber in IRB receives the message

Do the same thing for the signup confirmation.

### Implementing a Listener

Now let's put the listener that we had in IRB into a file
`lib/notifications.rb`:

```ruby
require 'redis'
redis = Redis.new(port: 6383)
redis.subscribe("email_notifications") do |event|
  event.message do |channel, body|
    puts "[#{channel}] #{body}"
  end
end
```

Start the file with `ruby lib/notifications.rb`

Run the controller tests. Verify both the output of the listener and the emails in
mailcatcher.

#### Sending the emails from the listener

```ruby
$redis.subscribe("email_notifications") do |event|
  event.message do |channel, body|
    body = JSON.parse(body)
    case body["type"]
    when "purchase_confirmation"
      Mailer.order_confirmation(body["data"]).deliver
    when "signup_confirmation"
      Mailer.welcome_email(body["data"]).deliver
    end
  end
end
```

Comment out the line in PurchaseConfirmation and SignupConfirmation that
triggers the email delivery.

This time, in order to start the listener, we're going to need to use `rails
runner`, since it needs the application environment.

We also need to run the script against the rails test environment so that it
listens to the correct port:

{% terminal %}
RAILS_ENV=test bundle exec rails runner lib/notifications.rb
{% endterminal %}

Kick off the controller tests, and verify that the emails end up in
mailcatcher and that they have all their data.

Delete the commented out lines in the Confirmation classes.

### Writing a stand-alone notification service

We don't need all of rails to send emails. We can create a small, stand-alone
ruby project that listens to the Redis channel and sends emails when events
arrive.

#### Project Structure

We'll just call this project `notifications`, but in real life the project
would probably be named by going to [wordoid.com](http://wordoid.com) and
finding something clever-sounding.

The project structure we're starting out with is an idiomatic ruby project
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

We're going to need `pony` to send emails, and `redis` to subscribe to the
messages from the primary application.

We'll use `minitest` for testing. The Gemfile looks like this:

```ruby
source 'https://rubygems.org'

gem 'pony'
gem 'redis'

group :test do
  gem 'minitest', require: false
end
```

Run `bundle install`.

Let's create a default rake task that will run all our tests:

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

#### Making sure everything is wired together

Create a file `test/notifications_test.rb` and add the following:

```ruby
require './test/test_helper'

class NotificationsTest < Minitest::Test
  def test_wired_together
    assert_equal 42, Notifications.answer
  end
end
```

Run the test with `rake`.

You'll probably get a NameError `uninitialized constant`.

Open up `test/test_helper.rb` and add:

```ruby
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride' # optional, but makes everything better
```

The `gem 'minitest'` line tells the code to use the minitest gem rather than
the minitest that is in the Ruby standard library. There was a major overhaul
between version 4 and 5, and 5 is nicer.

Run `rake` again, and you'll get another NameError: `uninitialized constant
NotificationsTest::Notifications`.

Open up `lib/notifications.rb` and create a module called Notifications.

Run `rake` again.

We've forgotten to require the file we need in the test.
Let's just require the whole `notifications` library. It's going to be tiny.

Add the following to the `test/test_helper.rb`:

```ruby
require 'notifications'
```

Run `rake`. It complains that it can't find the file. Put the following line at
the top of the test helper to put lib on the path:

```ruby
$:.unshift File.expand_path("./../../lib", __FILE__)
```

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

#### Cleaning up after ourselves

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

#### Implementing the purchase confirmation email

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

