# Linked Lists

Linked Lists are one of the most fundamental Computer Science data structures. A Linked List models a collection of data as a series of "nodes" which link to one another in a chain.

In a singly-linked list (the type we will be building) you have a __head__, which is a node representing the "start" of the list, and subsequent nodes which make up the remainder of the list.

The __list__ itself can hold a reference to one thing -- the head node.

Each node can hold a single element of data and a link to the next node in the list.

The last node of the list is often called its __tail__.

Using sweet ASCII art, it might look like this:

```
List -- (head) --> ["hello" | -]-- (link) --> ["world" | -]-- (link) --> ["!" | ]
```
The three nodes here hold the data "hello", "world", and "!". The first two node have links which point to other nodes. The last node, holding the data "!", has no reference in the link spot. This signifies that it is the end of the list.

## Base Expectation

Write an implementation of a linked list which can __at least__ do all of the following:

* `append` an element to the end of the list
* `prepend` an element at the beginning of the list
* `insert` an element at an arbitrary position in the list
* `includes?` gives back `true` or `false` whether the supplied value is in the list
* `pop` an element from the end of the list
* `count` the number of elements in the list
* return the `head` value at the beginning of the list
* return the `tail` value at the end of the list
* `find_by_index` find the value at a numeric position
* `find_by_value` finds the position of the first occurrence of a value
* `remove_by_index` removes the value at the specified index
* `remove_by_value` removes the first occurrence of the specified value

## Extensions

* Find the distance between two nodes

## Tips

* A linked list it not an array. While it may perform many of the same functions as an array, its structure is conceptually very different.
* There are only 3 types of "state" that need to be tracked for a linked list -- the head of the list, the data of each node, and the "next node" of each node.
* In object-oriented programming, "state" is generally modeled with instance variables
* There are two main ways to implement Linked Lists: __iteration__ and __recursion__. Iterative solutions use looping structures (`while`, `for`) to walk through the nodes in the list. Recursive solutions use methods which call themselves to walk through nodes. It would be ideal to solve it each way.
* Most of your methods will be defined on the `List` itself, but you will need to manipulate one or more `Node`s to implement them.
* __TDD__ will be your friend in implementing the list. Remember to start small, work iteratively, and test all of your methods.
* An __empty__ list has `nil` as its head
* The __tail__ of a list is the node that has `nil` as its next node

## Constraints

* Make sure that your code is well tested for both *expected cases* and *edge cases*.
* Avoid using other ruby collections (Arrays, Hashes, etc) in your implementation.

## Resources

Need some help? You check out some of the following resources:

* https://www.youtube.com/watch?v=oiW79L8VYXk
* http://www.eternallyconfuzzled.com/tuts/datastructures/jsw_tut_linklist.aspx
* http://www.cs.cmu.edu/~adamchik/15-121/lectures/Linked%20Lists/linked%20lists.html
* http://www.sitepoint.com/rubys-missing-data-structure/

## Evaluation Rubric

The project will be assessed with the following rubric:

### 1. Functional Expectations

* 4: Application fulfills all base expectations and the one extension
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
