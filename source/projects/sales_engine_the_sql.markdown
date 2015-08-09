---
layout: page
title: SalesEngine the SQL
---

In this project you'll practice designing a database and using
raw SQL.

## Project Overview

### Goals

* Use tests to drive both the design and implementation of code
* Implement a database structure based on existing datasets
* Write SQL inserts to store data in the database
* Write SQL queries to fetch data from the database
* Practice refactoring across a code base

### Abstract

Let's write a data reporting tool that manipulates and reports on merchant transactional data backed by a SQL database.

### Restrictions

Project implementation may *not* use:

* Rails' `ActiveRecord` library or a similar object-relational mappers (including `Sequel`, `DataMapper`, etc)
* Your implementation may not use `Struct` or `OpenStruct`
* Metaprogramming (`method_missing`, `define_method`, etc)
* Internal arrays to store object sets

## Base Expectations

You remember SalesEngine, yes? You'll begin with an existing SalesEngine
implementation and need to retrofit the SQL backend. You should *not* implement any internal memoization since the database data may be changed externally.

Your final product needs to pass the same spec harness as the original project.

## Extensions

Extensions may be added during the course of the project.

## Evaluation Rubric

The project will be assessed with the following rubric:

### 1. Functional Expectations

* 4: Application fulfills all base expectations in the spec harness. Ranking all complete solutions in the class by spec harness runtime, this solution is in the top 50%.
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

### 5. SQL

* 4: Application makes excellent use of the SQL database such as indices, joins, or views to efficiently solve problems.
* 3: Application makes use of the SQL database and performs set operations in the database rather than in Ruby.
* 2: Application makes use of the SQL database instead of internal collection storage but manipulates/filters those sets in Ruby.
* 1: Application still uses one or more Ruby data collections to track data.
