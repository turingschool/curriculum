---
layout: page
title: FeedEngine Peer Review Script
---

## Peer Reviews

### Setup

#### Submission Page

https://github.com/JumpstartLab/feed_engine

#### Reviewers

* Open one laptop and connect it to the screen
* Open a browser window with only http://eval.jumpstartlab.com open and logged in as one of your pair
* Open the "Peer Review for FeedEngine"

#### Reviewees

On the connected laptop, open tabs for:

* Your production application being evaluated
* Your GitHub code
* Your PivotalTracker
* Your NewRelic RPM

### Beginning the Review

You have just under an hour, make good use of it. Recommended outline:

* 5 minutes: Project tour driven by reviewees
* 25 minutes: Story evaluation driven by reviewers
* 15 minutes: Running/Evaluating Non-Functional requirements (details below)
* 5 minutes: Data submission and wrapup
* 5 minutes: Transition to next room

### Stories

Use the story names in the eval and follow the detailed description in the evaluated team's Pivotal Tracker.

### Non-Functional Requirements

1. Performance Under Load
2. User Interface & Design
3. Test Coverage
4. Code Style

#### Notes on Performance Measuring in NewRelic
  * You should already have NewRelic open for your app
  * Click on the "Menu" button, then click on the "Map" link under the "App Server" header
  * Set your time frame to the last 60 minutes (top right corner)
  * Look for requests over 200ms; average speed of all requests.
