---
layout: page
title: Revisiting Authentication and Authorization
---

You've worked through the fundamentals of Authentication and Authorization before, but let's do it all again.

## Setup

Let's start with the basic Storedom project. You might have it locally already. If so, make sure you pull down the most recent version using `git pull`, but if not clone it and get it ready to go:

{% terminal %}
$ git clone git@github.com:turingschool-examples/storedom.git
$ cd storedom
$ git checkout authorization-revisited
$ bundle
$ rake db:create db:migrate db:seed
{% endterminal %}

## Part 1: Building Authentication and Authorization (Code-along)

We've used `has_secure_password` and OmniAuth in the past. Now, let's try Devise. We've set up the basics for you, but if you're curious on how to get started with Devise, you can read the [Getting Started guide](https://github.com/plataformatec/devise#getting-started).

The following has already been done for you:

* `devise` and `cancancan` have been installed
* A password of "password" has been set for each user
* A guest or logged-in user can view all items on `/items`
* A guest attempting to access `/orders` is redirected to login
* A guest attempting to access `/users` is redirected to login
* A logged-in user accessing `/orders` sees only orders tied to their account

## Part 2: Adding Managers (Pair Practice)

Some users of Storedom are managers and other users report to those managers. Managers get some insight into what their subordinates are ordering. Ideally, we'd set up an relationship as well, but that is beyond the scope of this exercise.

* Add a `manager_id` to `User`.
* A user cannot only see their own orders, but they can also see any order placed by a user with a `manager_id` that equals their `id`.
* A user can only see their own account along with any user that has a `manager_id` equal to their `id`.

## Part 3: Changing Content with Authorization (Extension)

Now that we can browse content, let's look at changing content. Logged-in users can put together orders, but a manager must approve the order before it gets charged to the company credit card.

* When a logged-in non-admin user visits `/orders`, they already see their orders
* Add a `status` column to `Order` that defaults to `"pending"`
* Display that status when the user views their own orders
* When an admin visits `/orders`, add a button `Complete` which changes the `status` to `"complete"`
* Ensure that a non-admin cannot mark an order as `"complete"`
