---
layout: page
title: Extract Ratings Service
sidebar: true
---

This tutorial blah blah blah assumes finished Extract Notifications Service (link). It's open source, please pull request and all that.

Extracting the email into a service was relatively easy. Really, it wasn't much different than the way many apps implement background workers.

Now, let's look at a more complex architecture that, rather than just "doing" an action, is used to read and write domain data.

## Introduction

Each product in the store has multiple ratings. This functionality is perfect for extraction to a service because:

* it has relatively self-contained data. The only external data dependencies are a product ID and a user ID
* it doesn't have side effects / shared functionality with other parts of the application
* it's easy to reason about as a unit of functionality

## Validating Functionality

The existing ratings do not have unit tests or controller tests. There are some feature specs, but they're incomplete.

### Using Capybara

In `spec/features/user_rates_products_spec.rb` add tests to cover the functionality.

We need:

GET /account/ratings

- in the unique list of products ordered:
-[ ] if they've rated it: show rating
-[ ] else: link to add rating
-[x] create a rating
-[x] update
-[x] create fails (incorrect params)
-[x] edit fails (incorrect params)
-[ ] edit fails (window of opportunity closed)

Also, we need a test for displaying the ratings on the products page.
`spec/features/public_user_views_products_spec.rb`

GET /products/:id
-[ ] view all the ratings for a product

### Ignoring Bugs

The current implementation has a number of issues, but we'll just ignore them.

## Reading Ratings

The easier part of the story is reading ratings from the service.

### Where Ratings (Currently) Come From

* Controller queries the model
* Model queries the database

### Loosening the Coupling

#### Hiding data that will go away

When the ratings move into the remote service, it will not make sense to expose the primary key of the database. Users should only ever have a single rating for a given product, so we can use the combination of user id and product id to access the ratings.

In order to make this possible, we'll refactor the primary app so it doesn't rely on the rating id.

$ git grep rating.id # will catch both rating.id and rating_id

* app/models/ordered_product.rb # definition
* app/views/products/_rating.html.erb # raty gem
* app/views/ratings/_product.html.erb # raty gem + edit link

Deal with raty first.

Change the dom id for the rating stars. We don't actually rely on the id being a particular value, we just need it to be unique.

* http://localhost:3000/account/ratings
* app/views/products/_rating.html.erb

Here we are showing a list of all the products the user has ordered. Since each product only occurs once in the list, we can use the product id rather than the rating id in the dom id.

* http://localhost:3000/products/4 # or whatever
* app/views/ratings/_product.html.erb

Here we are showing a product with all of its reviews. Since each user only reviews a given product once, we can use the user's id in the DOM.


Links. Let's check rake routes:

{% terminal %}
$ rake routes | grep rating
            account_ratings GET    /account/ratings(.:format)                       ratings#index
            product_ratings POST   /products/:product_id/ratings(.:format)          ratings#create
         new_product_rating GET    /products/:product_id/ratings/new(.:format)      ratings#new
        edit_product_rating GET    /products/:product_id/ratings/:id/edit(.:format) ratings#edit
             product_rating PUT    /products/:product_id/ratings/:id(.:format)      ratings#update
{% endterminal %}

Only two routes use the rating.id: edit and update

edit gets called as a link, we'll need to update both the routes and the places where the links are built to explicitly send in rating.user_id


```ruby
resources :products, only: [ :index, :show ] do
  resources :ratings, except: [ :index, :show, :destroy ]
end
```

Reverse this to use only instead of except:

```ruby
resources :products, only: [ :index, :show ] do
  resources :ratings, only: [ :new, :create, :edit, :update ]
end
```

Add a couple of extra handlers:
  get "/products/:product_id/ratings/:user_id" => "ratings#edit", as: :product_rating
  put "/products/:product_id/ratings/:user_id" => "ratings#update", as: :edit_product_rating

Then delete :edit, and :update

Verify rake routes, to see that these are now using the user id.

             product_rating GET    /products/:product_id/ratings/:user_id(.:format)         ratings#edit
        edit_product_rating PUT    /products/:product_id/ratings/:user_id(.:format)         ratings#update

change edit_product_rating_path(product, rating)
to:
change edit_product_rating_path(product.id, rating.user_id)

in app models ordered_product add a delegator for user_id
remove the delegator to rating_id

update gets called when the edit form gets submitted. We'll need to update the form action.

Rather than trying to figure out how to make the form work for both cases, let's just duplicate the form into the new and edit templates.

Inline the form, delete the partial, and then change the edit form so that the first line looks like this:

<%= simple_form_for @rating, url: product_rating_path(@rating.product_id, @rating.user_id), method: :put do |f| %>

Now if we try to submit the form the controller gets confused.

```ruby
def update
    @rating = Rating.find(params)
    # ...
end
```

We could change it to find_by_product_id_and_user_id, but that isn't going to raise an exception if it isn't found. Let's introduce a method called find_unique(params) which plucks out the user id, product id, and raises an ActiveRecord::RecordNotFound if nothing is in the database.

In rating:

```ruby
def self.find_unique(attributes)
  rating = where(user_id: attributes[:user_id], product_id: attributes[:product_id]).first
  unless rating
    raise ActiveRecord::RecordNotFound
  end
  rating
end
```

in the ratings controller:


```ruby
def edit
  @rating = Rating.find_unique(params)
  # ...
end

def update
  @rating = Rating.find_unique(params)
  # ...
end
```

Verify that everything still works.


#### Introducing an Adapter

* an adapter that will talk to the remote service. But first, use it to talk to the database.

Create a new file in `app/models/ratings_repository.rb`. Put a simple ruby object in it. We'll move all references to the Rating class into this.

There are three relevant files, let's do one at a time:

* app/controllers/products_controller.rb

```ruby
Rating.where(product_id: params[:id])
```

Change this to:

```ruby
RatingRepository.ratings_for(@product)
```

Then in the RatingRepository:

```ruby
class RatingRepository
  def self.ratings_for(product)
    Rating.where(product_id: product.id)
  end
end
```

The product listing should still work.

* app/models/ordered_product.rb

Current code:

```ruby
Rating.where(user_id: user.id)
```

Change to:

```ruby
RatingRepository.ratings_by(user)
```

In the rating repository:

```ruby
def self.ratings_by(user)
  Rating.where(user_id: user.id)
end
```

verify that the account rating page still works.

* app/controllers/ratings_controller.rb

change:

```ruby
def new
  @rating = Rating.new(product_id: params[:product_id])
  # ...
end
```

to:

```ruby
def new
  @rating = RatingRepository.new_rating(product_id: params[:product_id])
  # ...
end
```

In repository:

```ruby
def self.new_rating(attributes)
  Rating.new(attributes)
end
```

```ruby
def create
  # ...
  @rating = Rating.new(params[:rating])
  # ...
end
```

```ruby
def create
  # ...
  @rating = RatingRepository.new_rating(params[:rating])
  # ...
end
```

Then edit and update:

```ruby
def edit
  @rating = Rating.find_unique(params)
  # ...
end

def update
  @rating = Rating.find_unique(params)
  # ...
end
```

```ruby
def edit
  @rating = RatingRepository.find_unique(params)
  # ...
end

def update
  @rating = RatingRepository.find_unique(params)
  # ...
end
```

#### Introducing a simple rating proxy

Create a class called `ProxyRating`.

* a simple ruby class that will be a local stand-in for the rating object

Make the RatingRepository return ProxyRating objects rather than Rating objects.

In RatingRepository.ratings_for(product):

```ruby
def self.ratings_for(product)
  Rating.where(product_id: product.id).map {|rating|
    ProxyRating.new(rating.attributes)
  }
end
```

Flesh out the proxy rating until the product page can render.
It's OK if it's gross.

Then do the account/ratings page:

```ruby
def self.ratings_by(user)
  Rating.where(user_id: user.id).map {|rating|
    ProxyRating.new(rating.attributes)
  }
end
```

Then the new page:

In the repository class change Rating to ProxyRating in the new_rating method:

```ruby
def self.new_rating(attributes)
  ProxyRating.new(attributes)
end
```

It's going to complain that it doesn't have a `model_name`. Add:

```ruby
class ProxyRating
  extend  ActiveModel::Naming
end
```

Then it will complain about `to_key`:

```ruby
class ProxyRating
  extend  ActiveModel::Naming
  include ActiveModel::Conversion
end
```

Then it will complain about `persisted?`. If it has a created it, it's persisted.

```ruby
def persisted?
  !!created_at
end
```

Then it complains about product_proxy_ratings_path.

The form needs to be updated:

<%= simple_form_for @rating, url: product_ratings_path(@rating.product_id), method: :post do |f| %>

But then the body gets a text field rather than a textarea. Change it to:


<%= f.input :body, as: :text, input_html: { placeholder: t('placeholder.ratings.body') } %>

Also, the stars went blank.

Change it to:

<%= f.input :stars, as: :select, collection: [0,1,2,3,4,5], include_blank: false %>

Try to save - proxy object doesn't have a save. Give it one that delegates to RatingRepository, which delegates to rating.

  def save
    RatingRepository.save(attributes)
  end

  def self.save(attributes)
    Rating.new(attributes).save
  end

Then do edit:

Repo:
  def self.find_unique(attributes)
    ProxyRating.new(Rating.find_unique(attributes).attributes)
  end

The edit page complains, no `:id`.

Go to the form, and change:


  <%= simple_form_for @rating, url: product_rating_path(@rating.product_id, @rating.user_id), method: :put do |f| %>

  to:

  <%= simple_form_for :rating, url: product_rating_path(@rating.product_id, @rating.user_id), method: :put do |f| %>

The body turns into a text field, make it a text area:

<%= f.input :body, as: :text, input_html: { placeholder: t('placeholder.ratings.body') } %>

The stars have a blank option, remove it:

<%= f.input :stars, as: :select, collection: [0,1,2,3,4,5], include_blank: false %>

Submit the form, no `update_attributes`. Implement one in ProxyRating that delegates to rating.

  def update_attributes(attributes)
    RatingRepository.update(attributes.merge(user_id: user_id, product_id: product_id))
  end

  def self.update(attributes)
    Rating.find_unique(attributes).update_attributes(attributes)
  end

### Creating a Ratings Application

#### Wiring together the stand-alone application

Let's create a minimal ruby project:


.
├── Gemfile
├── README.md
├── Rakefile
├── db
├── lib
│   └── opinions.rb
└── test
    ├── opinions_test.rb
    └── test_helper.rb

The gemfile is simple:

```ruby
source 'https://rubygems.org'

group :test do
  gem 'minitest', :require => false
end
```

```ruby
module Opinions
  def self.env
    @env ||= ENV.fetch("RACK_ENV") { "development" }
  end
end
```

Test helper:

```ruby
$:.unshift File.expand_path("./../../lib", __FILE__)

gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'

ENV['RACK_ENV'] = 'test'

require 'opinions'
```

```ruby
require './test/test_helper'

class OpinionsTest < Minitest::Test
  def test_environment
    assert_equal 'test', Opinions.env
  end
end
```

and finally a rake file to automatically run all the tests:

```ruby
$:.unshift File.expand_path("./../lib", __FILE__)

require 'rake/testtask'

Rake::TestTask.new do |t|
  require 'bundler'
  Bundler.require
  t.pattern = "test/**/*_test.rb"
end

task default: :test
```

Run `rake` and the test should pass.

### Wiring up active record

Add more files:

├── config
│   ├── database.yml
│   └── environment.rb
├── db
│   ├── migrate
│   │   └── 0_initial_migration.rb
├── lib
│   ├── opinions
│   │   └── rating.rb
└── test
    └── opinions
        └── rating_test.rb

Add activerecord and sqlite3 to the gemfile:

```ruby
source 'https://rubygems.org'

gem 'activerecord', require: 'active_record'
gem 'sqlite3'

group :test do
  gem 'minitest', require: false
end
```

Create a test in test/opinions/rating_test.rb

```ruby
require './test/test_helper'

class RatingTest < Minitest::Test
  def test_existence
    rating = Opinions::Rating.new(stars: 3)
    assert_equal 3, rating.stars
  end
end
```

Run rake, and make it all pass.

You'll need to: create an empty rating class that inherits from active record

require active record and the rating class in `lib/opinions.rb`.

require the environment in the test helper instead of requiring 'opinions':

```ruby
require './config/environment'
```

```ruby
# config/environment.rb
require 'bundler'
Bundler.require
require 'yaml'

module Opinions
  class Config
    def self.db
      @config ||= YAML::load(File.open("config/database.yml"))
    end

    def self.env
      return @env if @env
      ENV['RACK_ENV'] ||= "development"
      @env = ENV['RACK_ENV']
    end

    def self.active_record
      db[env]
    end
  end
end

ActiveRecord::Base.establish_connection(Opinions::Config.active_record)
require 'opinions'
```

database.yml

```ruby
---
development:
  adapter: sqlite3
  database: db/opinions_development
  pool: 5
  timeout: 5000
  username: opinions

test:
  adapter: sqlite3
  database: db/opinions_test
  pool: 5
  timeout: 5000
  username: opinions
```

```ruby
# db/migrate/0_initial_migration.rb
class InitialMigration < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :product_id
      t.integer :user_id
      t.string :title
      t.text :body
      t.integer :stars, default: 0

      t.timestamps
    end
    add_index :ratings, [:product_id, :user_id], unique: true
  end
end
```

The opinions file can use the env from the config:

```ruby
require 'opinions/rating'

module Opinions
  def self.env
    Config.env
  end
end
```

Add a database migration task to the Rakefile:

```ruby
namespace :db do
  desc "migrate your database"
  task :migrate do
    require './config/environment'
    ActiveRecord::Migrator.migrate(
      'db/migrate',
      ENV["VERSION"] ? ENV["VERSION"].to_i : nil
    )
  end
end
```

We didn't add a rollback -- just delete the db/opinions_test or db/opinions_development file if you want to start over.

You'll need to run the migrations in the test environment to get the rating test to pass:

```ruby
RACK_ENV=test rake db:migrate
```

We're going to need to run tests within a transaction. Create a module in the test helper that can be included in the test suites:

```ruby
module WithRollback
  def temporarily(&block)
    ActiveRecord::Base.connection.transaction do
      block.call
      raise ActiveRecord::Rollback
    end
  end
end
```

Test it in the rating test:

```ruby
include WithRollback

def test_rollback
  assert_equal 0, Opinions::Rating.count
  temporarily do
    data = {
      user_id: 1,
      product_id: 2,
      title: "title",
      body: "body",
      stars: 3
    }
    Opinions::Rating.create(data)
    assert_equal 1, Opinions::Rating.count
  end
  assert_equal 0, Opinions::Rating.count
end
```

Go ahead and add in the rest of the rating class:

```ruby
module Opinions
  class Rating < ActiveRecord::Base
    validates :user_id, :product_id, :title, :body, :stars, presence: true
    validates :stars, inclusion: 0..5

    def editable?
      created_at > Time.now.utc - 900
    end
  end
end
```

### Wiring up sinatra

Add to gemfile:

```ruby
gem 'puma', require: false
gem 'sinatra', require: false

# then, in the test group
gem 'rack-test', require: false
```

New files:

* test/api_helper.rb

```ruby
require './test/test_helper'
require 'rack/test'
require 'api'
```

* test/api_test.rb

```ruby
require './test/api_helper'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    OpinionsApp
  end

  def test_hello_world
    get '/'
    assert_equal "Hello, World!", last_response.body
  end

end
```

* lib/api.rb

```ruby
require 'sinatra/base'

class OpinionsApp < Sinatra::Base
  get '/' do
    "Hello, World!\n"
  end
end
```

* config.ru

```ruby
$:.unshift File.expand_path("./../lib", __FILE__)

require 'bundler'
Bundler.require

require './config/environment'
require 'opinions'
require 'app'

use ActiveRecord::ConnectionAdapters::ConnectionManagement
run OpinionsApp
```

This will allow you to verify that sinatra is wired together correctly (run the tests with `rake`). Start the server with `rackup -p4567 -s puma`.

curl -XGET "http://localhost:4567".

Now curl -XGET "http://localhost:4567/no/such/endpoint"

That's pretty ugly. Let's create a better error message.

```ruby
not_found do
  "Not found: #{request.path_info}\n"
end
```

### Connecting the two apps

Add single API endpoint
* GET    api/v1/users/:id/ratings
Set content type to json

Delete wiring tests

Use Petroglyph (no id, created_at->rated_at)

### Consuming the JSON in the primary app

But... does it work? We don't have any data in the stand-alone app

#### Adding a POST endpoint

#### Using VCR to Mock Tests

#### Writing a migration script

Duplicate the seeds from the primary app to the secondary app using the POST endpoint.

* POST   api/v1/products/:id/ratings

### Writing Ratings from the Adapter

#### Creating ratings

Save both places.

#### Editing ratings

* GET    api/v1/products/:id/ratings/:user_id
* PUT    api/v1/products/:id/ratings/:user_id

Save both places.

### Displaying all ratings for a product

* GET    api/v1/products/:id/ratings

#### We won't delete them, but it's usually good to support the full complement of RESTful endpoints.

* DELETE api/v1/products/:id/ratings/:user_id

### Stop writing to the local ratings

### Delete obsolete data

### Protecting user's data

Implement shared secret, protect write endpoints

## Asyncronous Writes

The system we've built so far is distributed but it's still synchronous. Given that there's some latency when the primary app calls out to the ratings app, we've actually slowed down our application.

### Deleting obsolete code

### Dealing with Validation

* Run some validation within the proxy object to check the Rating params.

## Asyncronous Reading Through JavaScript

### Implementing JavaScript-Executing Specs with Poltergeist

* How to install and setup Poltergeist with Capybara

### Duplicating Ratings

* Fetch the ratings from the server via JavaScript
* Insert them into the DOM so there are two whole sets of the ratings

### Remove Non-JavaScript Fetched Ratings

### Dealing with Latency

* Will the test fail because the JavaScript hasn't finished executing yet?
* Capybara will keep looking for 2 seconds, long enough for the JavaScript to complete: https://github.com/jnicklas/capybara#asynchronous-javascript-ajax-and-friends

