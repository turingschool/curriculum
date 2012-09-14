---
layout: page
title: More Than Just An `Array`
---

## More than just an `Array`

The most common object implementing `Enumerable` that you'll work with is certainly `Array`. The abstract data type we call array can be thought of as a contiguous list of elements, like a set of train cars on a track, each with their own payload, that can be walked from beginning to end or accessed at an arbitrary place in the middle. Because it is layed out as connected cells, each side by side, it can be easy to add an item to the end, but it is difficult to add items in the middle. (Think about how much physical effort it would take to add a car into the middle of a long train!)

In Ruby, the `Array` class actually plays more roles than just the traditional array data type. It also can act like a linked list, a stack, or a queue, among others. We'll take a look at the how the latter two data types can be simulated.
