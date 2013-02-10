---
layout: page
title: Testing Fundamentals
section: Testing
---

## The Big Picture

* What is "Automated Software Testing"?
  * Generally
  * Adoption in various programming cultures: MS/.NET, Java, Python, Ruby
  * Showmanship and Reality
  * Our Goals
* Reasons to Write Tests
  * Testing for Validation
  * Testing for Design
  * Testing for Communication
* What software deserves testing?
* When should you not write tests?
* Testing Workflows
  * Test-After aka Validation Testing
  * Test-First
  * Test-Driven
* Testing Frameworks
  * MiniTest & Test::Unit
  * RSpec

## Getting Started with MiniTest

### Introduction to MiniTest

* MiniTest tests are normal looking Ruby
* Basic construction:
  * Write a descriptive name
  * Setup your necessary data / object(s)
  * Perform the operation you're interested in
  * Check that the output is what you expected

### MiniTest References

* Github: https://github.com/seattlerb/minitest
* MiniTest Quick Reference: http://www.mattsears.com/articles/2011/12/10/minitest-quick-reference
* Most common assertions:
  * `assert`
  * `assert_equal`
  * `assert_includes`
  * `assert_nil`
  * `assert_raises`
