---
layout: page
title: Creating a Web Interface
date: 2013-11-06
---

**NOTE** These are all just raw notes.

## Wiring up Sinatra and Rack::Test

We need to update the Gemfile:

```ruby
source 'https://rubygems.org'

gem 'sinatra', require: 'sinatra/base'

group :test do
  gem 'minitest', require: false
  gem 'rack-test', require: false
end
```

Then we need a test that will prove that we've wired everything up correctly:

```ruby
require './test/test_helper'
require 'sinatra/base'
require 'rack/test'
require './lib/app'

class IdeaboxAppHelper < Minitest::Test
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

This is failing. To get it to pass, create a file `lib/app.rb`:

```ruby
class IdeaboxApp < Sinatra::Base
  get '/' do
    "Hello, World!"
  end
end
```

It's all wired together. Let's make it actually render some ideas.

Replace the `test_hello` test with this test:

```ruby
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
```

Since we're now creating ideas, it's breaking our other tests. We need to clean up after ourselves. Create a `teardown` method:

```ruby
def teardown
  IdeaStore.delete_all
end
```

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

We don't want to require each individual file from the `app.rb`. Create a file `lib/ideabox.rb` with this in it:

```ruby
require './lib/ideabox/idea'
require './lib/ideabox/idea_store'
```

It still blows up, because we don't have a view. Create a file
`lib/app/views/index.erb`:

```ruby
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

This should get the test passing.

Commit your changes.

### Run it in the Browser

It's a web application, but we can't actually run it in the browser yet.

Change the `app.rb` file:

```ruby
require 'bundler'
Bundler.require
require './lib/ideabox'

class IdeaboxApp < Sinatra::Base
  set :root, "./lib/app"

  get '/' do
    erb :index, locals: {ideas: IdeaStore.all}
  end

  run! if app_file == $0
end
```

Now you can start the application like this:

{% terminal %}
ruby lib/app.rb
{% endterminal %}

Visit the application at [localhost:4567](http://localhost:4567).

There's nothing there, because we haven't added any ideas.

Also, this is not the standard way to organize a Sinatra app. Let's create a rackup file (`config.ru`) to run it.

```ruby
require 'bundler'
Bundler.require

require './lib/app'

run IdeaboxApp
```

Now clean up the `app.rb` file:

```ruby
require './lib/ideabox'

class IdeaboxApp < Sinatra::Base
  set :root, "./lib/app"

  get '/' do
    erb :index, locals: {ideas: IdeaStore.all}
  end

end
```

Kill the application and start it again like this:

{% terminal %}
rackup -p 4567
{% endterminal %}

Visit the browser. Our very minimal page is still working.

We can't actually add any ideas because there's no form to do so.

I guess we better add that.

## Adding an Input Form

Because filling in form fields is a pain, we're going to use Capybara to fill in the fields and submit the form, and verify that the page contains the new idea.

We need a couple more gems in the test group:

```ruby
gem 'capybara', require: false
gem 'minitest-capybara', require: false
```

Bundle.

Create a new directory:

```plain
test/acceptance/
```

Add a new file:

```plain
test/acceptance/idea_management_test.rb
```

```ruby
require './test/test_helper'
require 'bundler'
Bundler.require
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

  def test_manage_ideas
    IdeaStore.save Idea.new("eat", "chocolate chip cookies")
    visit '/'
    assert page.has_content?("chocolate chip cookies")
  end
end
```

This test doesn't do anything interesting, it just verifies that our current index view is working as expected.

If the test suite blows up saying that it doesn't know anything about `Minitest::Test`, take a look at the version of minitest in your Gemfile.lock file.

It turns out that `minitest-capybara` has specified that it will only work with minitest v4.x, which is the old-school version.

To fix this, change `Minitest::Test` to `MiniTest::Unit::TestCase` everywhere.

Since we've managed to wire together Capybara and Minitest successfully, go ahead and commit your changes.

### Implementing a Real Acceptance Test

Capybara tests are end-to-end tests. They'll test an entire happy path of one feature. They're more like sagas than stories. Epic tails of resounding success. Failures should be tested in lower-level tests.

```ruby
def test_manage_ideas
  # Create an idea

  # Edit the idea

  # Delete the idea

end
```

We'll simulate a user who creates, edits, and deletes an idea.

This is the first part of the test:

```ruby
def test_manage_ideas
  # Create an idea
  visit '/'
  fill_in 'title', :with => 'eat'
  fill_in 'description', :with => 'chocolate chip cookies'
  click_button 'Save'
  assert page.has_content?("chocolate chip cookies"), "Idea is not on page"

  # Edit the idea

  # Delete the idea

end
```

To start making this pass we need to put a form in the `index.erb` page.

This is the updated index page:

```ruby
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

Put a `skip` in the capybara test, and go to the `app_test.rb` file.

```ruby
def test_create_idea
  post '/', title: 'costume', description: "scary vampire"

  assert_equal 1, IdeaStore.count

  idea = IdeaStore.all.first
  assert_equal "costume", idea.title
  assert_equal "scary vampire", idea.description
end
```

Make the test pass:

```ruby
post '/' do
  idea = Idea.new(params[:title], params[:description])
  IdeaStore.save(idea)
  redirect '/'
end
```

Now try unskipping the capybara test. It should pass.

Commit your changes.

### Editing Ideas

```ruby
def test_manage_ideas
  skip
  # Create a couple of decoys
  # This is so we know we're editing the right thing later
  IdeaStore.save Idea.new("laundry", "buy more socks")
  IdeaStore.save Idea.new("groceries", "macaroni, cheese")

  # Create an idea
  visit '/'
  # The decoys are there
  assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page"
  assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page"

  # Fill in the form
  fill_in 'title', :with => 'eat'
  fill_in 'description', :with => 'chocolate chip cookies'
  click_button 'Save'
  assert page.has_content?("chocolate chip cookies"), "Idea is not on page"

  # Find the idea - we need the ID to find
  # it on the page to edit it
  idea = IdeaStore.find_by_title('eat')

  # Edit the idea
  within("#idea_#{idea.id}") do
    click_link 'Edit'
  end

  assert_equal 'eat', find_field('title').value
  assert_equal 'chocolate chip cookies', find_field('description').value

  fill_in 'title', :with => 'eats'
  fill_in 'description', :with => 'chocolate chip oatmeal cookies'
  click_button 'Save'

  # Idea has been updated
  assert page.has_content?("chocolate chip oatmeal cookies"), "Updated idea is not on page"

  # Decoys are unchanged
  assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page"
  assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page"

  # Original idea (that got edited) is no longer there
  refute page.has_content?("chocolate chip cookies"), "Original idea is on page still"

  # Delete the idea

end
```

If you get stuck, try sticking `print page.html` at the place in your test where you're stuck.

Notice that we need an extra method on IdeaStore to get this working.

Add a test to the IdeaStoreTest:

```ruby
def test_find_by_title
  IdeaStore.save Idea.new("dance", "like it's the 80s")
  IdeaStore.save Idea.new("sleep", "like a baby")
  IdeaStore.save Idea.new("dream", "like anything is possible")

  idea = IdeaStore.find_by_title("sleep")

  assert_equal "like a baby", idea.description
end
```

Make it pass:

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

When we click Edit we need to go to a `GET /:id` url.

It doesn't have any fancy behavior, so let's create the endpoint for it in `app.rb`:

```ruby
get '/:id' do |id|
  idea = IdeaStore.find(id.to_i)
  erb :edit, locals: {idea: idea}
end
```

This requires an `edit.erb` view:

```erb
<html>
  <head>
    <title>IdeaBox</title>
  </head>
  <body>
    <h1>Edit your idea</h1>
    <form action="/<%= idea.id %>" method="POST">
      <input type="hidden" name="_method" value="PUT">
      <label for="title">Title</label>
      <input type='text' id="title" name="title" value="<%= idea.title %>"/><br/>
      <label for="description">Description</label>
      <textarea id="description" name="description"><%= idea.description %></textarea><br/>
      <input type='submit' value='Save'/>
    </form>
  </body>
</html>
```

At this point we can't get any further without a `PUT /:id` endpoint.

Since this has behavior we'll drop down into the `app_test.rb`.
Add a `skip` to the capybara test while we test drive the new behavior.

```ruby
def test_edit_idea
  id = IdeaStore.save Idea.new('sing', 'happy songs')

  put "/#{id}", {title: 'yodle', description: 'joyful songs'}

  assert_equal 302, last_response.status

  idea = IdeaStore.find(id)
  assert_equal 'yodle', idea.title
  assert_equal 'joyful songs', idea.description
end
```

Make it pass:

```ruby
put '/:id' do |id|
  idea = IdeaStore.find(id.to_i)
  idea.title = params[:title]
  idea.description = params[:description]
  IdeaStore.save(idea)
  redirect '/'
end
```

Now we have what we need to complete the capybara test. Unskip it.

It's still failing. We need to tell Sinatra that a parameter called `_method` is to be understood to be the HTTP verb so that it uses the `PUT /:id` endpoint to respond to the update form.

Add this inside the Sinatra app, right at the top:

```ruby
set :method_override, true
```

It now looks like this:

```ruby
class IdeaboxApp < Sinatra::Base
  set :method_override, true
  set :root, "./lib/app"

  # ...
end
```

### Deleting an idea

```ruby
def test_manage_ideas
  skip
  # Create a couple of decoys
  # This is so we know we're editing the right thing later
  IdeaStore.save Idea.new("laundry", "buy more socks")
  IdeaStore.save Idea.new("groceries", "macaroni, cheese")

  # Create an idea
  visit '/'
  # The decoys are there
  assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page"
  assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page"

  # Fill in the form
  fill_in 'title', :with => 'eat'
  fill_in 'description', :with => 'chocolate chip cookies'
  click_button 'Save'
  assert page.has_content?("chocolate chip cookies"), "Idea is not on page"

  # Find the idea - we need the ID to find
  # it on the page to edit it
  idea = IdeaStore.find_by_title('eat')

  # Edit the idea
  within("#idea_#{idea.id}") do
    click_link 'Edit'
  end

  assert_equal 'eat', find_field('title').value
  assert_equal 'chocolate chip cookies', find_field('description').value

  fill_in 'title', :with => 'eats'
  fill_in 'description', :with => 'chocolate chip oatmeal cookies'
  click_button 'Save'

  # Idea has been updated
  assert page.has_content?("chocolate chip oatmeal cookies"), "Updated idea is not on page"

  # Decoys are unchanged
  assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page after update"
  assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page after update"

  # Original idea (that got edited) is no longer there
  refute page.has_content?("chocolate chip cookies"), "Original idea is on page still"

  # Delete the idea
  within("#idea_#{idea.id}") do
    click_button 'Delete'
  end

  refute page.has_content?("chocolate chip oatmeal cookies"), "Updated idea is not on page"

  # Decoys are untouched
  assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page after delete"
  assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page after delete"

end
```

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

Once again, we need an endpoint that does more than render a view. Add a skip to the capybara test, and drop down to `app_test.rb`:

```ruby
def test_delete_idea
  id = IdeaStore.save Idea.new('breathe', 'fresh air in the mountains')

  assert_equal 1, IdeaStore.count

  delete "/#{id}"

  assert_equal 302, last_response.status
  assert_equal 0, IdeaStore.count
end
```

Make it pass:

```ruby
delete '/:id' do |id|
  IdeaStore.delete(id.to_i)
  redirect '/'
end
```

Unskip the capybara test.

It should be passing.

Commit your changes.

### Liking!

Add a new capybara test that clicks `+1` a number of times on different ideas and then verifies that the ideas are sorted in the expected order.

You will need to drop down to the `app_test.rb` to test drive the `like` endpoint in the sinatra application.

Here's the test I wrote:

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

  # now check that the order is correct
  ideas = page.all('li')
  assert_match /camping in the mountains/, ideas[0].text
  assert_match /a book about being brave/, ideas[1].text
  assert_match /ride horses/, ideas[2].text
end
```

I had to add another button form on the index page:

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

Then I had to send a sorted list of ideas to the index page from the controller:

```ruby
erb :index, locals: {ideas: IdeaStore.all.sort.reverse}
```

Refactor where appropriate.

### Next Up:

Start using a `YAML::Store` so that your ideas persist when you shut down your server. You shouldn't have to change any tests.

You'll need a different database file for the test environment and the development environment.

