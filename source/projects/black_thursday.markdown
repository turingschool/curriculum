# Black Thursday

A business is only as smart as its data. Let's build a system able to load, parse, search, and execute business intelligence queries against the data from a typical e-commerece business.

## Project Overview

### Learning Goals

* Use tests to drive both the design and implementation of code
* Decompose a large application into components
* Use test fixtures instead of actual data when testing
* Connect related objects together through references
* Learn an agile approach to building software

### Getting Started

1. One team member forks the repository at https://github.com/turingschool-examples/black_thursday and adds the other(s) as collaborators.
2. Everyone on the team clones the repository
3. Create a [Waffle.io](http://waffle.io) account for project management.
4. Setup [SimpleCov](https://github.com/colszowka/simplecov) to monitor test coverage along the way

### Spec Harness

This project will be assessed with the help of a [spec harness](https://github.com/turingschool/black_thursday_spec_harness). The `README.md` file includes instructions for setup and usage. Note that the spec harness **is not** a replacement for your own test suite.

## Key Concepts

From a technical perspective, this project will emphasize:

* File I/O
* Relationships between objects
* Encapsulating Responsibilities
* Light data / analytics

## Project Iterations and Base Expectations

Because the requirements for this project are lengthy and complex, we've broken
them into Iterations in their own files. Your project *must* implement iterations 0 through 3.

* [Iteration 0](black_thursday/iteration_0.markdown) - Merchants & Items
* [Iteration 1](black_thursday/iteration_1.markdown) - Beginning Relationships and Business Intelligence
* [Iteration 2](black_thursday/iteration_2.markdown) - Basic Invoices
* [Iteration 3](black_thursday/iteration_3.markdown) - Item Sales
* [Iteration 4](black_thursday/iteration_4.markdown) - Merchant Analytics
* [Iteration 5](black_thursday/iteration_5.markdown) - Customer Analytics

## Evaluation Rubric

The project will be assessed with the following guidelines:

### 1. Functional Expectations

* 4: Application implements iterations 0, 1, 2, 3, (4 or 5), and features of your own design
* 3: Application implements iterations 0, 1, 2, 3, and either 4 or 5
* 2: Application implements iterations 0, 1, 2, and 3
* 1: Application does not fully implement iterations 0, 1, 2, and 3

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
