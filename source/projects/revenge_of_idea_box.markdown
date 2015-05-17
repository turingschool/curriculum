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
* See a 2 text boxes for entering the "Title" and "Body" for a new idea,
  and a "Save" button for committing that idea. 

__Adding a new idea:__

When a user clicks "Save":

* A new idea with the provided title and body should appear in the idea list
* The text fields should be cleared (ready to accept a new idea)
* The page _should not_ reload
* The idea should be committed to the database (it should still be present upon reloading the page)
* A new idea should default to the "swill" quality state

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

__Idea List User Interface__

* by default ideas should appear in descending chronological order (most recently created
  idea at the top)
* when viewing the list of ideas, the user should be able to sort ideas by "quality";
  the default sort should be "Descending" (genius ideas, followed by plausible ideas, followed by swill).
  Clicking the sort a second

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
