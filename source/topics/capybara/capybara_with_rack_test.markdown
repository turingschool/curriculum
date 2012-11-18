---
layout: page
title: Capybara with Rack::Test
section: Integration Testing with Capybara
---

Integration testing is awesome.  Years ago, running integration tests was painful, slow, and they were so brittle that every change to the codebase broke the test suite.

Today it's a different story. We have amazing tools that make a tough job much easier. Let's check them out.

## Background on Integration Testing

Integration tests are critically important because they exercise your application just like a real user. They therefore depend on the full stack from your models up through your controllers, helpers, view templates, web server, database, and middleware. 

Integration tests *can* be brittle if they know too much about how those components work.  Proper integration tests use your application as a black box. They should know as little as possible about what happens under the hood, they're just there to interact with the interface and observe the results.

<div class='opinion'>
<p>A great testing strategy is to extensively cover the data layer with unit tests then skip all the way up to integration tests. This approach gives great code coverage and builds a test suite that can flex with a changing codebase.</p>
</div>

### Test/Behavior Driven Development

By formal definition, Behavior Driven Development (BDD) relies on using natural language frameworks to specify business value, then translates that natural language into software tests that exercise the application.

The Cucumber framework, built just for this purpose, has many fans in the Ruby community. If you're in the situation where the client is so technical that they might write scenarios, then this approach makes sense. In practice, however, that's rarely the case.

Instead the developer writes the scenarios, then spends a lot of time writing natural language parsers to translate those scenarios to runnable tests. This feels like an unnecessary burden. If a highly technical developer is writing the scenarios, just skip to the good part!

### RSpec, Capybara, and Steak

Some developers don't want to bother with Cucumber. They wanted the power of doing outside-in testing but didn't want to deal with the translation step. *Steak* was born as a way to meld the powers of RSpec and Capybara directly. Now we can write integration tests in a similar language to our unit tests, greatly simplifying the process.

In late 2010 the Capybara community decided to absorb the Steak syntax and roll it right into Capybara itself. Together with RSpec we can build awesome integration tests.

### Rack::Test

By default Capybara will use `Rack::Test`. This Ruby library interacts with your app from the Rack level, similar to an external user. It runs requests against your app, then provides the resulting HTML to Capybara and RSpec for examination.

`Rack::Test` is completely headless, though, so you won't see anything. It doesn't use a real browser, it's similar to using the unix utility `curl`. The advantage is that it can run fast--there's no GUI to render, images to process, etc. 

The disadvantage is that it doesn't process JavaScript. If you need to test JavaScript in your integration tests, we'll look at solutions with Selenium and `capybara-webkit` later.

## Capybara Setup

To use the library, add `gem 'capybara'` to the `:test` and `:development` groups in your `Gemfile`, then run `bundle` from the command line.

## Capybara Usage and Syntax

Capybara's RSpec integration gives us several new methods and matchers we can use in our examples. The library is still young and the best reference is the RDoc site: [http://rubydoc.info/github/jnicklas/capybara/master](http://rubydoc.info/github/jnicklas/capybara/master)

### Session Methods

We can script Capybara like we would interact with a browser. The session methods allow us to set and query the current state of our headless "browser." The Capybara::Session class is documented here: [http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session](http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session)

#### Visit

The `visit` method takes an address parameter and will fetch the page. Example:

```ruby
visit "/articles/"
```

But when we are running tests against a Rails application, we have access to the named routes directly in our examples like this:

```ruby
visit articles_path
```

This allows your test to delegate the responsibility for understanding that path to the router, allowing greater flexibility in the future.

#### Current Path

The `current_path` method returns the path without the protocol, server, and port. This is useful for checking that you arrive on a certain page after a previous action took place. For example:

```ruby
page.current_path
```

That would return `"/articles/"` when you're on the articles index page.

#### Save and Open Page

Sometimes you can't tell why a test is passing when it should be failing or _vice versa_. This method is a great debugging tool. At any point in an example you can write:

```ruby
save_and_open_page
```

It will store the page it fetched to a file and open it in your default web browser. 

<div class='opinion'>
<p>Whenever a test is doing something mysterious, this is my first debugging step. Usually you'll see that sample data is different than expected or the browser is on a totally different page than intended. Note that Capybara is saving a static page of HTML--it's not clickable and you can't <em>do</em> much of anything other than look at the page and inspect the DOM.</p>
</div>

#### Within

The `within` method allows you to scope all your actions down to a certain section of the page. This is awesome when you want to focus your tests down to just one component. For instance:

```ruby
within("#articles") do
  page.should have_link(article.title, href: article_path(article))
end
```

This will *only* look for the link inside the node with ID `"articles"`, ignoring everything else on the page.

### Page Actions

The most interesting integration tests involve page actions: click here, fill in that text box, click submit, and see what happens.

You can check out all the actions available here: http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Actions

The most useful are:

* `click_on(locator)` (alias for `click_link_or_button`)
* `fill_in(locator, with: "My Data")`

You can click on any link or button by using `click_on` and a CSS-style locator. You can fill in text fields or areas by using `fill_in` with a CSS selector and the `with:` option to send in the data.

### Capybara-RSpec Matchers

If you look in the Capybara documentation for RSpec information, you'll be drawn to this page: http://rubydoc.info/github/jnicklas/capybara/master/Capybara/RSpecMatchers

Look at the method descriptions and you'll see...not much. There is no explanation of how the methods and parameters work! This is on purpose.

The RSpec matchers are just RSpec-style aliases for methods that already exist in Capybara's `Node::Matchers` class. The documentation for those methods is here: http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Matchers

When you want to use the RSpec-style `have_link` matcher, look at that second page for the `has_link?` method--the former is an alias for the latter. The same is true for `have_content` and `has_content?`, `have_selector` and `has_selector?`, and so on.

Let's take a closer look at a few of the more important matchers.

#### `have_content` / `has_content?`

`has_content?` is defined as:

```plain
Checks if the page or current node has the given text content,
ignoring any HTML tags and normalizing whitespace.
```

For example, within an example we might have:

```ruby
visit articles_path
page.should have_content("All Articles")
```

Ignoring HTML tags means that if our page has HTML like `"My Super <span>Title</span>"` and we ask if it has content `"My Super Title"` the matcher will return `true`. This matcher is extremely broad, basically asking "Does this string appear _anywhere_ on the page?" It might be in the page title as you're thinking, but it could be in a link that says "Back to All Articles," something text on the sidebar, or anywhere on the page.

Hesitate before writing tests using `have_content` unless you're at least scoping down to a component of the page using `within` like this:

```ruby
visit articles_path
within('#title') do
  page.should have_content("All Articles")
end
```

This gives some reasonable specificity to the match--it'll have to appear within a DOM object with ID `title`.

#### `have_link` / `has_link?`

This matcher checks if the page or current node has a link with the given text or id. It's impartial whether we pass in the actual text of the link or the DOM ID of the link.

There's an additional option, the `:href`, which specifies where the link points. This option can only be used in conjunction with the "locator" (text contents or CSS id of the link), you can't use it on it's own.

Imagine that our `articles/index` DOM is going to have a link with the text "Create a New Article", has the DOM ID `#new_article`, and points to `new_article_path`. All of these matchers would work:

```ruby
visit articles_path
page.should have_link("Create a New Article")
page.should have_link("Create a New Article", href: new_article_path)
page.should have_link("new_article")
page.should have_link("new_article", href: new_article_path)
```

Which is the right choice? During an application lifetime, the copy text is unstable. It's very likely that the link could change to "Write a New Article" as it goes through UI revisions. For that reason, the first two options are poor choices.

On the other hand, the DOM ID is generally stable. They're commonly used as the interface between the DOM and CSS/JavaScript, so IDs should only change if there's a compelling reason to do so. Then should we use the `:href` option?

It varies by scope. If you want to lay down a broad matcher like we have here, searching the whole page, then specifying the HREF is a good idea. The link's target is unlikely to change, so why not?

But, if we used a `within` to scope to a certain part of the page, it's reasonable to leave off the HREF to just have less code:

```ruby
visit articles_path
within('#toolbar') do
  page.should have_link("new_article")
end
```

That's a good balance of specificity without getting too brittle.

#### `have_selector` / `has_selector?`

The `has_selector?` method is documented here: http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Matchers#has_selector%3F-instance_method

`has_selector?` is a general purpose search of the page that will find elements using CSS expressions. It's basically a more targeted version of `has_content?` useful for verifying the existence of DOM elements. For instance, we might write something like:

```ruby
visit article_path(article)
page.should have_selector("h2#article_title")
```

That matcher validates that there is, specifically, an H2 tag with the ID `"article_title"`. We could get more specific and also check the contents of the element:

```ruby
visit article_path(article)
page.should have_selector("h2#article_title", text: article.title)
```

This can be a great tool when you're validating the functionality of a form. Visit the form, fill it in, submit it, then verify that the resulting page has the text you entered in an H2 tag.

Be cautious when you're using `have_selector`, though. It's easy to write tests that become brittle by tying them too closely to the details of the HTML design. Think about "Should this test break if X tag is changed?" If your SEO expert decides to change the article title to an H1, should that break your tests? There's no blanket answer, you have to decide what makes sense for your application.

#### Other Matchers

There are several other matchers that look for specific form element types, search the DOM via XPath, work with tables, etc. Check them out here:

http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Matchers#has_selector%3F-instance_method

You'll notice that there are `_no_` methods like `has_no_content?` defined in `Capybara::Node::Matchers`, but they don't have RSpec aliases in `Capybara::RSpecMatchers`. When writing RSpec we'd handle the negative case like this:

```ruby
visit article_path(article)
page.should_not have_selector("h1", text: "All Articles)
```

This relies on RSpec's built in `should_not` rather than handling the negation with the Capybara selector.
