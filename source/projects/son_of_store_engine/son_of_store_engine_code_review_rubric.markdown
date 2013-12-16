---
layout: page
title: SonOfStoreEngine Code Review Rubric
---


This rubric is used for the "Pro" judging of [SonOfStoreEngine project]({% page_url projects/fourth_meal %})

Evaluations should be collected through http://eval.jumpstartlab.com

### Code Review Rubric (42 points total)

<div class="note">
  <p>The rubric below is organized as list of high level areas of interest, each worth a portion of the total points, that are then broken further down into specific sub-areas.</p>
  <p>Some of those sub-areas also provide suggestions or examples to the reviewers as they critique the projects, but those examples are <strong>not</strong> meant to be exhaustive.</p>
</div>

1. Object-oriented and general application design (10 points)
    1. Single Responsibility Principle (3)
        * small methods, classes, files
    2. Encapsulation (2)
        * Tell, Don't Ask
        * Delegation
    3. Don't Repeat Yourself (1)
    4. You Ain't Gonna Need It (1)
    5. Rails MVC (3)
        * Logic pushed to domain models
        * Domain models that aren't ActiveRecords
        * Use of REST-like patterns when appropriate
        * Little to no logic in views
2. Use of Ruby and Rails idioms and features (6 points)
    1. Leverage Enumerable, Array and Hash (2)
    2. Take advantage of Ruby standard library (1)
    3. Leverage deeper Rails features (2)
        * Advanced/efficient ActiveRecord relationships
        * Nested attributes/fields_for
        * Avoid ActiveRecord lifecycle callback abuse
        * Advanced routing
    4. Take advantage of Rails plugin gems (1)
3. Testing practices and coverage (8 points)
    1. Writing clear, meaningful specs (2)
        * Descriptive spec names
        * Helpful use of spec contexts
        * Test one thing per spec
    2. Well-written integration specs (2)
        * Structure integration specs like user stories
        * Avoid going through the user interface when it's outside the scope of spec
        * Use of tools such as VCR
    3. Avoid [testing anti-patterns](http://blog.james-carr.org/2006/11/03/tdd-anti-patterns/) (2)
        * Ugly mirror
        * Confusing or onerous setup
        * Overly brittle or misleading mocking
    4. Significant but sensible test coverage (2)
        * Essential, interesting, and complicated code covered
        * Effort not wasted on over-specification
        * Don't unit test something that would be better integration tested, or vice-versa
4. Improvement and evolution of the code, use of refactoring (4 points)
    1. Simplify, clean up, or make more consistent the existing code (2)
    2. Refactor the design to make it easier to work with or more easily support new features (2)
5. Adherence to the intent of non-functional requirements (10 points)
    1. Implement background workers for email, other tasks (3)
    2. Performant queries (4)
        * Use of indices
        * Limiting records returned, scoping queries
        * Avoid n+1
        * Arel methods: `includes`, `joins`, `merge`, `pluck`, `find_each`
        * Prudent use of serialized columns
    3. View caching (2)
    4. Data caching (1)
        * Cache columns
        * External cache such as Redis or memcached
6. Application correctness and robustness (4 points)
    1. User experience (2)
    2. Corner cases and error conditions outside the happy path (2)
