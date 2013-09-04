---
layout: page
title: FeedEngine
---

The goal of this project is to practice consuming web service APIs as well as publishing an API of your own. You will create a Tumblr or Friendfeed-like system that lets users publish a timeline of activities that they have either created on the site or that are activity imported from another third-party site such as GitHub, Twitter, and Instagram. In addition, you will provide an API for reading and writing to a user's activity stream, and publish a gem to let other application developers consume your API.

<div class="note">
<p>This project is open source. If you notice errors, typos, or have questions/suggestions, please <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/projects/feed_engine.markdown">submit them to the project on Github</a>.</p>
</div>

### Learning Goals

* Allow users to consume various third-party APIs where they hold accounts.
* Publish an API, with accompanying client gem, and dog-food your API internally.
* Coordinate with project stakeholders to produce quality code and product.
* Continue to emphasize performance, UI, and overall user experience.
* Continue using TDD to drive all layers of Rails development.

### Teams and Process

Teams consist of three to four developers.

#### Project Starting Point

This is a greenfield project, which means you're starting from scratch, free from the confines of legacy. Don't let it overwhelm you with its raw possibility.

Choose one team member to create a repository, set up your teammates as collaborators, and get started.

#### Workflow

You should review and follow the [project workflow patterns for Tracker & Github]({% page_url projects/workflow %}).

#### Authoritative Requirements

As in the previous project, the authoritative project requirements will be created and maintained in your team's  Pivotal Tracker project. Again, this means that the requirements for your team may differ significantly from others' over the duration of the project.

## Customized Concepts

Each group will work on some customized version of the FeedEngine concept. The [custom project concepts](http://tutorials.jumpstartlab.com/projects/feed_engine_concepts.html) are listed separately, this document focuses on the common requirements.

The expectations in this document have *lower precedence* than those in the custom concepts or those developed in customer meetings.

## Base Expectations

You're expected to complete the following functional and non-functional requirements, which describe an application and accompanying gem that function as a user activity feed, API consumer, and API producer.

You will also need to focus on an excellent user experience, and your stakeholders will emphasize that when reviewing and accepting stories during the show and tell sessions.

### Friendly validation and error messages

Any submitted forms should validate the submitted data as is appropriate and display friendly error messages when allowing the user to resubmit

### Functional Requirements

The application will host multiple users and their respective activity feeds. Think Tumblr, but with service API support both as a publisher and consumer.

* Feeds show posts in descending chronological order
* Feed items should be paginated to show a reasonable number of elements per page
    * Various paging and scrolling approaches may be considered valid

#### Public Visitor

As a public visitor to FeedEngine I can:

* View any public user feed at &lt;user-feed-subdomain&gt;.example.com
* Indicate your appreciation for a single feed item by clicking its "Points!" link
    * Be prompted to sign up or log in when the link is clicked
    * Each feed item shows its total Points! as part of its display
* Visit `example.com/login` to log in to my already existing account
    * I should be redirected to my `example.com/dashboard`
* Request a password reset and receive a login link via email
* Visit `example.com/signup` to create an account and set up my activity feed
    * Provide an email address, password and password confirmation, and display name
    * Account creation always results in a welcome email being sent
    * Setting up my activity feed allows me to add account info for Twitter, GitHub, and Instagram to add activities from those sources to my feed
    * Upon completion of these steps I have set up my feed and I am viewing my dashboard

#### Authenticated Feed User

As an authenticated user I can:

* View any public user feed at &lt;user-feed-subdomain&gt;.example.com
    * Refeed that feed, so you republish its subsequent posts in your feed
* View any private user feed to which I have been given access
    * Visit a private feed to which I don't have access and request access
* Indicate your appreciation for a single feed item by clicking its "Points!" link
    * Each feed item shows its total Points! as part of its display
* Refeed a single feed item so that it shows up in your feed, attributed to the original creator
* Visit `/dashboard` to manipulate my feed
    * Post a new message (up to 512 characters in length), post a link to another web page with optional comment (256 characters max), or post a photo with optional comment (256 characters max)
    * View a 'Visibility' tab to make my feed public or private
        * If my feed is private
            * I will see a list of approved viewers whose approval I may revoke
            * I will see a list of pending viewer requests whose approval I may grant
    * View a notification if I have pending viewer requests with a count
    * View a 'Linked Services' tab to manage my service subscriptions
        * Unlink or link with a Twitter account
        * Unlink or link with a GitHub account
        * Unlink or link with an Instagram account
    * View a "Refeeds" tab to manage my refeeded accounts
        * See a list of feeds I am refeeding with a link to stop refeeding them
    * View an "Account" tab where I can:
      * Change my password by providing a new password and confirmation
      * Update my email address
          * A confirmation email should be sent
      * Disable my account

### Service Integration Specifics

The exact services that you integrate with will vary by group, but here are a few guidelines.

Importing the latest items should be done on a sensible interval. Once an item has been imported from a third-party service for a user, it should remain in that user's feed history so long as they have a FeedEngine account.

#### Twitter

* Import new tweets from the user's timeline [documented here](http://rdoc.info/gems/twitter) and [here](https://dev.twitter.com/docs)
* Optionally create a tweet linking to any new post created directly on the feed

#### GitHub

* Import new events from their authenticated timeline (specifically the `CreateEvent`, `ForkEvent`, and `PushEvent` [documented here](http://developer.github.com/v3/events/types/))

#### Instagram

* Import new images from the user's feed, [documented here](http://instagr.am/developer/endpoints/users/#get_users_feed)

#### YouTube

* When following a specific user, embed any new videos that they post
* When following a search term, embed any new matches for the search

#### Etsy

* When following a specific store, embed any new items carried offered by that store
* When following a specific user, embed any new favories they add

#### FourSquare

* When following a specific user, embed any new check-ins they create and any new achievements

#### Tumblr

* When following a specific page, embed any new content

#### FeedEngine

* Import direct FeedEngine items (text, links, images) from a feed, [documented here]({% page_url projects/feed_engine %})

### Ruby Developer Consuming a FeedEngine feed

The API should produce JSON output and expect JSON payloads for creation and updating actions.

As an authenticated API user (using an API token) I can:

* Read any publically viewable feed via GET
    * Read only feed items created directly on FeedEngine (text, link, image)
* Read any private feed to which the user has access via GET
    * Read only feed items created directly on FeedEngine (text, link, image)
* Publish a text, link, or photo feed item, given the appropriate arguments, via POST
* Refeed another user's feed item, given its `id`

### Non-Functional Requirements

The non-functional requirements are based around maintaining or improve site performance as data and users scale up. The primary metric for this is in keeping response time&mdash;the elapsed time between a browser making a web request and when a "usable" page has been loaded&mdash;below some threshold. 200ms is probably a good first-pass target for the upper end of your request times.

Implement two common methods for reducing response times: caching and background workers.

#### Caching and Data Querying

Take advantage of caching techniques and efficient data queries as used in prior projects.

* data caching
* fragment caching
* page caching
* query consolidation
* database optimizations (query count, using indicies, join)

#### Out of Process Work (Background Workers)

Use background workers as appropriate. Send all email in a background process. Querying third-party APIs and processing the resulting data is very slow, and doesn't make sense to do in-process. (In-process means during the request-response cycle.) Create background jobs that can import data from third-party APIs and save the data as part of user's activity feed.

#### Dogfood API Consumption

Dogfooding is a term used to describe using internally one's own public facing product or tool in order to validate its usability and completeness. In this case, the dogfood is your published API and accompanying gem. When a user sets up their feed to include the feeds of other FeedEngine users, the system must consume those feeds via your gem.

To enforce this, the background workers **may not** connect to your application database directly, or load the Rails environment for your app. They must go through your API gem to read from and write to users' feeds.

### Extensions

In this project you as developers are expected to take a more active role in shaping the product. You are encouraged to propose additional extensions, in the form of new features and user stories describing them, to your product manager and project manager.

If you have an idea for a killer feature for your application, pitch it to your stakeholders for refinement. If they think it's awesome, they'll work with your team to create one or more user stories in Pivotal Tracker and prioritize those stories in the context of the rest of the requirements. You may be able to convince them to prioritize your feature ahead of current base requirements if it is sufficiently compelling or necessary. The product manager and project manager will work with you to determine the point value of any extension user stories.

Here are two possible extensions:

#### API Consumption Swap

You're required to provide a web service API that exposes reading and writing the activities your users publish directly on their FeedEngine feed. Your friendly competitors are, too. Partner with another team to add your projects to each others respective list of services your users may integrate with.

#### Fully-fledged API Gem

Fulfill the following, more complete API requirements:

The API should produce JSON output and expect JSON payloads for creation and updating actions.

As an anonymous API user I can:

* Read any publically viewable feed via GET

As an authenticated API user (using an API token) I can:

* Read any publically viewable feed via GET
    * Read only feed items created directly on FeedEngine (text, link, image)
    * Read all feed items (directly created and imported)
* Read any private feed to which the user has access via GET
    * Read only feed items created directly on FeedEngine (text, link, image)
    * Read all feed items (directly created and imported)
* Publish a text, link, or photo activity item, given the appropriate arguments, via POST
* Refeed another user's feed item, given its id
* Update an existing post with new information via PUT
* Make my feed public or private via PUT
* Given a private feed
    * Get a list of approved viewers via GET
    * Remove an approved viewer via DELETE
    * Add an approved viewer via POST

### Evaluation Criteria

The evaluation of the project is broken into three areas:

1. Evaluation of the user stories for each feature of the application. (44 points possible for the basic requirements, up to 12 additional extension points available)
2. Code critique and review by instructors and engineers
3. Non-functional requirements and metrics

The breakdown puts a lot of emphasis on the effort put into the quality of the code for your app. But also note that it's possible to earn 12 "bonus" points by building extensions. This means that "full" credit can be earned without building any extensions and that extensions can make up for points lost elsewhere.

#### Evaluation of User Stories for Base and Extensions

Each user story for the base expectations will be worth the point value they have been assigned in Pivotal Tracker. Points for a story will be awarded if that story can be exercised without crash or error.

Extension stories will also be worth their story point value in Tracker, but no story's points will count toward the total score unless all other stories of higher priority have been delivered. This means, in effect, that you must have delivered the base expecations to receive credit for any extensions.

#### Code Critique by Instructors

The review will be performed on the Git tag `release_v1`, which must be pushed to your project's GitHub repo by 30 minutes prior to project presentations on the due date. Use the command `git tag -a release_v1` to create it and push it to your repo (with `git push --tags`).

The high-level outline for the evaluation is:

1. Good object-oriented and general application design practices, such as SOLID and DRY.
2. Use of Ruby and Rails idioms and features.
3. Good testing practices and coverage.
4. Meeting non-functional requirements, such as background workers and API dog-fooding.
5. Application correctness and robustness.

#### Non-Functional Metrics

Here are the criteria for the non-functional requirements.

1. Performance Under Load
2. User Interface & Design
3. Test Coverage
4. Code Style

For details on how these will be evaluated, please see the [Evaluation Protocol]({% page_url projects/feed_engine_peer_review %})
