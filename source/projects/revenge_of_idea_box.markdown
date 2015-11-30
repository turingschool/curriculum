---
layout: page
title: Revenge of IdeaBox
sidebar: true
points: 150
---

**Nota bene**: This project is the spiritual successor to [Idea Box][ib], but there is no requirement that you need to have done or even be away of Idea Box to be successful on this project.

[ib]: ./idea_box.markdown

Every developer has more ideas than time. As David Allen likes to say "the
human brain is for creating ideas, not remembering them." In this project,
we'll be building a simple application for recording and archiving our ideas
(good and bad alike).

Throughout the project, one of our focuses will be on providing a fluid and responsive
client-side interface. To this end, we'll rely on JavaScript and jQuery
to implement snappy filtering in the browser, and AJAX to enable
inconspicuous communication between client and server.

## Project Requirements

### Architecture

For this project, we'll be increasingly thinking about the "server" and "client"
as separate entities. We'll be using:

* A Rails application to manage data related to our ideas and serve
  initial UI templates (or just `public/index.html`)
* JavaScript (with jQuery) to manage client-side interactions and communicate
  asynchronously with the server

In order to get more experience doing DOM manipulations and AJAX event handling on our own,
we will _not_ be using client-side frameworks (Ember, Angular, React, etc.).

Your entire application will consist of one HTML page or template. You will not have separate pages for each CRUD action.

All of your AJAX functionality will be triggered by jQuery.

### Data Model

(5 points total.)

We'll be primarily working with _Idea_ objects.

* An Idea has a _title_, a _body_, and a _quality_. (1 point)
  * _title_ and _body_ are free-form strings.
* _quality_ can be represented however you feel best in the database,
  but in the user interface it should manifest as the options "genius", "plausible", and "swill" (2 points)
* By default, the idea's "quality" should default to the lowest setting (i.e. "swill"). (2 points)

### User Flows

#### Viewing ideas

(10 points total.)

On the application's root, the user should:

* See a list of all existing ideas, including the title, body, and quality for each idea. (2 points, manditory for specification adherence)
* Idea bodies longer than 100 characters should be truncated to the nearest word. (5 points)
* Ideas should appear in descending chronological order (with the most recently created
  idea at the top). (3 points)

#### Adding a new idea

(15 points total.)

On the application's main page, a user should:

* See two text boxes for entering the "Title" and "Body" for a new idea,
  and a "Save" button for committing that idea. (3 points, manditory for specification adherence)

When a user clicks "Save":

* A new idea with the provided title and body should appear in the idea list. (5 points, manditory for specification adherence)
* The text fields should be cleared and ready to accept a new idea. (2 points)
* The page _should not_ reload. (3 points, manditory for specification adherence)
* The idea should be committed to the database. It should still be present upon reloading the page. (2 points, manditory for specification adherence)

#### Deleting an existing idea

(15 points total.)

When viewing the idea list:

* Each idea in the list should have a link or button to "Delete" (or 𝗫, etc). (2 points)
* Upon clicking "Delete", the appropriate idea should be removed from the list (5 points, manditory for specification adherence).
* The page _should not_ reload when an idea is deleted. (5 points, manditory for specification adherence)
* The idea should be removed from the database. It should not re-appear on next page load. (3 points, manditory for specification adherence)

#### Changing the quality of an idea

(15 points total.)

As we said above, ideas should start out as "swill." In order to change the recorded quality of an idea, the user will interact with it from the idea list.

* Each idea in the list should include a "thumbs up" and "thumbs down" button. (3 points)
* Clicking thumbs up on the idea should increase its quality one notch ("swill" → "plausible",
  "plausible" → "genius"). (4 points)
* Clicking thumbs down on the idea should decrease its quality one notch ("genius" → "plausible",
  "plausible" → "swill"). (4 points)
* Incrementing a "genius" idea or decrementing a "swill" idea should have no effect. (4 points)

#### Editing an existing idea

(20 points total.)

* Each idea on the idea list should include a link or button to edit the idea. (4 points)
* Clicking this link should _not_ take the user to a separate "edit" page for the given
  idea. (4 points, manditory for specification adherence)
* After clicking on the edit link, the user should see form fields to modify the idea's title and body. (4 points)
* The user should have the option to "Save" their edits, and clicking this should create an PUT request using AJAX. (4 points, manditory for specification adherence)
* If the user reloads the page, their edits will be reflected. (4 points, manditory for specification adherence)

#### Idea Filtering and Searching

(15 points total.)

We'd like our users to be able to easily find specific ideas they already created, so
let's provide them with a filtering interface on the idea list.

* At the top of the idea list, include a text field labeled "Search". (3 points)
* As a user types in the search box, the list of ideas should filter in real time to only display ideas whose title or body include the user's text. The page _should not_ reload. (6 points)
* Clearing the search box should restore all the ideas to the list. (6 points)

### Extensions

Extensions are a great way to earn additional points beyond the 150 available in this project. That said, awarding points for delivering a given extension is up to the instructor, who may only award partial points depending on the quality of the implementation. The points listed below represent the maximum number of points. Extensions can _not_ be done after the fact without instructor permission in advance.

#### Inline idea editing

(10 additional points.)

When a user clicks the title or idea of an idea in the list, that text should become an editable text field, pre-populated with the existing idea title or body. The user should be able to "commit" their changes by pressing "Enter/Return" or by clicking outside of the text field.

#### Tagging

(20 additional points.)

Add an optional third text field upon idea creation for "Tags". Tags should be a comma-separated list of short text tags, and should be processed on the server such that any existing tags are re-used, and any new ones are created. Once there are tags to display, a list of existing tags should appear at the top of the idea list. Clicking one of these tags should show only ideas that include it. When viewing ideas filtered by tag, be sure to include a link to take the user back to "All Ideas". This filtering could be implemented either as a separate page or via javascript within the same interface.

#### Sorting

(10 additional points.)

When viewing the ideas list, the user should have the option to sort ideas by Quality. The default sort should be descending ("genius" → "plausible" → "swill"), and clicking the sort a second time should reverse it. The Idea list should be sorted client-side without reloading the page.

## Instructor Evaluation Points

### Specification Adherence

* **10 points**: The application consists of one page with all of the major functionality being provided by jQuery. There is no use of `format.js` in Rails. There is no use of unobstrusive JavaScript. There are no front-end frameworks used in the application. No approach was taken that is counter to the spirit of the project and its learning goals. There are no features missing from above that make the application feel incomplete or hard to use.

### User Interface

* **5 points** - The application is pleasant, logical, and easy to use. There no holes in functionality and the application stands on it own to be used by the instructor _without_ guidance from the developer.
* **3 points** - The application has many strong pages/interactions, but a few holes in lesser-used functionality.
* **2 points** - The application shows effort in the interface, but the result is not effective. The evaluator has some difficulty using the application when reviewing the features in the user stories.
* **0 points** - The application is confusing or difficult to use.

### Testing

* **10 points** - Project has a running test suite that exercises the application at multiple levels including JavaScript tests.
* **8 points** - Project has a running test suite that tests and multiple levels but fails to cover some features. All controller actions are covered by tests. The application makes some use of integration testing.
* **5 points** - Project has sporadic use of tests and multiple levels. Not all controller actions are tested. There are little or no attempts at integration testing.
* **0 points** - There is little or no evidence of testing in this application.

### Ruby and Rails Quality

* **10 points** - Developer is able to craft Rails features that make smart use of Ruby, follow the principles of MVC, and push business logic down where it belongs. There _zero_ instances where an instructor would recommend taking a different approach. Developer writes code that is exceptionally clear and well-factored. Application is expertly divided into logical components each with a clear, single responsibility.
* **8 points** - Developer solves problems with a balance between conciseness and clarity and often extracts logical components. Developer can speak to choices made in the code and knows what every line of code is doing.
* **5 points** - Developer writes effective code, but does not breakout logical components. Application shows some effort to break logic into components, but the divisions are inconsistent or unclear. There are many large methods or functions and it is not clear to the evaluator what a given section of code does. Developer cannot speak to every line of code on the server side.
* **3 points** - Developer writes code with unnecessary variables, operations, or steps which do not increase clarity.
* **0 points** - Developer writes code that is difficult to understand. Application logic shows poor decomposition with too much logic mashed together.

### JavaScript Style

* **10 points** - Application has exceptionally well-factored code with little or now duplication and all components separated out into logical components. There _zero_ instances where an instructor would recommend taking a different approach.
* **8 points** - Application is thoughtfully put together with some duplication and no major bugs. Developer can speak to choices made in the code and knows what every line of code is doing.
* **3 points** - Your application has a significant amount of duplication and one or major bugs.
* **1 point** - Your client-side application does not function or the application does not make use of AJAX using jQuery for updating information on the client. Developer writes code with unnecessary variables, operations, or steps which do not increase clarity.
* **0 points** - There is little or no client-side code. Developer writes code that is difficult to understand. Application logic shows poor decomposition with too much logic mashed together.

### Workflow

* **10 points** - The developer effectively uses Git branches and many small, atomic commits that document the evolution of their application.
* **5 points** - The developer makes a series of small, atomic commits that document the evolution of their application. There are no formatting issues in the code base.
* **3 points** - The developer makes large commits covering multiple features that make it difficult for the evaluator to determine the evolution of the application.
* **1 point** - The developer commited the code to version control in only a few commits. The evaluator cannot determine the evolution of the application.
* **0 points** - The application was not checked into version control.
