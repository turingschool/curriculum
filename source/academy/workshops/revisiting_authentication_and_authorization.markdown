---
layout: page
title: Revisiting Authentication and Authorization
---

You've worked through the fundamentals of Authentication and Authorization before, but let's do it all again.

## Setup

Let's start with the basic Storedom project. You might have it locally already, but if not clone it and get it ready to go:

{% terminal %}
$ git clone https://github.com/JumpstartLab/storedom
$ cd storedom
$ bundle
$ rake db:create db:migrate db:seed
{% endterminal %}

## Part 1: Building Authentication

We've used `has_secure_password` and OmniAuth in the past. Now let's try Devise. Jump to the wiki and follow the setup procedure:

https://github.com/plataformatec/devise#getting-started

## Part 2: Adding Simple Authorization

We're not to get get very complex with authorization. Work through each of these requirements:

* A guest or logged-in user can view all items on `/items`
* A guest attempting to access `/orders` is redirected to login
* A logged-in admin accessing `/orders` sees all orders
* A logged-in user accessing `/orders` sees only orders tied to their account
* An admin visiting `/users` sees all users
* A guest or logged-in non-admin user gets a `403 - Forbidden` if they attempt to access `/users`

## Part 3: Changing Content with Authorization

Now that we can browse content, let's look at changing content.

* When a logged-in non-admin user visits `/orders`, they already see their orders
* Add a `status` column to `Order` that defaults to `"pending"`
* Display that status when the user views their own orders
* When an admin visits `/orders`, add a button `Complete` which changes the `status` to `"complete"`
* Ensure that a non-admin cannot mark an order as `"complete"`
