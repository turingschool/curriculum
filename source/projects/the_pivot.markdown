---
layout: page
title: The Pivot
sidebar: true
---

Your Dinner Dash application was *almost* great, but it turns out that we need
to *pivot* the business model.

In this project you'll build upon an existing implementation of
[Dinner Dash]({% page_url projects/dinner_dash %}), turning it from a
restaurant ordering site to something much bigger.

### Learning Goals

#### Modeling

* Adapt the existing restaurant models to belong to individual businesses
* Mind security permissions such that each business does **not** have any knowledge of other businesses' data
* Push *all* logic down to the model layer so controllers and views remain simple

#### Interface & Views

* Use and switch between multiple view templates to reduce view-layer logic
* Implement a clean, logical order flow that minimizes customer frustration

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

You'll build upon an existing code base assigned by the instructors. You need to
work on adapting and improving this codebase, not building your own thing from
scratch. This is sometimes called "brownfield" development, and you'll soon know
why.

#### Exploring the Dinner Dash App

As a group, dig into the code base and pay particular attention to:

* Test coverage and quality
* Architectural concerns
* Components that are particularly strong or weak
* General strengths and weaknesses

#### Beginning The Pivot

Once you've explored the base project:

* Select one member of the group who will host the canonical repository for the project
* Create a new, blank repository on GitHub named `the_pivot`
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

Your project should evolve, refactor, and clean up the code you inherit. This includes deleting redudant, broken, or obsolete code. However, you should **not** throw out the previous work wholesale.

Furthermore, there should be *no reduction in functionality* except when explicitly called for by new requirements.

### Setup the Project Management Tool

There are many popular project management tools out there. For this project
we'll use a lightweight tool that wraps GitHub issues: [Waffle.io](https://waffle.io/)

Setup a Waffle project for your new repo. Your team members and instructors should
be added to the project.

## Managing Requirements

### Authoritative Requirements

The stories as written and prioritized in your project management tool will be
the authoritative project requirements. They may go against and likely go beyond
the general requirements in this project.

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

### Project Check-In Meetings

Rapid and frequent feedback about the work we produce is a central tenet of
agile software development. As such, we'll have frequent meetings to discuss the
state of your project and correct course as necessary.

[TODO: Revise Meeting Schedule and Contents]

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

## Pivots

Your group will be assigned one of the following problem domains to pivot Dinner Dash:

### Keevahh

Micro-lending is a powerful tool for social progress. Let's rework Dinner Dash
into a micro-lending platform.

* Users register on the site as either a borrower (*the business*) or a lender
(*the customer*)
* Borrowers automatically have a borrower page (*the store*)
* Within that borrower page, they post one or more loan requests (*the products*)
* A loan request has a title, description, categories, photos, borrowing amount, requested-by
date, a repayments-begin date, and a repayment rate
* A lender can browse the site and view all open loan requests
* They can add multiple loans from multiple borrowers to their cart
* They can then checkout and the funds are allocated to the borrowers
* The borrowers are notified that funding has come through and their loan request
page is updated

Lending like this is more fun together -- it'd be great if lenders could band
together into lending groups that make loans together on a weekly or monthly basis.

### EmployMe

Employment is key to quality of life. Let's rework our Dinner Dash into a platform
to help people find great jobs.

* Users register on the site as either a job poster (*the business*) or a job seeker (*the customer*)
* A business has a listings page with all their job listings
* The business can create one or more job listing
* A listing has a title, description, categories, full-time/part-time indicator,
wage/salary range, number of positions open, and a closing date
* A job seeker can browse the site and view all open job listings
* They can add one or more job listings to their cart
* They can upload a PDF resume that's attached to their user account
* During the "checkout" process, they can add a brief hello note to each job they're
applying for
* The job posters are notified that a new application has come in

The job posters will need a great dashboard where they can review the applicants
and either send them rejections or schedule interviews.

### Airlift

Technology has a huge role to play in disaster relief and recovery. Let's rework
Dinner Dash to help get relief supplies to the people and places that need them.

* Users register on the site as either suppliers (*the business*) or service
providers (*the customer*)
* A supplier has a listings page with all their available supplies
* A listing has a title, description, categories, quantity available, unit size,
current location, shippable indicator, unit weight
* A service provider can browse the site and view all available supplies
* They can add one or more supplies to their cart
* During checkout they can choose to (a) pickup the supplies and request a
pickup day/time or (b) request delivery and set their current location using GPS coordinates
* The suppliers are notifed that a new request has come in

Disaster areas probably don't have desktops, electricity, and internet
access. This project needs to be built targeting *mobile web* and *SMS* where
appropriate.

### TravelHome

Experiencing other cultures is one of the strongest ways to build our understanding
of humanity. Let's make it easier for people to open their homes to travelers.

* Users register on the site and can be both hosts (*the business*) and travelers
(*the customer*)
* A host has a listings page where they list available accommodations and they
have a profile with their photo, name, and description
* A listing has a title, description, categories, quantity available, people-per-unit,
daily rate, photos, location, shared/private bathroom indicator, and available dates
* A traveler can browse the site and view all available listings
* They can add one or more listings along with requested dates to their cart
* Their profile has their name, photo, and previous bookings
* When they checkout, the hosts are notified of the requests
* The hosts can either confirm or deny the requests
* The traveler is notified when request status changes

Of course a traveler will need a good way to roll up all their bookings into
an itinerary that helps them get from place to place with a map and pushes data
to their Google Calendar.

### Future Ideas

* A bespoke clothing shopping site
* A medical services comparison and shopping site

## Base Expectations

You are to extend Dinner Dash so that it can handle multiple, simultaneous businesses. Each business has their own name, unique URL pattern, items, orders, and administrators.

<div class='note'>
<p>The requirements reference an <b>example.com</b>, but your URL will differ.</p>
</div>

## Functional Requirements

Individual restaurants can be accessed by specifying their restaurant name as the path prefix.

* Given a business named _Billy's BBQ_
* When I visit `http://example.com/billys-bbq`
* Then I expect to see all items defined for _Billy's BBQ_
* And I expect to see branding defined for _Billy's BBQ_
* When I visit `http://example.com/billys-bbq/categories`
* Then I expect to see all categories defined for _Billy's BBQ_

### Public Visitor

As a public, unauthenticated visitor to a business I can:

* Maintain a **shared** shopping cart across all businesses I browse
* Add items to a shopping cart
* Log in to or create an account before completing checkout
   * When I create an account, then I expect to receive a welcome email
   * After login or creating an account, I will **immediately** resume the checkout process
* Request that my account become a business owner

### Authenticated Customer

As an authenticated customer I can:

* Make purchases on any business I am browsing
  * Receive an email confirmation of my order with basic order details and a link to the order detail page
* Manage my account information shared by all businesses centrally on my account page
  * Shipping addresses
  * Billing addresses
  * Credit cards associated with my account
  * Basic account info like name and password, as managed previously in Dinner Dash v1
* View and manage my purchase history across all businesses

### Creating a Business

* An account can request to create a new business that includes a name,
URL identifier ("slug"), and description
* The platform administrators are notified of the pending request
* If approved...
  * the requester is notified by email
  * the requester automatically becomes a business administrator for the business
* If denied...
  * the requester is notified by email

### Authenticated Business Administrator

As an authenticated business admin, by using a dedicated admin area, I can:

* Add items, edit items, and retire listings in my business only
* Update the details of my business such as the: name, URL identifier, and description
* Add or remove other admins for the business
    * There can never be fewer than 1 admin for a business
* Perform the admin actions available to administrators in Dinner Dash as appropriate

### Authenticated Platform Administrator

As an authenticated Platform Administrator, I can:

* Approve or decline the creation of new businesses
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

### Background Workers

Use background workers for any job that doesn't **have to** be completed before the response is sent to the user (ex: sending email, updating statistics, etc).

Use Resque or a similar library to support this functionality.

## Base Data

Before final delivery, and ideally before customer check-ins, you should have the following data pre-loaded in your marketplace:

* At least 10 total businesses
* At least 20 listings per business
* At least 5 listing categories
* 100 known customers
* 2 business admins per business
* 2 platform administrators

It creates a much stronger impression of your site if the data is plausible. We recommend creating a few "template" businesses that have real listings, then replicating those as needed. It's better to have "Taste of India 26" and "Taste of India 27" than "Lorem Ipsum" and "Tellus Domit".

## Extensions

In this project you as developers are expected to take a more active role in shaping the project. Although there are a few potential extensions proposed at the outset, you are encouraged to propose additional extensions, in the form of new features and user stories describing them, to your project manager.

If you have an idea for a killer feature for your application, pitch it to your stakeholders for refinement. If they are convinced of its value, they'll work with your team to create one or more user stories in your project management software and prioritize those stories in the context of the rest of the requirements. You may be able to convince them to prioritize your feature ahead of current base requirements if it is sufficiently compelling or necessary.

**However**, your application should not implement features which have not been approved
by your customer.

### Custom CSS per Business

Provide a mechanism so that business administrators may provide custom a CSS sheet to change the appearance of their listing page. This custom styling should not affect any other business's appearance.

Have four pre-built themes they can select from and the ability to upload their own.

### Use Sub-Domains To Distinguish Businesses

In order to give greater precedence and more SEO-juice to each individual business, as well as pave the way for businesses to use custom domains, change your application so that, instead of using a path prefix per request to identify individual businesses in the system, use unique sub-domains instead.

So instead of `http://www.example.com/billys-bbq/items` pointing to the items belonging to the business _Billy's BBQ_, allow `http://billys-bbq.example.com/items` to be used instead.

## Evaluation Criteria

[TODO: Rework evaluation criteria to include expectations for check-ins]

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
