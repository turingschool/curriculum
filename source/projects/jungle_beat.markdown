---
layout: page
title: Jungle Beat
---

# Jungle Beat

## Basics

In this project we're going to do some silly things with sound. Specifically, we're going to make a very basic drum machine program.

However to add some additional depth, let's also use this project as a chance to explore one of the fundamental data structures in computer science -- the Linked List.

### Drum Machine 101 -- Making Sounds

Go into your Terminal and try this:

```
$ say -r 500 -v Boing "ding, dah, oom, oom, ding, oom, oom, oom, ding, dah, oom, oom, ding, dah, oom, oom, ding, dah, oom, oom "
```

Yeah. That's what we're looking for. Now try it from Ruby:

```
$ pry
> `say -r 500 -v Boing "ding, dah, oom, oom"`
```

Note that the backticks allow you to run terminal commands from within Ruby.

### Linked Lists

Linked Lists are one of the most fundamental Computer Science data structures. A Linked List models a collection of data as a series of "nodes" which link to one another in a chain.

In a singly-linked list (the type we will be building) you have a __head__, which is a node representing the "start" of the list, and subsequent nodes which make up the remainder of the list.

The __list__ itself can hold a reference to one thing -- the head node.

Each node can hold a single element of data and a link to the next node in the list.

The last node of the list is often called its __tail__.

Using sweet ASCII art, it might look like this:

```
List -- (head) --> ["hello" | -]-- (link) --> ["world" | -]-- (link) --> ["!" | ]
```
The three nodes here hold the data "hello", "world", and "!". The first two nodes have links which point to other nodes. The last node, holding the data "!", has no reference in the link spot. This signifies that it is the end of the list.

## Learning Goals / Areas of Focus

* Practice breaking a program into logical components
* Distinguishing between classes and instances of those classes
* Understanding how linked lists work to store and find data
* Testing components in isolation and in combination

## Iterative Development

As we work through this project, we'll be following an _iterative_ development process. This means we'll aim to build the system out of small but complete chunks which could reasonably stand on their own to perform some required function. The iterations are outlined below. It may be worth reading through them all at first to get a sense of the scope of the entire project, but we encourage you to then forget about later iterations until you get to them.

The point of this process is to help us focus on small pieces at a time without getting overwhelmed by the scope of the entire project.

### Iteration Base Expectations

* [Iteration 0](jungle_beat/iteration_0.md) - Node Basics
* [Iteration 1](jungle_beat/iteration_1.md) - Append, All and Count (Single Node)
* [Iteration 2](jungle_beat/iteration_2.md) - Append, All and Count (Multiple Nodes)
* [Iteration 3](jungle_beat/iteration_3.md) - Insert and Prepend
* [Iteration 4](jungle_beat/iteration_4.md) - Find, Pop, and Includes?
* [Iteration 5](jungle_beat/iteration_5.md) - Creating a Linked List Wrapper
* [Iteration 6](jungle_beat/iteration_6.md) - Playing Beats
* [Extensions](jungle_beat/extensions.md) - Validating Beats, Speed & Voice

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

* Make sure that your code is well tested for both *expected cases* and *edge cases*. Try popping more elements than there are in the list. Try seeing if an empty list includes anything. Try inserting elements at a position beyond the length of the list. Setup [SimpleCov](https://github.com/colszowka/simplecov) to better monitor test coverage along the way.
* Avoid using other ruby collections (Arrays, Hashes, etc) for the storage of your beats. That's where you're supposed to use the linked list. But having Arrays elsewhere in your code, or using methods that return arrays (like `.split`) are totally ok.

## Resources

Need some help on Linked Lists? You can check out some of the following resources:

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
