---
layout: page
title: Pushing Logic Down the Stack
---

## High Level

In an MVC application the Controller has a lot of jobs, which means that over
time it tends to attract code. To build high-quality applications we need to
always push logic down the stack towards the models.

### Learning Goals

Through this discussion you should developer a stronger understanding of:

* What does and doesn't belong in a controller?
* Why are controllers difficult to reason about and test?
* How can we relocate appropriate logic to the model layer?
* How can we use non-ActiveRecord objects ("POROs") to help organize and
simplify code?

### Example

It's best to show these kinds of problems with an actual student codebase. For this
exercise we've selected the project below. Clone, bundle, and prep the database:

{% terminal %}
$ git clone XYZ
$ cd XYZ
$ bundle
$ rake db:create db:migrate db:seed
{% endterminal %}

## The Main Concept

### XYZController

Let's first look at the XYZ action of the XYZController.

### Rules of Thumb

* Anything related to HTTP and parameters stays in the controller
* Any complexity involving data, like filtering or ordering, belongs in the model
* Ask "could this possibly be reused in our [mobile|desktop] app?" If yes, then
it probably belongs in the model.
* *Use* a method in the controller before you write it in the model. Think through
what data the model will need and pick a name that flows well.

### Now You

### XYZController 2

Let's first look at the XYZ action of the XYZController 2.

#### Now You
