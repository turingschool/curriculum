---
layout: page
title: Real Time
sidebar: true
---

## About the Project

Every project that we've done so far—with the exception of Game Time—has been bound by the whole HTTP request/response cycle. In this project, we're going to head off the beaten track for a bit and build real time applications with WebSockets. When the server gets new information, it pushes it out to all of the connected clients.

You will choose the approach that you feel works best.

## Approach

This is your last project at Turing, which means you're about to go off and be developers out in the real world. A big topic for Module 4 has been this idea of trade-offs. Your mission is to complete a base set of requires and satisfy the user personas described below. How you choose to approach it is up to you. Some possible approaches might be:

### On the Server

- Build a Node application that starts off just keeping all of the data in memory using local variables. The trade-off here is that if your process crashes it will lose all of that data in memory. On the other hand, it's simple to get up and running. Once you have the basic application up and running, you can use a simple key-value data store (like Redis, for example) to persist your data in the event that your process goes down or write the data to the file system.
- Build two applications: a Rails application that handles data persistence, providing an API, and serving static assets along with a Node application that focuses exclusively on pushing messages to client over a WebSocket connection. You could use Redis to facilitate PubSub messaging between the two applications.

### On the Client

- Use jQuery for all updating and DOM manipulations.
- You're welcome to explore a front-end framework like Ember or React to handle all of the client-side concerns of your application.

## Learning Objectives

- Build a rich web application that leverages WebSockets to push data to connected clients in real time.
- Leverage simple data structures to manage the state of your application.
- Evaluate the trade-offs involved in different approaches and make informed decisions about your application's design and architecture.

## Case Studies and User Flows

Your application must meet the needs of _both_ users for whichever application you select as outlined below.

### Crowdsource

#### Steve

Steve is an instructor at a seven month developer training program in Colorado. In the middle of a long rant about the merits of CoffeeScript, he wants to check for student understanding. He could pause for a moment and ask the room if they have any idea what he's talking about, but he suspects they'll just smile and nod like they always do. He knows that some students may not want to admit in front of the whole group that they neither understand what Steve is talking about, nor do they particularly care.

- Steve decides to use Crowdsource to anonymously poll the room.
- He goes to the site to generate a new poll and adds three potential responses: "This is old hat to me", "I have an okay understanding of this", "I have no idea what you're babbling about".
- He gets back two links: a admin view that shows the poll and a voting page that shows the options.
- He drops the link into Slack and his students vote.
- Steve feels pleased when he sees that 100% of his students are absolute masters of everything he has ever taught.
- He turns off the poll before a certain student that comes late every day arrives and messes up his perfect score.

#### Tan

Tan is a software engineer who often finds him self in the odd position of not having enough to do. As a result, he often stops by his old school to grab lunch or a cup of decaffeinated tea with the current students there. But, the neighborhood gets pretty busy around lunch time, and trying to figure out where to eat can take a while and by the time everyone agrees, most places are already full.

- These days, Tan uses Crowdsource to tally everyone's preferences before he arrives.
- Tan puts in three or four local places into the application and generates a new poll. He chooses to share the results as they come in. As a result each voting page is also showing the results in real time as they come in.
- Before leaving the house, he realizes that he is going to need to have this decided by the time he gets there. He chooses a time to have the poll automatically close.
- He shares a link to the poll with his friends.
- Tan arrives at his old school and checks his phone. He sees that the group has made a decision and one of his friends has already headed over to grab a table.


### Personal Time

#### Marissa

Marissa works at a local non-profit helping where she helps people find jobs in the technology industry. Many of the students want to schedule time with her, but it can be hard sometimes to work around everyone's schedule and whatnot. She decides to use Personal Time to schedule her appointments.

- She heads over to the Personal Time website and clicks on the link to create a new schedule.
- This generates two unique URLs: one where she can see all of her appointments and one that she can give to people to schedule a time.
- She is autoredirected to the first URL, which we'll call the "Admin Dashboard" from this point forward.
- On the Admin Dashboard, the application displays an additional URL for her to give out to students. We'll call this the "scheduling page" from this point forward.
- She puts in a bunch of time slots into the administration dashboard. Each time slot has the following:
  - The date in which the time slot occurs.
  - The start time.
  - The end time.
  - A text field for comments or other notes.
- She then sends the URL to the scheduling page out to everyone she is working with. (The mechanism for sending out the URL is _not_ part of the application.)
- On the scheduling page, if someone selects a time, it becomes disabled for everyone viewing the scheduling page immediately (without a page refresh). This means that it isn't possible to be double booked.
- Users can also deselect their current choice if they want to free up that spot while they think about it a little more.
- After selecting a slot, the student scheduling a meeting with Marisa sees that they can add it to their calendar, either by downloading an iCal file or adding it directly to a Google Calendar.
  - The iCal file format is just a text file with a particular structure and format. You might consider using a library.
- Later on, she finds out that her friend Tan is trying to schedule lunch with a bunch of people. She notices that lunch overlaps with some of her appointment slots. She heads over the administration view and notices that she can delete open time slots, but she cannot delete time slots that have been scheduled.

#### Mary

Mary mentors up and coming software engineers because of the deep joy it generates in her heart. As much as she loves working with junior developers, she is on the East Coast and many of the people she works with live in Mountain Time. Mary, being comfortable with technology, decides to offload this task to a computer rather than dealing with it herself. Mary has many of the same needs as Marissa, with some additional requirements:

- She heads over to the Personal Time website and creates a bunch of slots. She notices that the site already knew she was on Eastern Time. She puts in a number of time slots.
- She sends the link out to her proteges.
- When they visit the page, they see all of the dates and times in their current time zones as well, so there is no confusion about when they're meeting.

## Evaluation Criteria

Please read the entire rubric before beginning the project.

### Concept and Features

Does it have the expected features?

* 100 points - Exceeded expectations. There are more features than we planned.
* 75 points - Met expectations as outlined by the user personas, the application is a solid first version. All planned features were delivered.
* 50 points - Some features were sacrificed to meet the deadline. At best, this is a prototype. Major features covered by the learning goals listed above were not written by the developer.
* 25 points - Major features are missing, there are major bugs that make it impossible to use, and/or the application is not deployed to production.
* 0 - There is no application.

### Code Quality (JavaScript and/or Ruby)

* 30 points - Developer writes code that is exceptionally clear and well-factored. Application is expertly divided into logical components each with a clear, single responsibility.
* 25 points - Developer solves problems with a balance between conciseness and clarity and often extracts logical components. Developer can speak to choices made in the code and knows what every line of code is doing.
* 20 points - Developer writes effective code, but does not breakout logical components. Application shows some effort to break logic into components, but the divisions are inconsistent or unclear. There are many large methods or functions and it is not clear to the evaluator what a given section of code does.
* 10 points - Developer writes code with unnecessary variables, operations, or steps which do not increase clarity.
* 0 points - Developer writes code that is difficult to understand. Application logic shows poor decomposition with too much logic mashed together.

### Client-Side Application

* 30 points - Your application has exceptionally well-factored code with little or now duplication and all components separated out into logical components.
* 25 points - Your application is thoughtfully put together with some duplication and no major bugs.
* 20 points - Your application has a significant amount of duplication and one or major bugs.
* 10 points - Your client-side application does not function or the application does not make use of WebSockets for updating information on the client.
* 0 points - There is little or no client-side code.

### Test-Driven Development

* 30 points - The code demonstrates high test coverage. It is tested at the feature, controller and unit levels. It tests the WebSocket as well as the controller endpoints.
* 25 points - The code demonstrates high test coverage. It is tests at controller and unit levels. All controller/routes are tested. There are no failing tests.
* 20 points - The code demonstrates high test coverage. One or more enpoints are not tested or the internal business logic is not fully tested.
* 10 points - Many areas of the code are not covered by tests.
* 0 points - No tests were written or the testing framework does not work.

### Interface

* 5 points - The application is pleasant, logical, and easy to use
* 4 points - The application has many strong pages/interactions, but a few holes in lesser-used functionality.
* 2 points - The application shows effort in the interface, but the result is not effective. The evaluator has some difficulty using the application when reviewing the features in the user stories.
* 0 points - The application is confusing or difficult to use.

### Workflow

* 5 points - The developer effectively uses Git branches and many small, atomic commits that document the evolution of their application.
* 4 points - The developer makes a series of small, atomic commits that document the evolution of their application. There are no formatting issues in the code base.
* 2 points - The developer makes large commits covering multiple features that make it difficult for the evaluator to determine the evolution of the application.
* 0 points - The developer commited the code to version control in only a few commits. The evaluator cannot determine the evolution of the application.
* 0 points - The application was not checked into version control.
