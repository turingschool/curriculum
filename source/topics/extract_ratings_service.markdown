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

Wire together test and lib directories
Wire up activerecord
Implement rollback for tests
Wire up sinatra lib/api.rb
 - handle not_found
 - handle 500 errors
Create config/environment file
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

