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
4. Setup [CodeClimate](https://codeclimate.com/) to monitor code quality along the way
5. Setup [TravisCI](https://travis-ci.org/) to run your tests ever time you push

## Key Concepts

From a technical perspective, this project will emphasize:

* File I/O
* Parsing and Markup
* Encapsulating Responsibilities
* Light data / analytics

## Evaluation Rubric

Available [here](rubric.markdown).

## Project Iterations and Base Expectations

Because the requirements for this project are lengthy and complex, we've broken
them into Iterations in their own files:

* [Iteration 0](iteration_0.markdown) - Generating a new Hyde project
* [Iteration 1](iteration_1.markdown) - Building Hyde source files into HTML
* [Iteration 2](iteration_2.markdown) - Generating new blog post files
* [Iteration 3](iteration_3.markdown) - Customizing site design with layouts and CSS

### Serving static assets

We'd like our users to be able to include static assets like Javascripts, Stylesheets, and Images.

### Extensions

* Rails-style "layouts" for extracting standard template functionality
* Partials
* CSS preprocessor (using sass or less)

