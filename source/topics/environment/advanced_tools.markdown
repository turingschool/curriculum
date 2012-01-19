---
layout: page
title: Environment Setup
section: Environment & Source Control
---

### Ruby Debugger

The Ruby debugger is a separate gem which requires installation, usually through your Gemfile. Note that the debugger relies on native extensions, so you need to have the Ruby headers and compilation tools setup on your system.

#### Ruby 1.8.7

Add the dependency to your development gems in the `Gemfile`:

```ruby
group :development do
  gem 'ruby-debug'
end
```

Or install it from the terminal with `gem install ruby-debug`

#### Ruby 1.9.X

Assuming you're using Bundler, add the dependency to your development gems in the `Gemfile`:

```ruby
group :development do
  gem 'ruby-debug19'
end
```

Or install it from the terminal with `gem install ruby-debug19`

If you leave off the `19` you would instead get the package for use with 1.8.7 and it is incompatible with 1.9.

### Redis