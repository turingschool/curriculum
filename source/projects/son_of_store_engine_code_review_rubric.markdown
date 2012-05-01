---
layout: page
title: SonOfStoreEngine Code Review Rubric
---

This rubric is used to judge the [SonOfStoreEngine project](http://tutorials.jumpstartlab.com/projects/son_of_store_engine.html). Consider it when building your application. Please ask for clarication on it when needed.

### Review Groupings

* Team 1:
  * 1A: Silvis, Anderson
  * 1B: Verdi, Worthy
* Team 2:
  * 2A: Gilman, Thal
  * 2B: Kaufman, Rimmer
* Team 3:
  * 3A: Koszewski, Scheffler
  * 3B: Shah, Cutrali
* Team 4:
  * 4A: Glass, Tabler
  * 4B: Ito, Kiefhaber
* Team 5:
  * 5A: Maddox, Williams
  * 5B: Chenault, Chlipala
* Team 6:
  * 6A: Strahan, Valentine
  * 6B: Rivera, Weng

### Review Schedule

Please be at your appointed times early and take careful notice of who is reviewing whom:

* 1:00 - 2:00
  * 4A reviews 5B in Classroom High
  * 5A reviews 6B in Classroom Low
  * 6A reviews 4B in Boardroom
* 1:00 - 1:30
  * Team 1 with Yoho in Yoho's Office
  * Team 2 with Wehner in the Fishbowl
  * Team 3 with Swasey in Jeff's Office
* 1:30 - 2:00
  * Team 2 with Yoho in Yoho's Office
  * Team 3 with Wehner in the Fishbowl
  * Team 1 with Swasey in Jeff's Office
* 2:00 - 3:00
  * 1A reviews 2B in Classroom High
  * 2A reviews 3B in Classroom Low
  * 3A reviews 1B in Boardroom
* 2:00 - 2:30
  * Team 4 with Yoho in Yoho's Office
  * Team 5 with Wehner in the Fishbowl
  * Team 6 with Swasey in Jeff's Office
* 2:30 - 3:00
  * Team 5 with Yoho in Yoho's Office
  * Team 6 with Wehner in the Fishbowl
  * Team 4 with Swasey in Jeff's Office
* 3:00 - 4:00
  * 3B reviews 1A in Yoho's Office
  * 4B reviews 2A in the Fishbowl
  * 5B reviews 3A in Jeff's Office
  * 6B reviews 4A in Classroom High
  * 1B reviews 5A in Classroom Low
  * 2B reviews 6A in Boardroom

### Evaluation Records

Both "Pro" and "Peer" evaluations are available at http://eval.jumpstartlab.com

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
        * Prudent use of seralized columns
    3. View caching (2)
    4. Data caching (1)
        * Cache columns
        * External cache such as Redis or memcached
6. Application correctness and robustness (4 points)
    1. User experience (2)
    2. Corner cases and error conditions outside the happy path (2)

