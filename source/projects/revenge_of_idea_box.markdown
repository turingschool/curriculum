---
layout: page
title: Revenge of IdeaBox
sidebar: true
---

Every developer has more ideas than time. As David Allen likes to say "the
human brain is for creating ideas, not remembering them." In this project,
we'll be building a simple application for recording and archiving our ideas
(good and bad alike).

Throughout the project, one of our focuses will be on providing a fluid and responsive
client-side interface. To this end, we'll rely on javascript and Jquery
to implement snappy filtering in the browser, and AJAX to enable
inconspicuous communication between client and server.

## Project Requirements

__Architecture__

For this project, we'll be increasingly thinking about the "server" and "client"
as separate entities. We'll be using:

* A rails application to manage data related to our ideas and serve
  initial UI templates
* Javascript (with JQuery) to manage client-side interactions and communicate
  asynchronously with the server

In order to get more experience doing DOM manipulations and AJAX event handling on our own,
we will _not_ be using client-side frameworks (Ember, Angular, React, etc.)

__Data Model__

We'll be primarily working with "Idea" objects.

* An Idea has a __title__, a __body__, and a __quality__.
* __title__ and __body__ are free-form strings
* __quality__ can be represented however you feel best in the database,
  but in the user interface it should manifest as the options "genius", "plausible", and "swill"

__Creating and viewing ideas (application root)__

On the application's root, the user should:

* See a list of all existing ideas, including the title, body, and quality for each idea.
* Idea bodies longer than 100 characters should be truncated to the nearest word
* See 2 text boxes for entering the "Title" and "Body" for a new idea,
  and a "Save" button for committing that idea.
* ideas should appear in descending chronological order (most recently created
  idea at the top)

__Adding a new idea:__

When a user clicks "Save":

* A new idea with the provided title and body should appear in the idea list
* The idea's "quality" should default to the lowest setting ("swill" -- ideas got to
  work their way up from the bottom...)
* The text fields should be cleared (ready to accept a new idea)
* The page _should not_ reload
* The idea should be committed to the database (it should still be present upon reloading the page)

__Deleting an existing idea:__

When viewing the idea list:

* Each idea in the list should have a link or button to "Delete" (or "X", etc)
* Upon clicking "Delete", the appropriate idea should be removed from the list
* The page _should not_ reload
* The idea should be removed from the database (it should not re-appear on next page load)

__Changing the quality of an idea__

As we said above, ideas should start out as "swill." In order to change the
recorded quality of an idea, the user will interact with it from the idea list.

* Each idea in the list should include a "thumbs up" and "thumbs down" button
* Clicking thumbs up on the idea should increase its quality 1 notch ("swill" -> "plausible",
  "plausible" -> "genius")
* Clicking thumbs down on the idea should decrease its quality 1 notch ("genius" -> "plausible",
  "plausible" -> "swill")
* thumb-upping a "genius" idea or thumb-downing a "swill" idea should have no effect

__Editing an existing idea:__

* Each idea on the idea list should include a link or button to "Edit"
* Clicking this link should take the user to a separate "Edit" page for the given
  idea, and the user should see form fields to modify the idea's title and body.
* The user should have the option to "Save" their edits, and clicking this should
  take them back to the idea list, where the edits will be reflected.

__Idea Filtering (searching)__

We'd like our users to be able to easily find specific ideas they already created, so
let's provide them with a filtering interface on the idea list.

* At the top of the idea list, include a text field labeled "Search"
* As a user types in the search box, the list of ideas should filter in real
  time to only display ideas whose title or body include the user's text (the page _should not_ reload)
* Clearing the search box should restore all the ideas to the list

### Extensions

* __Inline idea editing__ -- When a user clicks the title or idea of an idea in the list, that text should become an editable text field,
  pre-populated with the existing idea title or body. The user should be able to "commit" their changes by pressing "Enter/Return" or by
  clicking outside of the text field.
* __Tagging__ -- Add an optional third text field upon idea creation for "Tags". Tags should be a
  comma-separated list of short text tags, and should be processed on the server
  such that any existing tags are re-used, and any new ones are created. Once there are
  tags to display, a list of existing tags should appear at the top of the idea list.
  Clicking one of these tags should show only ideas that include it. When viewing ideas
  filtered by tag, be sure to include a link to take the user back to "All Ideas". This
  filtering could be implemented either as a separate page or via javascript within the
  same interface.
* __Sorting__ -- When viewing the ideas list, the user should have the option to sort
  ideas by Quality. The default sort should be descending ("genius" -> "plausible" -> "swill"),
  and clicking the sort a second time should reverse it. The Idea list should
  be sorted client-side without reloading the page.

### Rubric

### 1. Features

* 4: All of the base expectations were completed and as well as one or more extensions
* 3: All of the base expectations were met
* 2: Missing one or two features from the base expectations
* 1: Missing more than two base expectations and/or the application is not deployed and working in production

### 2. User Interface

* 4: The application is pleasant, logical, and easy to use
* 3: The application has many strong pages/interactions, but a few holes in lesser-used functionality
* 2: The application shows effort in the interface, but the result is not effective
* 1: The application is confusing or difficult to use

### 3. Testing

* 4: Project has a running test suite that exercises the application at multiple levels including JavaScript tests
* 3: Project has a running test suite that tests and multiple levels but fails to cover some features
* 2: Project has sporadic use of tests and multiple levels
* 1: Project did not really attempt to use TDD

### 4. Rails Style

* 4: Developer is able to craft Rails features that make smart use of Ruby, follow the principles of MVC, and push business logic down where it belongs
* 3: Developer generally writes clean Rails features that make smart use of Ruby, with some struggles in pushing logic down the stack
* 2: Developer struggles with some concepts of MVC and pushing logic down the stack
* 1: Developer shows little or no understanding of how to craft Rails applications

### 5. Ruby Style

* 4: Developer writes code that is exceptionally clear and well-factored
* 3: Developer solves problems with a balance between conciseness and clarity and often extracts logical components
* 2: Developer writes effective code, but does not breakout logical components
* 1: Developer writes code with unnecessary variables, operations, or steps which do not increase clarity
* 0: Developer writes code that is difficult to understand

### 6. JavaScript Style

* 4: Developer writes code that is exceptionally clear and well-factored
* 3: Developer solves problems with a balance between conciseness and clarity and often extracts logical components
* 2: Developer writes effective code, but does not breakout logical components
* 1: Developer writes code with unnecessary variables, operations, or steps which do not increase clarity
* 0: Developer writes code that is difficult to understand
