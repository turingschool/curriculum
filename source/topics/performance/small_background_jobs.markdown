---
layout: page
title: Small Background Jobs
section: Performance
---

## Setup

* Clone the storedom repo from https://github.com/turingschool-examples/storedom
* Switch to the "mega" branch (`git checkout -b mega origin/mega`)
* Run `bundle`
* Make sure you have redis installed/running (`brew install redis`)
* Check to make sure redis is running with (`redis-cli ping`) and you should get `PONG`

## I0: Starting Point

We're going to use our seeds file as it's an easy way to write some plain Ruby
inside a Rails application. We want to create a massive stack of data in our
database. Let's see how long it takes as-is:

{% terminal %}
$ time rake db:seed
{% endterminal %}

That uses the UNIX `time` utility to measure how long it takes to run a `db:seed`.
It should take about 90 seconds. You can move on while it's running.

## I1: Big Jobs

Let's start to break this into a few big jobs.

Sidekiq is already in the app's `Gemfile`. Let's change our Generator classes to
fit Sidekiq's worker style. We need to include `Sidekiq::Worker` and define a `perform`
method.

### Defining a UserGenerator Job

Here's what the `UserGenerator` would look like as a job:

```ruby
class UserGenerator
  include Sidekiq::Worker

  def perform(quantity)
    generate(quantity)
  end

  def generate(quantity)
    quantity.times do |i|
      Delay.wait
      user = User.create!(
        name: Faker::Name.name,
        email: Faker::Internet.email
        )
      puts "User #{i}: #{user.name} - #{user.email} created!"
    end
  end
end
```

### Queueing the Job

Then, at the bottom of the seeds file, replace this:

```ruby
user_generator = UserGenerator.new
user_generator.generate(100)
```

With this:

```ruby
UserGenerator.perform_async(100)
```

### Starting the Worker

Open a new terminal tab and start a sidekiq worker:

{% terminal %}
$ bundle exec sidekiq
{% endterminal %}

### Run It!

Go back to your first tab and run the seeds:

{% terminal %}
$ rake db:seed
{% endterminal %}

Flip to your worker tab and you should see it cranking out users. The primary
seed run still builds your items and orders.

### Run a Second Worker

Open another tab and start another worker. Run your seeds again. You should see
that it takes about the same amount of time because only one worker can do the work
since there's just one big job.

## I2: Many Small Jobs

Instead of queuing one big job, let's queue many small jobs. In the seeds, let's
go back to the original call to `UserGenerator` like this:

```ruby
user_generator = UserGenerator.new
user_generator.generate(100)
```

### Revising the Job

Then bring the worker usage inside of the `UserGenerator` class itself. First
create a `generate_one` method like this:

```ruby
  def generate_one(marker)
    Delay.wait
    user = User.create!(
      name: Faker::Name.name,
      email: Faker::Internet.email
      )
    puts "User #{marker}: #{user.name} - #{user.email} created!"
  end
```

Then revise the `perform` method to call `generate_one`:

```ruby
  def perform(marker)
    generate_one(marker)
  end
```

And revise `generate` to queue a bunch of jobs, one per user:

```ruby
  def generate(quantity)
    quantity.times do |i|
      UserGenerator.perform_async(i)
    end
  end
```

### Run It

Restart your Sidekiq workers and run it again. If you have two tabs running Sidekiq then you should see 20 threads
start per tab, creating all the users in just a few seconds.

## I3: Revising Items & Orders

Now go through the same process to queue jobs for items and orders.

### I4: An Approximate Benchmark

Want to figure out the resulting impact on the timing?

Create a file `db/seeds_benchmark.rb` with these contents:

```ruby
require 'benchmark'

User.destroy_all
Item.destroy_all
Order.destroy_all

Rails.application.load_seed

puts Benchmark.measure {
  user_target = 100
  item_target = 500
  order_target = 100
  complete = false

  until complete
    user_count = User.count
    item_count = Item.count
    order_count = Order.count

    if user_target == user_count &&
      item_target == item_count &&
      order_target == order_count

      complete = true
    else
      sleep 0.25
      puts "Counts: #{user_count} users, #{item_count} items, #{order_count} orders"
    end
  end
}
```

Then run it from the command line:

{% terminal %}
$ rails runner ./db/seeds_benchmark.rb
{% endterminal %}
