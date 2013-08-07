---
layout: page
title: Extract Ratings Service
sidebar: true
---

## Introduction

We'll take an existing project, the Monsterporium store, and extract the ratings system to an external API.

This tutorial assumes that you have completed the {% extract_notifications_service %} tutorial, but can be completed independently of it.

Extracting the email into a service was relatively easy. Really, it wasn't much different than the way many apps implement background workers. Now, let's look at a more complex architecture that, rather than just "doing" an action, is used to read and write domain data.

### Goals

Through this extraction process you'll learn:

* How to write a JSON API using Sinatra and Active Record
* How to use Rails form helpers with non-ActiveRecord objects
* How to access data that's been computed by an external service

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

If you already have a copy of Monsterporium from the Extract Notification Service tutorial and all your tests are green, feel free to continue using it.

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

On the `ProductsController#show` page, all the ratings for that product are listed. These are currently not tested at all.

In the user's account, there is a page where the user can manage all of their
ratings. These have no unit tests or controller tests. There are some feature
specs, but they are incomplete.

### Getting Features Under Test

#### Users and Possible Ratings

Log in with username `judy@example.com` and password `password`. There are
other test accounts, see the `db/seed.rb` file for details.

Go to the [/account/ratings](http://localhost:3000/account/ratings) page.

This feature shows a list of the (unique) products that a user has ordered. If
the user has rated it, this rating is displayed, otherwise, a link to add a
rating for that item is shown.

If the user rated it in the last 15 minutes, there is an edit link.

#### The Feature Specs

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

At this point, you need to **improve the test suite to cover these cases**. Some tips to keep in mind:

* The [Timecop library](https://github.com/travisjeffery/timecop) can help manipulate time in your app
* The [Capybara README](https://github.com/jnicklas/capybara#using-capybara-with-rspec) has details about how it use it with RSpec

#### Testing the Product's Ratings

On the individual product page, the ratings by all users for that product are displayed. If the user has rated the item within the last 15 minutes, there is a link to edit the rating.

This is not tested in any way.

Use the same techniques as before to get the features under test.

#### Ignoring Bugs

The current implementation has a number of issues, all of which we will
cheerfully ignore unless they become relevent.

## Prepare for Extraction

Currently, in a normal MVC flow, 

* the controller queries the `Rating` model
* the model queries the database
* the data flows back to the model
* the model passes it back to the controller
* the controller renders the view template

One controller action queries a model named `OrderedProducts` which delegates
to both the `Order` model and the `Rating` model. It returns a ruby
object, maybe you'd call it a presenter, which delegates messages to both the product and the rating.

### Loosening the Coupling

We'll add two new objects to the system:

* An object that will sit in front of the `Rating` model and mediate all
  communications in and out. This will allow us to slowly swap out talking to the
  model with talking to a remote API.
* A plain ruby object that represents a rating, but it will not
  have access to the persistence layer. Once we're talking to the remote
  service, this object will be a wrapper around the JSON object that
  the API returns.

Before we can do this, we need to make some small changes to the rest of the application.

### Hiding the `rating.id`

When the ratings move into the remote service, it will not make sense to
expose the primary key of the database. Users should only ever have a single
rating for a given product, so we can use the combination of `user_id` and
`product_id` to access the ratings rather than a unique `id`.

In order to make this possible, we'll refactor the primary app so it doesn't
rely on the rating id.

#### Finding Usages

First, let's find out where it is being used. We'll assume that most rating
objects are assigned to a local variable or instance variable named `rating`.
We can grep for this:

{% terminal %}
$ git grep rating.id
{% endterminal %}

Note that the period is a wildcard, and the search returns both instance of `rating.id`
and `rating_id`.

This uncovers a few different use cases:

* creating a unique DOM id that the raty gem can use to display 1-5 stars
* passing into to the url helpers related to ratings

To find routes that use the ratings ID, let's look at `rake routes`:

{% terminal %}
$ bundle exec rake routes | grep rating
    account_ratings GET    /account/ratings(.:format)                       ratings#index
    product_ratings POST   /products/:product_id/ratings(.:format)          ratings#create
 new_product_rating GET    /products/:product_id/ratings/new(.:format)      ratings#new
edit_product_rating GET    /products/:product_id/ratings/:id/edit(.:format) ratings#edit
     product_rating PUT    /products/:product_id/ratings/:id(.:format)      ratings#update
{% endterminal %}

Only two routes use the `rating.id`: the `ratings#edit` and the
`ratings#update`.

#### Creating Alternate DOM IDs

The front-end code does not rely on the CSS ID being a particular value, we just need it to be unique.

On the [user's rating page](http://localhost:3000/account/ratings), the
products are unique, so we can use the `rating.product_id` rather than the
`rating.id`.

On the [product page](http://localhost:3000/products/4) we're displaying a
product with all of its reviews. Since each user may only review a given product
once, we can use the `rating.user_id` to create a unique DOM ID.

Within the `OrderedProduct` we need to:

* delegate `user_id` to rating
* delete the `rating_id` delegation

Run your test suite and confirm that things are working as expected.

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

Define custom routes for the ratings' `edit` and `update` routes with these:

```
get "/products/:product_id/ratings/:user_id" => "ratings#edit", as: :product_rating
put "/products/:product_id/ratings/:user_id" => "ratings#update", as: :edit_product_rating
```

Now our `resources :ratings` only needs to define two actions. Switch over to using the `:only` key with the list of actions we want:

```ruby
resources :products, only: [ :index, :show ] do
  resources :ratings, only: [ :new, :create ]
end
```

Run `rake routes` and see that no routes are using the rating ID, but our two custom routes are included:

{% terminal %}
     product_rating GET    /products/:product_id/ratings/:user_id(.:format)         ratings#edit
edit_product_rating PUT    /products/:product_id/ratings/:user_id(.:format)         ratings#update
{% endterminal %}

#### Calling the Routes

Finding uses of the edit path is straightforward. Since they are explicit calls to `edit_product_rating`, we can grep for the usages and update them.

But usages of the update path are more difficult to find. It's not listed explicitly, it's used in the `form_for` helper. We need to update the form action, but the form is used both for the `create` and for the `update`.

Rather than trying to get fancy with the `form_for` parameters, let's move the first and last lines of the form out from the partial into the `edit` and `new`
template files, leaving just the form inputs in the `_form` partial. Remember
to pass the local form variable `f` to the partial.

##### Modifing the Edit Form

In the `edit` template change the first line to use the new route like this:

```erb
<%= simple_form_for @rating, url: product_rating_path(@rating.product_id, @rating.user_id), method: :put do |f| %>
```

#### Updating the Rating

Now if we try to submit the form, the controller gets confused, because it's
trying to find the rating by the `id`, which is no longer being passed in:

```ruby
def update
  @rating = Rating.find(params[:id])
  # ...
end
```

We could change this to use `find_by_product_id_and_user_id`, but that will behave
differently in a subtle way: it won't raise an exception if the object isn't
found.

Let's introduce a class method on `Rating` named `find_unique(params)` which
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

Verify that everything still works and your specs are green.

### Introducing an Adapter

The adapter will eventually talk to the remote service, but the first step is
to use this adapter to talk to the `Rating` model.

Create a new file `app/models/ratings_repository.rb` and stub a `RatingsRepository` class.We'll migrate all usages of the `Rating` class from the
controllers and other models to point to this class.

There are three files that talk directly to the `Rating` model.

#### Decoupling from the `ProductsController`

The `ProductsController` needs to get a list of all the ratings for a
particular product.

```ruby
Rating.where(product_id: params[:id])
```

Without the idea of building a SQL query, we're free to create a more Ruby-esque lookup method. Change this to:

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

We're just passing the call through the `RatingRepository` and letting the `Rating` class do the hard work. The product listing should still work and all tests pass.

#### Decoupling from the `OrderedProduct`

The `OrderedProduct` is asking for all of the ratings by a particular user:

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

Verify that the account rating page still works and the specs pass.

#### Decoupling the `RatingsController`

As one would expect, the `RatingsController` has several references to the
Rating model.

In the new action, it instantiates a `Rating` object:

```ruby
def new
  @rating = Rating.new(product_id: params[:product_id])
  # ...
end
```

Change this to ask the `RatingRepository` to create a new rating for the given `product_id`:

```ruby
def new
  @rating = RatingRepository.new_rating(product_id: params[:product_id])
  # ...
end
```

And add the wrapper-method to the `RatingRepository`:

```ruby
def self.new_rating(attributes)
  Rating.new(attributes)
end
```

The `create` method also needs a new Rating. Make the same change there.

The `edit` and `update` actions both make calls to `Rating.find_unique`.
Create a method on `RatingRepository` that delegates the message to Rating.

At that point, there should be no references to the `Rating` model outside of `RatingRepository`.

### Introducing a Proxy Rating

Create a class named `ProxyRating`, which will be a plain ruby object that
eventually will be the simple, read-only representation of the rating within the primary app.

Write an `initialize` method that takes a hash of attributes mirroring the columns in the current ratings table and makes them available as readable attributes.

#### Using `ProxyRaiting` in `RatingsRepository`

Within `RatingsRepository`, return `ProxyRating` instances rather than `Rating` instances. Take the `Rating` instances that you get back from ActiveRecord and iterate over them to create `ProxyRating` objects as needed.

```ruby
def self.ratings_for(product)
  Rating.where(product_id: product.id).map {|rating|
    ProxyRating.new(rating.attributes)
  }
end
```

Lean on the error messages you get and expose the attributes you need in the
`ProxyRating` one by one until the product page renders correctly.

It's OK if the code is gross, it's going away soon.

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

#### New Rating Form

Next, we'll update the new rating submission page.

In `RatingsRepository` class change `Rating` to `ProxyRating` in the `new_rating` method:

```ruby
def self.new_rating(attributes)
  ProxyRating.new(attributes)
end
```

##### Naming

The page, through the use of the `form_for` helper, will complain that the proxy rating object doesn't have a `model_name` method.

We can extend Active Model's `Naming` module to get this behavior:

```ruby
class ProxyRating
  extend ActiveModel::Naming
end
```

##### Conversion

The next error says that the proxy rating doesn't know about `to_key`.

Include the Active Model's `Conversion` module:

```ruby
class ProxyRating
  extend  ActiveModel::Naming
  include ActiveModel::Conversion
end
```

##### Persisted

Then it will complain about `persisted?`.

We'll use the `created_at` attribute of the `ProxyRating` to determine whether
or not a record has been persisted. If it has a timestamp, it has been persisted.

```ruby
def persisted?
  !!created_at
end
```

##### URL Helper

The next error is for a url helper that doesn't exist.

The form helper uses the name of the class to figure out what url helper to
call. It was calling `product_ratings_path`, but now it's trying to call
`product_proxy_ratings_path`, which doesn't exist.

We can fix this by explicitly defining the url and HTTP verb in the form
declaration:

```erb
<%= simple_form_for @rating, url: product_ratings_path(@rating.product_id), method: :post do |f| %>
```

##### Form Elements: Body

The original project uses the `simple_form` gem which can make form building quite a bit easier. Many of its features depend on inspecting the ActiveRecord object that the form is about, but our proxy object won't have all that data and structure.

This has some side effects in the form. For one, the `body` attribute has
become a text field rather than a textarea. We can force a textarea by specifying the option
`as: :text`:

```erb
<%= f.input :body, as: :text, input_html: { placeholder: t('placeholder.ratings.body') } %>
```

##### Form Elements: Stars

Second, the stars used to default to `0`, but now it defaults to a blank option. We can explicitly tell the form not to include the blank line:

```erb
<%= f.input :stars, as: :select, collection: [0,1,2,3,4,5], include_blank: false %>
```

#### Trying to Save

Once the page renders, go ahead and fill out the form and create a new rating. That blows up because the `ProxyRating` doesn't have a save method.

Give the `ProxyRating` a save method which delegates to `RatingRepository` to create a new record:

```ruby
def save
  RatingRepository.save(attributes)
end
```

Implement `save` on the `RatingRepository` to actually store it in the database:

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

### Editing Ratings

Next, let's try to edit a rating. 

Most likely all the existing ratings in the system are older than 15 minutes, so they're uneditable. If you want to re-seed the DB:

{% terminal %}
$ bundle exec rake db:drop db:migrate db:seed
{% endterminal %}

#### Finding a Rating

In the `RatingRepository` return a `ProxyRating` object from the `find_unique`
method:

```ruby
def self.find_unique(attributes)
  ProxyRating.new(Rating.find_unique(attributes).attributes)
end
```

#### Changing the Edit Form

Instead of passing `@rating` to the form, give it the symbol `:rating` which avoids another issue about trying to access `.id`:

```ruby
<%= simple_form_for :rating, url: product_rating_path(@rating.product_id, @rating.user_id), method: :put do |f| %>
```

The page should render properly at this point.

#### Submit the Updated Data

Submit the form. It blows up because `ProxyRating` has no `update_attributes` method which is called from the `update` action in the controller.

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

Now your edits should persist correctly.

### Back to Fully Functional

At this point the shim is in place and everything should be working both through the web UI and all tests should be green.

## Creating a Ratings Application

Now let's build the external ratings application to interact with the primary app.

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

We could put all the setup right in our test file, but we're going to need more test files in just a moment, so let's wire everything up with a helper straight off the bat.

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

### Wiring up Active Record

We have a stand-alone ruby project with tests wired in. In the primary
application the ratings are stored in the database, and we have an
ActiveRecord model that accesses that data.

In order to make the fewest changes possible to the `Rating` object, and make
any data migrations as simple as possible, we're going to use the same Active
Record Rating object in the stand-alone application.

There's more to it than just requiring 'active_record' and copying the file over, however.

We're going to need to deal with

* configuration
* opening and closing the connection to the database
* database migrations
* running tests in transactions so that tests don't interfere with each other

We will modify some of the existing files, and we'll also add some files.

The new files we'll be adding are:

{% terminal %}
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
{% endterminal %}

We need to add both ActiveRecord and an appropriate adapter to the Gemfile.
The primary application uses SQLite3, so we'll use that here as well.

```ruby
source 'https://rubygems.org'

gem 'activerecord', require: 'active_record'
gem 'sqlite3'

group :test do
  gem 'minitest', require: false
end
```

Run `bundle install` to install the dependencies.

We'll add a separate test for the Rating. Since the Rating class will live in
`lib/opinions/rating.rb` we'll put the test in `test/opinions/rating_test.rb`.

We won't test anything fancy yet. If our test manages to load a new Rating
class, even if it doesn't save it, it means that:

* the active record gem is being required
* the database configuration is being loaded
* we're connecting to the database correcly
* the test has access to all of it

```ruby
require './test/test_helper'

class RatingTest < Minitest::Test
  def test_existence
    rating = Opinions::Rating.new(stars: 3)
    assert_equal 3, rating.stars
  end
end
```

Run rake.

It blows up with `NameError: uninitialized constant Opinions::Rating`.

Copy the `Rating` class from the primary application to
`lib/opinions/rating.rb`. Make sure to delete any methods that refer to parts
of the primary application that we no longer have access to.

Namespace Rating inside of Opinions:

```ruby
module Opinions
  class Rating < ActiveRecord::Base
  end
end
```

Run `rake` again. It blows up with the same error, because we're not loading
the class anywhere.

Open up `lib/opinions.rb` and require 'opinions/rating'.

Run `rake` again. Now it complains about an `uninitialized constant
Opinions::ActiveRecord (NameError)`. It's not loading Active Record.

Rather than manually load all the dependencies, let's create an environment.rb
file that loads bundler with anything required explicitly in the Gemfile.

Create a file `config/environment.rb`, and add the following to it:

```ruby
require 'yaml'
require 'bundler'
Bundler.require

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

The tests still fail with the same error, because the test helper isn't
requiring the environment file.

Open up the test helper and replace `require 'opinions' with:

```ruby
require './config/environment'
```

The next error is a complaint that `No such file or directory -
config/database.yml (Errno::ENOENT)`.

Create the file and add a basic sqlite3 config in it:

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

Run the tests again, and you'll get a complaint that
`ActiveRecord::StatementInvalid: Could not find table 'ratings'`.

We need a migration. In `db/migrate/0_initial_migration.rb` copy over the part
of the migration in the primary application that is relevant to the ratings
feature, which is the ratings table:

```ruby
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

To run the migration we'll need a rake task. Open up the Rakefile and add the
following:

```ruby
namespace :db do
  desc "migrate your database"
  task :migrate do
    require './config/environment'
    ActiveRecord::Migrator.migrate('db/migrate')
  end
end
```

Then you can run `rake db:migrate`.

When you run `rake`, it will *still* not find the ratings table. That's because
the `rake db:migrate` task defaulted the environment to development, and the
tests are running against the test environment.

Run the migration with the test configuration:

{% terminal %}
OPINIONS_ENV=test rake db:migrate
{% endterminal %}

Run `rake` again, and finally the tests should pass.

#### Cleaning Up

We no longer need the wiring test. Delete the `test/opinions_test.rb` file.
Open up `lib/opinions.rb` and delete everything inside the module, so it looks
like this:

```ruby
require 'opinions/rating'

module Opinions
end
```

Now let's have a test that writes to the database:

```ruby
def test_persist
  assert_equal 0, Opinions::Rating.count # guard against weird behavior

  data = {
    user_id: 1,
    product_id: 1,
    stars: 3,
    title: "Adorable",
    body: "Very cute monster."
  }
  rating = Opinions::Rating.create(data)
  assert rating.persisted?, "Expected rating to persist"
  assert_equal 1, Opinions::Rating.count
end
```

Run the tests. They should pass. Run them again. They fail.

The test is writing to the database, but there's nothing that deletes it when
the test is done.

We could require the `database_cleaner` gem, but let's go old-school and
hand-roll some rollback functionality.

In the test helper, add this module:

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

Include the module in the test class:

Change the `test_persist` to `test_rollback`, wrapping the write action in a
`temporarily` block. We'll also make an assertion at the very end, outside the
`temporarily` block, that the rating count is zero.

```ruby
class RatingTest < Minitest::Test
  include WithRollback

  # ...

  def test_rollback
    assert_equal 0, Opinions::Rating.count # guard against weird behavior

    temporarily do
      data = {
        user_id: 1,
        product_id: 1,
        stars: 3,
        title: "Adorable",
        body: "Very cute monster."
      }
      rating = Opinions::Rating.create(data)
      assert rating.persisted?, "Expected rating to persist"
      assert_equal 1, Opinions::Rating.count
    end
    assert_equal 0, Opinions::Rating.count
  end
end
```

Delete the `db/opinions_test` file, rerun `OPINIONS_ENV=test rake db:migrate`,
and run the tests a couple times.

### Wiring up Sinatra

To add Sinatra into the mix we need to add a few more files and a few more gems.

The files are:

{% terminal %}
.
├── config.ru
├── lib
│   ├── api.rb
└── test
    └── api_test.rb
{% endterminal %}

The gems are `sinatra` itself, a web server to run it (we'll use Puma), and a gem to help us test the Sinatra controller actions.

Change the Gemfile to the following:

```ruby
source 'https://rubygems.org'

gem 'activerecord', require: 'active_record'
gem 'puma', require: false
gem 'sinatra', require: false
gem 'sqlite3'

group :test do
  gem 'minitest', require: false
  gem 'rack-test', require: false
end
```

As before, we're going to write the simplest test possible to make sure
that everything is wired together correctly.

Create a file `test/api_test.rb`, and add this code to it:

```ruby
require './test/test_helper'
require 'rack/test'
require 'api'

class APITest < Minitest::Test
  include Rack::Test::Methods

  def app
    OpinionsAPI
  end

  def test_hello_world
    get '/'
    assert_equal "Hello, World!\n", last_response.body
  end
end
```

Once everything is wired up correctly, that test will pass.

Follow the errors:

* `cannot load such file -- api`

Create an empty file `lib/api.rb`

* `NameError: uninitialized constant APITest::OpinionsAPI`

Implement the simple Sinatra application in `lib/api.rb`:

```ruby
require 'sinatra/base'

class OpinionsAPI < Sinatra::Base
  get '/' do
    "Hello, World!\n"
  end
end
```

This should get the tests passing.

We also want to be able to run the server so that we can hit the API over
HTTP.

We need a rackup file. Create a file at the root of the directory named
`config.ru`, with the following code in it:

```ruby
$:.unshift File.expand_path("./../lib", __FILE__)

require 'bundler'
Bundler.require

require './config/environment'
require 'opinions'
require 'api'

use ActiveRecord::ConnectionAdapters::ConnectionManagement
run OpinionsAPI
```

Start the server with:

{% terminal %}
$ rackup -p 4567 -s puma
{% endterminal %}

And now you can hit the site at [localhost:4567](http://localhost:4567):

{% terminal %}
$ curl http://localhost:4567
{% endterminal %}

That's it. We have a working, tested Sinatra application.

Admittedly, our Sinatra application doesn't do much work. Let's start with a
single, read-only endpoint.

Since the product show page is a pretty self-contained thing that only reads
data, let's start there.

The Primary app will send over the product ID, and the Sinatra app will return
all the ratings for that product.

In REST, that's a GET endpoint, and it should probably look like this:

```plain
GET /products/:id/ratings
```

We'll version the api in the URL, making it:

```plain
GET /api/v1/products/:id/ratings
```

### Implementing the First Endpoint

The simplest case to test for is the response when a product doesn't have any
ratings:

```ruby
def test_get_ratings_when_there_are_none
  get '/api/v1/products/1/ratings'
  assert_equal 200, last_response.status
  assert_equal "[]", last_response.body
end
```

Next we need the case where a product has multiple ratings. We need:

* two ratings that will be returned (to test "multiple")
* one rating that will not be returned (to test that the response excludes
  ratings).

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

Right now we're getting a full dump of the object's attributes. That's not
going to hold up in the long run, but for the moment it's fine.

Make the test pass:

```ruby
get '/api/v1/products/:id/ratings' do |id|
  Opinions::Rating.where(:product_id => id).map(&:attributes).to_json
end
```

### Consuming Data from the Primary App

What we're going to need in the primary app is a bit of code that will connect
to the sinatra app and parse the JSON response, making a proxy rating for each
item.

Add 'faraday' to your Gemfile.

Right now the ProductsController sends `RatingRepository.ratings_for(product)`:

```ruby
def self.ratings_for(product)
  Rating.where(product_id: product.id).map {|rating|
    ProxyRating.new(rating.attributes)
  }
end
```

Let's add a call to the remote repository above the one that talks to the
local database. We want it to look something like this:

def self.ratings_for(product)
  remote.get("/api/v1/products/#{product.id}/ratings").map {|attributes|
    ProxyRating.new(attributes)
  }

  Rating.where(product_id: product.id).map {|rating|
    ProxyRating.new(rating.attributes)
  }
end

That's going to blow up since we don't have a `remote` method. Create one that
delegates to the `:new` method:

```ruby
def self.remote
  new
end
```

Within the instance we need a couple things:

* a connection that sets up everything to make the request
* a get method that actually makes the request and parses the response

```ruby
def connection
  @connection ||= Faraday.new(:url => "http://localhost:8080") do |c|
    c.use Faraday::Adapter::NetHttp
  end
end

def get(endpoint)
  response = connection.get do |req|
    req.url endpoint
  end
  JSON.parse(response.body)
end
```

This should work.

Comment out the bit that talks to the local database.

Try loading up a product page. Are the comments there?

Probably not, since we haven't seeded the database in the Sinatra application.

Back in the primary app, we should be able to access the endpoint, but it's empty. We don't have any data.

### Migrating Data

Let's create a migration script that we can run to copy ratings from the
primary app to the Sinatra app.

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

Two pieces are missing for this to work:

* the `post` method in the RatingRepository
* the `POST` endpoint in the Sinatra application



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

