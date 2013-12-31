---
layout: page
title: FeedEngine
---

The goal of this project is to practice consuming web service APIs as well as publishing an API of your own. You will create a data aggregator service that pulls data and activity from other applications and publishes it through both a web interface and an API.

## Project Structure

### Learning Goals

* Allow users to consume various third-party APIs where they hold accounts.
* Publish an API, with accompanying client gem, and dog-food your API internally.
* Coordinate with project stakeholders to produce quality code and product.
* Continue to emphasize performance, UI, and overall user experience.
* Continue using TDD to drive all layers of Rails development.

### Teams and Process

Teams consist of four to five developers.

### Project Starting Point

This is a greenfield project, which means you're starting from scratch, free from the confines of legacy. Don't let it overwhelm you with its raw possibility.

Choose one team member to create a repository, set up your teammates as collaborators, and get started.

### Team Workflow

You should review and follow the [project workflow patterns for Tracker & Github]({% page_url projects/workflow %}).

### Planning & Requirements

The authoritative project requirements will be created and maintained in collaboration with your client through Pivotal Tracker. This means that the requirements for your team may differ significantly from others groups.

## Base Expectations

You're expected to complete the following functional and non-functional requirements, which describe an application and accompanying gem that function as a user activity feed, API consumer, and API producer.

You will also need to focus on an excellent user experience, and your stakeholders will emphasize that when reviewing and accepting stories during the show and tell sessions.

### Functional Requirements

The application will host multiple users and their respective feeds. 

* Feeds show posts in descending chronological order
* Feeds should be paginated to show a reasonable number of elements per page
* Various paging and scrolling approaches may be used including pagination links, infinite scroll, etc

#### Custom Concepts

Each group will work on some customized version of the FeedEngine concept. The [custom project concepts]({% page_url feed_engine_concepts.html %}) are listed separately, this document focuses on the common requirements.

The expectations in this document have *lower precedence* than those in the custom concepts or those developed in customer meetings.

### Technical Requirements

#### Caching and Data Querying

Take advantage of caching techniques and efficient data queries as used in prior projects.

* data caching
* fragment caching / Russian-Doll Caching
* query consolidation
* database optimizations (query count, using indicies, join)

#### Background Workers

Make extensive use of background workers including:

* Sending or receiving email
* Querying third-party APIs
* Processing bulk data

#### Providing an API & Gem

The full functionality of your application should be available through an API. That API should come with a wrapper gem that makes it easy to work with.

The background workers **may not** connect to your application database directly or load the Rails environment for your app. They must go through your API gem to read from and write to feeds.

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
