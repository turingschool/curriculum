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
to implement snappy sorting and filtering in the browser, and AJAX to enable
inconspicuous communication between client and server.

## Project Requirements

__Architecture__

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

* Inline idea editing -- When a user clicks the title or idea of an idea in the list, that text should become an editable text field,
  pre-populated with the existing idea title or body. The user should be able to "commit" their changes by pressing "Enter/Return" or by
  clicking outside of the text field.


-----------


Your application is able to capture, rank and sort ideas. If only that was enough
for you. The following extensions allow you to define additional features to
make your application more dynamic and interesting.

### Tagging

Besides viewing ideas in ranked order  it would be great if you could also view
ideas that are similar to one another or share the same thing that ignited the
idea.

* When you create an idea you can specify one or more tags.
* A tag is a single phrase, a single word or fragment sentence, that you use
  to describe an idea.
* Each idea can have one or more tags
* You are able to view all ideas for a given tag
* You are able to view all ideas sorted by tags

### Statistics

After creating ideas you want to start tracking when you create your ideas.

* When ideas are created the time they were created is captured.
* You are able to view a breakdown of ideas created across the hours of the day
  (e.g. 12:00AM to 12:59AM, 1:00AM to 1:59AM)
* You are able to view a breakdown of ideas created acorss the days of the week
  (i.e. Mon, Tue, Wed, Thu, Fri, Sat, Sun)

### Revisions

You start with an idea that eventually changes over time. Where you started from
and where you ended is a very different place. Sometimes you would like to see
the evolution of an idea.

* When you edit and save an idea the previous version of the idea is also saved.
* An idea now has a history or list of revisions
* You are able to view the history of an idea

### Grouped Ideas

Tagging allows for you to view ideas that within a certian category. Sometimes
you want to differentiate your work ideas from your personal ideas.

* By default all ideas are added to a default group
* You are to define additional groups
* When you create an idea you can specify the group for that idea
* An idea can only belong to a single group
* You can view only the ideas contained in a particular group
* When sorting ideas on rank or tags only the ideas within that group are sorted

### Mobile Friendly

Ideas strike like lightning and it is important to be able to be able to enter
your ideas from a small-screen device. While the original site works with a
mobile device, it would be great to optimize the experience.

* You are able to add, view, and edit ideas easily through a mobile browser.

### Searching for Idea

After creating so many ideas it becomes hard to manage all the ideas. It would
be great if you could search for a specific idea based on a word or phrase
contained within an idea.

* The main index page has a search field
* The search field allows you to specify a phrase.
* A phrase is a word or or fragment sentence
* When search is initiated the contents of the search field will be used to
  find only the ideas with that contain the phrase, case insensitive, provided
  within the search field.

### Fuel

With your defined ideas it would be great to start adding more details and
resources for each of those ideas.

* For each idea you can add a new resource
* A resource is text or link related to the idea
* You are not able to see the resources of an idea on the index page
* You are able to view all the resources for an idea when you view the details
  of an idea.

### Haml

You have templated your application with ERB. It might be interesting to see
what it would look like using Haml.

* Replace all the *erb* templates with *haml* templates.

### Image Upload

Pictures are worth a 1000 words.

* When you create an idea you can specify an image
* When you create a resource for an idea you can specify an image
* You are able to upload an image that will be associated with the idea
* When viewing an idea the image is displayed within the idea
* When viewing a resource the image is displayed within that resource

### Sound Upload

The power of the spoken word

* When you create an idea you can specify an sound
* When you create a resource for an idea you can specify an sound
* When viewing an idea the sound is displayed as a downloadable link
* When viewing a resource the sound is displayed as a downloadable link

### SMS Integration

Faster than even a mobile website might be the ability to define ideas through
text message.

* You able to text a new idea to a particular phone number
* The message from the text appear in your list of ideas

### Users

Currently you can only track the ideas of one person. What would help you to
generate ideas is if you could take idea generation socially

* A person is able to generate a user account
* A user account has a username
* When viewing a user's page you are only able to the ideas for that user
* When viewing a user's page you are able to add ideas as previously defined

> At the moment we are not going to discuss the policies for good password
> creation and rentention or maintaining a logged in user. The idea of a
> user in this implementation simply allows you to segment the ideas across
> users. Any person viewing a user's page can add a new idea for that user.
