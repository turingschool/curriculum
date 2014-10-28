---
layout: page
title: Small Background Jobs
section: Performance
---

## Setup

* Clone the storedom repo from https://github.com/turingschool-examples/storedom
* Switch to the "mega" branch (`git checkout mega`)
* Run `bundle`
* Make sure you have redis installed/running (`brew install redis`)

## I0: Starting Point

We're going to use our seeds file as it's an easy way to write some plain Ruby
inside a Rails application. We want to create a massive stack of data in our
database. Let's see how long it takes as-is:

```
$ time rake db:reset
```

That uses the UNIX `time` utility to measure how long it takes to run a `db:reset`.
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

```
$ bundle exec sidekiq
```

### Run It!

Go back to your first tab and run the seeds:

```ruby
$ rake db:reset
```

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

Run it again. If you have two tabs running Sidekiq then you should see 20 threads
start per tab, creating all the users in just a few seconds.

## I3: Revising Items & Orders

Now go through the same process to queue jobs for items and orders.
