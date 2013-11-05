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
  and observe [result 2]
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
  assert_equal new_article_path, current_path
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
  assert_equal new_article_path, current_path
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

Let's continue the example from above where you've implemented an acceptance test about posting an article. You run it and it fails.

### A Feature Test

You drop down a level to the feature tests and write this test (from above):

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

You run it and it fails, too. To focus, you go back to the acceptance test and mark it as `skip`, then re-run your suite and see just this feature test failing.

### Dive Inside the App

Now you change gears and step *inside* the application. How do you pass the test? You need:

* a `new_article_path` that displays a form
* that form to have `title` and `body` text fields and a `save` button
* a redirect to the `show` action for that article

What **don't** you need? This feature test doesn't actually compel you to store the data from the form!

Let's dive down to the controller tests.

#### Testing the Controller

We don't believe in controller tests specifying much about content, but to focus instead on functionality.

You could, for instance, write a controller test that specifies the `new` action renders a `form` partial. But why? What does it really help you learn about the design of the application? Nothing.

Your feature test is failing because the controller doesn't exist or doesn't have a `new` action. You go ahead and implement it:

```
class ArticlesController < ApplicationController
  def new
    @article = Article.new
  end
end
```

Then the test fails because the view template is missing. Go ahead and implement that template with a form:

```erb
<%= form_for @article do |f| %>
  <%= f.text_field :title, :id => 'title' %>
  <%= f.text_area :body, :id => 'body' %>
  <%= f.submit "Save Article", :id => 'save' %>
<% end %>
```

And now, finally, the feature test fails because the `create` action doesn't exist to receive the form data. 

It's time for a controller test. In `test/controller/articles_controller_test.rb`:

```
class ArticlesControllerTest < ActionController::TestCase
  def test_create_redirects_to_the_new_article
    post(:create, {'title' => "Hello, World", 'body' => "The Body"})
    assert_redirected_to article_path(assigns(:article))
  end
end
```

Check out the [Rails Testing Documentation](http://guides.rubyonrails.org/testing.html#functional-tests-for-your-controllers) for more details on what you can do in a controller test. This one submits a post request with some parameters, then checks that it gets redirected. The `assigns(:article)` checks that the action defines a variable `article` and fetches it in order to build the URL.

#### Write a Unit/Model Test

#### Repeat and Bubble-Up

### Write the Next Feature Test

Repeat.
