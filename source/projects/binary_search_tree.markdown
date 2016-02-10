---
layout: page
title: Suggested for You
---

## Overview

You are a junior developer at Netflix. You're on a team that is developing a list of movies for Netflix users called "Suggested for You." Each time movies are added to Netflix, an algorithm determines a score of how likely a given user is to enjoy that movie.

* Scores are integers between 0 and 100
* No two movies will get the same score

It is your job to take new movies that have been scored, and store them in a Binary Search Tree.

## Binary Search Trees

A binary search tree is a fundamental data structure useful for organizing large sets of data.

More on Wikipedia: http://en.wikipedia.org/wiki/Binary_search_tree

A binary tree is built from *nodes*. Each node has:

* A) An element of data
* B) A link to the *left*. All nodes to the left have elements with a value less or lower than this node's data element.
* C) A link to the *right*. All nodes to the right have elements with a value more or greater than this node's data element.

## Base Expectations

Build a binary search tree which can fulfill each of the interactions below.

Assume we've started with:

```ruby
tree = BinarySearchTree.new
```

### `insert`

The `insert` method adds a new node with the passed-in data. Each node is comprised of a score and a movie title. It returns the depth of the new node in the tree.

```ruby
tree.insert(61, "Bill & Ted's Excellent Adventure")
# => 0
tree.insert(16, "Johnny English")
# => 1
tree.insert(92, "Sharknado 3")
# => 1
tree.insert(50, "Hannibal Buress: Animal Furnace")
# => 2
```

For all the later methods defined here, assume that we've run these four inserts.

### `include?`

Verify/reject the presence of a score in the tree:

```ruby
tree.include?(16)
# => true
tree.include?(72)
# => false
```

### `depth_of`

Reports the depth of the tree where a score appears. Return nil if the score does not exist:

```ruby
tree.depth_of(92)
# => 1
tree.depth_of(50)
# => 2
```

### `max`

Which movie has the highest score in the list? What is it's score?

```ruby
tree.max
# => {"Sharknado 3"=>92}
```

### `min`

Which movie has the lowest score in the list? What is it's score?

```ruby
tree.min
# => {"Johnny English"=>16}
```

### `sort`

Return an array of all the movies and scores in sorted ascending order. Return them as an array of hashes.
*Note*: you're not using Ruby's `Array#sort`. You're traversing the tree.

```ruby
tree.sort
# => [{"Johnny English"=>16},
#   {"Hannibal Buress: Animal Furnace"=>50},
#   {"Bill & Ted's Excellent Adventure"=>61},
#  {"Sharknado 3"=>92}]
```

### `load`

Assuming we have a file named `movies.txt` with one score/movie pair per line:

```
# movies.txt sample format:
34, Hannibal Buress: Comedy Camisado
63, Meet My Valentine
22, Experimenter
84, French Dirty
41, Love
10, I Love You Phillip Morris
```

```ruby
tree.load('movies.txt')
# => 26
```

Where the return value is the number of movies inserted into the tree. If a score is already present in the tree when `load` is called, ignore it.

See an example file [here](https://gist.github.com/neight-allen/dbc9e3ad0f79bff24888)

### `health`

Report on the health of the tree by summarizing the number of child nodes (nodes beneath each node) at a given depth. For health, we're worried about 3 values:

* Score of the node
* Total number of child nodes including the current node
* Percentage of all the nodes that are this node or it's children

```ruby
tree.insert(98, "Animals United")
tree.insert(58, "Armageddon")
tree.insert(36, "Bill & Ted's Bogus Journey")
tree.insert(93, "Bill & Ted's Excellent Adventure")
tree.insert(86, "Charlie's Angels")
tree.insert(38, "Charlie's Country")
tree.insert(69, "Collateral Damage")
tree.health(0)
=> [[98, 7, 100]]
tree.health(1)
=> [[58, 6, 85]]
tree.health(2)
=> [[36, 2, 28], [93, 3, 42]]
```

Where the return value is an `Array` with one nested array per node at that level. The nested array is:

```
[score in the node, 1 + number of child nodes, floored percentage of (1+children) over the total number of nodes]
```

When the percentages of two nodes at the same level are dramatically different, like `28` and `42` above, then we know that this tree is starting to become unbalanced.

## Extensions

### Understanding the Shape

This extensions is made up of two methods:

#### `leaves`

A leaf is a node that has no left or right value. How many leaf nodes are on the tree?

```ruby
tree.leaves
# => 2
```

#### `height`

What is the height (aka the maximum depth) of the tree?


```ruby
tree.height
# => 3
```

### Deleting Nodes

Remove a specified piece score from the tree:

```ruby
tree.delete(30)
# => 30
tree.delete(101)
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

### 5. Looping *or* Recursion

* 4: Application makes excellent use of loop/recursion techniques
* 3: Application makes effective use of loop/recursion techniques
* 2: Application has issues with loop/recursion techniques or mixes them inappropriately
* 1: Application struggles to loop/recurse at all
