---
layout: page
title: FeedEngine Code Review Rubric
---


This rubric is used for the judging of [FeedEngine project]({% page_url projects/feed_engine %}) 

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
2. Use of Ruby and Rails idioms and features (8 points)
    1. Leverage Enumerable, Array and Hash (1)
        * I.e., don't reinvent the wheel
    2. Take advantage of Ruby standard library (1)
        * I.e., don't reinvent the wheel
    3. Leverage deeper Rails features (3)
        * Advanced/efficient ActiveRecord relationships
        * Nested attributes/fields_for
        * Avoid ActiveRecord lifecycle callback abuse
        * Advanced routing
    4. Use of proper scoping and other techniques to ensure authorization (2)
    5. Take advantage of plugins/gems (1)
        * Particularly around API consumption
3. Testing practices and coverage (10 points)
    1. Writing clear, meaningful specs (3)
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
    4. Significant but sensible test coverage (3)
        * Essential, interesting, and complicated code covered
        * Effort not wasted on over-specification
        * Adhere to the testing pyramid: more faster tests, fewer slower ones
        * Don't unit test something that would be better integration tested, or vice-versa
4. Adherence to the intent of non-functional requirements (10 points)
    1. Implement background workers for API interaction, email (2)
    2. Well-written and integrated internal API gem (4)
    3. Performant queries (2)
        * Use of indices
        * Limiting records returned, scoping queries
        * Avoid n+1
        * Arel methods: `includes`, `joins`, `merge`, `pluck`, `find_each`
        * Prudent use of seralized columns
    4. View caching (1)
    5. Data caching and pre-fetching (1)
        * Do not live-query APIs
        * External cache such as Redis or memcached
5. Application correctness and robustness (4 points)
    1. User experience (2)
    2. Corner cases and error conditions outside the happy path (2)
