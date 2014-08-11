---
layout: page
title: Visualizing Enumerable Methods
sidebar: true
---

Let's take a different look at a few of
the most important Enumerable methods:

### Raw Enumeration, No Useful Result

"I want to go through the collection and do some arbitrary operation, often
throwing away the return value."

* `each`
* `each_with_index`

### Result is a Collection

"I want to take the elements I have and create a new collection from them."

* `sort`
* `select` / `find_all`
* `map` / `collect`
* `group_by`

### Result is an Element of the Collection

"I want to find one special element within the collection."

* `detect` / `find`
* `max` / `min`
* `max_by` / `min_by`

### Result is a Boolean

"Is this question about the collection true or false?"

* `all?`
* `any?`

### Result is a New Value

"Based on the elements in the collection, calculate a single new value."

* `inject` / `reduce`
* `count`
