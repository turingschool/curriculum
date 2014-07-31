---
layout: page
title: Clone Wars
sidebar: true
---

## Intro

In this project you'll take a client's website and rebuild it as a Sinatra and SQL-database powered web application.

## Learning Goals

The overarching goals are to understand how web applications...

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

In this project you'll adopt a client -- without their knowledge. You'll select an existing website and:

* scrape the content
* rip the design and assets (CSS, photos, etc)
* implement a CMS per the specifications below
* deploy your new version of their website into production
* optionally improve the graphic/visual/interaction/information design

### Client Options

Each group will choose a client and no two groups will have the same client. Your options include:

* [Backcountry Deli](http://backcountry-deli.com/) - Sandwich Shop
* [FastFrame of LoDo](http://www.fastframeoflodo.com/blog/) - Framing Shop
* [Jimmy's Urban Bar & Grill](http://www.lodojimmys.com/) - Restaurant
* [Players](http://playersclothing.com/) - Mens Clothing
* [Uncubed](http://www.uncubedspace.com/) - Coworking Space
* [Hapa Sushi](http://hapasushi.com/) - Sushi Restaurant
* [Luxe Salon](http://www.luxesalon.com/) - Salon
* [Indox Services](http://www.indoxservices.com/) - Print Shop

### General Requirements

Your Content Management System needs to:

* serve the content just like the original site
* offer a way for content (ie: hours, menu, description) to be edited by an administrator (single user may be hard-coded)
* include at least one "interactive element" as described below

### What Not To Do

* Don't use `ActiveRecord`, `DataMapper`, or `Sequel::Model` -- just `Sequel` and SQL
* Don't start into 12 features and plan for them all to come together at the last minute. Start small and iterate.
* Don't try and build a more complex database schema than you need -- KISS
* Don't let the details of your database structure leak all over the application. Hide them with a wrapper class.

## Interactive Elements

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

## Evaluation Rubric

The project will be assessed with the following rubric:

### 1. Functional Expectations

* 4: Application recreates the original site and adds three Interactive Elements
* 3: Application recreates the original site and adds one Interactive Element
* 2: Application has some small missing functionality
* 1: Application is not a usable replacement of the original site

### 2. Test-Driven Development

* 4: Application is broken into components which are well tested in both isolation and integration using appropriate data
* 3: Application is well tested but does not balance isolation and integration/feature tests
* 2: Application makes some use of tests, but the coverage is insufficient
* 1: Application does not demonstrate strong use of TDD

### 3. Encapsulation / Breaking Logic into Components

* 4: Application is expertly divided into logical components each with a clear, single responsibility
* 3: Application effectively breaks logical components apart but breaks the principle of SRP
* 2: Application shows some effort to break logic into components, but the divisions are inconsistent or unclear
* 1: Application logic shows poor decomposition with too much logic mashed together

### 4. Fundamental Ruby & Style

* 4:  Application demonstrates excellent knowledge of Ruby syntax, style, and refactoring
* 3:  Application shows strong effort towards organization, content, and refactoring
* 2:  Application runs but the code has long methods, unnecessary or poorly named variables, and needs significant refactoring
* 1:  Application generates syntax error or crashes during execution

### 5. Sinatra / Web and Business Logic

* 4: Application takes advantage of all the features Sinatra has to offer and
effectively separates the web application from the business logic.
* 3: Application makes good use of Sinatra but has some mixing of the web and
business logic.
* 2: Application has web and business logic totally mixed together
* 1: Application demonstrates a weak understanding of Sinatra and how applications
should be built.

### 6. View Layer

* 4: Application expertly breaks components out to view partials and makes use
of both built-in and custom-written view helpers.
* 3: Application breaks components out to view partials but has some logic
or complexity leaking into the view
* 2: Application has messy views that mix logic and presentation
* 1: Application shows a lack of understanding around view templates and how
they should be used/constructed.
