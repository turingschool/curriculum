---
layout: page
title: Measuring Code Coverage
section: Internal Testing
---

Code coverage is not the only way to judge the quality of a test suite, but it is a leading indicator. Low code coverage likely means the test suite is inadequate, but high coverage does not mean the test suite is bullet-proof.

## CoverMe

Ruby 1.9 changed enough of the implementation's internals that the old coverage library, `rcov`, no longer works. Thankfully, the Ruby development team added hooks to make coverage measurement even _easier_ than it was in 1.8.

The best coverage library for 1.9 is CoverMe: https://github.com/markbates/cover_me/

### Setup

Add `gem "cover_me"` to your `Gemfile` in the _development/test_ section and run `bundle`.

Once the gem is installed there are two additional steps:

1. Open `spec/spec_helper.rb` and add `require 'cover_me'` as the first line
2. Run `rails generate cover_me:install` from the terminal to add it to the default RSpec testing tasks

### Usage

Run your tests normally with `bundle exec rake`. After each run there will be a coverage data file output in your project directory. To generate and open a report using the data, execute the provided Rake task:

{% terminal %}
$ rake cover_me:report
{% endterminal %}

That's about all there is to it!

## Want More Metrics?

If you want to go totally bananas with metrics, try the `metric_fu` gem: https://github.com/jscruggs/metric_fu

It includes tools to estimate code complexity, find repetitive code snippets, and more.