---
layout: page
title: Binary Search Tree
---

A binary search tree is a fundamental data structure useful for organizing large sets of data.

More on Wikipedia: http://en.wikipedia.org/wiki/Binary_search_tree

## Overview

A binary tree is built from *nodes*. Each node has:

* A) An element of data
* B) A link to the *left*. All nodes to the left have data elements less/lower than this node's data element.
* C) A link to the *right*. All nodes to the right have data elementes more/greater than this node's data element.

## Base Expectations

Build a binary search tree which can:

* `insert` a new unique value into the tree
* verify/reject the presence of a value in the tree with `include?`
* report the depth of a node in the tree with `depth_of`
* find the `maximum` value in the tree
* find the `minimum` value in the tree
* implement a `sort` that outputs an array of the values in sorted order (by traversing the tree, not using Ruby's sort method)

As the final challenge, add the ability to `delete` a value from the tree and repair the tree.

Beyond your tests, data should come in and go out using files:

* import data from a file with one value per line (values are unique within the input)
* output a file, similar to the input file, with the values in ascending order

## Extensions

Additionally you can implement these features:

* find the total number of leaves on the tree
* report the (maximum) height of the tree

## Evaluation Rubric

The project will be assessed with the following rubric:

### 1. Functional Expectations

* 4: Application fulfills all base expectations and two extensions
* 3: Application fulfills all base expectations
* 2: Application is missing one base expectation
* 1: Application is missing more than one base expectation

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
