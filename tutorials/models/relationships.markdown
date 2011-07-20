# Relationships

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

Imagine we want to display a message like "Hello, John" in the header of each page. That might be achieved by a SQL statement like this:

```sql
SELECT * from CUSTOMERS where ID='17';
```

And, of course, that's going to fetch the entire row from our `customers` table. We're trying to get the `first_name`, why bother fetching the `birthday`, `gender`, and `home_city` every request? Instead, we could create a one-to-one relationship between a customer and their "details". 

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

#### Hiding the Child Object

Reaching through an object, talking to the object's child, and calling methods is a violation of the "Law of Demeter" (http://avdi.org/devblog/2011/07/05/demeter-its-not-just-a-good-idea-its-the-law/). Instead, the parent object should present an interface to the child object. From the outside, we shouldn't know the `Detail` object exists at all!

To do that we use Rails' `delegate` method:

```ruby
class Customer
  has_one :detail
  delegate :birthday, :gender, :city, :to => :detail
end
```

Then when we call `Customer.find(17).city` it will proxy the call to the associated `Detail` object, fetch it from the database if it hasn't already been loaded, and return us the value returned from the `Detail` object's method. All of this is transparent from the outside.

We gain performance across our app, simpler database structures, and lose nothing in usability.

### One-to-Many

### Many-to-Many

## Exercises

[TODO: Add exercises]