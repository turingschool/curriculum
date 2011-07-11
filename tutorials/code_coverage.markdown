# Measuring Code Coverage

Code coverage is not the only way to judge the quality of a test suite, but it an excellent indicator. Low code coverage means that the test suite is likely inadequate, but the converse is not true: just because you have high coverage does not mean that your test suite is bullet-proof.

## CoverMe

Ruby 1.9 changed enough of the internals that the old coverage library, rcov, no longer works. Thankfully, the Ruby development team added hooks to make coverage measurement even _easier_ than it was in 1.8.

The best coverage library for 1.9 is CoverMe: https://github.com/markbates/cover_me/

### Setup

Add `gem "cover_me"` to your `Gemfile` in the development/test section and run `bundle`.

Once the gem is installed there are two additional steps:

1. Open `spec/spec_helper.rb` and add `require 'cover_me'` as the first line
2. Run `rails g cover_me:install` from the terminal to add it to the default RSpec testing tasks

### Usage

The usage couldn't be easier: just run your tests normally with `bundle exec rake`. If your tests all pass you'll see the coverage report opened in your default web browser. You can sort columns and click on the various files to see details about coverage.

That's about all there is to it!

## Want More Metrics?

If you want to go totally bananas with metrics, try the `metrics_fu` gem: https://github.com/jscruggs/metric_fu