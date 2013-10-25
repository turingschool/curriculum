---
layout: page
title: Clone Wars
date: 2013-10-25
---

## Intro

In this project you'll take a client's website and rebuild it as a Sinatra and SQL-database powered web application -- without permission.

## Learning Goals

This project is a bridge between smaller projects with Sinatra like [WebGuesser]({% page_url web_guesser %}) and [IdeaBox]({% page_url idea_box %}) to Rails-based projects like [Blogger]({% page_url blogger %}) and [SalesEngine]({% page_url sales_engine %}).

The big goals are to understand how web applications...

* Receive requests and send responses with HTTP
* Store data to and fetch data from a SQL database
* Write code that is well designed and tested

### Working with HTTP

By the end of this project you will:

* understand `GET` and `POST` coming from the browser
* understand how and why we *fake* the `PUT` and `DELETE` verbs
* use paths to control which part of the application is activated
* use data embedded in the URL path (`GET` and `POST` requests)
* use parameters appended to the path (`GET` requests)
* use parameters embedded in the request body (`POST` requests)

### Databases

By the end of this project you will:

* use the Sequel library to generate and execute SQL statements
* implement `SELECT`, `INSERT`, `DELETE`, and `UPDATE` SQL queries
* use `WHERE`, `LIMIT`, `INNER JOIN`, and `ORDER` modifiers in SQL queries
* use appropriate techniques to avoid SQL injection attacks
* design an elemntary database schema with at least 2 tables and a relationship between them
* use separate environment-specific databases (*development*, *test*, and *production*)

### Architecture

Throughout the project your code will:

* separate business logic from the Sinatra web application
* use layouts and partials in view templates to reduce repetition and increase clarity
* test at multiple levels including:
  * unit tests for business logic
  * controller tests for the web application
  * acceptance tests to imitate user interactions

## The Project

Imagining a bunch of content and creating a from-scratch design are not the goals of this project. Instead, you'll adopt a client -- without their knowledge.

You'll select an existing website and:

* scrape the content
* rip the design and assets (CSS, photos, etc)
* implement a CMS per the specifications below
* deploy your new version of their website into production
* optionally improve the graphic/visual/interaction/information design

### Client Options

We've selected a variety of potential clients for you. Your group can pick one of the below:

* [The Bike Depot](http://www.thebikedepot.org/) - Bike Coop
* [Eskie Rescuers](http://www.eskierescuers.org/) - Animal Fostering/Adoption (non profit)
* [Le Central](http://www.lecentral.com/) - Restaurant
* [Denver Kung Fu](http://kungfudenver.com/) - Martial Arts
* [Clyfford Still](http://www.clyffordstillmuseum.org/) - Museum
* [Buntport](http://www.buntport.com/) - Theatre Company
* [Good Chemistry](http://goodchem.org/) - Dispensary
* [Bodylab Fitness](http://bodylabfitness.com/) - Training Studio

### General Requirements

Your CMS needs to:

* serve the content just like the original site
* offer a way for content (ie: hours, menu, description) to be edited by an administrator (single user may be hard-coded)
* include at least one "interactive element" as described below

### Interactive Elements

Depending on the domain of your client, your site should include **at least one** of the following:

#### Contact Us

* Basic: A contact form that emails the client/administrator, asks for a name, subject, and body
* Medium: Building on the above, allow the user to attach a photo. Only allow files that are PNGs or JPGs.
* Advanced: User emails create "discussions" accessible to the admin through a web interface *and* email. The admin can reply to the email, which goes to the app, which adds the response to the discussion and emails the client.

#### Site-wide Banner

* Basic: A banner message displayed on all pages (e.g. "we will be closed for Thanksgiving")
* Medium: Schedule the banner to start and stop at certain days/times *or* after certain user activities (ex: once they've visited three pages, the banner displays "Questions? Call us at 888-555-5555")
* Advanced: Display a banner to users based on membership in a group (ie: all registered users with a pending appointment/reservation)

#### Domain-Specific Reservations

* Basic: Send an email with a open text request that specifies the day, time, party size, and contact information. Send to admin via email.
* Medium: Request the reservation using selectable dates, times, and party size. The admin can approve/deny requests through a web interface.
* Advanced: View a schedule which displays available slots. Requests are approved/denied through a web interface and the requester is notified over email or phone/SMS.

#### User-generated content

* Basic: unauthenticated product reviews / images
* Medium: authenticate with an external service before creating (twitter, facebook, etc)
* Hard: implement your own authentication system from scratch (including salted/hashed passwords, of course)

#### Web-Based Application System

* Basic: Fill-out and store the data in the database (ex: to apply for a job, apply to adopt, etc)
* Medium: Send email confirmation to the applicant and notification to the admin
* Advanced: add an approval/feedback workflow for the admin with notifications as appropriate
