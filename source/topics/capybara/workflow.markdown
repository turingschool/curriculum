---
layout: page
title: Capybara Workflow
section: Testing with Capybara
---

Capybara is a great tool, but what do you actually *do* with it?

## Acceptance & Feature Tests

We use the terms "acceptance tests" and "feature tests" to mean almost the same thing -- with a nuanced difference.

### Acceptance Tests are for End Users

Acceptance tests exercise your application just like a real user. They therefore depend on the full stack from your models up through your controllers, helpers, view templates, web server, database, and middleware. 

Acceptance tests are typically a translation of a user story:

```plain
As a [user]
When I [do action] 
  and [do other action]
Then I observe [result 1]
  and observer [result 2]
```

Proper acceptance tests use your application as a *black box*. They know nothing about what happens under the hood, they just interact with the interface and observe the results.

Acceptance tests are the 30,000-foot view of your application. They're focused on the happy-path, the business value driving the creation of the application.

When your user stories have been translated to acceptance tests and those tests pass, then your application is finished! Until they write more stories...

### Feature Tests are for Clients & Developers

But there are often a lot of details a little bit under the surface. What about when things go wrong? What happens when a user tries to save an article without a title? Or a title that's too short?

While we might write just a small number of acceptance tests or even just one for a user story, we can use several feature tests to drive more of the development.

### Breaking Down an Example

Let's talk about creating an article on our blog.

#### Acceptance Test

The acceptance test might go like this:

```plain
As an authenticated user
  and I'm on the articles index
When I click the new article link
  and I enter a title
  and I enter a body
  and I click the submit button
Then I observe the title I entered
  and I observe the body I entered
```

That's the happy path. Translated to Minitest and Capybara, that might go like this:

```ruby
def test_an_authenticated_user_creates_an_article
  login_as_user # you'd write this method elsewhere
  visit article_path
  click_on('new-article')
  fill_in('title', :with => "My Tester Title")
  fill_in('body', :with => "My Tester Body")
  click_on('save')
  assert page.has_css?("#title", :text => "My Tester Title")
  assert page.has_css?("#body", :text => "My Tester Body")
end
```

#### Feature Tests

The feature tests drill down just a bit deeper:

##### Create and Redirect

The concept:

```plain
As an authenticated user
  and I'm on the new article page
When I enter a title
  and I enter a body
  and I click the submit button
Then I am redirected to the article page
```

Implemented in Capybara:

```ruby
def test_an_authenticated_user_creates_an_article
  login_as_user
  visit new_article_path
  fill_in('title', :with => "Hello, World")
  fill_in('body', :with => "My Tester Body")
  click_on('save')
  id_from_path = current_path.scan(/\d+$/).first
  assert_match article_path(id_from_path), current_path
end
```

##### Body is Required

Conceptually...

```plain
As an authenticated user
  and I'm on the new article page
When I enter a title
  but I do not enter a body
  and I click the submit button
Then I am returned to the form
  and I see an error message that a body is required
```

Implemented with Capybara:

```ruby
def test_an_authenticated_user_creates_an_article
  login_as_user
  visit new_article_path
  fill_in('title', :with => "Hello, World")
  fill_in('body', :with => "")
  click_on('save')
  assert page.current_path(new_article_path)
  assert page.has_css?("#error", :text => "body")
end
```

##### Titles Are Unique

Conceptually:

```plain
As an authenticated user
  and I'm on the new article page
  and there's an article in the system with the title "Hello, World"
When I enter a title of "Hello, World"
  and I enter a body
  and I click the submit button
Then I am returned to the form
  and I see an error message that the title has already been used
```

Implemented with Capybara:

```ruby
def test_an_authenticated_user_creates_an_article
  login_as_user
  visit new_article_path
  create_article(:title => "Hello, World") # write this method elsewhere
  fill_in('title', :with => "Hello, World")
  fill_in('body', :with => "My Tester Body")
  click_on('save')
  assert page.current_path(new_article_path)
  assert page.has_css?("#error", :text => "title")
end
```

### Maintaining the Veil

The goal of both acceptance and feature tests is to know very little about your application. If they need some data to be in the app, the test needs to create that data first.

But that can be a real pain, not to mention slow. Imagine you're writing a suite of tests focused on the admin functionality in your appliction. If you keep your suite conceptually pure, then **every test** needs to:

* Register a new user
* Confirm a user
* Upgrade the user to an administrator (how does this even happen?)

Each of those happens *before* you get to the meat of the test. You could easily wait a long time for all that to complete, end up with a slow test suite, and either (A) waste development time or (B) stop running the tests. Both are bad.

#### Making Compromises

When you do these kinds of tests you'll have to make compromises. But you want to *encapsulate* those cheats so you can pull them out later.

In the examples above, we used this method:

```
login_as_user
```

You can assume what that method does, but how does it do it? From the test, *you don't care*. By abstracting the steps for that method, the test can maintain a consistent level of abstraction from the application's implementation.

*Inside* the method, it very well might do something like this:

```ruby
def login_as_user
  visit new_user_path
  fill_in "name", :with => "Sample User"
  fill_in "password", :with => "samplepass"
  fill_in "password_confirmation", :with => "samplepass"
  click_on "save"
  visit login_path
  fill_in "name", :with => "Sample User"
  fill_in "password", :with => "samplepass"
  click_on "login"
end
```

But that's slow, right? You could also implement it in a way that reaches directly into the application:

```ruby
def login_as_user
  User.create(:name => "Sample User", :password => "samplepass")
  visit login_path(:name => "Sample User", :password => "samplepass")
end
```

Then you'd setup the controller who responds to `login_path` to allow the username and password to be passed in as URL parameters. You should **only** allow this in non-production environments because it's a potential security hole.

Do you really know that user registration is working properly? You should have tests elsewhere that examine *just* that functionality. But you have the continuous integration server who's time doesn't matter. Implement the method to use the slow approach on CI:

```ruby
def login_as_user
  if Rails.env.ci?
    login_as_user_through_interface
  else
    login_as_user_directly
  end
end

def login_as_user_through_interface
  visit new_user_path
  fill_in "name", :with => "Sample User"
  fill_in "password", :with => "samplepass"
  fill_in "password_confirmation", :with => "samplepass"
  click_on "save"
  visit login_path
  fill_in "name", :with => "Sample User"
  fill_in "password", :with => "samplepass"
  click_on "login"
end

def login_as_user_directly
  User.create(:name => "Sample User", :password => "samplepass")
  visit login_path(:name => "Sample User", :password => "samplepass")
end
```

## Outside-In Testing

### Write an Acceptance Test

### Write a Feature Test

### Dive Inside the App

#### Write a Controller Test

#### Write a Unit/Model Test

#### Repeat and Bubble-Up

### Write the Next Feature Test

Repeat.