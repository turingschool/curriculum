---
layout: page
title: Supper Slog
sidebar: true
---

Old Dinner Dashes

https://github.com/HoracioChavez/dinner_dash
https://github.com/ericfransen/dinner_dash
https://github.com/BobGu/dinner_dash
https://github.com/marcgarreau/grubhub_v2
https://github.com/glenegbert/dinner-dash
https://github.com/ianderse/dinner_dash

new pivot features

- Multitenancy - I should be able to register a new 
- new order state: machine ordered -> paid -> in preparation -> out for delivery -> delivered
- Assigning responsibility through delivery flow: after paid, order assigned to cook; after prepared order assigned to delivery person
- New Roles: Cook, Delivery Person
- "Theming" -- add ability for restaurants to a) select from a handful of existing themes / color schemes or b) add there own limited CSS
- Restaurant "stocking" -- need to add available inventory to items; items shouldn't be
  order-able when sold out
- other pivot extensions

Your Dinner Dash is *getting* somewhere, but our investors have decided that
serving orders out of a single restaurant is never going to get us to the scale we'd like
to see. What we need is a *platform*. 

In this project you'll build upon an existing implementation of
[Dinner Dash]({% page_url projects/dinner_dash %}), turning it from an
ordering site for a single restaurant into a platform allowing individual restaurants
to sell food online.

## Learning Goals


### Multi-Tenancy / White-Labeling

* Adapting the existing data model to flexibly serve multiple tenants
* Maintaining a robust permission model to keep tenants' data secure and isolated from other tenants

### Business Logic

* Dealing with more sophisticated features and expressing them through idiomatic Rails constructs
* Modeling new data requirements using ActiveRecord
* Using a variety of simple Ruby objects to encapsulate various business responsibilities and
maintain an object-oriented codebase

### Interface & Views

* Factoring view layer into well-organized partials and helper functions that make templates easy to follow
* Maintaining a clean, easy-to-follow user experience for navigating the site

**Note** that we are talking about user experience, not design. The primary focus for this project
is on working with more complex Rails codebases. We'll be relatively unconcerned with design and styling.

### Process

* Practice reading and digesting code in order to familiarize yourself with the existing codebase
* Practice adding functionality to a "legacy" codebase without breaking existing features
* Use outside-in TDD/BDD to drive all layers of Rails development
* Use a professional project management tool to pace and track progress

## Teams

The project will be completed by teams of three to four developers over the span of eighteen days.

Like all projects, individual team members are expected to:

* Seek out features and responsibilities that are uncomfortable. The time to learn is *now*.
* Support your teammates so that everyone can collaborate and contribute.

## Project Starting Point

For this project, you'll be building upon an existing code base assigned by the instructors.
Our primary focus is adding new functionality in incremental steps without trashing existing
tests or features. This is sometimes called "brownfield" development, and you'll soon know
why.

Furthermore, there should be *no reduction in functionality* except when explicitly called for by new requirements.

Finally, as a therapeutic exercise, take a moment now to say aloud: "But, I didn't write this code!"
Well done. That should be the last time we hear those words for the duration of the project.

### Exploring the Dinner Dash App

As a group, dig into the code base and pay particular attention to:

* Test coverage and quality
* Application Architecture (especially pay attention to how the schema and routes are designed)
* Components that are particularly strong or weak
* Any interesting or unusual tools that were used

### Beginning The Pivot

Once you've explored the base project:

* Select one member of the group who will host the canonical repository for the project
* Create a new, blank repository on GitHub named `the_pivot`
* Clone the Dinner Dash project that you'll be working with to your local machine
* Go into that project directory and `git remote rm origin`
* Add the new repository as a remote `git remote add origin git://new_repo_url`
* Push the code `git push origin master`
* In GitHub, add the other team members as collaborators
* The other team members can then fork the new repo

### Tagging the Start Point

We want to be able to easily compare the change between the start of the project and the end. For that purpose, create a tag in the repo and push it to GitHub:

{% terminal %}
$ git tag -a dinner_dash_v1
$ git push --tags
{% endterminal %}

## Project Workflow

Another focus for this project will be using Agile development processes
to maintain steady, incremental progress. This will be require with a combination
of tooling and communication.

### Setup the Project Management Tool

There are many popular project management tools out there. For this project
we'll use a lightweight tool that wraps GitHub issues: [Waffle.io](https://waffle.io/)

Setup a Waffle project for your new repo. Your team members and instructors should
be added to the project so they can create, edit, and comment on issues.

### Managing Requirements

The stories as written and prioritized in your project management tool will be
the authoritative project requirements. They may go against and likely go beyond
the general requirements in this project description.

### Workflow

Generally speaking, work for your project should go through this process:

* A story is written in the project management tool
* A developer comments on the story that they're beginning work
* They create a feature branch
* They develop and test the feature
* They push the *feature* branch to the repository
* They submit a pull request asking to merge the branch into *master*
* A teammate reviews the code for quality and functionality
* The teammate merges the pull request and closes the story/issue

Every few days, we'll have customer check-ins where we will review delivered
features and sign off on them. A feature is not considered complete until the
customer has approved it.

Additionally, we'll be having regular group retrospectives to check in on the
team's overall process and communication.

## Project Requirements

With those general points out of the way, let's talk about what we're actually building.
Our new project will involve turning the existing Dinner Dash into a platform that serves
any number of individual restaurants. This concept is sometimes called "Multi-tenancy" or
"White labeling".

On top of that, we have a number of new features that we'll need to add to make our ordering
platform competitive.

### Multitenancy -- Iteration 1

__Registering a Restaurant__

* As a registered user on the site, I should find in the interface an option to "register a new restaurant/store"
* When registering a restaurant, I should be prompted to enter some basic info including name, slug (optional), and description
* If no slug is entered, generate one for them using the `dash-er-ized-lower-cased` version of the restaurant name 
* No 2 restaurants should be able to have the same slug or name

__Viewing a Restaurant__

Once I have registered a restaurant, I should be taken to its "homepage", which should have a unique
URL using the restaurant's slug. This could be done via a path, e.g. `/restaurants/woraces-jerky-shop` or
via subdomains, e.g. `woraces-jerky-shop.mysite.com`

On this page, I should see a list of all items associated with my restaurant.

__Item/Order/User Relationships__

Now that we have a concept of individual restaurants/tenants, we want to migrate other elements
in our schema to reflect this. Specifically, items in the platform need to be
attached to a specific restaurant. Once this is done, the restaurant's main page
should show all those items that are attached to it.

Indirectly, we can also think of a restaurant having its own collection of *orders* and
*customers* via the items it sells, but we will leave it up to you to determine how
this is modeled.

__Managing a Restaurant__

As the user who created a given restaurant, I should have the ability to edit/manage it by
changing its basic info. Other users (including other owners of different restaurants) should
not be able to modify my restaurant's info.

Additionally, as a restaurant owner, I should have the ability to create/edit/destroy *items* for
my restaurant. These items should be attached to my specific restaurant, and should not
appear on other restaurants' pages. They _should_ appear on the main page for my restaurant.

Note that we'll be re-purposing the existing Admin functionality to work for individual restaurants.
So whenver we talk about features for managing a restaurant from a store owner perspective,
this should take place somewhere within the "admin" portion of the site.

__Browsing Restaurants__

Instead of showing a list of items on the application's main page, let's now display
a list of restaurants. This will give users a basic way to browse the restaurants
on the platform.

### Ordering -- Iteration 2

As a logged-in user, I should be able to browse restaurants on the site and
browse items sold by those restaurants. Just as before, I should be able
to add items to my cart, however this will now need to account for items across
*multiple* stores.

Once I have items in my cart, I should be able to check out. When checking out,
I should see the existing dinner dash order flow, however I should now see my items
divided by the store to which they belong.

Once I complete my order, I should land on an order display page showing my items
ordered by restaurant, as well as total spent, order status, etc.

One question to consider is whether we model orders as a single record attached
to multiple businesses via multiple items, or as individual records to separate
items ordered for each business. We're not so savvy on these technical details,
so we leave this decision up to you.

### Browsing and Categorization -- Iteration 3

As a restaurant owner, I should be able to CRUD a list of categories for my restaurant.
Obviously the categories needed by a pizza shop may be different than those needed by
a sushi shop, so my categories should be independent of those from other restaurants.

When users browse my shop, they should see the items organized by categories and have
the ability to filter on category.

### Order Flow and Processing -- Iteration 4

Customers nowadays expect constant updates on the status of their orders. Additionally,
we need to facilitate the process involved in taking an order from payment to preparation
to delivery.

__New Order Statuses__

We need to add some additional statuses to our order flow to track the
whole process. Your names for some steps may vary, but the overall process
should look something like:

1. Paid
2. Ready for Preparation
3. Cancelled
4. In Preparation
5. Ready for Delivery
6. Out for Delivery
7. Delivered / Completed

Unfortunately, we can't afford to refund orders that have already been made, so
once an order has progressed to "in preparation" or beyond, it can no longer be
cancelled.

Additionally, as a store owner, I should be able to see a list of existing orders
organized by their current status (just as in Dinner Dash, but now for my specific store).

__New Restaurant Roles -- Cooks and Delivery People__

Restaurant owners will need some additional hands to manage their production
and delivery flow, so we need to add tools to facilitate this.

1. As a restaurant owner, I should have an option in my admin panel to add users
as cooks or delivery people.
2. Adding users should be done by their email address.
3. If a user with the supplied email address already exists in the system, they should
be added to my store with the specified role
4. If the user does not exist in the system, they should receive an email inviting
them to register on the platform. Once they have done so, they should automatically
be added to my store as requested.

Cooks and Delivery People (we can call these users "staff") should also be able to
see the order status breakdown for restaurants to which they are attached.

__Order Delivery Pipeline__

Once an order is paid, it should become "ready for preparation". As a cook,
when viewing an order in this status, I should see an option to "prepare this order".

Clicking this should:

1. Assign it to me as the preparer/cook
2. Move its status to "in preparation"

As the cook preparing a given order, I should see an option to mark it "ready for delivery".
Doing this should update its status to "ready for delivery".

Similarly, as a delivery person viewing a list of orders marked "ready for delivery", I should have an
option to "deliver this order". Clicking this should assign the order to me as its deliverer
and should mark it "out for delivery".

As the delivery person for an out-for-delivery order, I should have the option to
"mark as delivered". This should make the order "completed"

### Supporting Features -- Iterations 5+

Completing all the above features should give us the baseline we need to get our
restaurant platform off the ground. But to be competitive, we need some special features
to really make our platform pop. Below is a list of supporting features that we're
considering for the platform. __Your team needs to complete at least 3 of these.__
