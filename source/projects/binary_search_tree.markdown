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

Build a binary search tree which can fulfill each of the interactions below.

Assume we've started with:

```ruby
tree = BinarySearchTree.new
```

### `insert`

The `insert` method adds a new node with the passed-in data. It returns the
depth of the new node in the tree.

```ruby
tree.insert("m")
# => 0
tree.insert("c")
# => 1
tree.insert("q")
# => 1
tree.insert("a")
# => 2
```

For all the later methods defined here, assume that we've run these four inserts.

### `include?`

Verify/reject the presence of a piece of data in the tree:

```ruby
tree.include?("q")
# => true
tree.include?("b")
# => false
```

### `depth_of`

Reports the depth of the tree where a piece of data appears:

```ruby
tree.depth_of("q")
# => 1
tree.depth_of("a")
# => 2
```

### `max`

What is the largest value present in the tree?

```ruby
tree.max
# => "q"
```

### `min`

What is the smallest value present in the tree?

```ruby
tree.max
# => "a"
```

### `sort`

Return an array of all the elements in sorted order. *Note*: you're not using
Ruby's `Array#sort`, you're traversing the tree.

What is the largest value present in the tree?

```ruby
tree.sort
# => ["a", "c", "m", "q"]
```

### `load`

Assuming we have a file named `numbers.txt` with one value per line:

```ruby
tree.load('numbers.txt')
# => 224
```

Where the return value is the number of unique values inserted into the tree. If
a number is present more than one time in the input file *or* already present in
the tree when `load` is called, ignore it.

## Extensions

### Understanding the Shape

This extensions is made up of two methods:

#### `leaves`

How many leaf nodes are on the tree?

```ruby
tree.leaves
# => 2
```

#### `height`

What is the height (aka the maximum depth) of the tree?

What is the largest value present in the tree?

```ruby
tree.height
# => 3
```

### Deleting Nodes

Remove a specified piece of data from the tree:

```ruby
tree.delete("a")
# => "a"
tree.delete("x")
# => nil
```

Note that any children of the deleted node should still be present in the tree.

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
