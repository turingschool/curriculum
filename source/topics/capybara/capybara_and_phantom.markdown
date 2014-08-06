---
layout: page
title: Capybara Overview
section: Integration Testing with Capybara
---


## What is all this stuff?

Before we dive in, lets make sure all this fancy lingo makes sense.

### Definitions

* **Use Case (aka Feature)**
  Way that a user of the application tries to use it E.g. sign up, add friend to contacts list, etc
* **Phantom.js**
  Headless (no window pops up) web browser
* **Capybara**
  Testing tool that browses the app, because it is so high-level, it is an effective way to test the user's perspective,
  so it is good for testing use cases
* **Poltergeist**
  Capybara "Driver", Capybara tells it what to do, and it translates that to instructons for Phantom.js (it "drives" Phantom)
  Capybara doesn't drive Phantom.js directly because it wants to be able to work with any number of technologies,
  so it expects all drivers to be able to understand it, and then lets them go do what they do without it needing to know what that means.
* **Acceptance test**
  High-level test that exercises the system in the way the user is expected to (defined by the use case)
* **Launchy**
  A gem that lets you "save and open screenshot" in Capybara

### What is Capybara?

Capybara provides an interface for interacting with websites from Ruby

It is specifically intended for testing, providing helpful methods for that purpose.
But given what it does, we could also use it in place of Mechanize for scraping.

It leaves the specifics of how to talk to the website to a "driver"
This allows you to use it with numerous tools, such as rack-test,
Which hooks it into your rack layer, allowing you to navigate your website
Without ever loading a server.
The driver that knows how to talk to Phantom.js is called Poltergeist
So we'll use Capybara to navigate the web, click links, and so forth, like Mechanize,
but we'll have it use Poltergeist so it does this in Phantom.js,
and we can interact with JavaScript

### What is Rack::Test
Rack::Test is a library that sits above the rack app, like Rack does
(note: Rails and Sinatra both implement the Rack interface, making them Rack apps)
It allows you to fake web requests to the app. To the app, they come from Rack,
the same as a real web request, but in reality, we haven't started a server,
these requests come from our our test suite commanding telling Rack::Test

Capybara's default driver works with Rack::Test, meaning that if we tell it
what our app is (normally the config.ru does this, but we aren't loading a server)
then we can use Capybara to test our app.

### What is Phantom.js?
Phantom.js is a web browser

It doesn't have a window like Opera or FireFox, it does all the work without ever displaying the pages.
Why use it, then? Because it has an api that allows external programs to tell it what to do.
This means that we can navigate the internet through Phantom.js, from our Ruby program
Which gives us the full power of a real browser (which is mostly to say that we can run JavaScript
the same way that we would in our web browser, whereas with Rack::Test, we were restricted to
just HTML).

### What is Poltergeist?

Poltergeist is a Capybara driver that knows how to talk to Phantom.js
So if we tell Capybara to use Poltergeist, we can run our test suite in the Phantom.js browser
with full javascript, CSS, etc, and all the capabilities and restrictions of an actual browser


## Thinking

### Process

* Place yourself in mind of the user (customer, admin, etc)
* Consider what should happen independent of the existing implementation (you are a user, not a developer!)
* Write down in English what you would like to and why, this is about context.
* Translate the English into tests (since we're building websites, these will use Capybara)
* Implement the feature.
* When the test passes, we believe the feature is complete.
* We don't need to test *every* facet of the feature at this level, but its good to get a good happy path and sad path.
  We can test the nuances of ways that this can be called at unit-level tests.

Lets do some [examples](http://tutorials.jumpstartlab.com/topics/capybara/workflow.html).

### When to use this

This is a great place to start when adding functionality to an application.
It gets you focused on the goal, thinking about the purpose of the code.
And then lets you know how far along you are towards that goal, directing your more focused efforts.

### When not to use this

While this provides many of the benefits of testing, such as regression checking
(aka "did I break everything?"), it is not a good way to perform fine-grained testing.
For example, if we want to say that your application is declined if you are from
Wisconsin, Idaho, California, or Montana, we don't want to operate at this level for each of these.
Perhaps we show that "when I am from an unserviced state, my application is declined".
Testing each one independently would be expensive, verbose, and not give us quick or good feedback.
But if we just made it a normal RSpec test, we could say something like this:

```ruby
context 'when I am from an unserviced state' do
  it 'declines my application' do
    set_unserviced_states_to(['Wisconsin', 'Idaho']) # a helper method we wrote elsewhere in our test suite
    expect(Application.new data.merge(state: 'Wisconsin')).to be_declined
    expect(Application.new data.merge(state: 'Idaho'    )).to be_declined
    expect(Application.new data.merge(state: 'Florida'  )).to be_approved
  end
end
```

Those tests are really focused, cheap to run, small to see what's involved,
and give us confidence that if this ever breaks, we'll know.

## Setting up Capybara

Alright, so we thought through it and made use case for what we want to do...
Now how do we write this test? We'll use Capybara, of course! (of course, b/c that's
the subject of this lesson)

### Versions used

```
$ phantomjs --version
1.9.7

$ bundle exec gem list | ruby -ne 'print if /^rails\b|capy|launch|polt|rspec-core/'
capybara (2.4.1)
launchy (2.4.2)
poltergeist (1.5.1)
rails (4.1.4)
rspec-core (3.0.3)
```

### Installation

```
$ brew install phantom.js
$ gem install rails capybara poltergeist launchy
```

### Did they install correctly?

Play around with them in pry: try the following.

```ruby
pry
require 'capybara/poltergeist'          # require the gems
Capybara.default_driver = :poltergeist  # configure Capybara to use poltergeist as the driver
internet = Capybara.current_session     # the object we'll interact with
url = "https://github.com/jnicklas/capybara"
internet.visit url                      # go to a web page (first request will take a bit)
internet.save_and_open_page             # save the page locally, open it (this is what Launchy does)
```

### Setting up a play environment

Lets make a new Rails app to play in (in reality, I committed all along the way as I did this,
but that made the example even longer, so I took it out. I'll leave it up to you to do that)

```
$ rails new play_app
$ cd play_app
```

We need to add all these gems to the Gemfile:

```ruby
group :development, :test do
  gem 'rspec-rails', '~> 3.0.0'
  gem 'pry',         '~> 0.10.0'
end

group :test do
  gem 'capybara',    '~> 2.4'
  gem 'launchy',     '~> 2.4'
  gem 'poltergeist', '~> 1.5'
end
```

Update the gems and setup rspec

```
$ bundle
$ rails generate rspec:install
```

And edit the .rspec file, remove `--warnings` and add `--format documentation` so it looks like

```ruby
--color
--require spec_helper
--format documentation
```

Now lets tell RSpec we want to use Capybara with Poltergeist,
edit spec/rails_helper.rb, add this after the other requires.

```ruby
# load up Capybara
require 'capybara/rspec'
require 'capybara/rails'

# load up Poltergeist
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
```

Make this test in `spec/features/play_app`.
Saying `js: true` tells it that we need JavaScript to work
which will cause Capybara to use its javascript_driver. The `feature: true` we
technically get by default simply because we're in the features directory, but
I hate that implicit stuff. This just tells it to make Capybara available.

```ruby
require 'rails_helper'

describe 'Ideas', js:true, type: :feature do
  specify 'retrieving an idea' do
    require "pry"
    binding.pry
  end
end
```

Run the spec, and we should have Capybara available.

```
$ bundle exec rake
```

And try this out in the pry session

```ruby
visit 'http://www.google.com'
save_and_open_page
save_and_open_screenshot
exit
```

## Writing our acceptance test.

First lets write a use-case together, remembering how to think about them [1](https://www.youtube.com/watch?v=tQ-8eAjss04).
Then lets translate it into Capybara,
if we need a more thorough walkthrough on how it works, we can read the [essentials](http://tutorials.jumpstartlab.com/topics/capybara/essentials.html).
Or to see my process for how I figured out how to use it, see my previous [Capybara example](https://gist.github.com/JoshCheek/1ef1c6fbe7ff7ee28de4/82b9f97d71e695a6f0d90525bdc6d0ace6362410#file-using_capybara_with_poltergeist_to_get_the_data-rb).
And if we're cool with having all that available, but lets just get to it, then we can use [this cheatsheet](https://gist.github.com/zhengjia/428105).

After we write the test, we'll make it pass (this is just writing normal Rails, and updating the test as necessary).
And if there's time at the end, you'll get to try writing your own without me.
