---
layout: page
title: Creating a Web Interface
sidebar: true
---

This tutorial builds on the code written in [Driving the Domain Model Using
TDD](/academy/workshops/ideabox/tdd.html).

## Wiring up Sinatra and Rack::Test

We need to update the Gemfile:

```ruby
source 'https://rubygems.org'

gem 'sinatra', require: 'sinatra/base'

group :test do
  gem 'minitest' # or 'rspec'
  gem 'rack-test'
end
```

Run `bundle install` to get any missing dependencies.

Then we need a test that will prove that we've wired everything up correctly.

### Using Minitest

Create a file `test/app_test.rb` with the following code in it:

```ruby
require './test/test_helper'
require 'sinatra/base'
require 'rack/test'
require './lib/app'

class IdeaboxAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    IdeaboxApp
  end

  def test_hello
    get '/'
    assert_equal "Hello, World!", last_response.body
  end
end
```

### Using RSpec

Create a file `spec/app_spec.rb` with the following code in it:

```ruby
require 'sinatra/base'
require 'rack/test'
require './lib/app'

describe IdeaboxApp do
  include Rack::Test::Methods

  def app
    IdeaboxApp
  end

  it 'returns "Hello, World!" from the root' do
    get '/'
    expect(last_response.body).to eq("Hello, World!")
  end
end
```

### Getting to Green

This is failing.

{% terminal %}
cannot load such file -- ./lib/app (LoadError)
{% endterminal %}

To get it to pass, create a file `lib/app.rb`, and add a
small Sinatra application to it:

```ruby
class IdeaboxApp < Sinatra::Base
  get '/' do
    "Hello, World!"
  end
end
```

That's it. We have a Sinatra application, and it's tested!

### Running the app in the Browser

It's a web application, but we can't actually run it in the browser yet.

Change the `app.rb` file:

```ruby
require 'bundler'
Bundler.require
require './lib/ideabox'

class IdeaboxApp < Sinatra::Base
  get '/' do
    "Hello, World!"
  end

  run! if app_file == $0
end
```

Now you can start the application like this:

{% terminal %}
ruby lib/app.rb
{% endterminal %}

Visit the application at [localhost:4567](http://localhost:4567).

It's not very impressive. Also, this is not the standard way to organize a
Sinatra app.

Let's create a rackup file (`config.ru`) to run it.

```ruby
require 'bundler'
Bundler.require(:default)

require './lib/app'

run IdeaboxApp
```

Now clean up the `app.rb` file, deleting the line with `run` in it:

```ruby
class IdeaboxApp < Sinatra::Base

  get '/' do
    "Hello, World!"
  end

end
```

Kill the application and start it again like this:

{% terminal %}
rackup -p 4567
{% endterminal %}

Visit the browser. Our very minimal page is still working.

## Rendering Ideas

Let's make it actually render some ideas.

Replace the simple "hello" test with this test:

```ruby
# minitest
def test_idea_list
  IdeaStore.save Idea.new("dinner", "spaghetti and meatballs")
  IdeaStore.save Idea.new("drinks", "imported beers")
  IdeaStore.save Idea.new("movie", "The Matrix")

  get '/'

  [
    /dinner/, /spaghetti/,
    /drinks/, /imported beers/,
    /movie/, /The Matrix/
  ].each do |content|
    assert_match content, last_response.body
  end
end

# rspec
it "displays a list of ideas" do
  IdeaStore.save Idea.new("dinner", "spaghetti and meatballs")
  IdeaStore.save Idea.new("drinks", "imported beers")
  IdeaStore.save Idea.new("movie", "The Matrix")

  get '/'

  [
    /dinner/, /spaghetti/,
    /drinks/, /imported beers/,
    /movie/, /The Matrix/
  ].each do |content|
    expect(last_response.body).to match(content)
  end
end
```

### Following the Trail of Test Failures

The test is not passing anymore:

{% terminal %}
NameError: uninitialized constant IdeaStore
{% endterminal %}

We need to make the `IdeaStore` and `Idea` classes available to the
application.

A typical Ruby project is organized like this:

```plain
lib
└── ideabox
    ├── idea.rb
    └── idea_store.rb
└── ideabox.rb
```

The `ideabox.rb` file will contain all the `require` statements for the files
that live in `./lib/ideabox`, which will make it possible to require the
entire application, just by saying `require './lib/ideabox'.

Let's make it so. Add the require statement to `./lib/app.rb`:

```ruby
require './lib/ideabox'

class IdeaboxApp < Sinatra::Base
  # ...
end
```

This gets us a new error from the test suite:

{% terminal %}
cannot load such file -- ./lib/ideabox
{% endterminal %}

Add the missing file, and run the tests again.

{% terminal %}
NameError: uninitialized constant IdeaStore
{% endterminal %}

We need to add the require statements for `idea` and `idea_store` to the
`./lib/ideabox.rb` file:

```ruby
require './lib/ideabox/idea'
require './lib/ideabox/idea_store'
```

This finally gets us the expected failure:

{% terminal %}
expected "Hello, World!" to match /dinner/
-/dinner/
+"Hello, World!"
{% endterminal %}

To make the test pass we need to tell the application to render a view:

```ruby
require './lib/ideabox'

class IdeaboxApp < Sinatra::Base
  set :root, "./lib/app"

  get '/' do
    erb :index, locals: {ideas: IdeaStore.all}
  end
end
```

Notice the `set :root` line. That tells the Sinatra app to look for the view templates in a directory `lib/app/views`.

Create the directory:

{% terminal %}
$ mkdir -p lib/app/views
{% endterminal %}

Then create the template that the test is expecting:

{% terminal %}
$ touch lib/app/views/index.erb
{% endterminal %}

Add a simple HTML page to the view template, looping through the collection of
`ideas`:

```ruby
<!DOCTYPE html>
<html>
  <head>
    <title>IdeaBox</title>
  </head>
  <body>
    <h1>Ideas</h1>
    <ul>
      <% ideas.each do |idea| %>
        <li><%= idea.title %> - <%= idea.description %></li>
      <% end %>
    </ul>
  </body>
</html>
```

This should get the test passing, but since we're creating ideas, it may be
breaking the other tests.

We need to clean up after ourselves. Create a `teardown` method (Minitest) or
a `after` block (RSpec):

```ruby
# minitest
def teardown
  IdeaStore.delete_all
end

# rspec
after(:each) do
  IdeaStore.delete_all
end
```

Commit your changes.

### Seeing the Ideas in the Browser

Kill the running application, and restart it (`rackup -p4567`), and reload the
page in the browser.

It's pretty empty-looking. That's because we haven't stored any ideas. We need
a way to add ideas.

## Adding an Input Form

Because filling in form fields is a pain, we're going to use Capybara to fill in the fields and submit the form, and verify that the page contains the new idea.

We need a another gem in the test group:

```ruby
gem 'capybara'
```

Also, if you're using Minitest, you'll need to add:

```ruby
gem 'minitest-capybara'
```

Run `bundle install` to get the required dependencies.

### Using Capybara

Until now, we've created test files that mirror a production file:

```plain
lib/ideabox/idea.rb
test/ideabox/idea_test.rb
spec/ideabox/idea_spec.rb

lib/ideabox/idea_store.rb
test/ideabox/idea_store_test.rb
spec/ideabox/idea_store_spec.rb

lib/app.rb
test/app_test.rb
spec/app_spec.rb
```

Now we're going to depart from this pattern a bit, and write an integration
test.

### Using Minitest

Create a new directory:

{% terminal %}
mkdir test/integration/
{% endterminal %}

Add a new file:

```plain
test/integration/idea_management_test.rb
```

Add the following code to the test file:

```ruby
require './test/test_helper'
require 'sinatra/base'
require 'rack/test'
require 'capybara'
require 'capybara/dsl'

require './lib/app'

Capybara.app = IdeaboxApp

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :headers =>  { 'User-Agent' => 'Capybara' })
end

class IdeaManagementTest < Minitest::Test
  include Capybara::DSL

  def teardown
    IdeaStore.delete_all
  end

  def test_display_ideas
    IdeaStore.save Idea.new("eat", "chocolate chip cookies")
    visit '/'
    assert page.has_content?("chocolate chip cookies")
  end
end
```

### Using RSpec

Create a new directory:

{% terminal %}
mkdir spec/integration/
{% endterminal %}

Add a new file:

```plain
spec/integration/idea_management_spec.rb
```

Add the following code to the test file:

```ruby
require 'sinatra/base'
require 'rack/test'
require 'capybara'
require 'capybara/dsl'

require './lib/app'

Capybara.app = IdeaboxApp

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :headers =>  { 'User-Agent' => 'Capybara' })
end

describe "managing ideas" do
  include Capybara::DSL

  after(:each) do
    IdeaStore.delete_all
  end

  it "displays ideas" do
    IdeaStore.save Idea.new("eat", "chocolate chip cookies")
    visit '/'
    expect(page).to have_content("chocolate chip cookies")
  end
end
```

### Running the Test

This test suite can be run in exactly the same way as the others:

```ruby
rake # if you have a Rakefile
ruby test/integration/idea_management_test.rb # if you're using minitest
rspec spec/integration/idea_management_spec.rb # if you're using rspec
```

This test doesn't do anything interesting, it just verifies that our current index view is working as expected.

### A Minitest Gotcha

If the test suite blows up saying that it doesn't know anything about `Minitest::Test`, take a look at the version of minitest in your Gemfile.lock file.

It turns out that `minitest-capybara` has specified that it will only work with minitest v4.x, which is the old-school version.

To fix this, change `Minitest::Test` to `MiniTest::Unit::TestCase` everywhere.

### Committing the Changes

Since we've managed to wire together Capybara and Minitest successfully, go ahead and commit your changes.

### Implementing a Real Acceptance Test

Capybara tests are end-to-end tests. They'll test an entire happy path of one feature. They're more like sagas than stories. Epic tails of resounding success. Failures should be tested in lower-level tests.

Delete the existing test (`test_displays_ideas` or `it "displays ideas"`) and
replace it with an empty test and some pseudo-code to guide you through the
next step.

We'll simulate a user who creates, edits, and deletes an idea.

```ruby
# minitest
def test_manage_ideas
  # Create an idea

  # Edit the idea

  # Delete the idea

end

# rspec
it "manages ideas" do
  # Create an idea

  # Edit the idea

  # Delete the idea

end
```

This is the first part of the test:

```ruby
# Create an idea
visit '/'
fill_in 'title', :with => 'eat'
fill_in 'description', :with => 'chocolate chip cookies'
click_button 'Save'
```

Then we'll need an assertion to make sure that everything up to now is
working:

```ruby
# minitest
assert page.has_content?("chocolate chip cookies"), "Idea is not on page"

# rspec
expect(page).to  have_content("chocolate chip cookies")
```

To start making this pass we need to put a form in the `index.erb` page.

This is the updated index page:

```ruby
<!DOCTYPE html>
<html>
  <head>
    <title>IdeaBox</title>
  </head>
  <body>
    <h1>Add a new idea</h1>
    <form action='/' method='POST'>
      <input type='text' name='title'/><br/>
      <textarea name='description'></textarea><br/>
      <input type='submit' value="Save"/>
    </form>

    <h2>Your ideas</h2>
    <ul>
      <% ideas.each do |idea| %>
        <li><%= idea.title %> - <%= idea.description %></li>
      <% end %>
    </ul>
  </body>
</html>
```

That gets us half-way there, but when we click Save, we're stuck. We need a new endpoint in the application, `POST /`, and we don't want to be writing that without a controller test.

Put the Capybara test on hold, and go to the `test/app_test.rb` or
`spec/app_spec.rb` file.

```ruby
# minitest
def test_create_idea
  post '/', title: 'costume', description: "scary vampire"

  assert_equal 1, IdeaStore.count

  idea = IdeaStore.all.first
  assert_equal "costume", idea.title
  assert_equal "scary vampire", idea.description
end

# rspec
it "stores an idea" do
  post '/', title: 'costume', description: "scary vampire"

  expect(IdeaStore.count).to eq(1)

  idea = IdeaStore.all.first
  expect(idea.title).to eq("costume")
  expect(idea.description).to eq("scary vampire")
end
```

To get the test passing, create a `POST '/'` endpoint in `IdeaboxApp`:

```ruby
post '/' do
  idea = Idea.new(params[:title], params[:description])
  IdeaStore.save(idea)
  redirect '/'
end
```

Now go back to the Capybara test, which should pass.

Commit your changes.

### Editing Ideas

At the very top of your _manage ideas_ test, create a couple of extra ideas.
These are decoys that prove that we're editing the right thing later.

```ruby
IdeaStore.save Idea.new("laundry", "buy more socks")
IdeaStore.save Idea.new("groceries", "macaroni, cheese")
```

Then below it, we will visit the page and ensure that the decoy ideas are
present:

```ruby
visit '/'
```

In Minitest, this looks like this:

```ruby
assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page"
assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page"
```

The same assertions in RSpec look like this:

```ruby
expect(page).to have_content("buy more socks")
expect(page).to have_content("macaroni, cheese")
```

Then we have the part that we wrote earlier, where we fill in the form with an
idea, and then verify the page:

```ruby
fill_in 'title', :with => 'eat'
fill_in 'description', :with => 'chocolate chip cookies'
click_button 'Save'
```

```ruby
# minitest
assert page.has_content?("chocolate chip cookies"), "Idea is not on page"
# rspec
expect(page).to  have_content("chocolate chip cookies")
```

Next, we need to find the idea so we can use the ID to edit it.

```ruby
idea = IdeaStore.find_by_title('eat')
```

With the idea in hand, the next step is to edit it:

```ruby
within("#idea_#{idea.id}") do
  click_link 'Edit'
end
```

This will, hypothetically take us to the edit page, which should contain a
form where the current values are pre-filled out in the fields:

```ruby
# minitest
assert_equal 'eat', find_field('title').value
assert_equal 'chocolate chip cookies', find_field('description').value

# rspec
expect(find_field('title').value).to eq('eat')
expect(find_field('description').value).to eq('chocolate chip cookies')
```

Then we need to edit the data in the form:

```ruby
fill_in 'title', :with => 'eats'
fill_in 'description', :with => 'chocolate chip oatmeal cookies'
click_button 'Save'
```

and prove that saving the idea changed the values.

We can't just go straight to the database to prove this, since it's an
end-to-end test. We need to make sure that the edited idea is being displayed
on the page, and that the decoys remain unchanged:

```ruby
# minitest
assert page.has_content?("chocolate chip oatmeal cookies"), "Updated idea is not on page"
assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page"
assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page"

# rspec
expect(page).to have_content("chocolate chip oatmeal cookies")
expect(page).to have_content("buy more socks")
expect(page).to have_content("macaroni, cheese")
```

We also want to make sure that the original values (the ones that got edited)
are no longer there, because we could have created a new idea rather than
editing the existing one:

```ruby
# minitest
refute page.has_content?("chocolate chip cookies"), "Original idea is on page still"

# rspec
expect(page).not_to have_content("chocolate chip cookies")
```

This is a very long test, and we're not done yet. If you get stuck, try
sticking `print page.html` at the place in your test where you're stuck.

Notice that we need an extra method on IdeaStore, `find_by_title`, to get this
working.

Add a test to the IdeaStoreTest to drive the new method.

```ruby
# minitest
def test_find_by_title
  IdeaStore.save Idea.new("dance", "like it's the 80s")
  IdeaStore.save Idea.new("sleep", "like a baby")
  IdeaStore.save Idea.new("dream", "like anything is possible")

  idea = IdeaStore.find_by_title("sleep")

  assert_equal "like a baby", idea.description
end

# rspec
it "finds by title" do
  IdeaStore.save Idea.new("dance", "like it's the 80s")
  IdeaStore.save Idea.new("sleep", "like a baby")
  IdeaStore.save Idea.new("dream", "like anything is possible")

  idea = IdeaStore.find_by_title("sleep")

  expect(idea.description).to eq("like a baby")
end
```

Here is the code to get the test to pass:

```ruby
def self.find_by_title(text)
  all.find do |idea|
    idea.title == text
  end
end
```

Then we need an edit link in the index page. Update the list of ideas:

```erb
<h2>Your ideas</h2>
<ul>
  <% ideas.each do |idea| %>
    <li id="idea_<%= idea.id %>">
      <%= idea.title %> - <%= idea.description %>
      <a href="/<%= idea.id %>">Edit</a>
    </li>
  <% end %>
</ul>
```

When we click _Edit_ we need to go to a `GET /:id` url.

It doesn't have any fancy behavior, so let's create the endpoint for it in `app.rb`:

```ruby
get '/:id' do |id|
  idea = IdeaStore.find(id.to_i)
  erb :edit, locals: {idea: idea}
end
```

This requires an `edit.erb` view:

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>IdeaBox</title>
  </head>
  <body>
    <h1>Edit your idea</h1>
    <form action="/<%= idea.id %>" method="POST">
      <label for="title">Title</label>
      <input type='text' id="title" name="title" value="<%= idea.title %>"/><br/>
      <label for="description">Description</label>
      <textarea id="description" name="description"><%= idea.description %></textarea><br/>
      <input type='submit' value='Save'/>
    </form>
  </body>
</html>
```

At this point we can't get any further without a `PUT /:id` endpoint to update
the attributes.

Since this endpoint does more than just render a view, we need drop down into
the `app_test.rb` and add a test for it.

```ruby
# minitest
def test_update_idea
  id = IdeaStore.save Idea.new('sing', 'happy songs')

  put "/#{id}", {title: 'yodle', description: 'joyful songs'}

  assert_equal 302, last_response.status

  idea = IdeaStore.find(id)
  assert_equal 'yodle', idea.title
  assert_equal 'joyful songs', idea.description
end

# rspec
it "updates an idea" do
  id = IdeaStore.save Idea.new('sing', 'happy songs')

  put "/#{id}", {title: 'yodle', description: 'joyful songs'}

  expect(last_response.status).to eq(302)

  idea = IdeaStore.find(id)
  expect(idea.title).to eq('yodle')
  expect(idea.description).to eq('joyful songs')
end
```

Here's the code to get the test running green:

```ruby
put '/:id' do |id|
  idea = IdeaStore.find(id.to_i)
  idea.title = params[:title]
  idea.description = params[:description]
  IdeaStore.save(idea)
  redirect '/'
end
```

Now we have what we need to complete the Capybara test.

It's currently failing.

HTTP has a a number of verbs (`GET`, `POST`, `PUT`, etc), however HTML is
somewhat limited. It only knows about `GET` and `POST`.

So we need our HTML form (which sends a `POST` request) to be understood to be
a `PUT` request by the Sinatra application.

A common hack for this is to send a parameter named `_method`, which the
application will then translate to the correct verb, passing the request to
the correct endpoint in the application.

Add a hidden field for `_method` in the edit form:

```erb
<input type="hidden" name="_method" value="PUT">
```

This is called _method override_ in Sinatra, and can be turned on with the
following code:

```ruby
set :method_override, true
```

The Sinatra application now looks like this:

```ruby
class IdeaboxApp < Sinatra::Base
  set :method_override, true
  set :root, "./lib/app"

  # ...
end
```

All the tests in the entire application  should now be passing.

### Deleting Ideas

So far, in the Capybara test we've ensured that we can:

* create ideas
* display a list of all ideas
* edit ideas

Here's what the test looks like so far in Minitest:

```ruby
def test_manage_ideas
  # Create a couple of decoys
  IdeaStore.save Idea.new("laundry", "buy more socks")
  IdeaStore.save Idea.new("groceries", "macaroni, cheese")

  # Verify that the decoys are being displayed
  visit '/'
  assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page"
  assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page"

  # Create an idea
  fill_in 'title', :with => 'eat'
  fill_in 'description', :with => 'chocolate chip cookies'
  click_button 'Save'
  assert page.has_content?("chocolate chip cookies"), "Idea is not on page"

  # Find the newly created idea
  idea = IdeaStore.find_by_title('eat')

  # Click the idea's edit link
  within("#idea_#{idea.id}") do
    click_link 'Edit'
  end

  # Verify that the edit form is correctly filled out
  assert_equal 'eat', find_field('title').value
  assert_equal 'chocolate chip cookies', find_field('description').value

  # Change the idea's attributes
  fill_in 'title', :with => 'eats'
  fill_in 'description', :with => 'chocolate chip oatmeal cookies'
  click_button 'Save'

  # Make sure the idea has been updated
  assert page.has_content?("chocolate chip oatmeal cookies"), "Updated idea is not on page"

  # Make sure the decoys are untouched
  assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page after update"
  assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page after update"

  # Make sure the original idea is no longer there
  refute page.has_content?("chocolate chip cookies"), "Original idea is on page still"
end
```

In RSpec, this is what the Capybara test looks like:

```ruby
it "manages ideas" do
  # Create a couple of decoys
  IdeaStore.save Idea.new("laundry", "buy more socks")
  IdeaStore.save Idea.new("groceries", "macaroni, cheese")

  # Verify that the decoys are being displayed
  visit '/'
  expect(page).to have_content("buy more socks")
  expect(page).to have_content("macaroni, cheese")

  # Create an idea
  fill_in 'title', :with => 'eat'
  fill_in 'description', :with => 'chocolate chip cookies'
  click_button 'Save'
  expect(page).to  have_content("chocolate chip cookies")

  # Find the newly created idea
  idea = IdeaStore.find_by_title('eat')

  # Click the idea's edit link
  within("#idea_#{idea.id}") do
    click_link 'Edit'
  end

  # Verify that the edit form is correctly filled out
  expect(find_field('title').value).to eq('eat')
  expect(find_field('description').value).to eq('chocolate chip cookies')

  # Change the idea's attributes
  fill_in 'title', :with => 'eats'
  fill_in 'description', :with => 'chocolate chip oatmeal cookies'
  click_button 'Save'

  # Make sure the idea has been updated
  expect(page).to have_content("chocolate chip oatmeal cookies")

  # Make sure the decoys are untouched
  expect(page).to have_content("buy more socks")
  expect(page).to have_content("macaroni, cheese")

  # Make sure the original idea is no longer there
  expect(page).not_to have_content("chocolate chip cookies")
end
```

#### Expanding the Capybara test once again

At the bottom of the test, add the interaction that will delete the idea:

```ruby
# Delete the idea
within("#idea_#{idea.id}") do
  click_button 'Delete'
end
```

Then we need more assertions.

In Minitest, these assertions look like this:

```ruby
# Make sure the idea is gone
refute page.has_content?("chocolate chip oatmeal cookies"), "Idea is not on page"

# Make sure the decoys are still untouched
assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page after delete"
assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page after delete"
```

In RSpec, the final assertions go like this:

```ruby
# Make sure the idea is gone
expect(page).not_to have_content("chocolate chip oatmeal cookies")

# Make sure the decoys are still untouched
expect(page).to have_content("buy more socks")
expect(page).to have_content("macaroni, cheese")
```

#### Getting the last bit passing

We need a delete button in the `index.erb`:

```erb
<h2>Your ideas</h2>
<ul>
  <% ideas.each do |idea| %>
    <li id="idea_<%= idea.id %>">
      <%= idea.title %> - <%= idea.description %>
      <a href="/<%= idea.id %>">Edit</a>
      <form action='/<%= idea.id %>' method='POST'>
        <input type="hidden" name="_method" value="DELETE">
        <input type='submit' value="Delete"/>
      </form>
    </li>
  <% end %>
</ul>
```

Once again, we need an endpoint that does more than render a view. Add a skip
to the capybara test, and drop down to `app_test.rb`:

```ruby
# minitest
def test_delete_idea
  id = IdeaStore.save Idea.new('breathe', 'fresh air in the mountains')

  assert_equal 1, IdeaStore.count

  delete "/#{id}"

  assert_equal 302, last_response.status
  assert_equal 0, IdeaStore.count
end

# rspec
it "deletes an idea" do
  id = IdeaStore.save Idea.new('breathe', 'fresh air in the mountains')

  expect(IdeaStore.count).to eq(1)

  delete "/#{id}"

  expect(last_response.status).to eq(302)
  expect(IdeaStore.count).to eq(0)
end
```

Here's the Sinatra endpoint that will make the test pass:

```ruby
delete '/:id' do |id|
  IdeaStore.delete(id.to_i)
  redirect '/'
end
```

This gets the rest of the Capybara test to green.

Commit your changes.

### Liking and Ranking Ideas

Our domain model allows us to like ideas, but the web interface doesn't expose
this yet.

Add a new Capybara test that clicks `+1` a number of times on different ideas and then verifies that the ideas are sorted in the expected order.

Here's the Capybara test I wrote in Minitest:

```ruby
def test_ranking_ideas
  id1 = IdeaStore.save Idea.new("fun", "ride horses")
  id2 = IdeaStore.save Idea.new("vacation", "camping in the mountains")
  id3 = IdeaStore.save Idea.new("write", "a book about being brave")

  visit '/'

  idea = IdeaStore.all[1]
  idea.like!
  idea.like!
  idea.like!
  idea.like!
  idea.like!
  IdeaStore.save(idea)

  within("#idea_#{id2}") do
    3.times do
      click_button '+'
    end
  end

  within("#idea_#{id3}") do
    click_button '+'
  end

  ideas = page.all('li')
  assert_match /camping in the mountains/, ideas[0].text
  assert_match /a book about being brave/, ideas[1].text
  assert_match /ride horses/, ideas[2].text
end
```

And here is the Capybara test in RSpec:

```ruby
it "allows ranking of ideas" do
  id1 = IdeaStore.save Idea.new("fun", "ride horses")
  id2 = IdeaStore.save Idea.new("vacation", "camping in the mountains")
  id3 = IdeaStore.save Idea.new("write", "a book about being brave")

  visit '/'

  idea = IdeaStore.all[1]
  idea.like!
  idea.like!
  idea.like!
  idea.like!
  idea.like!
  IdeaStore.save(idea)

  within("#idea_#{id2}") do
    3.times do
      click_button '+'
    end
  end

  within("#idea_#{id3}") do
    click_button '+'
  end

  ideas = page.all('li')
  expect(ideas[0].text).to match(/camping in the mountains/)
  expect(ideas[1].text).to match(/a book about being brave/)
  expect(ideas[2].text).to match(/ride horses/)
end
```

The index page needs another button form:

```erb
<h2>Your ideas</h2>
<ul>
  <% ideas.each do |idea| %>
    <li id="idea_<%= idea.id %>">
      <%= idea.rank %>: <%= idea.title %> - <%= idea.description %>
      <a href="/<%= idea.id %>">Edit</a>
      <form action='/<%= idea.id %>' method='POST'>
        <input type="hidden" name="_method" value="DELETE">
        <input type='submit' value="Delete"/>
      </form>
      <form action='/<%= idea.id %>/like' method='POST' style="display: inline">
        <input type='submit' value="+"/>
      </form>
    </li>
  <% end %>
</ul>
```

The test blows up because we don't have a `like` endpoint in the Sinatra
application.

Drop down to the controller test and add this test:

```ruby
# minitest
def test_like_idea
  id = IdeaStore.save Idea.new('run', 'really, really fast')

  post "/#{id}/like"

  assert_equal 302, last_response.status

  idea = IdeaStore.find(id)
  assert_equal 1, idea.rank
end

# rspec
it "likes an idea" do
  id = IdeaStore.save Idea.new('run', 'really, really fast')

  post "/#{id}/like"

  expect(last_response.status).to eq(302)

  idea = IdeaStore.find(id)
  expect(idea.rank).to eq(1)
end
```

This will return a 404. Add the endpoint:

```ruby
post '/:id/like' do |id|
  idea = IdeaStore.find(id.to_i)
  idea.like!
  redirect '/'
end
```

### Sorting the Ideas on the Index Page

The Capybara test still isn't passing.

The Sinatra endpoint is sending all the ideas to the page, but they're
unsorted. We need to update the list to be ranked, highest first:

```ruby
get '/' do
  erb :index, locals: {ideas: IdeaStore.all.sort.reverse}
end
```

Finally, the Capybara test is happy. Your web application is exposing all the
behavior that is supported in the domain model.

Restart the application with `rackup -p4567` and visit the page in the
browser, and try out your application.

Commit your changes, pat yourself on the back, and celebrate.

## Next Steps

Kill your application and restart it.

It turns out there is more work to be done. The application is storing the
ideas in memory. We need a more persistent form of storage.

