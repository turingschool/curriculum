---
layout: page
title: FeedEngine Peer Review Script
---

## Peer Reviews

### Setup

#### Submission Page

https://github.com/JumpstartLab/feed_engine_submissions

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

* 8 minutes: Project tour driven by reviewees
* 22 minutes: Story evaluation driven by reviewers
* 15 minutes: Running/Evaluating Non-Functional requirements (details below)
* 5 minutes: Data submission and wrapup
* 5 minutes: Transition to next room

### Stories

Use the story names in the eval and follow the detailed description in the evaluated team's Pivotal Tracker.

### Non-Functional Requirements

1. Performance Under Load (0-4 points)
  * 4: Average under 120ms
  * 2: Average below 200ms
  * 0: Average over 200ms
2. User Interface & Design (0-4 points)
  * 4: WOW! This site is beautiful, functional, and clear.
  * 2: Very good design and UI that shows work far beyond dropping in a library or Bootstrap.
  * 1: Some basic design work, but doesn't show much effort beyond "ready to go" components/frameworks/etc
  * 0: The lack of design makes the site difficult / confusing to use
3. Test Coverage (0-2 points)
  * 2: Test suite covers > 85% of application code
  * 1: Test suite covers 70-84% of application code
  * 0: Test suite covers < 70% of application code
4. Code Style (0-2 points)
  * 2: Source code generates no complaints from Cane or Reek, or only whitespace/comments warning.
  * 1: Source code generates five or fewer warnings about line-length or method statement count
  * 0: Source code generates more than five warnings about line-length or method statement count

#### Notes on Performance Measuring in NewRelic
  * You should already have NewRelic open for your app
  * Click on the "Menu" button, then click on the "Map" link under the "App Server" header
  * Set your time frame to the last 60 minutes (top right corner)
  * Look for requests over 200ms; average speed of all requests.
