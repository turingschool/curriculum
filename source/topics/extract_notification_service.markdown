---
layout: page
title: Extract Notification Service
sidebar: true
---

## Dependencies

Install redis:

{% terminal %}
$ brew install redis
{% endterminal %}

Install the redis gem:

{% terminal %}
$ gem install redis
{% endterminal %}

Clone the [store_demo repository](https://github.com/jumpstartlab/store_demo).

## Introduction

### Goals

### The Monsterporium

* Description of the project, what it has, what it does, etc

#### Where Email Notifications Come From

There are two emails that get sent to customers, both defined in
`app/mailers/mailer.rb`. They're called in:

* `UsersController#create`
* `OrdersController#create`
* `OrdersController#buy_now`

Request -> Controller -> Email -> Response

#### High-Level Overview of Where We're Going

* Whiteboard-level description of how it'll work when we're done.

Step 1:

Request -> Controller -> Redis -> Response
Redis -> Mailer

Step 2:

Request -> Controller -> Redis -> Response # no change
Redis -> separate app -> mailer

### Characterizing Functionality

We'll use a semi-automated test harness to check that emails are actually
sent, and that they look right.

1. Run the tests to check that they're passing.
2. Deliberately give the `order_confirmation` mailer an `Order.new`.
   Give the `welcome_email` mailer a `User.new`.
3. Rerun the tests. Which test files fail?

The failures don't tell us anything about what's wrong with the emails, and
doesn't even tell us if the emails were sent.

We need better tests.

#### Introducing Mailcatcher

Install mailcatcher:

{% terminal %}
gem install mailcatcher` # do not put in gemfile
{% endterminal %}

Configure the Action Mailer settings for the test and development
environments:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = { :address => "127.0.0.1", :port => 1025 }
```

Unfortunately, Action Mailer overrides the `delivery_method` inside the tests
so that they always deliver to `:test` rather than using the configured value
of `:smtp`.

We need to override the override.

#### The Mailer Tests

Add a before filter in `spec/mailers/mailer_spec.rb`:

```ruby
before(:each) do
  ActionMailer::Base.delivery_method = :smtp
end
```

Delete the expectation in both tests. We'll be checking these semi-manually.

Run the tests, open [mailcatcher](http://localhost:1080), eyeball the emails.

#### End-to-End Email Tests

Let's also capture the emails that get sent during integration tests.

The `spec/controllers/orders_controller_spec.rb` has two tests that send out
email: One for the `#create` action, and one for the `#buy_now` action.

Make these deliver to mailcatcher instead of `ActionMailer::Base.deliveries`.

There are no controller tests that trigger the welcome email. The feature
specs are very slow, so instead of changing
`spec/features/anon_user_creates_account_spec.rb` to deliver to mailcatcher,
let's add a controller test that can verify this.

```ruby
# in spec/controllers/users_controller_spec.rb
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

Note that you don't need to override `ActionMailer::Base.delivery_method`,
since this isn't an ActionMailer test.

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

