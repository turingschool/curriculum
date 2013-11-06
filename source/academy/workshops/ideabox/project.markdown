---
layout: page
title: Ideabox Project
---

Having completed [Ideabox TDD](/academy/workshops/ideabox/tdd.html) and
[Ideabox
WWW](http://tutorials.jumpstartlab.com/academy/workshops/ideabox/www.html) you
have a functional, albeit incredibly ugly, web application to capture, rank, and
sort ideas.

If only that were enough for you.

Create a better design, and define additional features to make your
application more dynamic and interesting.

Here are some ideas to get you started.

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
