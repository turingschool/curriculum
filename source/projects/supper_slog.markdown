---
layout: page
title: Supper Slog
sidebar: true
---

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

### Beginning Supper Slog

Once you've explored the base project:

* Select one member of the group who will host the canonical repository for the project
* Create a new, blank repository on GitHub named `supper_slog`
* Clone the Dinner Dash project that you'll be working with to your local machine
* Go into that project directory and `git remote rm origin`
* Add the new repository as a remote `git remote add origin git://new_repo_url`
* Push the code `git push origin master`
* In GitHub, add the other team members as collaborators
* The other team members can then fork the new repo

### Tagging the Start Point

We want to be able to easily compare the change between the start of the project and the end. For that purpose, create a tag in the repo and push it to GitHub:

{% terminal %}
$ git tag -a supper_slog_start_point
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
considering for the platform. __Your team needs to complete at least 2 of these.__

#### 1. Where's My Order / Magic 8-ball

You can't place a pickup order and expect it ready immediately. Predict the pickup time when an order is submitted:

* Each item in the store has a preparation time, defaulting to 12 minutes. Items can be edited to take longer.
* If an order has more than six items, add 10 minutes for every additional six items.
* Each already "paid" order in the system which is not "complete" delays the production start of this new order by 4 minutes.
* This information should be displayed to a user on their order page

#### 2. Deals! Deals! Deals!

Store owners may put items or entire categories of items on sale. They can:

* Create a "sale" and connect it with individual items or entire categories
* Sales are created as a percentage off the normal price
* View a list of all active sales
* End a sale

On the order "dashboard" they can:

* View details of an individual order, including:
  * If purchased on sale, original price, sale percentage and adjusted price
  * Subtotal for the order
  * Discount for the order
  * Total for the order reflecting any discounts from applicable sales

As a browsing User:

* Sale prices are displayed in item listings alongside normal price and percentage savings

#### 3. What's Good Here?

On any item I can, as an Unauthenticated User:

* See the posted reviews including:
  * title, body, and a star rating 0-5
  * the display name of the reviewer
* See an average of the ratings broken down to half-stars

On items I've purchased, as an Authenticated User I can:

* Add a rating including:
  * Star rating 0-5
  * Title
  * Body text

#### 4. The Machine Knows What You Like

Implement simple recommendations including:

* The ability to easily see your last order and add the same items to the current order
* When browsing an item, recommend 3 other items from that store that were ordered by customers who also ordered the item I'm viewing
* If 3 other items can't be found, pull the most popular overall items from that store

#### 5. Where Is It?

Implement full-text search for both the consumer and administrator:

__Consumer__

* Search for items in the whole site
* Search through "My Orders" for matches in the item name or description

__Store Owner__

Search orders using a builder-style interface (like Google's "Advanced Search") allowing them to specify any of these:

* Status (drop-down)
* Order total (drop-down for `>`, `<`, `=` and a text field for dollar-with-cents)
* Order date  (drop-down for `>`, `<`, `=` and a text field for a date)
* Email address of purchaser

#### 6. Transaction Processor

Implement a "checkout" procedure using Stripe, Paypal or another service to handle credit card transactions in a "sandboxed" developer environment.

You may need to add an additional "pending" order status to relect orders that are placed but not yet paid.

When the card is processed, update the order to "paid" and send a confirmation email to the user. Emails should _only_ be sent when the appis in `production` mode. Don't spam people while you're getting it working.

#### 7. Phone Updates

As a customer, give me the option to add a contact number to my account.
Whenever one of my orders changes its status, send me a text including information about the order and
its current status.

Additionally, include in the texts a contact number for the restaurant. If I text this number
and include the ID for an order, I should receive info about that order including current status,
items ordered, etc.

Make sure, however, that I can only receive updates about my own orders.

#### 8. Theming / Custom CSS per Restaurant

Provide a mechanism for store owners to customize the display of their site by:

1. selecting from a few pre-built themes
2. provde their own CSS that will be added to the page

For the included themes, focus on the basics like font style and color scheme.

## Evaluation Rubric

The following criteria will be used for each evaluation:

### Feature Delivery

You'll be graded on each of the criteria below with a score of (1) well below
expectations, (2) below expectations, (3) as expected, (4) better than expected.

* Completion: Did you complete all base features as well as 2 supporting features?
* Organization: did you use your project management tool to keep the project organized?

### Technical Quality

* Test-Driven Development: (1) disregard for testing, (2) gaps in test
usage/coverage/design, (3) adequate testing, (4) exceptional use of testing
* Code Quality: (1) poor factoring and understanding of MVC, (2) some gaps in
code quality / application of MVC, (3) solid code quality and pushing logic down
the stack, (4) exceptionally well factored code
* User Experience: (1) inattention to the user experience, (2) some gaps in the
UX, (3) UX is clear and makes it easy to navigate around the site (4) UX is especially polished and intuitive
