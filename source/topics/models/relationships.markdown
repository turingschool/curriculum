---
layout: page
title: Relationships
section: Models
---

The most important component of the Rails MVC stack is the model layer. `ActiveRecord`, Rails' built-in Object-Relational Mapper, makes working with databases easy. Let's look at the basic relationships in a traditional database and how they're implemented in `ActiveRecord`.

## The Basics

There are three core relationships:

* One-to-One
* One-to-Many
* Many-to-Many

### One-to-One

The simplest but most under-utilized relationship is one-to-one. It is best applied when you have an object that has more than one role in the system.

For instance, imagine an e-commerce site. We have customers, and for each of those customers we want to track information like:

* Orders
* Addresses
* First Name
* Last Name
* Birthday
* Gender
* Home City
* Username
* Password
* Email Address

Filtering that into a table `customers` would result in these columns:

* `first_name`
* `last_name`
* `birthday`
* `gender`
* `city`
* `username`
* `password`
* `email_address`

It's most common to drop all these attributes into a single model, but does that really make sense?

#### Problem Scenario

Imagine we want to display a message like "Hello, John" in the header of each page. In our controller we would say `Customer.find(17)` and use `@customer.first_name` in our view.  Rails will run a SQL statement like this:

```sql
SELECT * from CUSTOMERS where ID='17';
```

And, of course, that's going to fetch the entire row from our `customers` table. We're trying to get the `first_name`, so why bother fetching the `birthday`, `gender`, and `home_city` every request? Instead, we could create a one-to-one relationship between a customer and their "details". 

#### Building Details

We create a new table named details with just these columns:

* `birthday`
* `gender`
* `city`
* `customer_id`

Now that table can hold any small, infrequently used bits of information and we'll improve application performance.

#### Model Relationships

To explain this relationship to Rails we use the methods `has_one` and `belongs_to`. Which is which? The side that holds a foreign key, here the `customer_id`, is effectively the child which `belongs_to` the parent.

```ruby
class Customer
  has_one :detail
end

class Detail
  belongs_to :customer
end
```

#### Using the Objects

Now when we could find a customer by the ID 17 with `Customer.find(17)`. That object would just have the essential fields.

To access the details, we could do something like `Customer.find(17).detail.birthday` and it would work just fine.

#### Automatic Building

In this kind of scenario, we want every customer to have an associated `Detail` object.

In pseudocode, what we want to do is "create an attached `Detail` object whenever a `Customer` object is initialized". To implement that in code we can use the `after_initialize` callback:

```ruby
class Customer < ActiveRecord::Base
  has_one :detail
  after_initialize do
    self.build_detail if detail.nil?
  end  
end
```

Now when we call `Customer.new` it will automatically build a `Detail` and associate them in memory. Once the `Customer` is saved it will get an ID from the database and that ID will be stored in the `customer_id` field of the `Detail`. We only want to build a Detail object if we don't already have one, so we add the if detail.nil? condition to avoid replacing an existing Detail object.

#### Automatic Destruction

Given the current setup, when we destroy a `Customer` it is going to leave an orphaned `Detail` object in the database. Instead, we want the child object destroyed automatically when the parent is destroyed. That's accomplished with this change to the `has_one`:

```ruby
has_one :detail, dependent: :destroy
```

#### Hiding the Child Object

Reaching through an object, talking to the object's child, and calling methods is a violation of the "Law of Demeter" (http://avdi.org/devblog/2011/07/05/demeter-its-not-just-a-good-idea-its-the-law/). Instead, the parent object should present an interface to the child object. From the outside, we shouldn't know the `Detail` object exists at all!

To do that we use Rails' `delegate` method:

```ruby
class Customer < ActiveRecord::Base
  has_one :detail, dependent: :destroy
  
  delegate :birthday, :gender, :city, to: :detail
  
  after_initialize do
    self.build_detail if detail.nil?
  end  
end
```

Then when we call `Customer.find(17).city` it will proxy the call to the associated `Detail` object, fetch it from the database if it hasn't already been loaded, and return us the value returned from the `Detail` object's method. All of this is transparent from the outside.

#### Simplifying the Proxy

One small catch here is that `delegate` only handles the listed methods, so if you want to have full read/write access to the child's attributes you'd need:

```ruby
delegate :birthday, :birthday=, :gender, :gender=, :city, :city=, to: :detail
```

The list starts to get long, and if we add methods to `Detail` we need to remember to add them to the delegation. Programmers don't remember things, so here's one solution:

```ruby
class Detail < ActiveRecord::Base
  belongs_to :customer
  
  ATTR_METHODS = [:birthday, :birthday=, :gender, :gender=, :city, :city=]
end

class Customer < ActiveRecord::Base
  has_one :detail, dependent: :destroy
  
  delegate *Detail::ATTR_METHODS, to: :detail
  
  after_initialize do
    self.build_detail if detail.nil?
  end
end
```

The element that you're likely to notice here is the use of `*`, Ruby's splat operator. It breaks apart the array into a list of parameters, resulting in identical functionality to when we listed them all right in the call to `delegate`. 

### One-to-Many

One-to-many is the most common relationship in Rails. One customer connects to many orders. One article connects to many comments. The relationship is asymmetric because the parent has many children, but the child has only one parent.

#### In the Database

At the database level it is very similar to a one-to-one: the "child" record holds a foreign key pointing back to the "parent". The parent record or row actually has no idea how many children are out there and only the child links back to the parent.

#### In Your Models

Let's say we're going to connect our `Customer` object with multiple `Order` objects. In our Rails models:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders
end

class Order < ActiveRecord::Base
  belongs_to :customer
end
```

The `has_many :orders` tells Rails to expect a model named `Order` that has a foreign key named `customer_id`. The `belongs_to :customer` tells Rails that `customer_id` points to the ID field of a class named `Customer` or table named `customers`. All these expectations can be overridden as we'll see soon.

#### Building Child Objects

When you create a `Customer` it won't have any child `Order` objects. Here are three ways to create one, assuming we have a `customer` object:

* `Order.new(customer_id: customer.id)` -- least preferred. It has no future flexibility if we change details like the foreign key name
* `Order.new(customer: customer)` -- better. It created the object through the `ActiveRecord` relationship, so we can handle the details in that relationship.
* `customer.orders.new` -- best. The order is built directly off the relationship, hiding all the details. We can add things like a validation on customer that they don't have more than X open orders or whatever else applies to our domain. Note that `customer.orders.build` is equivalent to calling `.new`.

#### Destroying Children

Just like the `has_one` relationship, we frequently want the child objects to be destroyed when the parent is destroyed. We add the same `dependent` option to the `has_many` call:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, dependent: :destroy
end
```

### Many-to-Many

Strictly speaking, there is no such thing as a many-to-many relationship. It is only achieved through the composition of two one-to-many relationships via a join model.

#### HABTM

In the early days of Rails we used `has_and_belongs_to_many` to handle this relationship. A typical example might imagine a publisher of magazines: a customer connects to many magazines and a magazine connects to many customers.

Using HABTM, we would have modeled it like this:

```ruby
class Magazine < ActiveRecord::Base
  has_and_belongs_to_many :customers
end

class Customer < ActiveRecord::Base
  has_and_belongs_to_many :magazines
end
```

This told Rails that there was a table `magazines`, a table `customers`, and a table `customers_magazines` (named by alphabetizing the two table names). Neither `magazines` nor `customers` hold any foreign keys. Each row of the join table, `customers_magazines`, has a foreign key connecting to one row from `magazines` and one row from `customers`.

Thus a `Magazine` related to many rows in `magazine_customers` which, in turn, each related to one `Customer`. The reverse is also true, completing the illusion of many magazines connecting to many customers. 

For all later examples in this chapter, assume `@magazine` is an instance of `Magazine` and `@customer` an instance of `Customer`. We could then hop between them like this:

{% irb %}
$ customers = @magazine.customers
$ magazines = @customer.magazines
{% endirb %}

These days, through, HABTM is deprecated and should not be used.

#### Has Many Through

As our experience with HABTM grew, it became apparent that, in almost every circumstance, the join model should *not* just be an implementation detail. Instead, it is usually the sign of a missing domain model.

Consider this example of `Customer` and `Magazine`. What is their connection? It should be a `Subscription`. It deserves promotion to a proper model:

```ruby
class Magazine < ActiveRecord::Base
  has_many :subscriptions
end

class Subscription < ActiveRecord::Base
  belongs_to :magazine
  belongs_to :customer
end

class Customer < ActiveRecord::Base
  has_many :subscriptions
end
```

Why does it deserve to be a model in its own right? As apps grow we often want to store data in the connection. What day did the customer subscribe to the magazine? When does the subscription expire? What promotion code did they use to sign up? This data could probably be hacked into the `customers` table, but it really belongs in the join -- the `subscriptions` table.

What about hopping between the models? We can do this:

{% irb %}
$ mag_subscriptions = @magazine.subscriptions
$ customers = mag_subscriptions.collect{|sub| sub.customer}
$ cust_subscriptions = @customer.subscriptions
$ magazines = cust_subscriptions.collect{|sub| sub.magazine}
{% endirb %}

But we've lost the elegance of hopping directly from a `Magazine` to its associated `Customer` objects.

The solution is to add a second relationship to each of the primary models:

```ruby
class Magazine < ActiveRecord::Base
  has_many :subscriptions
  has_many :customers, through: :subscriptions
end

class Customer < ActiveRecord::Base
  has_many :subscriptions
  has_many :magazines, through: :subscriptions
end
```

Using "has many through", Rails can hop across the intermediary relationship. We can now call `@customer.subscriptions` when we want to work with the join, and `@customer.magazines` when we don't. Similarly, `@magazine.subscriptions` and `@magazine.customers`. We have the elegance of HABTM, but the ability to put logic and intelligence in the join.

## Reference

* Ruby's splat operator: http://kconrails.com/2010/12/22/rubys-splat-operator/
