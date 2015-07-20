---
layout: page
title: APICurious
sidebar: true
---

## Project Spec: APICurious

In this project, we'll be focusing on consuming and working with data from public APIs. As a vehicle for learning this concepts, we'll be selecting an API from a popular website and working to re-construct a simplified version of the website's existing UI using their own API. For example, you might decide to use the Twitter API to build a basic version of the Twitter feed where users can view and post tweets.

As we build these features, we'll also be working with the OAuth protocol to authenticate our users with the third-party provider, and using various testing techniques to allow us to test against the third-party data.

### Learning Goals

* Learn to consume data from third-party APIs
* Continue to emphasize performance, UI, and overall user experience
* Continue using TDD to drive all layers of development
* Coordinate with project stakeholders to produce quality code and product

This project will be completed individually over a period of 4 days.

### Available API Choices

To start, you need to select an API to work with. We've selected the following list of applications
for their well-documented public APIs, and relatively straightforward UI's.

For each project, we have included a rough summary list of features to include.
As with any development project, you should focus on moving iteratively through the most
basic features before starting on more complex ones. During the project, the
instructors will meet with you to assess progress and determine what features to focus
on next.

#### Twitter

Consider a basic version of the Twitter feed. I should be able to:

* Authenticate with my Twitter account
* View a list of recent tweets from my feed
* See my basic profile information (profile pic, follower count, following count, etc)
* Post a tweet
* Favorite a tweet

Additional possible interactions include:

* Retweeting a tweet
* Replying to a tweet
* Use a paginated or infinite-scroll interface to view more tweets
* Unfollow a user

#### Instagram

Consider a basic version of the Instagram (web) UI. I should be able to:

* Authenticate with my instagram account
* See my basic profile information (username, profile pic)
* View a list of recent posts from my feed
* View photos for each post
* View comments for each post
* View like count for each post

Additional interactions might include:

* Infinite Scroll to view more photos
* Post a comment on a post

#### Tumblr

Consider a basic version of the Tumblr UI. I should be able to:

* Authenticate with my Tumblr account
* See my basic profile information (username, profile pic)
* View a list of recent posts from my feed
* View embedded photo or video content for the posts
* Favorite a post
* Reblog a post

Additional interactions might include:

* Create a post (perhaps starting with just text posts and moving on to more complicated types)
* Generate a permalink for a post
* Follow a user whose post was reblogged into my feed

#### Github

Consider a basic version of the Github profile / feed UI. I should be able to:

* Authenticate with my github account
* View basic information about my account (profile pic, number of starred repos, followers, following)
* View contribution summary information (Contributions in last year, longest streak, current streak)
* View a summary feed of _my_ recent activity (recent commits) 
* View a summary feed of recent activity from _users whom I follow_
* View a list of organizations I'm a member of
* View a list of my repositories

Additional features might include:

* View a list of open pull requests that I have opened
* View a list of "@mentions" that I was included in
* Create a new repository

### Planning & Requirements

The authoritative project requirements will be created and maintained in collaboration with your client through meetings and your project management tool. This means that the requirements for your team will differ significantly from other groups.

## Technical Requirements

You'll work with an instructor to define more explicitly the requirements for your
specific application, but the basic requirements for this project include:

* Use of an Omniauth authentication library for authenticating users with the 3rd-party
service
* Use of an external client gem to interact with the 3rd-party api

## Evaluation Criteria

The evaluation of the project is broken into three areas of focus:

1. Technical Evaluation
2. Client Satisfaction

### Technical Evaluation

#### Server-Side Application and APIs

* 4 - Project wraps/isolates external API, tests API interaction without actual connectivity dependencies
* 3 - Project wraps/isolates external API but has some gaps or external connections in its testing
* 2 - Project uses an external API, but usage is scattered across the application *OR* its usage is not effectively tested
* 1 - Project does not effectively utilize the third party API

#### Test-Driven Development

* 4 - The code demonstrates high test coverage (>80%), tests at the feature and unit levels, and does not rely on external services.
* 3 - The code demonstrates high test coverage (>70%), tests at feature and unit levels, but relies on external services
* 2 - The code demonstrates high test coverage (>60%), but does not adequately balance feature and unit tests
* 1 - The code does not have 80% test coverage

### Client Satisfaction

First and foremost, the application needs to do what it is supposed to do.

#### Features

Does it have the expected features?

* 4 - There are more features than we planned
* 3 - All planned features were delivered
* 2 - Some features were sacrificed to meet the deadline
* 1 - Major features are missing and/or the application is not deployed to production

#### Interface

Does it have a highly usable interface?

* 4 - The application is a logical and easy to use implementation of the target application
* 3 - The application covers many interactions of the target application, but has a few holes in lesser-used functionality
* 2 - The application shows effort in the interface, but the result is not effective
* 1 - The application is confusing or difficult to use
