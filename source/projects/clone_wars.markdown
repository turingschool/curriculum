---
layout: page
title: Clone Wars
sidebar: true
---

## Intro

In this project you'll take a client's website and rebuild it as a Sinatra and SQL-database powered web application.

## Learning Goals

This project is a bridge between smaller projects with Sinatra like [WebGuesser]({% page_url web_guesser %}) and [IdeaBox]({% page_url idea_box %}) to Rails-based projects like [Blogger]({% page_url blogger %}) and [SalesEngine]({% page_url sales_engine %}).

The big goals are to understand how web applications...

* Receive requests and send responses with HTTP
* Store data to and fetch data from a SQL database
* Are built in a modular, object-oriented style

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
* design an elementary database schema with at least 2 tables and a relationship between them
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
* [Eskie Rescuers](http://www.eskierescuers.org/) - Animal Fostering/Adoption (non-profit)
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

### What Not To Do

* Don't use `ActiveRecord` or `DataMapper` -- just `Sequel` and SQL
* Don't start into 12 features and plan for them all to come together at the last minute. Start small and iterate.
* Don't try and build a more complex database schema than you need -- KISS
* Don't let the details of your database structure leak all over the application. Hide them with a wrapper class.

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

* Basic: Use a form to send an email with a request that specifies the day, time, party size, and contact information. Send to admin via email.
* Medium: Request the reservation using drop-down selectable dates, times, and party size. The admin can approve/deny requests through a web interface.
* Advanced: View a schedule which displays available slots. Requests are approved/denied through a web interface and the requester is notified over email or phone/SMS.

#### User-generated content

* Basic: Visitor can create product reviews / images without authenticating
* Medium: Visitors must authenticate with an external service (twitter, facebook, etc) before creating content
* Hard: Visitors must authenticate before creating content and implement your own authentication system from scratch (including salted/hashed passwords, of course)

#### Web-Based Application System

* Basic: Fill-out the web form and store the data in the database (ex: to apply for a job, apply to adopt, etc)
* Medium: After the user fills out the form, send email confirmation to the applicant and notification to the admin
* Advanced: After the form is submitted and notifications sent, add an approval/feedback workflow for the admin with notifications to the user as appropriate
