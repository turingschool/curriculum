---
layout: page
title: Capybara Essentials
section: Testing with Capybara
---

Let's take a look at the essential tools and understandings you need to begin working with Capybara.

## Setup

### Install the Gem

To use the library, first add it to the `:test` and `:development` groups in your `Gemfile`. While you're in there, add the `launchy` gem which is useful for understanding Capybara tests:

```ruby
group :development, :test do
  gem 'capybara'
  gem 'launchy'
end
```

Then run `bundle` from the command line to install the gems.

### Load the Gem

For a Rails application, the setup is simple. Before your tests run you need to require the gem. You should typically add the following to your `test_helper.rb` or similar file run before the test suite (this will allow us to use Capybara's methods, as well as use Rails' routing helpers in our tests):

```
# ...

require 'rails/test_help'
require 'capybara/rails'  ## add this line

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  include Capybara::DSL ## add this line
  include Rails.application.routes.url_helpers ## add this line

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # ...
end
```

### Reference

While this tutorial is geared towards just the pieces you need to get going, you should refer to the [official Capybara documentation](http://rubydoc.info/github/jnicklas/capybara/master) to understand all the features and tools available to you.

## Writing a Test

Let's walk through how you write a Capybara test.

### Using the `features` Folder

By default, any tests in the `features` subfolder will run with Capybara enabled. Presuming you're using Minitest rather than RSpec, you'd create a folder:

```
test/features
```

Then create a test file. Let's base our example on the [Blogger]({% page_url blogger %}) project. Say we're going to explore the article creation process, and create a file `article_creation_test.rb` like this:

```ruby
require './test/test_helper'

class ArticleCreationTest < MiniTest::Unit::TestCase

end
```

### Interaction Pattern

Good feature and acceptance tests are about the **interactions** not the **content**. We're testing how a user is going to *use* the application. In general, Capybara tests follow this outline

* 1) Login as a certain user (if necessary)
* 2) Go to a specific page
* 3) Click a link to take some action
* 4) Fill out a form or do the "action" step
* 5) Submit the form data
* 6) Verify that the data you submitted appears

In code, this looks like this for a Blogger application which does not implement authentication.

```
require './test/test_helper'

class ArticleCreationTest < MiniTest::Unit::TestCase
  def test_it_creates_an_article_with_a_title_and_body
    visit articles_path
    click_on 'new-article'
    fill_in 'title', :with => "My Capybara Article"
    fill_in 'body', :with => "This is a great article."
    click_on 'save-article'
    within('#title') do
      assert page.has_content?("My Capybara Article")
    end
    within('#content') do
      assert page.has_css?("p", text: "This is a great article.")
    end
  end
end
```

## API

### Navigating the Session

The session methods allow us to set and query the current state of our headless "browser." The Capybara::Session class is documented here: [http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session](http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session)

### Visit

The `visit` method takes an address parameter and will fetch the page. Example:

```ruby
visit "/articles"
```

But when we are running tests against a Rails application, we have access to the *named routes* directly in our examples like this:

```ruby
visit articles_path
```

Using the named routes is the **preferred** option. This allows your routes to change without unnecessarily breaking the test.

### Current Path

The `current_path` method returns the path without the protocol, server, and port. This is useful for checking that you arrive on a certain page after a previous action took place. For example:

```ruby
current_path
```

That would return `"/articles"` when you're on the articles index page. You can make use of the named routes here by doing something like:

```ruby
assert_equal articles_path, current_path
```

### Driving Interaction

The most interesting integration tests involve page actions: click here, fill in that text box, click submit, and see what happens.

You can check out all the actions available here: http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Actions

#### `click_on`

You can click on any link or button by using `click_on` and a CSS-style locator.

`click_on(locator)` for links or buttons

#### `fill_in`

`fill_in(locator, with: "My Data")` for text boxes or areas

You can fill in text fields or areas by using `fill_in` with a CSS selector and the `with:` option to send in the data.

#### `choose` and `check`

* `choose` for radio buttons
* `check` for checkboxes

### Examining the Response

It all leads up to this. You've forced the virtual browser to follow some path of interactions, now you want to verify the results. Let's look at how to examine the response.

We'll stick to the most important methods for this tutorial, but you can check out the [full matchers documentation](http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Matchers
) for more.

#### Seeing What You've Got

Sometimes you can't tell why a test is passing when it should be failing or _vice versa_. At any point in a capybara test you can write:

```ruby
save_and_open_page
```

It will store the current page to a file and open it in your default web browser. This is why we included the `launchy` gem up above.

Whenever a test is doing something mysterious, this should be your first debugging step. Usually you'll see that sample data is different than expected or the browser is on a totally different page than intended.

Note that Capybara is saving a static page of HTML--it's not clickable and you can't *do* much of anything other than look at the page and inspect the DOM. Relative paths to assets like CSS and images won't work, either.

#### HTTP Status Code

An easy thing to check is the HTTP status code. Recall that `200` means everything is OK, `30*` are redirects, `40*` are user errors, and `50*` are system errors.

To get the status code of the current response you'd call:

```
page.status_code
```

In the context of a test you might write:

```
assert_equal 200, page.status_code
```

But you might want to allow a little flexbility and just check that it's some form of `20*` code:

```
assert_includes 200...300, page.status_code
```

#### `within`

Now we want to start looking at page content. As an application grows, the HTML for any given page likely gets quite large. You need to be careful that your Capybara tests don't pass for the *wrong* reasons.

One common mistake is to look for certain content on the page intending to find it in the main content body. But, if the content appears in your navigation or maybe in a flash error message, your test could pass.

The `within` method allows you to scope all your actions down to a certain section of the page. For instance:

```ruby
within("#articles") do
  assert page.has_link?(article.title, href: article_path(article))
end
```

This will *only* look for the link inside the DOM node with ID `"articles"`, ignoring everything else on the page.

Note that the parameter to `within` is a CSS selector, so it can use HTML elements, classes, and IDs. If you can, use an ID to ensure you're looking at a specific component.

#### `has_content?`

`has_content?` is defined as:

```plain
Checks if the page or current node has the given text content,
ignoring any HTML tags and normalizing whitespace.
```

For example, within an example we might have:

```ruby
visit articles_path
assert page.has_content?("All Articles")
```

*Ignoring* HTML tags means that if our page has HTML like `"My Super <span>Title</span>"` and we ask if it has content `"My Super Title"` the matcher will return `true`.

This matcher is extremely broad, basically asking "Does this string appear _anywhere_ on the page?" It might be in the page title as you're thinking, but it could be in a link that says "Back to All Articles," something text on the sidebar, or anywhere on the page.

Hesitate before writing tests using `have_content` unless you're at least scoping down to a component of the page using `within` like this:

```ruby
visit articles_path
within('#title') do
  assert page.has_content?("All Articles")
end
```

This combination gives some reasonable specificity to the match --it'll have to appear within a DOM object with ID `title`.

#### `has_link?`

This matcher checks if the page or current node has a link with the given text or id. It's impartial whether we pass in the actual text of the link or the DOM ID of the link.

```ruby
visit articles_path
assert page.has_link?("Create a New Article")
```

However, we recommend that you use a CSS ID, even if that means adding one to the view template. Over time, the chance that the text of the link needs to change is very high. While the likelihood of the CSS ID needing to change is low. Using the ID will thus make your test more robust. The above matcher might be rewritten like this:

```ruby
visit articles_path
assert page.has_link?("new-article")
```

Note that the `#` marking it as a CSS ID is omitted.

There's an additional option, the `:href`, which specifies where the link points. This option can only be used in conjunction with the "locator" (text contents or CSS id of the link), you can't use it on it's own.

You could then assert that the page has a link with the CSS ID `new-article` *and* that the link points to the `new_article_path` like this:

```ruby
visit articles_path
assert page.has_link?("new-article", href: new_article_path)
```

#### `has_css?`

The `has_css?` method is documented here: http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Matchers#has_css%3F-instance_method

`has_css?` is a general purpose search of the page that will find elements using CSS expressions. It's basically a more targeted version of `has_content?`, useful for verifying the existence of DOM elements. For instance, we might write something like:

```ruby
visit article_path(article)
assert page.has_css?("h2#article-title")
```

That matcher validates that there is an H2 tag with the ID `"article-title"`. We could get more specific and also check the contents of the element:

```ruby
visit article_path(article)
page.has_css?("h2#article-title", text: article.title)
```

Be cautious when you're using `has_css?`, though. It's easy to write tests that become brittle by tying them too closely to the details of the HTML design. Think about "Should this test break if X tag is changed?" If your SEO expert decides to change the article title to an H1, should that break your tests? There's no blanket answer, you have to decide what makes sense for your application.

In this scenario, it'd probably be smarter to leave the `h2` tag out and just look for an element with the ID of `article-title`:

```ruby
visit article_path(article)
assert page.has_css?("#article-title", text: article.title)
```
