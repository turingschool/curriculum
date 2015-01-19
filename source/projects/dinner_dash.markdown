---
layout: page
title: Dinner Dash
sidebar: true
---

In this project you'll use Ruby on Rails to build an online commerce platform for a restaurant to facilitate online ordering.

## Introduction

### Learning Goals

* Use TDD to drive all layers of Rails development including unit, integration, and user acceptance tests
* Design a system of models which use one-to-one, one-to-many, and many-to-many relationships
* Practice mixing HTML, CSS, and Rails templates to create an inviting and usable User Interface
* Differentiate responsibilities between components of the Rails stack
* Build a logical user-flow that moves across multiple controllers and models

### Understandings

Please consider the requirements below *non-exhaustive* guidelines for building a great customer experience. If you know something should be done but it isn't listed below, do it.

### Restrictions

Project implementation may **not** use:

* Any external library for authentication except `bcrypt`
* A pre-existing, externally created CSS/HTML design/template

### Getting Started

1. One team member creates a repository named "dinner_dash"
2. Add the other team members as collaborators
3. Add your project to Waffle.io 
4. Configure [Hound](https://houndci.com/) for style guide violations
5. Configure [Skylight](http://docs.skylight.io/getting-started/) to monitor your app's performance
6. Create issues for user stories
7. Work on branches and use pull requests to review and merge code

## Base Expectations

You are to build an online ordering system for a restaurant which offers the complete
functionality for restaurant customers to order food and restaurant administrators
to process and complete those orders.

### Unauthenticated Users

As an unauthenticated user, I can:

* Browse all items
* Browse items by category
* Add an item to my cart
* View my cart
* Remove an item from my cart
* Increase the quantity of a item in my cart
* Log in, which does _not_ clear the cart

Unauthenticated users are *NOT* allowed to:

* View another user's private data (such as current order, etc.)
* Checkout (until they log in)
* View the administrator screens or use administrator functionality
* Make themselves an administrator

### Authenticated Users (Non-Administrators)

Allowed To:

* do everything Unauthenticated Users can do except "log in"
* log out
* view their past orders with links to display each order
* on that order display page there are:
  * items with quantity ordered and line-item subtotals
  * links to each item description page
  * the current status of the order
  * order total price
  * date/time order was submitted
  * if completed or cancelled, display a timestamp when that action took place
  * if any item is retired from the menu:
     * they can still access the item page
     * they cannot add it to a new cart

*NOT* allowed to:

* view another user's private data (such as current order, etc.)
* view the administrator screens or use administrator functionality
* make themselves an administrator

### Administrators

As an authenticated Administrator, I can:

* Create item listings including a name, description, price, and upload a photo
* Modify existing items' name, description, price, and photo
* Create named categories for items (eg: "Small Plates")
* Assign items to categories or remove them from categories. Products can belong to more than one category.
* Retire a item from being sold, which hides it from browsing by any non-administrator

As an Administrator, I can also view an order "dashboard" where I can:

* See a listing of all orders with:
  * the total number of orders by status
  * links for each individual order
  * filter orders to display by status type (for statuses "ordered", "paid", "cancelled", "completed")
  * link to transition to a different status:
      * link to "cancel" individual orders which are currently "ordered" or "paid"
      * link to "mark as paid" orders which are "ordered"
      * link to "mark as completed" individual orders which are currently "paid"
* Access details of an individual order, including:
  * Order date and time
  * Purchaser full name and email address
  * For each item on the order:
      * Name linked to the item page
      * Quantity
      * Price
      * Line item subtotal
  * Total for the order
  * Status of the order

*NOT* allowed to:

* Modify any personal data aside from their own

## Data Validity

There are several types of entities in the system, each with certain required data. Any attempt to create or modify a record with invalid attributes should return the user to the input form with a validation error indicating the problem along with suggestions how to fix it.

### Item

* An item must have a title, description, and price.
* An item must belong to at least one category.
* The title and description cannot be empty strings.
* The title must be unique for all items in the system.
* The price must be a valid decimal numeric value and greater than zero.
* The photo is optional. If not present, a stand-in photo is used.

### User

* A user must have a plausibly valid email address that is unique across all users
* A user must have a full name that is not blank
* A user may optionally provide a display name that must be no less than 2 characters long and no more than 32

### Order

* An order must belong to a user
* An order must be for one or more items currently being sold

## Example Data

To support the evaluation process, please make the following available via the `rake db:seed` task in your application:

* Items
  * At least 20 items of varying prices
  * Some of the items should be attached to multiple categories
* Categories
  * At least 5 categories with a varying number of member items
* Orders
  * At least 10 sample orders, with at least two at each stage of fulfillment (`ordered`, `completed`, `cancelled`)
* Users
  * Normal user with full name "Rachel Warbelow", email address "demo+rachel@jumpstartlab.com", password of "password" and no display name
  * Normal user with full name "Jeff Casimir", email address "demo+jeff@jumpstartlab.com", password of "password" and display name "j3"
  * Normal user with full name "Jorge Tellez", email address "demo+jorge@jumpstartlab.com", password of "password" and display name "novohispano"
  * User with admin priviliges with full name "Josh Cheek", email address "demo+josh@jumpstartlab.com", password of "password", and display name "josh"

## Submission Guidelines

* Your project must be live on Heroku for your evaluation 
* Your `README` file on GitHub should contain a link to your live site

## Extensions

### Is My Order Ready?

#### Magic 8-ball

You can't place a pickup order and expect it ready immediately. Predict the pickup time when an order is submitted:

* Each item in the store has a preparation time, defaulting to 12 minutes. Items can be edited to take longer.
* If an order has more than six items, add 10 minutes for every additional six items.
* Each already "paid" order in the system which is not "complete" delays the production start of this new order by 4 minutes.

### SAVINGS! SAVINGS! SAVINGS!

Administrators may put items or entire categories of items on sale. They can:

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

As an Unauthenticated User:

* Sale prices are displayed in item listings alongside normal price and percentage savings

### What's Good Here?

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
* Edit a review I've previously submitted until 15 minutes after I first submitted it

### The Machine Knows What You Like

Implement simple recommendations including:

* The ability to easily see your last order and add the same items to the current order
* After an item is added to and order, recommend three items other customers have ordered with this item. If there aren't three other things that've been ordered, fill in with the most popular overall items
* Combinations of several items (ex: an appetizer, main dish, and dessert) with a small discount over ordering them individually

### Where Is It?

Implement full-text search for both the consumer and administrator:

#### Consumer

* Search for items in the whole site
* Search through "My Orders" for matches in the item name or description

#### Administrator

Search orders using a builder-style interface (like Google's "Advanced Search") allowing them to specify any of these:

* Status (drop-down)
* Order total (drop-down for `>`, `<`, `=` and a text field for dollar-with-cents)
* Order date  (drop-down for `>`, `<`, `=` and a text field for a date)
* Email address of purchaser

### Transaction Processor

Implement a "checkout" procedure using Stripe, Paypal or another service to handle credit card transactions in a "sandboxed" developer environment.

When the card is processed, update the order to "paid" and send a confirmation email to the user. Emails should _only_ be sent when the app is in `production` mode. Don't spam people while you're getting it working.

### Phone Confirmation

As a restaurant I have a registered contact phone number. When an order is placed online the system calls me with an interaction like this:

* "Hi, this is DinnerDash calling with an online order. Press 1 to accept, 3 to reject". They press "1"
* "The customer name is John Schmoe."
* "The customer will pickup the order at 5:45PM"
* "The order includes: shrimp wontons, chicken pad thai large, and green tea ice cream small. There are a total of 3 items."
* "Press 1 to confirm the order, 2 to repeat, or 3 to cancel."
* The result of the call updates the order in the database and sends an email to the customer.

## Evaluation Process

For the evaluation we'll work through the expectations above and look at the
following criteria:

### 1. Feature Completeness

* 4: All features are correctly implemented along with two extensions
* 3: All features defined in the assignment are correctly implemented
* 2: There are one or two features missing or incorrectly implemented
* 1: There are bugs/crashes in the features present

### 2. Views

* 4: Views show logical refactoring into layout(s), partials and helpers, with no logic present
* 3: Views make use of layout(s), partials and helpers, but some logic leaks through
* 2: Views don't make use of partials or show weak understanding of `render`
* 1: Views are poorly organized

### 3. Controllers

* 4: Controllers show significant effort to push logic down the stack
* 3: Controllers are generally well organized with three or fewer particularly ugly parts
* 2: There are four to seven ugly controller methods that should have been refactored
* 1: There are more than seven unsatisfactory controller methods

### 4. Models

* 4: Models show excellent organization, refactoring, and appropriate use of Rails features
* 3: Models show an effort to push logic down the stack, but need more internal refactoring
* 2: Models are somewhat messy and/or make poor use of Rails features
* 1: Models show weak use of Ruby and weak structure

### 5. Testing

* 4: Project has a running test suite that exercises the application at multiple levels
* 3: Project has a running test suite that tests and multiple levels but fails to cover some features
* 2: Project has sporadic use of tests and multiple levels
* 1: Project did not really attempt to use TDD

### 6. Usability

* 4: Project is highly usable and ready to deploy to customers
* 3: Project is highly usable, but needs more polish before it'd be customer-ready
* 2: Project needs significantly more attention to the User Experience, but works
* 1: Project is difficult or unpleasant to use

### 7. Workflow

* 4: Excellent use of branches, pull requests, and a project management tool.
* 3: Good use of branches, pull requests, and a project-management tool. 
* 2: Sporadic use of branches, pull requests, and/or project-management tool. 
* 1: Little use of branches, pull requests, and/or a project-management tool.
