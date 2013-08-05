---
layout: page
title: Extract Ratings Service
sidebar: true
---

## Introduction

We'll take an existing project, the Monsterporium store, and extract the ratings system to an external API.

This tutorial assumes that you have completed the {% extract_notifications_service %} tutorial, but can be completed independently of it.

Extracting the email into a service was relatively easy. Really, it wasn't much different than the way many apps implement background workers.

Now, let's look at a more complex architecture that, rather than just "doing" an action, is used to read and write domain data.

### Goals

Through this extraction process you'll learn:

* How to write a JSON API using Sinatra and Active Record

<div class="note">
<p>This tutorial is open source. If you notice errors, typos, or have questions/suggestions,
  please <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/topics/extract_ratings_service.markdown">submit them to the project on Github</a>.</p>
</div>

### Background

Each product in the store has multiple ratings. This functionality is perfect
for extraction to a service because:

* it has relatively self-contained data. The only external data dependencies
  are a product ID and a user ID.
* it doesn't have side effects / shared functionality with other parts of the
  application.
* it's easy to reason about as a unit of functionality

### Setup

We're assuming that you [already have Ruby 1.9.3 or 2.0]({% page_url environment %}).

#### Clone the Monsterporium

You can see the [store_demo repository on Github](https://github.com/jumpstartlab/store_demo) and clone it like this:

{% terminal %}
$ git clone git@github.com:JumpstartLab/store_demo.git
{% endterminal %}

Then hop in and get ready to go:

{% terminal %}
$ cd store_demo
$ bundle
$ rake db:migrate db:seed db:test:prepare
$ rake
{% endterminal %}

## Validating Functionality

The ratings feature is used in two places.

On the Product page, all the ratings for that product are listed. These are
currently not tested at all.

In the user's account, there is a page where the user can manage all of their
ratings. These have no unit tests or controller tests. There are some feature
specs, but they are incomplete.

### Using Capybara

#### Testing the User's Ratings

Log in with username _judy@example.com_ and password _password_. There are
other test accounts, see the `db/seed.rb` file for details.

Go to the [/account/ratings](http://localhost:3000/account/ratings) page.

This feature shows a list of the (unique) products that a user has ordered. If
the user has rated it, this rating is displayed, otherwise, a link to add a
rating for that item is shown.

If the user rated it in the last 15 minutes, there is an edit link.

The tests for managing a user's ratings are in `spec/features/user_rates_products_spec.rb`.

The feature specs cover:

* creating a rating
* failure to create a rating (incorrect parameters)
* editing a rating
* failure to edit a rating (incorrect parameters)

The feature specs do not cover:

* the (correct) rating is displayed if a user has rated it
* the user may not edit after the 15 minute window closes
* there is a link to provide feedback if the product is not rated

Add features to complete the coverage.

#### Testing the Product's Ratings

On the product page, all the ratings are displayed. If the user has rated the
item within the last 15 minutes, there is a link to edit the rating.

This is not tested in any way.

Add feature specs for this behavior.

#### Ignoring Bugs

The current implementation has a number of issues, all of which we will
cheerfully ignore.

## Preparing to Extract

Currently the controller queries the Rating model, and the model queries the
database. One action queries a model called `OrderedProducts` which delegates
to both the Orders model and the Ratings model. It returns a simple ruby
object to the view which delegates messages to both the product and the
rating.

### Loosening the Coupling

We'll add two new objects to the system:

* an object that will sit in front of the Rating model and mediate all
  communication with it. This will allow us to slowly swap out talking to the
  model with talking to a remote API.
* an object that is a simple ruby object that represents a rating. It will not
  have access to the persistence layer. Once we're talking to the remote
  service, this object will be a simple wrapper around the JSON object that
  the API returns.

Before we can do this, we need to make some small changes.

### Hiding the `rating.id`

When the ratings move into the remote service, it will not make sense to
expose the primary key of the database. Users should only ever have a single
rating for a given product, so we can use the combination of user id and
product id to access the ratings.

In order to make this possible, we'll refactor the primary app so it doesn't
rely on the rating id.

First, let's find out where it is being used. We'll assume that most rating
objects are assigned to a local variable or instance variable named `rating`.
We can grep for this:

{% terminal %}
$ git grep rating.id
{% endterminal %}

Notice that the period is a wildcard, and the search returns both "rating.id"
and "rating_id".

This uncovers a few different use cases:

* creating a unique DOM id that the raty gem can use to display 1-5 stars
* passed to the edit link / url helper

So there's at least one route that uses the `:rating_id`. Let's see if there
are more:

{% terminal %}
$ bundle exec rake routes | grep rating
    account_ratings GET    /account/ratings(.:format)                       ratings#index
    product_ratings POST   /products/:product_id/ratings(.:format)          ratings#create
 new_product_rating GET    /products/:product_id/ratings/new(.:format)      ratings#new
edit_product_rating GET    /products/:product_id/ratings/:id/edit(.:format) ratings#edit
     product_rating PUT    /products/:product_id/ratings/:id(.:format)      ratings#update
{% endterminal %}

Only two routes use the `rating.id`, the `ratings#edit` and the
`ratings#update`.

#### Creating Alternate DOM IDs

The code does not rely on the ID being a particular value, we just need it to be unique.

On the [user's rating page](http://localhost:3000/account/ratings), the
products are unique, so we can use the `rating.product_id` rather than the
`rating.id`.

On the [product page](http://localhost:3000/products/4) we're displaying a
product with all of its reviews. Since each user may only review a given product
once, we can use the `rating.user_id` to create a unique DOM ID.

Be sure to update the `OrderedProduct` model so that it delegates `user_id` to
rating. We can delete the `rating_id` delegation.

#### Changing the Routes

We'll replace the rating `:id` in the URL pattern with `:rating_id`. We'd like
all of the other pieces to stay the same, so we'll need to hand-roll custom
routes.

The current route definition looks like this:

```ruby
resources :products, only: [ :index, :show ] do
  resources :ratings, except: [ :index, :show, :destroy ]
end
```

Of the seven default actions, we're using four. After this change, we'll only
be using two. Rather than defining them by exception, switch to defining
`:only` the ones we want.

```ruby
resources :products, only: [ :index, :show ] do
  resources :ratings, only: [ :new, :create ]
end
```

Then add these definitions:

```ruby
get "/products/:product_id/ratings/:user_id" => "ratings#edit", as: :product_rating
put "/products/:product_id/ratings/:user_id" => "ratings#update", as: :edit_product_rating
```

Verify `rake routes`, to see that these are now using the user id.

{% terminal %}
     product_rating GET    /products/:product_id/ratings/:user_id(.:format)         ratings#edit
edit_product_rating PUT    /products/:product_id/ratings/:user_id(.:format)         ratings#update
{% endterminal %}

#### Calling the Routes

Edit is straight forward, because we can just grep for the links and update
them.

Update is more tricky. It's not listed explicitly, it's used in the form
helper. We need to update the form action, but the form is used both for the
`create` and for the `update`.

Rather than trying to figure out how to make the form work for both cases,
let's move the first and last lines of the form into the `edit` and `new`
template files, leaving just the form inputs in the `_form` partial. Remember
to pass the local form variable `f` to the partial.

In the `edit` template change the first line to this:

```erb
<%= simple_form_for @rating, url: product_rating_path(@rating.product_id, @rating.user_id), method: :put do |f| %>
```

Now if we try to submit the form, the controller gets confused, because it's
trying to find the rating by the `id`, which is no longer being passed in.

```ruby
def update
  @rating = Rating.find(params[:id])
  # ...
end
```

We could change this to find_by_product_id_and_user_id, but that will behave
differently in a subtle way: it won't raise an exception if the object isn't
found.

Let's introduce a class method on `Rating` called `find_unique(params)` which
plucks out the `user_id` and the `product_id`, uses those to find the record,
and raises an `ActiveRecord::RecordNotFound` if the record doesn't exist.

The method looks like this:

```ruby
def self.find_unique(attributes)
  rating = find_by_user_id_and_product_id(attributes[:user_id], attributes[:product_id])
  unless rating
    raise ActiveRecord::RecordNotFound
  end
  rating
end
```

In the `RatingsController` change `Rating.find` to `Rating.find_unique`.

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

### Introducing an Adapter

The adapter will eventually talk to the remote service, but the first step is
to use this adapter to talk to the Rating model.

Create a new file in `app/models/ratings_repository.rb`. Put a simple ruby
object in it. We'll move all references to the `Rating` class from the
controllers and other models into this class.

There are three files that talk directly to the `Rating` model.

#### Decoupling from the `ProductsController`

The `ProductsController` needs to get a list of all the ratings for a
particular product.

```ruby
Rating.where(product_id: params[:id])
```

Change this to:

```ruby
RatingRepository.ratings_for(@product)
```

Then in the `RatingRepository` add the following:

```ruby
class RatingRepository
  def self.ratings_for(product)
    Rating.where(product_id: product.id)
  end
end
```

The product listing should still work.

#### Decoupling from the `OrderedProduct`

The `OrderedProduct` is asking for all of the ratings by a particular user.

```ruby
Rating.where(user_id: user.id)
```

Change this to:

```ruby
RatingRepository.ratings_by(user)
```

Then, in the rating repository add this code:

```ruby
def self.ratings_by(user)
  Rating.where(user_id: user.id)
end
```

Verify that the account rating page still works.

#### Decoupling the `RatingsController`

As one would expect, the `RatingsController` has several references to the
Rating model.

In the new action, it simply instantiates a `Rating` object:

```ruby
def new
  @rating = Rating.new(product_id: params[:product_id])
  # ...
end
```

Change this to ask the `RatingRepository` for the new rating:

```ruby
def new
  @rating = RatingRepository.new_rating(product_id: params[:product_id])
  # ...
end
```

We need to add the wrapper-method to the `RatingRepository`:

```ruby
def self.new_rating(attributes)
  Rating.new(attributes)
end
```

The `create` method also needs a new Rating. Make the same change there.

The `edit` and `update` actions both make calls to `Rating.find_unique`.
Create a method on `RatingRepository` that delegates the message to Rating.

That's it, we've hidden all of the references to the `Rating` model.

### Introducing a Simple Proxy Rating

Create a class called `ProxyRating`, which will be a plain ruby object that
eventually will be the simple, read-only representation of the rating.

Give it an `initialize` method that takes a hash of attributes.

We need to change the `RatingRepository` so that it returns `ProxyRating`
objects rather than `Rating` objects.

#### Using ProxyRating in the Product Page

In the `RatingRepository` change the `ratings_for(product)` method to map over
the ratings it gets back and return proxy ratings based on the attributes:

```ruby
def self.ratings_for(product)
  Rating.where(product_id: product.id).map {|rating|
    ProxyRating.new(rating.attributes)
  }
end
```

Lean on the error messages you get and expose the attributes you need in the
`ProxyRating` one by one until the product page renders correctly.

It's OK if the code is gross.

#### Using ProxyRating in the User's Rating Page

Back in the `RatingRepository`, make the same change to the `ratings_by(user)`
method.

```ruby
def self.ratings_by(user)
  Rating.where(user_id: user.id).map {|rating|
    ProxyRating.new(rating.attributes)
  }
end
```

You may need to expose more attributes in the `ProxyRating` class.

Next, we'll update the new rating page.

In the repository class change `Rating` to `ProxyRating` in the `new_rating` method:

```ruby
def self.new_rating(attributes)
  ProxyRating.new(attributes)
end
```

The page will complain that the proxy rating object doesn't have a
`model_name` method.

We can extend Active Model's Naming module to get this behavior:

```ruby
class ProxyRating
  extend ActiveModel::Naming
end
```

The next error says that the proxy rating doesn't know about `to_key`.

Include the Active Model's Conversion module:

```ruby
class ProxyRating
  extend  ActiveModel::Naming
  include ActiveModel::Conversion
end
```

Then it will complain about `persisted?`.

We'll use the `created_at` attribute of the `ProxyRating` to determine whether
or not a record has been persisted. If it has a timestamp, it has been persisted.

```ruby
def persisted?
  !!created_at
end
```

The next error is for a url helper that doesn't exist.

The form helper uses the name of the class to figure out what url helper to
call. It was calling `product_ratings_path`, but now it's trying to call
`product_proxy_ratings_path`, which doesn't exist.

We can fix this by explicitly defining the url and HTTP verb in the form
declaration:

```erb
<%= simple_form_for @rating, url: product_ratings_path(@rating.product_id), method: :post do |f| %>
```

This has some side effects in the form. For one, the `body` attribute has
become a text field rather than a textarea.

We can tell the form that we want a textarea by specifying the option
`as: :text`:

```erb
<%= f.input :body, as: :text, input_html: { placeholder: t('placeholder.ratings.body') } %>
```

Secondly, the stars used to default to `0`, but now they're blank. The whole
list of numbers is still around, it's just preceded by a blank line.

We can explicitly tell the form not to include the blank line:

```erb
<%= f.input :stars, as: :select, collection: [0,1,2,3,4,5], include_blank: false %>
```

Once the page renders, go ahead and fill out the form and create a new rating.

That blows up because the `ProxyRating` doesn't have a save method.

Give the `ProxyRating` a save method which delegates to `RatingRepository`:

```ruby
def save
  RatingRepository.save(attributes)
end
```

Implement `save` on the `RatingRepository`:

```ruby
def self.save(attributes)
  Rating.new(attributes).save
end
```

NOTE: In real life giving a dumb proxy object a save method is probably *not*
what you want. After everything is working, it would be good to change the
controller so that it calls the RatingRepository.save, passing it the object.
Because we're going to need to work against both a proxy and a real object,
that's going to get messy, so we're introducing this ugly thing first.

Next, we'll make sure we can edit a rating. If all of the products have
ratings and none of them are editable, drop the database and re-run the
migrations and the seed script:

{% terminal %}
$ bundle exec rake db:drop db:migrate db:seed
{% endterminal %}

In the `RatingRepository` return a `ProxyRating` object from the `find_unique`
method:

```ruby
def self.find_unique(attributes)
  ProxyRating.new(Rating.find_unique(attributes).attributes)
end
```

If you load up the edit page, it will complain that there's no `:id` on the
`ProxyRating`. The problem is due to the form helper again. It's trying to
create a hidden field for the `id` of the `@rating` object. Or something. I
think. I don't know, form helpers just do their thing. Anyway...
(TODO: check this)

Instead of passing `@rating` to the form, give it the symbol:

```ruby
<%= simple_form_for :rating, url: product_rating_path(@rating.product_id, @rating.user_id), method: :put do |f| %>
```

The page should render properly at this point.

Submit the form.

It blows up because `ProxyRating` has no `update_attributes` method.
Implement one in ProxyRating that delegates to rating:

```ruby
def update_attributes(attributes)
  RatingRepository.update(attributes.merge(user_id: user_id, product_id: product_id))
end
```

The `update` method doesn't exist yet in `RatingRepository`. Add it:

```ruby
def self.update(attributes)
  Rating.find_unique(attributes).update_attributes(attributes)
end
```

## Creating a Ratings Application

### Wiring together the stand-alone application

Let's create a minimal ruby project:

{% terminal %}
.
├── Gemfile
├── README.md
├── Rakefile
├── lib
│   └── opinions.rb
└── test
    ├── opinions_test.rb
    └── test_helper.rb
{% endterminal %}

We only need one gem: `minitest`. We could use `minitest` from the ruby standard library, but the gem version has so many improvements, that it's worth jumping through a couple of small hoops to get it.

Add this to the Gemfile:

```ruby
source 'https://rubygems.org'

group :test do
  gem 'minitest', :require => false
end
```

We could put all the setup right in our test file, but we're going to need more test files in just a moment, so let's just wire everything up with a helper straight off the bat.

```ruby
class OpinionsTest < Minitest::Test
  def test_addition
    assert_equal 1+1, 2
  end
end
```

Run the test with `ruby test/opinions_test.rb`.

It doesn't know about `minitest`. Add `require 'minitest/autorun'` to the top of the file and run it again.

It passes, but has a bunch of warnings. That's because we want to use the gem, but it finds the one in the standard library first.

Add `gem 'minitest'` to the top of the file, and run the test again.

This time it passes without warnings.

Now let's wire in the actual application. Change the test to send a method to the Opinions application itself:

```ruby
require 'minitest'

class OpinionsTest < Minitest::Test
  def test_environment
    assert_equal 'test', Opinions.env
  end
end
```

This will fail because it doesn't know about the Opinions class. Require 'opinions' at the top of the file, and run the test again.

It still fails, because it can't find 'opinions'.

Let's add `lib/` to the path. At the top of the test file, add this:

```ruby
$:.unshift File.expand_path("./../../lib", __FILE__)
```

Now it finds the file, but doesn't know about the Opinions constant. Add a module, run the tests, and now it's complaining about the method `env` not existing.

Let's read from an environment variable:

```ruby
module Opinions
  def self.env
    @env ||= ENV.fetch("OPINIONS_ENV") { "development" }
  end
end
```

At this point the test should pass. We're going to want all that setup in a separate test helper. Extract it to `test/test_helper.rb`:

```ruby
$:.unshift File.expand_path("./../../lib", __FILE__)
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride' # not strictly necessary, but worth it

ENV['OPINIONS_ENV'] = 'test'
require 'opinions'
```

We're also going to want a way to run all the tests at once. Open up the Rakefile and add the following:

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
      ENV['OPINIONS_ENV'] ||= "development"
      @env = ENV['OPINIONS_ENV']
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
OPINIONS_ENV=test rake db:migrate
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

That's hard to look at. Let's create a better error message.

```ruby
not_found do
  "Not found: #{request.request_method} #{request.path_info}\n"
end
```

### Connecting the two apps

We'll slowly start pointing methods in the RatingRepository to the new, stand-alone app.

Let's start with the product show page -- all the ratings for a particular product.

Add 'faraday' to your Gemfile. We'll create an instance of the repository to talk to the remote thing.

We'll want a RESTful endpoint for ratings that belong to a product. Something like /products/:id/ratings. Since it's an API, let's version it: `/api/v1/products/:id/ratings`.

So the current method in repository looks like this:


```ruby
def self.ratings_for(product)
  Rating.where(product_id: product.id).map {|rating|
    ProxyRating.new(rating.attributes)
  }
end
```

We want it to look something like this:


def self.ratings_for(product)
  remote.get("/api/v1/products/#{product.id}/ratings").map {|attributes|
    ProxyRating.new(attributes)
  }
end


We need a method that gives us an instance:

def self.remote
  new
end

In the instance we need a couple things:

A connection:

```ruby
def connection
  @connection ||= Faraday.new(:url => "http://localhost:8080") do |c|
    c.use Faraday::Adapter::NetHttp
  end
end
```

And a `get` method:

```ruby
def get(endpoint)
  response = connection.get do |req|
    req.url endpoint
  end
  JSON.parse(response.body)
end
```

This should work, provided that we actually have an endpoint that does what we need.

Let's make one.

### Implementing the first endpoint

Start with a test that asserts that if we ask for all the ratings for a product that doesn't have any, we get a proper response:

```ruby
def test_get_ratings_when_there_are_none
  get '/api/v1/products/1/ratings'
  assert_equal 200, last_response.status
  assert_equal "[]", last_response.body
end
```

This gives us a gentle start.

Next we need the case where a product has multiple ratings. We need:

* two ratings that will be returned (to test "multiple")
* one rating that will not be returned (to test that this is the correct subset).

So we need three test ratings. Something like:

* product id 1, user id 1 # match
* product id 1, user id 2 # match
* product id 2, user id 2 # no match

```ruby
def test_get_all_ratings_for_product
  temporarily do
    data = {
      title: "title",
      body: "body",
    }
    r1 = Opinions::Rating.create(data.merge(product_id: 1, user_id: 1, stars: 1))
    r2 = Opinions::Rating.create(data.merge(product_id: 1, user_id: 2, stars: 5))
    r3 = Opinions::Rating.create(data.merge(product_id: 2, user_id: 2, stars: 3))
    get '/api/v1/products/1/ratings'
    expected = JSON.parse([{rating: r1.attributes}, {rating: r2.attributes}].to_json)
    assert_equal expected, JSON.parse(last_response.body)
  end
end
```

To avoid any conversion things we're round-tripping the expectation through JSON.

Right now we're just getting a full dump of the object's attributes. That's not going to hold up in the long run, but for now it's fine.

Make the test pass.

Back in the primary app, we should be able to access the endpoint, but it's empty. We don't have any data.

Let's create a quick migration script that we can run to copy ratings from the primary app.

It will look something like this:

```ruby
require 'json'
Rating.all.each do |rating|
  data = {
    user_id: rating.user_id,
    product_id: rating.product_id,
    title: rating.title,
    body: rating.body,
    stars: rating.stars
    # we won't worry about getting the right created at timestamp
  }
  remote = RatingRepository.remote
  remote.post("/api/v1/products/#{rating.product_id}/", data)
end
```

We'll need to implement `post` in the ratings repository:

```ruby
def post(endpoint, params)
   response = connection.post do |req|
     req.url endpoint
     req.headers['Accept'] = 'application/json'
     req.headers['Content-Type'] = 'application/json'
     req.body = {rating: params}.to_json
  end
  response
end
```

If we run it it will fail because we haven't added a POST endpoint to the remote app.

Write a test for it, and then implement the endpoint.

Just make assertions about each of the attributes that we sent over, all in the same test.

That's the happy path, we also need a test for the case where it fails because of missing parameters. Return a 400 status and a helpful error message.

We should now be able to run the migration. Verify with
`curl -v http://localhost:8080/api/v1/products/1/ratings`

Look through the output. Does anything catch your eye?

The content type is html even though the endpoint is returning json. Let's fix that for the entire sinatra app at once:

```ruby
before do
  content_type 'application/json'
end
```

While we're at it, let's make the not found handler return json as well:

```ruby
not_found do
  halt 404, {error: "Not found: #{request.request_method} #{request.path_info}"}.to_json
end
```

Now that everything is wired together in the api test, delete the hello world endpoint and the test for it.

### Meanwhile, back on the homestead...

Load up a product page that has at least one rating. Fiddle with it until it works.

#### account/ratings

app/models/ordered_product.rb:    ratings = RatingRepository.ratings_by(user)

Get all the ratings for a user in `ratings_by(user)`

Write the test, write the api endpoint, make it work.

#### Writing to the api

When we create a new rating, create it both places and return the new one. This is so that editing works locally.

Then add a PUT endpoint, also writing to both places. Then add a get endpoint for an individual rating, and integrate it into the primary app.

At this point we should be able to no longer write to the database in the primary app.

### Using petroglyph for a nicer JSON experience (maybe)

We don't want to expose the primary key, and it would be nice if we could call created at `rated_at`. Let's use Petroglyph so we don't need to mess around with the active record `as_json` stuff.

Add petroglyph to the gem file.

Then create a dir: `lib/api/views` and tell the sinatra application that we'll be using petroglyhp, and  where to find the views:

In the sinatra app:

```ruby
require 'sinatra/base'
require 'sinatra/petroglyph'

class OpinionsAPI < Sinatra::Base
  set :root, 'lib/api'
  # ...
end
```

Create two templates, one for a single rating, and one for the collection. The collection will delegate to the single one.

```ruby
merge rating do
  attributes :title, :body, :stars, :user_id, :product_id
  node rated_at: rating.created_at
end
```

```ruby
collection ratings: ratings do |rating|
  partial :rating, rating: rating
end
```

Note: missing feature in petroglyph - discovered while writing this tutorial, collections MUST be namespaced under a key. That's kind of lame.



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


* GET    api/v1/users/:id/ratings

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

