---
layout: page
title: StoreEngine
---

In this project you'll use Ruby on Rails to build an online commerce platform.

<div class="note">
<p>This project is open source. If you notice errors, typos, or have questions/suggestions, please <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/projects/store_engine.markdown">submit them to the project on Github</a>.</p>
</div>

## Introduction

### Learning Goals

* Use TDD to drive all layers of Rails development including unit, integration, and user acceptance tests
* Practice mixing HTML, CSS, and Rails templates to create an inviting and usable User Interface
* Differentiate responsibilities between components of the Rails stack

### Understandings

Please consider the requirements below non-exhaustive guidelines for building a great store. If you know something should be done but it isn't listed below, do it.

### Restrictions

Project implementation may **not** use:

* Devise for Authentication

### Getting Started

1. One team member forks the repository at https://github.com/JumpstartLab/store_engine
2. Add the other team members as a collaborator

## Base Expectations

You are to build an online store which offers both administrator and consumer interfaces.

### Unauthenticated Users

As an unauthenticated user, I can:

* Browse all products
* Browse products by category
* Add a product to my cart
* View my cart
* Remove a product from my cart
* Increase the quantity of a product in my cart
* Log in, which should _not_ clear the cart

Unauthenticated users are *NOT* allowed to:

* View another user's private data (such as current shopping cart, etc.)
* Checkout (until they log in)
* View the administrator screens or use administrator functionality
* Make themselves an administrator

### Authenticated Non-Administrators

Allowed To:

* do everything Unauthenticated Users can do except "log in"
* log out
* view their past orders with links to display each order
* on that order display page there are:
  * products with quantity ordered and line-item subtotals
  * links to each product page
  * the current status
  * order total price
  * date/time order was submitted
  * if shipped or cancelled, display a timestamp when that action took place
  * if any product is retired:
     * they can still access the product page
     * they cannot add it to a new cart
* Place a "Two-Click" order from any active product page. The first click asks "Place an order for 'X'?" and if you then click "OK", the order is completed. Handle this in JavaScript or plain HTML at your discretion.

*NOT* allowed to:

* view another user's private data (such as current shopping cart, etc.)
* view the administrator screens or use administrator functionality
* make themselves an administrator

### Administrators

As an authenticated Administrator, I can:

* Create product listings including a title, description, price, and a photo
* Modify existing products title, description, price, and photo
* Create named categories for products
* Assign products to categories or remove them from categories. Products can belong to more than one category.
* Retire a product from being sold, which hides it from browsing by any non-administrator

As an Administrator, I can also view an order "dashboard" where I can:

* See a listing of all orders with:
  * the total number of orders by status
  * links for each individual order
  * filter orders to display by status type (for statuses "pending", "cancelled", "paid", "shipped", "returned")
  * link to transition to a different status:
    * link to "cancel" individual orders which are currently "pending"
    * link to "mark as returned" individual orders which are currently "shipped"
    * link to "mark as shipped" individual orders which are currently "paid"
* Access details of an individual order, including:
  * Order date and time
  * Purchaser full name and email address
  * For each product on the order
    * Name with link to product page
    * Quantity
    * Price
    * Line item subtotal
  * Total for the order
  * Status of the order
* Update an individual order
  * View and edit orders; may change quantity or remove products from orders with the status of pending or paid
  * Change the status of an order according to the rules as outlined above

*NOT* allowed to:

* Modify any personal data aside from their own

## Data Validity

There are several types of entities in the system, each with requirements about what makes for a valid record. These restrictions are summarized below.

Any attempt to create/modify a record with invalid attributes should return the user to the input form with a validation error indicating the problem along with suggestions how to fix it.

### Product

* A product must have a title, description, and price.
* The title and description cannot be empty strings.
* The title must be unique for all products in the system
* The price must be a valid decimal numeric value and greater than zero
* The photo is optional. If present it must be a valid URL format.

### User

* A user must have a valid email address that is unique across all users
* A user must have a full name that is not blank
* A user may optionally provide a display name that must be no less than 2 characters long and no more than 32

### Order

* An order must belong to a user
* An order must be for one or more of one or more products currently being sold

## Example Data

To support the evaluation process, please make the following available via the `rake db:seed` task in your production deployment:

* Products
  * At least 20 products of varying prices
  * Some of the products should be attached to multiple categories
* Categories
  * At least 5 categories with a varying number of member products
* Orders
  * At least 10 sample orders, with at least two at each stage of fulfillment (`pending`, `shipped`, etc)
* Users
  * Normal user with full name "Franklin Webber", email address "demoXX+franklin@jumpstartlab.com", password of "password" and no display name
  * Normal user with full name "Jeff", email address "demoXX+jeff@jumpstartlab.com", password of "password" and display name "j3"
  * User with admin priviliges with full name "Steve Klabnik", email address "demoXX+steve@jumpstartlab.com", password of "password", and display name "SkrilleX"

## Submission Guidelines

Your project must be "live" on the web for your peers to evaluate it. Setup your own VPS, use Heroku, whatever you have to do to make it work.

Your `README` file on Github should contain a link to your live site.

Conversely, on the live site, setup the URL http://yourwebsite.com/code to redirect the user to the Github repository.

## Extensions

### Put Items on Sale

Administrators may put products or entire categories of products on sale. They can:

* Create a "sale" and connect it with individual products or entire categories
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

* Sale prices are displayed in product listings alongside normal price and percentage savings

### Product Reviews

On any product I can, as an Unauthenticated User:

* See the posted reviews including:
  * title, body, and a star rating 0-5
  * the display name of the reviewer
* See an average of the ratings broken down to half-stars

On products I've purchased, as an Authenticated User I can:

* Add a rating including:
  * Star rating 0-5
  * Title
  * Body text
* Edit a review I've previously submitted until 15 minutes after I first submitted it

### Search

Implement search for both the consumer and administrator:

* Consumer
  * Search for products in the whole site
  * Search through "My Orders" for matches in the item name or description
* Administrator
  * Search orders using a builder-style interface (like Google's "Advanced Search") allowing them to specify any of these:
    * Status (drop-down)
    * Order total (drop-down for `>`, `<`, `=` and a text field for dollar-with-cents)
    * Order date  (drop-down for `>`, `<`, `=` and a text field for a date)
    * Email address of purchaser

### Transaction Processor

Implement a "checkout" procedure using Stripe, Paypal or another service to handle credit card transactions in a "sandboxed" developer environment.

When the card is processed, update the order to "paid" and send a confirmation email to the user. Emails should _only_ be sent when the app is in `production` mode. Don't spam people while you're getting it working.

## Evaluation Criteria

This project will be peer assessed using user-driven stories and the rubric below.

1. Correctness
  * 3: All provided stories pass
  * 2: One story could not be completed
  * 1: Two or three stories could not be completed
  * 0: More than three stories could not be completed
2. Testing
  * 3: Testing suite covers >95% of application code
  * 2: Testing suite covers 85-94% of application code
  * 1: Testing suite covers 70-84% of application code
  * 0: Testing suite covers <70% of application code
3. Code Style
  * 3: Source code generates no complaints from Cane or Reek
  * 2: Source code generates three or fewer warnings
  * 1: Source code generates four to eight warnings
  * 0: Source code generates more than eight warnings
4. Effort
  * 4: Program fulfills all Base Expectations and four Extensions
  * 3: Program fulfills all Base Expectations and two Extensions
  * 2: Program fulfills all Base Expectations
  * 1: Program is missing 1-3 features from the Base Expectations
  * 0: Program is missing more than three features from the Base Expectations
5. User Interface & Design
  * 3: WOW! This site is beautiful, functional, and clear
  * 2: Good design and UI that shows work far beyond dropping in a library or Bootstrap
  * 1: Some basic design work, but doesn't show much effort beyond "ready to go" components/frameworks/etc
  * 0: The lack of design makes the site difficult / confusing to use
6. Surprise
  * 2: A great idea that's well executed and enhances the shopping experience
  * 1: An extra feature that makes things a little nicer, but doesn't blow your mind
  * 0: No surprise. Sad face :(

### Evaluation Stories

Pull the stories from the upstream project which you originally forked and look in `/user_stories`. You can edit the `<>` markers to match with the theme/contents of your store.

## Code Style Metrics

### Setup

The application is pre-configured with cane and reek gems along with wrapper rake tasks.

### Running Reek

```ruby
bundle exec rake sanitation:methods
```

### Running Cane

```
bundle exec rake sanitation:lines
```

## Evaluation Protocol

### Round of Fours

In this round you'll break into an equal number of groups of four pairs each.

Follow the following protocol:

* Each pair presents their code/project for 5 or fewer minutes. Make sure to highlight any S&D features or extensions.
* Pairs then evaluate both other projects for 20 minutes each:
  * work through the evaluation stories
  * run the code metrics
  * subjectively measure the UI and S&D categories
  * submit one evaluation per project [eval.jumpstartlab.com](http://eval.jumpstartlab.com) (so your pair submits a total of two evals, one for each project you examine)

When all projects have been evaluated, use the total aggregate score of all sections across the two evaluations to choose *one* project to move on to the next round.

### Final Four &trade;

Each of the champions from the first round will present to the whole group and guests. You have seven minutes to show off:

* The basics
* What makes your project exceptional?
* Anything else you're proud of?

Audience members will then be invited to try out your store for five minutes.

When all four projects have been presented, all members of the audience will then submit a ranking of the four projects to [eval.jumpstartlab.com](http://eval.jumpstartlab.com)

### Surprise Showcase

If you weren't in the final four, here's your chance to *quickly* show the whole group what's exceptional about your project.

### Wrapup / Retrospective

* What was challenging about this project?
* What came easy?
* What would you have done differently?
* Did you reach your goals? Why or why not?
* Any lessons learned for the next project?
