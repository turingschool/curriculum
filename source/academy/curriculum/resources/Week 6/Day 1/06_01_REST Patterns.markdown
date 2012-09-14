---
layout: page
title: REST Patterns
---

## REST Patterns

* REST Intro
* REST concepts and constraints
    * Resources and URIs
    * CRUD and HTTP verbs
    * Multiple representations
    * Responsibilities of the Rails stack
* Refactor Cart and CartItem's RESTful approach
* Practical example: product reviews
    * Implement as a nested resource
    * JSON representation and form partial

### REST Introduction

<div style='width:600px'><script async class="speakerdeck-embed" data-id="4f82d9340e58c0001f006481" data-ratio="1.299492385786802" src="//speakerdeck.com/assets/embed.js"></script></div>

#### Key Ideas

* Any idea represented by a noun should probably be a resource
* Resources may or may not be persisted

### More on Models

* Models are just Ruby
* Pushing code to the model
  * From the view
  * From the controller
* Non-ActiveRecord classes
* Using Modules