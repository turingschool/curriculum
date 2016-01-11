# Hyde

Writing your own blogging engine is almost a right of passage for aspiring web developers. In this project you'll build a "Static Site Generator" -- a system that allows the author to write content in a writing-friendly format (like Markdown), then the system generates HTML and puts it all together. For reference, existing systems that do this include [Jekyll](https://jekyllrb.com/), [Middleman](https://middlemanapp.com/), and many others.

## Project Overview

### Learning Goals

* Use tests to drive both the design and implementation of code
* Decompose a large application into components
* Use test fixtures instead of actual data when testing
* Connect related objects together through references
* Learn an agile approach to building software

### Getting Started

1. One team member forks the repository at https://github.com/turingschool-examples/hyde and adds the other(s) as collaborators.
2. Everyone on the team clones the repository
3. Create a [Waffle.io](http://waffle.io) account for project management.

## Key Concepts

From a technical perspective, this project will emphasize:

* File I/O
* Parsing and Markup
* Encapsulating Responsibilities
* Light data / analytics

#### Functionality

The "application" will be run as an executable from a user's machine (gem or npm module). It needs to include several features:

* a "generator" to scaffold out a new site (eg `hyde new my-blog`)
* a "build" step which processes provided markdown files into rendered HTML templates. You'll likely want to use an existing Markdown processor for this, although if you ask nicely a module 1 student might let you use their Chisel.
* a "serve" command which boots a simple HTTP server to allow viewing the site in development.

#### File Locations and Path Conventions

Remember that by convention, the "root" file for a static HTML site is its `index.html`. This is what will be served by, for example, github pages if you ship your site to it. We'd like to also allow arbitrary path nesting based on whatever structure a user provides with their site.

So, for example, a file located in the source at:

`articles/my_article.markdown`

should get built as:

`articles/my_article.html`

and be retrievable on the server at:

`my_url.com/articles/my_article.html`

### Serving static assets

We'd like our users to be able to include static assets like Javascripts, Stylesheets, and Images.

### Extensions

* Rails-style "layouts" for extracting standard template functionality
* Partials
* CSS preprocessor (using sass or less)



## Project Iterations and Base Expectations

Because the requirements for this project are lengthy and complex, we've broken
them into Iterations in their own files:

* [Iteration 0](iteration_0.markdown) - Zero
* [Iteration 1](iteration_1.markdown) - One

## Evaluation Rubric

The project will be assessed with the following guidelines:

### 1. Functional Expectations

* 4: Application fulfills all base expectations and two extensions
* 3: Application fulfills all base expectations as tested by the spec harness
* 2: Application has some missing functionality but no crashes
* 1: Application crashes during normal usage

### 2. Test-Driven Development

* 4: Application is broken into components which are well tested in both isolation and integration using appropriate data
* 3: Application is well tested but does not balance isolation and integration tests, using only the data necessary to test the functionality
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

### 5. Enumerable & Collections

* 4: Application consistently makes use of the best-choice Enumerable methods
* 3: Application demonstrates comfortable use of appropriate Enumerable methods
* 2: Application demonstrates functional knowledge of Enumerable but only uses the most basic techniques
* 1: Application demonstrates deficiencies with Enumerable and struggles with collections

### 6. Code Sanitation

The output from `rake sanitation:all` shows...

* 4: Zero complaints
* 3: Five or fewer complaints
* 2: Six to ten complaints
* 1: More than ten complaints
