---
layout: page
title: Revisiting Authentication and Authorization
---

You've worked through the fundamentals of Authentication and Authorization before, but let's do it all again.

## Setup

Let's start with the basic Storedom project. You might have it locally already. If so, make sure you pull down the most recent version using `git pull`, but if not clone it and get it ready to go. We'll be working from the `authorization-revisited` branch which includes some basic setup for Deviese and CanCan.

{% terminal %}
$ git clone git@github.com:turingschool-examples/storedom.git
$ cd storedom
$ git checkout authorization-revisited
$ bundle
$ rake db:create db:migrate db:seed
{% endterminal %}

## Starting Point: Building Authentication and Authorization (Code-along)

We've used `has_secure_password` and OmniAuth in the past. Now, let's try Devise. We've set up the basics for you, but if you're curious on how to get started with Devise, you can read the [Getting Started guide](https://github.com/plataformatec/devise#getting-started).

The following has already been done for you:

* `devise` and `cancancan` have been installed
* A password of "password" has been set for each user
* A guest or logged-in user can view all items on `/items`
* A guest attempting to access `/orders` is redirected to login
* A guest attempting to access `/users` is redirected to login

* A logged-in user can view all orders on `/orders`
* A logged-in user can view all users on `/users`

## Part 1: User Order Permissions (Using CanCanCan)

Obviously allowing every user to view all orders in the system is not
ideal. Let's tighten this up to allow users to only view their own
orders on `/orders`. (Hint: the CanCanCan controller method `load_and_authorize_resource` is very helpful for this purpose; We'll also need to fill in the empty `ability.rb` file with some permissions.)

Objectives:

* A logged-in user accessing `/orders` sees only orders tied to their account

* A logged-in user accessing `/orders/<order_id>` can only see an order
they own.

* A logged-in user attempting to view an order they don't own should be
redirected to the items index.

## Part 2: Restricting User Access by Adding Managers

Similarly, allowing any user to view a list of all users seems a bit too
permissive. Let's tighten things up by adding a "manager" concept to
Storedom. We'll need to update the schema and then add some additional
CanCanCan permissions to restrict access.

Objectives:

* Add a `manager_id` column to the users table (for testing purposes it
will also be useful to give yourself a few "reports" by setting their
`manager_id` to the id of your user in the DB

* A logged-in user accessing `/users` sees only users for whom they are
the manager ("reports")

* A logged-in user accessing `/users/<user_id>` can only see user
information for: a) their own account and b) accounts they manage

* A logged-in user attempting to view another user whom they don't manage should be
redirected to the items index.

## Part 3: Managers Viewing Manag-ees' Orders (Pair Practice)

In addition to being able to view the basic info of a report, we'd
like managers to have access to the orders of their reports on the
Order#index page. This permission structure will be a bit more
sophisticated, but let's see if we can accomplish it using CanCanCan.

Objectives:

* Add a `#reports` association to User which returns all the other users
of whom the user is a manager (Hint: check out the ActiveRecord
Association docs for tips on setting up more custom relationships like
this one)

* Add a `#manager` association to User which returns a User's manager

* A User should be able to view Orders#show for an order whose user they
manage

## Part 3: Changing Content with Authorization (Extension)

Now that we can browse content, let's look at changing content. Logged-in users can put together orders, but a manager must approve the order before it gets charged to the company credit card.

* When a logged-in non-admin user visits `/orders`, they already see their orders

* Add a `status` column to `Order` that defaults to `"pending"`

* Display that status when the user views their own orders

* When an admin visits `/orders`, add a button `Complete` which changes the `status` to `"complete"`

* Ensure that a non-admin cannot mark an order as `"complete"`

## ExtraExtension -- Part 4:

* When viewing Orders#index (`/orders`), a user should see their own
orders as well as those orders for which the `user_id` matches a user
of whom they are a manager.
