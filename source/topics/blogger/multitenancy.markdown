---
layout: page
title: Multitenancy
section: Blogger
---

Fundamentally, adding multitenancy to an application allows it to support multiple users and give them *each* the impression that they have a dedicated application.

To illustrate the process of adding multitenancy, let's work with Blogger.

### Setup

We'll start with the Blogger-Advanced project:

```
git clone git@github.com:JumpstartLab/blogger_advanced.git
cd blogger_advanced
bundle
```

#### Login

The prerequisite for multi-tenancy is to have a login/logout system to identify users. In this version of Blogger we've implemented a stand-in login system just to get you going. Check it out at `http://localhost:3000/login`

### Process

* Articles already have an `author_id`
* Add an author username slug to the routes
* Scope the article index by the username
* Create new articles automatically scoped to the current user
* Scope edit/delete operations to the current user
