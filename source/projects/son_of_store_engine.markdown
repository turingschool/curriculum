---
layout: page
title: SonOfStoreEngine
sidebar: true
---

In this project you'll build on an existing implementation of [StoreEngine]({% page_url projects/store_engine %}), turning it from a single store to a platform for many stores.

<div class="note">
<p>This project is open source. If you notice errors, typos, or have questions/suggestions, please <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/projects/son_of_store_engine.markdown">submit them to the project on Github</a>.</p>
</div>

### Goals

#### Architecture & Technique

* Practice techniques for scalable application architecture including caching, pre-rendering, database optimization, and background workers.
* Build a user interface and experience that is clean, efficient, and attractive.
* Build a platform that allows multiple, concurrent storefronts with discreet records, users, and permissions.

#### Process & Skill

* Coordinate as a team to produce quality code and product.
* Practice working with a "legacy" codebase to add substantial functionality.
* Use outside-in TDD/BDD to drive all layers of Rails development.

### Teams

The project will be completed by teams of three to four developers over the span of ten days. 

Like all projects, individuals team members are expected to:

* Seek out features and responsibilities that are uncomfortable. The time to learn is now.
* Support your teammates so that everyone can collaborate and contribute.

### Project Starting Point

You'll build upon an existing code base. Your first task, then, is to decide which one to use.

#### StoreEngine Mini-Demos

Each teammate should give a quick demo of their existing code to the rest of the team, focusing on:

* General strengths and weaknesses
* Test coverage and quality
* Architectural concerns
* Components that are particularly strong or weak

#### Beginning SonOfStoreEngine

Once you select a base project:

* Select one member of the group who will host the cannonical repository for the project
* Create a new, blank repository on Github named "son_of_store_engine"
* Clone the StoreEngine project that you'll be working with to their local machine
* Go into that project directory and `git remote rm origin`
* Add the new repository as a remote `git remote add origin git://new_repo_url`
* Push the code `git push origin master`
* In Github, add the other team members as collaborators
* The other team members can then fork the new repo

#### Tagging the Start Point

We want to be able to easily compare the change between the start of the project and the end. For that purpose, create a tag in the repo and push it to Github:

{% terminal %}
$ git tag -a store_engine_v1
$ git push --tags
{% endterminal %}

### Restrictions &amp; Outside Code

Your project should evolve, refactor, and clean up the code you inherit. This includes deleting redudant, broken, or obsolete code. However, you should not throw out the previous work wholesale. 

Furthermore, there should be *no reduction in functionality* except when explicitly called for by new requirements.

## Managing Requirements

### Authoritative Requirements

While this document is a starting place, the Pivotal Tracker project for your team should be considered the **canonical** version of the requirements. Questions or requests for clarification about the requirements should be raised as comments in the appropriate Tracker stories. More about Tracker workflow is covered at the end of this document.

This does mean that the requirements for your team may drift slightly from others' over the duration of the project. Keep this in mind. If we encounter recurring questions or ambiguity around a particular requirement, or find legitimate error with one, we will make all teams aware of the clarifications or changes.

### Teams & Workflow

Your team should understand and follow our [Project Workflow for Development Teams]({% page_url projects/workflow %}).

#### Setting Up Tracker

* Create a new Tracker project and invite all team members
* Download [this set of starter stories]({% page_url projects/son_of_store_engine/sonofstoreengine_initial_requirements.csv %})
* Upload the stories into the tracker project (look under the *Project* menu)

### Project Check-Ins

Rapid and frequent feedback about the work we produce is a central tenet of agile software development and lean product delivery. 

#### Show-And-Tell

This meeting will verify that the work done so far is in line with the product manager's expectations and to sanity check your team's progress toward delivery.

A 'Show and Tell' milestone exists in the starter stories. This milestone is positioned to indicate the features required for completion. Meeting this milestone will affect your project evaluation.

When you reach this milestone please create a tag or branch (named `show_and_tell`) for reference.

The show-and-tell session will take place two days after work begins.

#### Pre-flight

A second check-in, the pre-flight, will take place five days later (two days before the deadline). During this check-in teams are expected to have a nearly completed product and most or all base stories ready for acceptance.

#### Meeting Expectations

Both the show-and-tell and pre-flight meetings are intended to model interactions with a real customer. As the stories clearly define the customer's expectations, your application needs to **exactly** follow the stories or the stories will be rejected. 

A 95% implementation is wrong and will be rejected. If you want to deviate from the story as it was originally written, you need to discuss that with your customer and get approval to change the story.

## Base Expectations

You are to extend StoreEngine so that it can handle multiple, simultaneous stores, each with their own name, unique URL, product stock, order queue, and administrators. Each store must maintain the functionality previously required for the StoreEngine project in addition to the new requirements or enhancements defined here.

At least for the base requirements, all StoreEngine stores share single sign-on.

You are to put effort into the application's performance under load, in order to accommodate the additional stores, traffic, users, and revenue that this functionality with generate. To do so, you will implement various caching techniques and introduce background workers into the system.

You will also need to focus on an excellent user experience.

<div class='note'>
<p>The requirements reference an <b>example.com</b>, but your URL will differ.</p>
</div>

## Functional Requirements

Individual stores can be accessed by specifying their store name as the path prefix.

* Given a store named _Slick Bike Shoppe_
* When I visit `http://storeengine.com/slick-bike-shoppe`
* Then I expect to see all products defined for _Slick Bike Shoppe_
* And I expect to see branding defined for _Slick Bike Shoppe_
* When I visit `http://storeengine.com/slick-bike-shoppe/categories`
* Then I expect to see all categories defined for _Slick Bike Shoppe_

### Public Visitor

As a public, unauthenticated visitor to a store I can:

* Maintain a **separate** shopping cart for each store I browse
* Purchase products in a shopping cart when I provide my email, billing address, shipping address, and credit card number.
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
<p>Your inherited StoreEngine program may not implement unauthenticated checkout. You'll need to add support for that to complete these requirements.</p>
</div>

### Authenticated Store Shopper

As an authenticated shopper I can:

* Maintain a **separate** shopping cart for each store I browse
* Make purchases on any store I am browsing
  * Recieve an email confirmation of my order with basic order details and a link to the order detail page
* Manage my account information shared by all stores centrally on my account page
  * Shipping addresses
  * Billing addresses
  * Credit cards associated with my account
  * Basic account info like name and password, as managed previously in StoreEngine v1
* View and manage my purchase history across all stores
* Create a new store, pending admin approval, via my account page
  * Specify basic store info: name, URL identifier, and description
  * Automatically become store admin

### Authenticated Store Stocker

As an authenticated store stocker, I can:

* Add products, edit products, and retire products in my store only

### Authenticated Store Administrator

As an authenticated store admin, by using a dedicated admin area, I can:

* Do everything a stocker for my store can do
* Update the details of my store such as the: name, URL identifier, and description
* Add or remove store stocker accounts
    * Adding a stocker account automatically emails the account holder with a link to confirm their account and status
* Add or remove other admins for the store
    * There can never be fewer than 1 admin for a store
* Perform the admin actions available to administrators in the current StoreEngine version

### Authenticated Platform Administrator

As an authenticated Platform Administrator, I can:

* Approve or decline the creation of new stores
* Take a store "offline" temporarily so that attempting to browse it redirects its root and displays a maintenance message
    * Bring an offline store back online
* Override/assist store admins in any functionality available to them via the admin portion of their store pages

### Validation and Error Messages

Any form in the application must:

* validate the submitted data appropriately
* reject invalid input
* display clear and helpful errors and corrective instructions
* allow the user to quickly fix and resubmit

## Non-Functional Requirements

The non-functional requirements are based around maintaining or improve site performance as data and users scale up. The primary metric for this is in keeping response time&mdash;the elapsed time between a browser making a web request and when a "usable" page has been loaded&mdash; below some threshold. 

200ms is a reasonable ceiling for your request times. It's also important to consider consistency of response times. Maintaining sub-100ms times for 9 requests but allowing the 10th to take a full second is an unacceptable user experience.

Implement two common methods for reducing response times: caching and background workers.

### Caching

Response time and caching are critically imporant. Your improved StoreEngine should make significant use of:

* data caching
* fragment caching
* page caching
* query consolidation
* database optimizations (query count, using indicies, join)

Use the built-in Rails functionality along with Redis and/or Postgres to implement these strategies.

### Background Workers

Use background workers for any job that doesn't **have to** be completed before the response is sent to the user (ex: sending email, updating statistics, etc).

Use Resque or a similar library to support this functionality.

## Base Data

You should have the following data pre-loaded in your marketplace:

* At least 10 stores
* At least 10,000 products per store
* At least 10 product categories per store
* 10,000 users
* 2 store admins per store
* 2 stockers per store
* 2 platform administrators

## Extensions

In this project you as developers are expected to take a more active role in shaping the product. Although there are a few potential extensions proposed at the outset, you are encouraged to propose additional extensions, in the form of new features and user stories describing them, to your product manager and project manager.

If you have an idea for a killer feature for your application, pitch it to your stakeholders for refinement. If they are convinced of its value, they'll work with your team to create one or more user stories in Pivotal Tracker and prioritize those stories in the context of the rest of the requirements. You may be able to convince them to prioritize your feature ahead of current base requirements if it is sufficiently compelling or necessary. The product manager and project manager will work with you to determine the point value of any extension user stories.

Here are some possible example extensions, but you are encouraged to dream up your own as well:

### Custom CSS per store

Provide a mechanism so that store administrators may provide custom a CSS sheet to change the appearance of their store. This custom styling should not affect any other store's appearance.

Have four pre-built themes they can select from and the ability to upload their own.

### Use Sub-Domains To Distinguish Stores

In order to give greater precedence and more SEO-juice to each individual store, as well as pave the way for stores to use custom domains, change your application so that, instead of using a path prefix per request to identify individual stores in the system, use unique sub-domains instead.

So instead of `http://www.storeengine.com/slick-bikes/products` pointing to the products belonging to the store _Slick Bikes_, allow `http://slick-bikes.storeengine.com/products` to be used instead.

### Separate Per-store Sign In

So that each store can optionally create the impression of being independent by cordoning off their user experience, it should be possible for a store to require a unique sign on and account management that is not shared across stores. 

Shipping, billing, credit card info, and order history must be uniquely managed through this store's management interface alone. Email address are thus not unique across multiple stores on the platform, but must be unique for within a given store.

## Evaluation Criteria

The evaluation of the project is broken into three areas:

1. Evaluation of the user stories for each feature of the application. (40 points possible for the basic requirements, up to 12 additional extension points available)
2. Code critique and review by instructors and engineers according to rubric. (42 points possible)
3. Non-functional requirements and metrics according to rubric. (18 points possible)

The breakdown puts a lot of emphasis on the effort put into the quality of the code for your app. But also note that it's possible to earn 12 "bonus" points by building extensions. This means that "full" credit can be earned without building any extensions and that extensions can make up for points lost elsewhere.

### Evaluation of User Stories for Base and Extensions

Each user story for the base expectations will be worth the point value they have been assigned in Pivotal Tracker. Points for a story will be awarded if that story can be exercised without crash or error.

Extension stories will also be worth their story point value in Tracker, but no story's points will count toward the total score unless all other stories of higher priority have been delivered. Therefore you must have delivered the complete base expecations to receive credit for any extensions.

### Code Critique by Instructors and Mentors

Reviewers will compare the state of the code before the project began and the state of the code at the end, looking for improvement and evolution. 

The high-level outline for the rubric is:

1. Good object-oriented and general application design practices, such as SOLID and DRY. (8 points)
2. Use of Ruby and Rails idioms and features. (6 points)
3. Good testing practices and coverage. (6 points)
4. Improvement and evolution of the code, use of refactoring. (4 points)
5. Adherence to the intent of project-specific non-functional requirements, such as background workers and caching. (10 points)
6. Application correctness and robustness. (4 points)
7. Security protections against common attacks (4 points)

### Non-Functional Metrics

Here are the criteria for the non-functional requirements. Please read this rubric carefully, as not all point values are linear.

1. Performance Under Load (0-5 points)
  * 5: Average under 110ms, and all requests < 200ms
  * 3: All requests sub 200ms
  * 2: Average below 200ms
  * 0: Average over 200ms
2. User Interface & Design (0-4 points)
  * 4: WOW! This site is beautiful, functional, and clear.
  * 2: Very good design and UI that shows work far beyond dropping in a library or Bootstrap.
  * 1: Some basic design work, but doesn't show much effort beyond "ready to go" components/frameworks/etc
  * 0: The lack of design makes the site difficult / confusing to use
3. Test Coverage (0-2 points)
  * 2: Testing suite covers > 85% of application code
  * 1: Testing suite covers 70-84% of application code
  * 0: Testing suite covers < 70% of application code
4. Code Style (0-2 points)
  * 2: Source code generates no complaints from Cane or Reek, or only whitespace/comments warning.
  * 1: Source code generates five or fewer warnings about line-length or method statement count
  * 0: Source code generates more than five warnings about line-length or method statement count
5. Show And Tell Milestone (0-2 points)
  * 2: Delivered the features that were prioritized above the show and tell milestone before the meeting
  * 0: Did not deliver all features prior to show and tell

## Evaluation Protocol

Please see the [Son of Store Engine Evaluation Protocol]({% page_url projects/son_of_store_engine/evaluation_protocol %})
