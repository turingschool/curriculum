---
layout: page
title: StoreEngine
---

In this project you'll use Ruby on Rails to build an online commerce platform.

<div class="note">
<p>Consider the requirements fluid until 11:59PM, Monday, April 9th.</p>
</div>

### Learning Goals

* Use TDD to drive all layers of Rails development including unit, integration, and user acceptance tests
* Practice mixing HTML, CSS, and Rails templates to create an inviting and usable User Interface
* Differentiate responsibilities between components of the Rails stack

### Understandings

Please consider the requirements below non-exhaustive guidelines for building a great store. If you know something should be done but it isn't listed below, do it.

### Restrictions

Project implementation may *not* use:

* Devise for Authentication

### Base Expectations

You are to build an online store which offers both administrator and public shopper interfaces.

#### Administrators

As an authenticated Administrator, I can:

* Create product listings including a title, description, price, and a photo
* Modify existing products title, description, price, and photo
* Create named categories for products
* Assign products to categories or remove them from categories
* Retire a product from being sold, which hides it from browsing by any non-administrator

As an Administrator, I can also view an order "dashboard" where I can:

* See a listing of all orders with:
  * the total number of orders by status
  * links for each individual order
  * filter orders to display by status type (for statuses "pending", "cancelled", "paid", "shipped", "returned")
  * link to transition to a different status:
    * link to "cancel" orders which are currently "pending"
    * link to "mark as returned" orders which are currently "shipped"
    * link to "mark as shipped" orders which are currently "paid"
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
  * Links to transition to other statuses as explained above

#### Shoppers

As a Public User, I can:

* Browse all products
* Browse products by category
* Add a product to my cart
* View my cart
* Remove a product from my cart
* Increase the quantity of a product in my cart
* Checkout by entering my billing information, shipping address, and email address
* View the status of my order:
  * Accessible at a special, unique URL
  * Displays the current status, total, date placed, products with quantity purchased and line-item totals
  * If shipped or cancelled, display a timestamp when that action took place

### Security and Usability

#### Unauthenticated Users

Allowed To:

* browse items or categories
* add items to a cart
* log in which should _not_ clear the cart

NOT Allowed To:

* view another public users's shopping cart
* checkout (until they log in)
* view the administrator screens or use administrator functionality
* make themselves an administrator

#### Authenticated Non-Administrators

Allowed To:

* do everything Unauthenticated Users can do except "log in"
* log out
* view their past orders
  * view any product on the order
  * if any product is retired:
    * that should be included in the display
    * they cannot add it to a new cart

NOT Allowed To:

* view another users's shopping cart
* view the administrator screens or use administrator functionality
* make themselves an administrator

#### Administrators

Allowed To:

* todo: move down from section above?

NOT Allowed To:

* todo

### Data Validity

There are several types of entities in the system, each with requirements about what makes for a valid record. These restrictions are summarized below:

#### Product

* A product must have a title, description, and price.
* The title and description cannot be empty strings.
* The title must be unique for all products in the system
* The price must be a valid decimal numeric value and greater than zero
* The photo is optional. If present it must be a valid URL format.

#### User

* A user must have a valid email address that is unique to all users
* A user must have a full name that is not blank
* A user may optionally provide a display name that must be no less than 2 characters long and no more than 32

#### Order

* An order must belong to a user
* An order must be for one or more of one or more products currently being sold

### Example Data

In order to run automated acceptance tests against your project, please make the following users available via the db:seed task:

* Normal user with full name "Matt Yoho", email address "matt.yoho@livingsocial.com", password of "hungry" and no display name
* Normal user with full name "Jeff", email address "jeff.casimir@livingsocial.com", password of "hungry" and display name "j3"
* User with admin priviliges with full name "Chad Fowler", email address "chad.fowler@livingsocial.com", password of "hungry", and display name "SaxPlayer"

Also, in order to support easily batch importing a lot of product data, provide a Rake task called `import_stock` that accepts a path to a CSV file filled with product data. The data will be of the following format:

```
title,description,price,photo_url
Bike Pump,Put air in your tires,5.29,http://photos.domain.com/pics/sdf234.jpg
Racing Saddle,Peddle all you want without brusing your tailbone,25.99,http://photos.domain.com/pics/shf2t55.jpg
Emergency Tube,Recover from a blow out with this quick-inflate tube,12.99,http://photos.domain.com/pics/fd789gs.jpg
```

The data file will be provided by Thursday, 4/5.

### Extensions

#### Put Items on Sale

Administrators may put products or entire categories of products on sale. They can:

* Create a "sale" and connect it with individual products or entire categories
* Sales are created as a percentage off the normal price
* View a list of all active sales
* End a sale

On the order "dashboard" they can:

* View details of an individual order, including:
  * If purchased on sale, sale percentage and adjusted price
  * Total for the order, including any discount from applicable sales

As a Public User:

* Sale prices are displayed in product listings alongside normal price and percentage savings

#### Product Reviews

On any product I can, as a Public User:

* See the posted reviews including:
    * title, body, and a star rating 0-5
    * the display name of the reviewer
* See an average of the ratings broken down to half-stars

On products I've purchased I can:

* Add a rating including:
  * Star rating 0-5
  * Title
  * Body text
* Edit a review I've previously submitted until 15 minutes after I first submitted it

#### Search

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

#### Transaction Processor

Implement a "checkout" procedure using Stripe, Paypal or another service to handle credit card transactions in a "sandboxed" developer environment.

When the card is processed, update the order to "paid" and send a confirmation email to the user. Emails should _only_ be sent when the app is in `production` mode. Don't spam people while you're getting it working.

### Evaluation Criteria

This project will be peer assessed using automated tests and the rubric below. Automated tests will be available by 8AM, Tuesday, April 10th.

1. Correctness
  * 4: All provided tests pass without an error or crash
  * 3: One test failed or crashed
  * 2: Two or three tests failed or crashed
  * 1: More than three tests failed or crashed
  * 0: Program will not run
2. Testing
  * 4: Testing suite covers >99.0% of application code
  * 3: Testing suite covers 95-99% of application code
  * 2: Testing suite covers 85-94% of application code
  * 1: Testing suite covers 70-84% of application code
  * 0: Testing suite covers <70% of application code
3. Style
  * 4: Source code consistently uses strong code style with no complaints from Cane or Reek.
  * 3: Source code generates warnings about whitespace/comments, but no violations of line-length or method statement count
  * 2: Source code generates three or fewer warnings about line-length or method statement count
  * 1: Source code generates four to ten warnings about line-length or method statement count
  * 0: Source code is unacceptable, containing more than ten line-length or method statement count warnings
4. Effort
  * 5: Program fulfills all Base Expectations and four Extensions
  * 4: Program fulfills all Base Expectations and two Extensions
  * 3: Program fulfills all Base Expectations
  * 2: Program fulfills Base Expectations except for one or two features.
  * 1: Program fulfills many Base Expectations, but more than two features.
  * 0: Program does not fulfill any of the Base Expectations
