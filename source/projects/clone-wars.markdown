---
layout: page
title: Clone Wars
date: 2013-10-25
---

## Intro

(Big idea of the project)
(What is / why use a CMS)

## Learning Goals

### HTTP

Understand and use

* HTTP verbs
* Paths
* Params
* Data from request

### Databases

* Understanding enough SQL to use the Sequel gem
* Avoiding SQL injection
* Design an elemntary database schema (at least 2 tables with a relationship between them)
* Creating separate environment-specific databases

### Architecture

* Understand how and why to separate business logic from web application
* Understanding and using layouts and partials in view templates
* Testing at multiple levels:
    * Unit tests for business logic
    * Controller tests for web application
    * Acceptance tests for web interface

## Teams

( groups of three, how to work together / divide responsibilities)

## The Project

( intro about what/why you need a client )

### End-Goal / Deliverable

Working site deployed and running in production (on Heroku)
Uses and builds upon existing content / design

### Client Recommendations

* (our suggestions)

### Selecting Your Own Client

Suggested sites to look at:

* Local neighborhood restaurants
* Shelters (animal shelters, homeless shelters)
* Non-profits
* Massage therapists and other tiny 1-person businesses
* Local galleries or theatre companies

## Project Expectations

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
