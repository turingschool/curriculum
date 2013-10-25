---
layout: page
title: "clone_wars"
date: 2013-10-25
---

Create a CMS to reproduce an existing site in the wild:

1. semi-complicated implementation -> keep design
2. advanced implementation (e.g. scheduling, reservations) -> keep design
3. easy implementation -> needs design

Possible logic pieces:

* contact form / email (using pony)
* update content that changes reasonably often (e.g. menu, opening hours)
* an admin message to go across all the pages (e.g. "we will be closed for thanksgiving")

Suggested sites to look at:

* Local neighborhood restaurants
* Shelters (animal shelters, homeless shelters)
* Non-profits
* Massage therapists and other tiny 1-person businesses
* Local galleries or theatre companies

## Deliverable

Working site deployed and running in production (on Heroku)

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

