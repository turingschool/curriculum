---
layout: page
title: Monsterporium - Extracting Responsibilities
sidebar: true
---

Let's start today as we will every day: by programming.

In this session, our goals are to:

* Get your mind ready for programming
* Explore the fundamental premise of extracting logic out into related objects

## Setup

Please:

* Get together with another developer to pair program
* Clone the [Robot Simulator](https://github.com/JumpstartLab/code_retreat) exercise

## Round 1 - Initial Implementation

Spend the next 30 minutes trying to get the tests to pass with your pair.

If you'd like an extra challenge, implement your solution with **no if statements**.

### Discuss

Were you able to get it finished? Probably not. Let's quickly talk about a few techniques that were useful.

## Round 2 - Extracting a `Plane`

What does "North" have to do with the concept of a `Robot`? Nothing.

Get together with a *new* pair. For the next 30 minutes, attempt to:

* Implement the exercise again **from scratch**
* Create a `Plane` class which a robot instance is connected to
* Extract all the "knowledge" about cardinal directions to the plane
* Think about what it'd be like to implement a plane with diagonal directions (N, NE, E, SE, S, SW, W, NW). The tests would have to be rewritten, but would your `Robot` be able to handle `Plane` changing?

### Discuss

* How did extracting `Plane` affect the complexity of `Robot`?
* What does that mean about the **churn** of `Robot` over time?
* Could your `Robot` now exist in 3D space?
* What about Ruby makes this pattern easy?
