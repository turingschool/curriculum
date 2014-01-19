---
layout: page
title: Fourth Meal
sidebar: true
---

In this project you'll build on an existing implementation of [Dinner Dash]({% page_url projects/dinner_dash %}), turning it from a single restaurant to a platform for multiple restaurants.

### Learning Goals

#### Modeling

* Adapt the existing restaurant models to belong to individual restaurants
* Mind security permissions such that each restaurant does **not** have any knowledge of other restaurants' data
* Push *all* logic down to the model layer so controllers and views remain simple

#### Interface & Views

* Use and switch between multiple view templates to reduce view-layer logic
* Implement a clean, logical order flow that minimizes customer frustration

#### Performance

* Use database indices to improve query performance
* Use an in-memory data store to cache pre-calculated and pre-fetched data
* Use "Russian-Doll Caching" to reduce the render time of view fragments

#### Process

* Practice working with a "legacy" codebase to add substantial functionality
* Use outside-in TDD/BDD to drive all layers of Rails development
* Use a professional project management tool to pace and track progress

### Teams

The project will be completed by teams of three to four developers over the span of eighteen days.

Like all projects, individual team members are expected to:

* Seek out features and responsibilities that are uncomfortable. The time to learn is *now*.
* Support your teammates so that everyone can collaborate and contribute.

### Project Starting Point

You'll build upon an existing code base authored by one of your teammates in the Dinner Dash project. Your first task, then, is to decide which project to use. 

#### Dinner Dash Mini-Demos

Each teammate should give a quick demo of their existing app/code to the rest of the team, focusing on:

* General strengths and weaknesses
* Test coverage and quality
* Architectural concerns
* Components that are particularly strong or weak

#### Beginning Fourth Meal

Once you select a base project:

* Select one member of the group who will host the cannonical repository for the project
* Create a new, blank repository on GitHub named `fourth_meal`
* Clone the Dinner Dash project that you'll be working with to your local machine
* Go into that project directory and `git remote rm origin`
* Add the new repository as a remote `git remote add origin git://new_repo_url`
* Push the code `git push origin master`
* In GitHub, add the other team members as collaborators
* The other team members can then fork the new repo

#### Tagging the Start Point

We want to be able to easily compare the change between the start of the project and the end. For that purpose, create a tag in the repo and push it to GitHub:

{% terminal %}
$ git tag -a dinner_dash_v1
$ git push --tags
{% endterminal %}

### Restrictions &amp; Outside Code

Your project should evolve, refactor, and clean up the code you inherit. This includes deleting redudant, broken, or obsolete code. However, you should not throw out the previous work wholesale.

Furthermore, there should be *no reduction in functionality* except when explicitly called for by new requirements.

## Managing Requirements

### Authoritative Requirements

While this document is a starting place, the Pivotal Tracker project for your team should be considered the **canonical** version of the requirements. 

### Teams & Workflow

Your team should understand and follow our [Project Workflow for Development Teams]({% page_url projects/workflow %}).

Questions or requests for clarification about the requirements should be raised as *comments* in the appropriate Tracker stories.

This means that the requirements for your team will likely drift  apart from others teams over the duration of the project.

### Project Check-In Meetings

Rapid and frequent feedback about the work we produce is a central tenet of agile software development and lean item delivery.

* Day 3 - Iteration Planning
* Day 8 - Show & Tell
* Day 10 - Technical Review
* Day 15 - Fit & Finish

#### Meeting 1 - Iteration Planning

As the project gets rolling, we'll meet with your team to evaluate and give recommendations on:

* Your planned iterations and features
* Strengths/Weaknesses in your chosen codebase
* Strategies for how your team will work together

#### Meeting 2 - Show-And-Tell

This meeting will verify that the work done so far is in line with the item manager's expectations and to sanity check your team's progress toward delivery.

A 'Show and Tell' milestone exists in the starter stories. This milestone is positioned to indicate the features required for completion. Meeting this milestone will affect your project evaluation.

When you reach this milestone please create a tag or branch (named `show_and_tell`) for reference.

The show-and-tell session will take place on day eight after work begins.

#### Meeting 3 - Technical Review

Just beyond the midway point, this check-in focuses on the code. Is your team on track to hit the technical goals?

#### Meeting 4 - Fit & Finish

During this check-in teams are expected to have a nearly completed project and all base stories ready for acceptance. The purpose of this meeting is to find any last rough-edges that can be smoothed out before project submission.

#### Meeting Expectations

Both the show-and-tell and fit & finish meetings are intended to model interactions with a *real customer*. As the stories clearly define the customer's expectations, your application needs to **exactly** follow the stories or the stories will be rejected.

A 95% implementation is wrong. If you want to deviate from the story as it was originally written, you need to discuss that with your customer and get approval to change the story *first*.

## Base Expectations

You are to extend Dinner Dash so that it can handle multiple, simultaneous restaurants. Each has their own name, unique URL, item stock, order queue, and administrators. Each restaurant must maintain the functionality previously required for the Dinner Dash project in addition to the new requirements or enhancements defined here.

At least for the base expectations, all Dinner Dash restaurants share single sign-on.

You are to optimize the application's performance under load in order to accommodate the additional restaurants, traffic, users, and revenue that this platform will generate. To do so, you will implement various caching techniques and introduce background workers into the system.

You will also need to focus on an excellent user experience.

<div class='note'>
<p>The requirements reference an <b>example.com</b>, but your URL will differ.</p>
</div>

## Functional Requirements

Individual restaurants can be accessed by specifying their restaurant name as the path prefix.

* Given a restaurant named _Billy's BBQ_
* When I visit `http://example.com/billys-bbq`
* Then I expect to see all items defined for _Billy's BBQ_
* And I expect to see branding defined for _Billy's BBQ_
* When I visit `http://example.com/billys-bbq/categories`
* Then I expect to see all categories defined for _Billy's BBQ_

### Public Visitor

As a public, unauthenticated visitor to a restaurant I can:

* Maintain a **separate** shopping cart for each restaurant I browse
* Purchase items in a shopping cart when I provide my email, billing address, shipping address, and credit card number.
* Create an account
   * When I create an account, then I expect to receive a welcome email
* Login with my account and become an authenticated shopper

#### First-time User Experience

* I may proceed through the process of adding an item to my cart and checking out
* I may then create an account or simply enter my email, billing, shipping, and credit card info
* If I create an account, I will **immediately** resume the checkout process
* If I do not create an account
    * My order confirmation email will include a unique, obscure link to view my order details
    * The unique link will be displayed on the confirmation page for the order

<div class='note'>
<p>Your inherited Dinner Dash program may not implement unauthenticated checkout. You'll need to add support for that to complete these requirements.</p>
</div>

### Authenticated Restaurant Shopper

As an authenticated shopper I can:

* Maintain a **separate** shopping cart for each restaurant I browse
* Make purchases on any restaurant I am browsing
  * Recieve an email confirmation of my order with basic order details and a link to the order detail page
* Manage my account information shared by all restaurants centrally on my account page
  * Shipping addresses
  * Billing addresses
  * Credit cards associated with my account
  * Basic account info like name and password, as managed previously in Dinner Dash v1
* View and manage my purchase history across all restaurants
* Create a new restaurant, pending admin approval, via my account page
  * Specify basic restaurant info: name, URL identifier, and description
  * Automatically become restaurant admin

### Authenticated Restaurant Stocker

As an authenticated restaurant stocker, I can:

* Add items, edit items, and retire items in my restaurant only

### Authenticated Restaurant Administrator

As an authenticated restaurant admin, by using a dedicated admin area, I can:

* Do everything a stocker for my restaurant can do
* Update the details of my restaurant such as the: name, URL identifier, and description
* Add or remove restaurant stocker accounts
    * Adding a stocker account automatically emails the account holder with a link to confirm their account and status
* Add or remove other admins for the restaurant
    * There can never be fewer than 1 admin for a restaurant
* Perform the admin actions available to administrators in the current Dinner Dash version

### Authenticated Platform Administrator

As an authenticated Platform Administrator, I can:

* Approve or decline the creation of new restaurants
* Take a restaurant "offline" temporarily so that attempting to browse it redirects its root and displays a maintenance message
    * Bring an offline restaurant back online
* Override/assist restaurant admins in any functionality available to them via the admin portion of their restaurant pages

### Validation and Error Messages

Any form in the application must:

* validate the submitted data appropriately
* reject invalid input
* display clear and helpful errors and corrective instructions
* allow the user to quickly fix and resubmit

## Non-Functional Requirements

The non-functional requirements are based around maintaining or improving site performance as data and users scale up. The primary metric for this is in keeping response time &mdash; the elapsed time between a browser making a web request and when a "usable" page has been loaded &mdash; below some threshold.

200ms is a reasonable ceiling for your request times. It's also important to consider consistency of response times. Maintaining sub-100ms times for 9 requests but allowing the 10th to take a full second is an unacceptable user experience.

Implement two common methods for reducing response times: caching and background workers.

### Caching

Response time and caching are critically important. Your improved Dinner Dash should make significant use of:

* data caching
* fragment caching (aka Russian-Doll caching)
* query consolidation
* database optimizations (query count, using indicies, join)

Use the built-in Rails functionality along with Redis and/or Postgres to implement these strategies.

### Background Workers

Use background workers for any job that doesn't **have to** be completed before the response is sent to the user (ex: sending email, updating statistics, etc).

Use Resque or a similar library to support this functionality.

## Base Data

Before final delivery, and ideally before customer check-ins, you should have the following data pre-loaded in your marketplace:

* At least 10,000 total restaurants broken up into...
* At least 30 different regions (ex: [US cities](http://en.wikipedia.org/wiki/List_of_United_States_cities_by_population) )
* At least 20 items per restaurant
* At least 3 item categories per restaurant and at least 30 categories total
* 100,000 known users
* 2 restaurant admins per restaurant
* 2 stockers per restaurant
* 2 platform administrators

It creates a much stronger impression of your site if the data is plausible. We recommend creating a few "template" restaurants that have real dishes, then replicating those many times. It's better to have "Taste of India 26" and "Taste of India 27" than "Lorem Ipsum" and "Tellus Domit".

## Extensions

In this project you as developers are expected to take a more active role in shaping the project. Although there are a few potential extensions proposed at the outset, you are encouraged to propose additional extensions, in the form of new features and user stories describing them, to your project manager.

If you have an idea for a killer feature for your application, pitch it to your stakeholders for refinement. If they are convinced of its value, they'll work with your team to create one or more user stories in Pivotal Tracker and prioritize those stories in the context of the rest of the requirements. You may be able to convince them to prioritize your feature ahead of current base requirements if it is sufficiently compelling or necessary.

Here are some possible extensions:

### Custom CSS per restaurant

Provide a mechanism so that restaurant administrators may provide custom a CSS sheet to change the appearance of their restaurant. This custom styling should not affect any other restaurant's appearance.

Have four pre-built themes they can select from and the ability to upload their own.

### Use Sub-Domains To Distinguish Restaurants

In order to give greater precedence and more SEO-juice to each individual restaurant, as well as pave the way for restaurants to use custom domains, change your application so that, instead of using a path prefix per request to identify individual restaurants in the system, use unique sub-domains instead.

So instead of `http://www.example.com/billys-bbq/items` pointing to the items belonging to the restaurant _Billy's BBQ_, allow `http://billys-bbq.example.com/items` to be used instead.

### Separate Per-Restaurant Sign In

So that each restaurant can optionally create the impression of being independent by cordoning off their user experience, it should be possible for a restaurant to require a unique sign on and account management that is not shared across restaurants.

Shipping, billing, credit card info, and order history must be uniquely managed through this restaurant's management interface alone. Email address are thus not unique across multiple restaurants on the platform, but must be unique within a given restaurant.

## Evaluation Criteria

The evaluation of the project is broken into three areas:

1. Evaluation of the user stories for each feature of the application
2. Code critique and review by instructors
3. Non-functional requirements and metrics

### Evaluation of User Stories for Base and Extensions

Each user story for the base expectations will be worth the point value they have been assigned in Pivotal Tracker. Points for a story will be awarded if that story can be exercised without crash or error.

Extension stories will also be worth their story point value in Tracker, but no story's points will count toward the total score unless all other stories of higher priority have been delivered. Therefore you must have delivered the complete base expecations to receive credit for any extensions.

### Code Critique by Instructors

Reviewers will compare the state of the code before the project began and the state of the code at the end, looking for improvement and evolution.

The high-level outline for the evaluation is:

1. Good object-oriented and general application design practices, such as SOLID and DRY.
2. Use of Ruby and Rails idioms and features.
3. Good testing practices and coverage.
4. Improvement and evolution of the code, use of refactoring.
5. Adherence to the intent of project-specific non-functional requirements, such as background workers and caching.
6. Application correctness and robustness.
7. Security protections against common attacks.

### Non-Functional Metrics

Here are the criteria for the non-functional requirements.

1. Performance Under Load
2. User Interface & Design
3. Test Coverage
4. Code Style
5. Show And Tell Milestone
