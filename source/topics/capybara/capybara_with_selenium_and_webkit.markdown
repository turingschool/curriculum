---
layout: page
title: JavaScript Testing with Selenium & Capybara-Webkit
section: Integration Testing with Capybara
---

By default Capybara uses `Rack::Test` which is a headless browser emulator. It gives us great speed, but we sacrifice the ability to run JavaScript. If you need to test JS as part of your integration suite, then you need to use another _driver_.

### Linux Note

If you're using Linux, you'll need to set up xvfb in order to use either Selenium or Capybara-Webkit. Here are the Ubuntu commands to install xvfb and additional fonts to get rid of some warnings.

```bash
sudo apt-get install xvfb
sudo apt-get install x11-xkb-utils
sudo apt-get install xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic
```

In order to use xvfb with your specs, you will need to run `xvfb-run bundle exec rake` (an alias may be in order).
Now selunium and capybara-webkit will use *xvfb* when launching a browser.

There are alternative x-servers and alternative ways to use the x-server from the specs (*headless* gem) but they are not covered here.


## Using Selenium

The most popular driver is Selenium. It uses an actual browser window and you can watch the test happen. It uses the browser's actual JavaScript engine, so it's identical to having a human Q/A department interacting with your application.

### Setup?

If you have Firefox 4 installed then there are no extra setup steps. It's possible to use Chrome or another WebKit-based browser, but it is more work.

### Modifying Your Examples

If you want to only use the browser for a few specific tests, you can add `js: true` into the `it` line like this:

```ruby
it "should list the article titles on the index", js: true do
  @articles.each do |article|
    page.should have_link(article.title)
  end
end
```

More commonly you'll have a group of tests that you want to run in the browser. Rather than litter `js: true` all over the place, do this:

* Create a `describe` block that contains the examples that need JavaScript
* Add a before-all block like this:

```ruby
before(:all) do
  Capybara.current_driver = :selenium
end
```

* Put your examples after the `before` block
* Add an after-all block like this:

```ruby
after(:all) do
  Capybara.use_default_driver
end
```

Now any example added inside that `describe` will use Selenium.  If you forget the `after(:all)` block, all subsequent tests will continue using the `:selenium` driver, which will work, albeit more slowly than with the default, headless driver.

### Selenium Methods

If you're just triggering AJAX actions via JavaScript you can probably get by with the normal Capybara actions. But Selenium itself has many actions that are not directly supported by Capybara.

But that's ok! If you ask Capybara for `page.driver.browser` while in a Selenium-powered test, it'll give you the `Selenium::WebDriver::Driver` object. You can then access any Selenium method according to the API here: http://selenium.googlecode.com/svn/trunk/docs/api/rb/Selenium/WebDriver/Driver.html

#### Checking for an Alert

Here's a complete example of how you could use Selenium to check that an alert pops up when we attempt to delete an article:

```ruby
describe "on the show page for an article" do
  before(:all) do
    Capybara.current_driver = :selenium
  end
  
  before(:each) do
    @article = @articles.first
    visit article_path(@article)
  end
  
  it "pops up a confirm dialog when we click delete" do
    page.click_link("Delete")
    dialog = page.driver.browser.switch_to.alert
    dialog.text.should == "Delete '#{@article.title}'?"
    dialog.dismiss
  end    
  
  after(:all) do
    Capybara.use_default_driver
  end
end
```

You could also use `dialog.accept` to click the `OK` button where `dialog.dismiss` clicks `CANCEL`.

## Selenium Alternatives

Selenium, for one reason or another, makes developers a little uneasy. It sometimes has issues in the development versions but, most importantly, it's slow. It would be awesome if we could run JavaScript without actually waiting for the slow rendering of a GUI window.

There are some attempts to make this work, libraries such as HTML::Unit and Akephalos. They do a good job, but their JavaScript engines aren't a perfect match for a real browser. If only there were a real browser that we could run without the GUI!

### Using WebKit

The WebKit framework powers Chrome, Safari, and most mobile phone browsers. It's a popular open source project and is really at the vanguard of web browsers.

The team at ThoughtBot, a Rails consultancy in Boston, put together the `capybara-webkit` gem: https://github.com/thoughtbot/capybara-webkit

It uses the WebKit framework as a headless browser. We get almost all the speed of being headless with `Rack::Test`, but the power of a full, real-world JavaScript interpreter.

### Setup Qt

`capybara-webkit` uses the QtWebKit port, which depends on the Qt windowing framework. Even though the whole point is to run WebKit without windows, the compilation process has dependencies on Qt. 

Because Qt is not available for Windows, it's not possible to build WebKit for use with Capybara-Webkit on Windows. You'll need OS X or Linux.

OS X users can download and install the non-debug Qt from Nokia here: http://qt.nokia.com/downloads/qt-for-open-source-cpp-development-on-mac-os-x

Ubuntu users can `sudo apt-get install libqt4-dev`, while other Linux distributions can build it from Nokia's source code: http://qt.nokia.com/downloads/linux-x11-cpp

### Add the Gem

Open your `Gemfile` and add the following in your development dependencies:

```ruby
gem 'capybara-webkit'
```

At the time of this writing, it was necessary to use the 1.0 branch of capybara-webkit like this:

```ruby
gem "capybara-webkit", git: "https://github.com/thoughtbot/capybara-webkit.git", branch: "1.0"
```

### Tell Capybara about Capybara-Webkit

Then you'd hop into your `spec/spec_helper.rb` and add this line inside the `RSpec.configure` block:

```ruby
Capybara.javascript_driver = :webkit
```

### Run Your Examples

Now all you do is run your examples! We just swapped the driver, but the way we tell Capybara to use it is exactly the same as Selenium. If you want to run a single test with WebKit, add `js: true` to the `it` line. 

If you have a set of examples to run with JavaScript, wrap them in a `describe` block with a before-all and after-all like this:

```ruby
describe "run with webkit" do
  before(:all) do
    Capybara.current_driver = :webkit
  end

  it "runs something fancy with javascript"

  after(:all) do
    Capybara.use_default_driver
  end
end
```

You'll practice using the JavaScript-enabled drivers in the exercises in the next section.
