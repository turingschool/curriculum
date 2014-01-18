---
layout: page
title: Extract Ratings Service
sidebar: true
---

## Introduction

We'll take an existing project, the Monsterporium store, and extract the ratings system to an external API.

This tutorial assumes that you have completed the [Extract Notification Service]({% page_url extract_notification_service %}) tutorial, but can be completed independently of it.

Extracting the email into a service was relatively easy. Really, it wasn't much different than the way many apps implement background workers. Now, let's look at a more complex architecture that, rather than just "doing" an action, is used to read and write domain data.

### Goals

Through this extraction process you'll learn:

* How to write a JSON API using Sinatra and Active Record
* How to use Rails form helpers with non-ActiveRecord objects
* How to access data that's been computed by an external service

<div class="note">
<p>This tutorial is open source. If you notice errors, typos, or have questions/suggestions,
  please <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/topics/extract_ratings_service.markdown">submit them to the project on GitHub</a>.</p>
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

If you don't already have the Monsterporium and Redis installed, hop over to [the installation instructions]({% page_url projects/monsterporium/setup %}).

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
get "/products/:product_id/ratings/:user_id" => "ratings#edit", as: :edit_product_rating
put "/products/:product_id/ratings/:user_id" => "ratings#update", as: :product_rating
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
RatingsRepository.ratings_for(@product)
```

Then in the `RatingsRepository` add the following:

```ruby
class RatingsRepository
  def self.ratings_for(product)
    Rating.where(product_id: product.id)
  end
end
```

We're passing the call through the `RatingsRepository` and letting the `Rating` class do the hard work. The product listing should still work and all tests pass.

#### Decoupling from the `OrderedProduct`

The `OrderedProduct` is asking for all of the ratings by a particular user:

```ruby
Rating.where(user_id: user.id)
```

Change this to:

```ruby
RatingsRepository.ratings_by(user)
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

Change this to ask the `RatingsRepository` to create a new rating for the given `product_id`:

```ruby
def new
  @rating = RatingsRepository.new_rating(product_id: params[:product_id])
  # ...
end
```

And add the wrapper-method to the `RatingsRepository`:

```ruby
def self.new_rating(attributes)
  Rating.new(attributes)
end
```

The `create` method also needs a new Rating. Make the same change there.

The `edit` and `update` actions both make calls to `Rating.find_unique`.
Create a method on `RatingsRepository` that delegates the message to Rating.

At that point, there should be no references to the `Rating` model outside of `RatingsRepository`.

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

Back in the `RatingsRepository`, make the same change to the `ratings_by(user)`
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

Give the `ProxyRating` a save method which delegates to `RatingsRepository` to create a new record:

```ruby
def save
  RatingsRepository.save(attributes)
end
```

Implement `save` on the `RatingsRepository` to actually store it in the database:

```ruby
def self.save(attributes)
  Rating.new(attributes).save
end
```

NOTE: In real life giving a dumb proxy object a save method is probably *not*
what you want. After everything is working, it would be good to change the
controller so that it calls the RatingsRepository.save, passing it the object.
Because we're going to need to work against both a proxy and a real object,
that's going to get messy, so we're introducing this ugly thing first.

### Editing Ratings

Next, let's try to edit a rating. 

Most likely all the existing ratings in the system are older than 15 minutes, so they're uneditable. If you want to re-seed the DB:

{% terminal %}
$ bundle exec rake db:drop db:migrate db:seed
{% endterminal %}

#### Finding a Rating

In the `RatingsRepository` return a `ProxyRating` object from the `find_unique`
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
  RatingsRepository.update(attributes.merge(user_id: user_id, product_id: product_id))
end
```

The `update` method doesn't exist yet in `RatingsRepository`. Add it:

```ruby
def self.update(attributes)
  Rating.find_unique(attributes).update_attributes(attributes)
end
```

Now your edits should persist correctly.

### Back to Fully Functional

At this point the shim is in place and everything should be working both through the web UI and all tests should be green.

## Creating a Ratings Application

Now let's build the external ratings application to interact with the primary
app. We'll start with plain Ruby, add in ActiveRecord to manipulate the
database, then mix in Sinatra for HTTP interaction.

### Starting the Project

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

#### Dependencies

We only need one gem: `minitest`. We could use `minitest` from the ruby standard library, but the gem version has so many improvements, that it's worth jumping through a couple of small hoops to get it.

Add this to the Gemfile:

```ruby
source 'https://rubygems.org'

group :test do
  gem 'minitest', :require => false
end
```

#### Beginning to Test

We can start with a `test/opinions_test.rb`:

```ruby
gem 'minitest'
require 'minitest'
require 'minitest/autorun'

class OpinionsTest < Minitest::Test
  def test_exists
    assert Opinions
  end
end
```

Run it and it'll fail because it doesn't know about the `Opinions` class. Require 'opinions' at the top of the file, and run the test again.

#### Changing the Load Path

It still fails, because it can't find `Opinions`.

Let's add `lib/` to the path. At the top of the test file, add this:

```ruby
$:.unshift File.expand_path("./../../lib", __FILE__)
```

Now it finds the file, but that file doesn't contain anything. Define an `Opinions` module, run the tests, then it complains about the method `env` not existing.

#### Defining `.env`

```ruby
def test_environment
  assert_equal 'test', Opinions.env
end
```

Well that's easy:

```ruby
def teardown
  ENV['OPINIONS_ENV'] = 'test'
end
```

Easy, but not very good.

We should be able to configure the environment.

```ruby
def test_environment_is_configurable
  ENV['OPINIONS_ENV'] = 'production'
  assert_equal 'production', Opinions.env
end
```

TODO: rework this section to TDD the env stuff correctly.

Let's read from an environment variable:

```ruby
module Opinions
  def self.env
    @env ||= ENV.fetch("OPINIONS_ENV") { "development" }
  end
end
```

If you're not familiar with `fetch`, it will look for the `OPINIONS_ENV` key in the `ENV` hash of environment variables. If the key is found, the value will be returned. If it is not found, `"development"` will be used like a default value.

At this point the test should pass. 

#### Extracting a `test_helper.rb`

We're going to want all that setup in a separate test helper. Extract it to `test/test_helper.rb`:

```ruby
$:.unshift File.expand_path("./../../lib", __FILE__)
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride' # not strictly necessary, but worth it

ENV['OPINIONS_ENV'] = 'test'
require 'opinions'
```

#### Building a `Rakefile`

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
any data migrations as simple as possible, we're going to use the same ActiveRecord `Rating`object in the stand-alone application.

There's more to it than just requiring 'active_record' and copying the file over, however.

We're going to need to deal with

* configuration
* opening and closing the connection to the database
* database migrations
* running tests in transactions so that tests don't interfere with each other

#### Adding Files to the New Application

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

#### Dependencies in the `Gemfile`

We need to add both ActiveRecord and an appropriate adapter to the Gemfile. The primary application uses SQLite3, so we'll use that here as well.

```ruby
source 'https://rubygems.org'

gem 'activerecord', require: 'active_record'
gem 'sqlite3'

group :test do
  gem 'minitest', require: false
end
```

Run `bundle install` to install the dependencies.

#### Unit Testing `Rating`

We'll add a separate test file for the `Rating` class. Since the code will live in
`lib/opinions/rating.rb` we'll put the test in `test/opinions/rating_test.rb`.

We won't test anything fancy yet. If our test manages to load a new `Rating`
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

Run `rake`.

It blows up with `NameError: uninitialized constant Opinions::Rating`.

#### Copying `Rating`

Copy the `Rating` class from the primary application to
`lib/opinions/rating.rb`. Make sure to *delete* any methods that refer to parts
of the primary application that we no longer have access to.

Also, put `Rating` inside the `Opinions` namespace:

```ruby
module Opinions
  class Rating < ActiveRecord::Base
    # ...
  end
end
```

Run `rake` again.

It blows up with the same error, because we're not loading
the class anywhere.

#### Requiring the Model

Open `lib/opinions.rb` and require 'opinions/rating'.

Run `rake` again.

Now it complains about an `uninitialized constant
Opinions::ActiveRecord (NameError)`. It's not loading ActiveRecord.

#### Loading ActiveRecord

Rather than manually load all the dependencies, let's create an `environment.rb`
file that loads bundler and anything required explicitly in the Gemfile.

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

Run `rake` and we're making progress.

The next error is a complaint that `No such file or directory -
config/database.yml (Errno::ENOENT)`.

#### Writing a `database.yml`

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

#### Writing a Migration

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

#### Rake Task to Run Migrations

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

Then you can run `rake db:migrate`. Try the tests again.

#### Migrating for the Test Environment

When you run `rake`, it will *still* not find the ratings table. That's because
the `rake db:migrate` task defaulted the environment to development, and the
tests are running against the test environment.

Run the migration with the test configuration:

{% terminal %}
OPINIONS_ENV=test rake db:migrate
{% endterminal %}

Run `rake` again, and **finally the tests should pass**.

#### Cleaning Up

We no longer need the wiring test. Delete the `test/opinions_test.rb` file.
Open up `lib/opinions.rb` and delete everything inside the module, so it looks
like this:

```ruby
require 'opinions/rating'

module Opinions
end
```

#### Writing to the Database

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

Run the tests. They should pass. Run them again. They fail. **WAT**.

#### Rolling Back Test Saves

The test is writing to the database, but there's nothing that deletes it when
the test is done. We could require the `database_cleaner` gem, but let's go old-school and
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

Let's clear and re-migrate the database.

* delete the `db/opinions_test` file
* rerun `OPINIONS_ENV=test rake db:migrate`

Then run the tests a couple times and they should pass *consistently*.

### Wiring up Sinatra

To add Sinatra into the mix we need to add a few more files and a few more gems.

#### Additional Files

Create the following files in your existing app:

{% terminal %}
.
├── config.ru
├── lib
│   ├── api.rb
└── test
    └── api_test.rb
{% endterminal %}

#### Additional Dependencies

The gems are `sinatra` itself, a web server to run it (we'll use Puma), and a gem to help us test the Sinatra controller actions.

Change the `Gemfile` to the following:

```ruby
source 'https://rubygems.org'

gem 'activerecord', require: 'active_record'
gem 'puma'
gem 'sinatra', require: 'sinatra/base'
gem 'sqlite3'

group :test do
  gem 'minitest', require: false
  gem 'rack-test', require: false
end
```

#### Validating the Setup

As before, we're going to write a very simple test to make sure
that everything is wired together correctly.

Create a file `test/api_test.rb`, and add this code to it:

```ruby
require './test/test_helper'
require 'rack/test'
require 'sinatra/base'
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

Once everything is wired up correctly, that test will pass. But first you'll have to follow and fix a series of errors:


* `cannot load such file -- api` -- Create an empty file `lib/api.rb`
* `NameError: uninitialized constant APITest::OpinionsAPI` -- add this  Sinatra application in `lib/api.rb`:

```ruby
class OpinionsAPI < Sinatra::Base
  get '/' do
    "Hello, World!\n"
  end
end
```

This should get the test passing.

#### Creating a `rackup` File

We also want to be able to run the server so that we can hit the API over
HTTP using Rack.

Create a file at the root of the directory named `config.ru` (ru stands for **r**ack**u**p), with the following:

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

#### Start the Server

Start the server with:

{% terminal %}
$ rackup -p 4567 -s puma
{% endterminal %}

#### Test It Out

And now you can hit the site at [localhost:4567](http://localhost:4567) either
in your browser or from the command line:

{% terminal %}
$ curl http://localhost:4567
{% endterminal %}

That's it! We have a working, tested Sinatra application.

#### Next Steps

Admittedly, our Sinatra application doesn't do anything. Let's start with a
single, read-only endpoint.

## Ratings for a Single Product

Think about the product display page in the primary application. You've got an `id` which is used to find the product in the database, then the same `id` is needed to find the ratings in this remote service.

### Verb & Path

In REST, that's read operation is GET endpoint with a path like this:

```plain
GET /products/:id/ratings
```

We'll version the api in the URL, making it:

```plain
GET /api/v1/products/:id/ratings
```

### Implementing the First Endpoint

Let's follow a TDD process to gradually build up the implementation.

#### When There Are No Ratings

In the stand-alone application, open up the `test/api_test.rb`. We're going to
implement the `/api/v1/products/:id/ratings` endpoint.

The simplest case to test for is the response when a product doesn't have any
ratings:

```ruby
def test_get_ratings_when_there_are_none
  get '/api/v1/products/1/ratings'
  assert_equal 200, last_response.status
  assert_equal "[]", last_response.body
end
```

Modify your Sinatra app to make this pass.

#### Finding Multiple Matched Ratings

Next, we need the case where a product has multiple ratings.

In order to test that this actually returns the correct ratings, we need three ratings in the database: two that match and should be returned, and one that does not match and should be omitted.

```ruby
def test_get_all_ratings_for_product
  temporarily do
    data = {title: "title", body: "body"}
    r1 = Opinions::Rating.create(data.merge(product_id: 1, user_id: 1, stars: 1))
    r2 = Opinions::Rating.create(data.merge(product_id: 1, user_id: 2, stars: 5))
    r3 = Opinions::Rating.create(data.merge(product_id: 2, user_id: 2, stars: 3))
    get '/api/v1/products/1/ratings'
    ratings = JSON.parse(last_response.body)["ratings"]
    ids = ratings.map {|r| r["rating"].id}.sort
    assert_equal ids, [r1, r2].sort
  end
end
```

##### Sinatra Implementation

To get the tests to pass we'll ask the `Rating` model for the relevant ratings
and map over the attributes.

```ruby
get '/api/v1/products/:id/ratings' do |id|
  {ratings: Opinions::Rating.where(:product_id => id)}.to_json
end
```

We will want a better solution eventually, but for
now this will let us connect the two applications.

### Consuming Data from the Primary App

In the primary app we're going to need a bit of code that

* connects to the sinatra app
* parses the JSON response
* creates a `ProxyRating` for each entry

#### Setup Faraday

We'll use the `faraday` gem to connect to the Sinatra application. In your
Gemfile add:

```ruby
gem 'faraday'
```

If you'd like to learn about Faraday and how it's used for HTTP requests in Ruby, [check out the README](https://github.com/lostisland/faraday).

#### Modifying `.ratings_for`

In the primary app, the `ProductsController` sends
`RatingsRepository.ratings_for(product)`. The method is implemented like this:

```ruby
def self.ratings_for(product)
  Rating.where(product_id: product.id).map {|rating|
    ProxyRating.new(rating.attributes)
  }
end
```

Before we replace that code, let's use Ruby as a compiler and work on our Faraday/API call.

```ruby
def self.ratings_for(product)
  remote.get("/api/v1/products/#{product.id}/ratings")["ratings"].map {|r|
    ProxyRating.new(r["rating"])
  }

  Rating.where(product_id: product.id).map {|rating|
    ProxyRating.new(rating.attributes)
  }
end
```

That's going to blow up since we don't have a `remote` method.

#### Connecting to `remote`

What does `remote` represent? It's our connection to the external service -- which itself is really a repository of ratings. Get it?

Let's implement `remote` to create a new instance of `RatingsRepository`:

```ruby
def self.remote
  new
end
```

Then we need to think about how a `RatingsRepository` instance actually connects to the external service.

#### Building the Connection

Within the instance we need a couple things:

* a connection that sets up everything to make the request
* a `get` method that actually makes the request and parses the JSON response

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

With that in place, run your tests. If they don't pass, try to debug and get it working.

Once they *do* pass, comment out the bit that talks to the local database,
leaving only the remote call.

#### Next Steps

Try loading up a product page in the browser. Are any ratings there?

Doh! We haven't seeded the database in the Sinatra application. We're able to call the API endpoint, but the result is always an empty array.

### Migrating Data

We want to see reading from the API work before we get into implementing the write story. But we can't just generate ratings within the service, they have to match up with the product and user IDs from the primary app. So let's migrate the ratings data over from the primary app to the service using `sqlite`.

#### Exporting the Data

Go to the project directory for the primary application in your terminal, and
run:

{% terminal %}
$ sqlite3 db/monster_development
sqlite> .mode insert
sqlite> .out ratings.sql
sqlite> select * from ratings;
sqlite> .quit
{% endterminal %}

This will dump the contents of the ratings table into a file named
`ratings.sql`, which you can then load into the stand-alone application.

#### Loading the Data

Move the file to the `opinions` project directory, and run:

{% terminal %}
$ sqlite3 db/opinions_development
sqlite> .read ratings.sql
sqlite> .quit
{% endterminal %}

#### Test It Out

Return to the browser and load a product listing. You should now see the ratings show up from the remote service!

### Writing to the API

Let's move on writing data to the remote application.

#### Writing Tests

There are two cases that we should test for:

* the happy path, where a rating is created
    - has a response status of `201`
    - creates a rating in the database
    - the rating has the expected values
* the sad path, when parameters are missing
    - has a response status of `400`
    - has a helpful error message

The basic test structure is:

* do some setup
* call the endpoint
* verify the results

```ruby
def test_create_rating_by_user_for_product
  temporarily do
    data = {
      user_id: 2,
      title: "title",
      body: "body",
      stars: 3
    }

    post '/api/v1/products/1/ratings', {rating: data}.to_json

    assert_equal 1, Opinions::Rating.count
    rating = Opinions::Rating.first
    assert_equal "title", rating.title
    assert_equal "body", rating.body
    assert_equal 3, rating.stars
    assert_equal 2, rating.user_id
    assert_equal 1, rating.product_id
  end
end

def test_create_fails
  temporarily do
    post '/api/v1/products/1/ratings', {rating: {user_id: 2}}.to_json

    assert_equal 0, Opinions::Rating.count
    assert_equal 400, last_response.status
    assert_equal "Missing required data.", JSON.parse(last_response.body)["error"]
  end
end
```

Run those tests and verify that they fail.

#### Implementing the Write API

There's a tricky piece to making this test pass:

When we send JSON in the body of the `POST` Sinatra
doesn't know it's JSON, and sticks the whole JSON string into a key in the
params hash.

There's middleware in `sinatra-contrib` that we could include in order to
handle JSON in the POST-body, but we're going to deal with the incoming string ourself:

```ruby
post '/api/v1/products/:id/ratings' do |id|
  request.body.rewind
  data = JSON.parse(request.body.read)
  rating = data["rating"]
  # ...
end
```

#### Posting Data from the Primary App

We have most of what we need in the `RatingsRepository` already.

The piece that is missing is a method on the `RatingsRepository` instance that
performs the actual `post` to the remote API:

```ruby
def post(endpoint, params)
   response = connection.post do |req|
     req.url endpoint
     req.headers['Accept'] = 'application/json'
     req.headers['Content-Type'] = 'application/json'
     req.body = {rating: params}.to_json
  end
end
```

Try (A) running your tests in the primary app and (B) posting/viewing a rating through the browser -- both should now work.

### Implementing the Remaining API Endpoints

Add tests in in the Sinatra application for the following API endpoints:

* Reading all the user's ratings - `GET /api/v1/users/:id/ratings`
* Reading a particular rating - `GET /api/v1/products/:id/ratings/:user_id`
* Updating a particular rating - `PUT /api/v1/products/:id/ratings/:user_id`

Now that you're a pro with services, Sinatra, and APIs, make those tests pass.

### Finishing the `RatingsRepository`

Convert each method in the `RatingsRepository` to use the remote API rather
than the `Rating` model.

Verify in the browser that everything still works.

## Cleaning Up

### Deleting Temporary Code

Now that we have a fully developed API, go ahead and delete the "Hello World"
endpoint and the test that calls it.

### Specifying Content-Type

Take a look at the headers when you make a verbose call to the API:

{% terminal %}
curl -v http://localhost:8080/api/v1/products/1/ratings
{% endterminal %}

Does anything catch your eye?

The content type is `application/html` even though the endpoint is returning JSON.

We can fix that with a before filter in the `lib/api.rb` file:

```ruby
before do
  content_type 'application/json'
end
```

### Protecting User Data

One of the bugs in the original implementation, which we've perpetuated here,
is that anyone can create or update ratings for any user by manipulating the submitted parameters.

A robust, authentication model is a complicated beast, but we can use a fairly
simple "shared secret" approach to protecting the write endpoints.

#### Test Service Secret Generation

In the Sinatra app write tests around the generation of a "secret" based on an ID number:

```ruby
require './test/test_helper'

class OpinionsTest < Minitest::Test
  def test_valid_user
    key = Opinions.secret_for(1)
    assert Opinions.user_is?(1, key)
    refute Opinions.user_is?(2, key)
  end

  def test_key_is_not_just_the_id
    refute_equal "1", Opinions.secret_for(1).to_s
  end
end
```

#### Generate a Secret

Then implement a secret in the Sinatra app. The "shared secret" here is wrapped in a method named `quote`. We'll combine that with the user ID and pass it through a SHA1 hash to generate the unique secret per user:

```ruby
require 'digest'

# ...

def self.secret_for(id)
  Digest::SHA1.hexdigest("#{quote}, to user: #{id}")
end

def self.user_is?(id, key)
  key == secret_for(id)
end

def self.quote
  "Don't cry because it's over, smile because it happened. -- Doctor Seuss"
end
```

Now, when we call the API, the primary app can send the rating data, the user ID, and the similarly-generated key. The service will compute a key using the user ID and the secret, then verify that it matches the incoming parameter.

If a user tries to change the user ID then it'll generate a totally different hash and the submission will be rejected.

#### Verify the Secret is Used

Test that each method of the API is guarded by this strategy. If we submit parameters without a secret, we should get back an HTTP `401 Unauthorized`:

```ruby
def test_post_is_protected_by_shared_secret
  temporarily do
    data = {
      user_id: 2,
      title: "title",
      body: "body",
      stars: 3
    }
    post '/api/v1/products/1/ratings', {rating: data}.to_json
    assert_equal 401, last_response.status
  end
end

def test_put_is_protected_by_shared_secret
  temporarily do
    data = {
      title: "title",
      body: "body",
      stars: 3
    }
    Opinions::Rating.create(data.update(stars: 5))
    put '/api/v1/products/1/ratings/2', {rating: data}.to_json
    assert_equal 401, last_response.status
  end
end

def test_delete_is_protected_by_shared_secret
  assert_equal 0, Opinions::Rating.count
  delete '/api/v1/products/1/ratings/2'
  assert_equal 401, last_response.status
end
```

Run those tests and see them fail, then change the Sinatra app to make them pass.

#### Repeat in the Primary Application

Go over to your primary application and...

* Add tests to drive the creating of a secret
* Send the secret along with the data when writing to the API
* Verify that all your tests pass

### Testing with VCR

* create a small set of seed data that corresponds to the fixture data
* write a script to create it in the Sinatra app
* run the sinatra app in test mode
* run the seed script
* use VCR to capture the HTML response

```ruby
gem 'vcr' # in the test group
```

In the spec helper:

```ruby
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = './spec/fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
end
```

```ruby
it "works" do
  VCR.use_cassette('user-creates-rating') do
    # the body of the test
  end
end
```

### Easier JSON Output with Petroglyph Templates

In the Gemfile:

```ruby
gem 'petroglyph', require: false # only needed in the Sinatra app
```

In the Sinatra API:

```ruby
require 'petroglyph'
require 'sinatra/petroglyph'

class API < Sinatra::Base
  set :root, 'lib/app' # let Sinatra know where to look for views

  get '/products/:id/ratings' do |id|
    # ...
    ratings = Opinions::Ratings.where(product_id: id)
    pg :ratings, locals: {ratings: ratings}
  end

  # ...
end
```

`mkdir lib/app/views`

In `lib/app/views/ratings.pg`:

```ruby
collection ratings: ratings, partial: rating
```

In `lib/app/views/rating.pg`:

```ruby
node rating: rating do
  attributes :product_id, :user_id, :stars, :title, :body
  node rated_at: rating.created_at
end
```

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

