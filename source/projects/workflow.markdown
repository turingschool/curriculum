---
layout: page
title: Project Workflow
sidebar: true
---

## Organizing a Development Team

### Pairing

Most work should be done in the context of pairing. Heed it, lest ye suffer the pain of duplicate work, gaps in functionality, hellacious merge conflicts, and the acute onset of mild to murderous rage.

Pairing structure is left up to your team. However, we strongly suggest that you rotate pairs frequently.

### Communication

Communication is paramount between you and your team members.

Try to treat communication with your team members as you would a close personal relationship:

* communicate often
* be proactive
* actively listen
* don't take your team members for granted

### Standups

It's difficult to put too much importance on good communication among your team members, but it can be difficult to find the right balance. You've probably encountered some of the pain points and pitfalls of communication with your pairs on previous projects. Try to treat communication with your team members as you ideally would any close personal relationship: communicate often, be proactive, actively listen, and don't take things for granted. All problems are less costly when they're tackled sooner rather than later.

Although there's no need to ensnare yourselves in heavy process, it is generally good to have regular, lightweight check-ins. It's a common practice for agile software teams to hold a session known as a "standup meeting", or just "standup", daily. It's called a standup because you should be able to have the entire thing standing comfortably. 

We recommend taking 5 minutes at the beginning or ending of each day to have everyone quickly cover:

* What have I worked on since last we meet?
* What am I going work on until we meet again?
* What is currently blocking me from getting work done?

### Shipping Early and Rapid Feedback

Rapid and frequent feedback about the work we produce is a central tenet of agile software development and lean product delivery. A common way of getting this feedback is by holding frequent show and tell sessions with the project stakeholders.

If the stories meet with product stakeholder approval, they will be accepted. If not, they will be rejected and you'll get feedback about why so that you can fix them and deliver them again.

## Pivotal Tracker

The Pivotal Tracker project is **the** authoritative source for the requirements of any assignment. The stories contained within it will ultimately determine how your implementation's correctness is evaluated and its points are tallied.

### Stories

* Stories communicate intent and achievement
* Good stories are easy to understand
* Like any goals, they should be [SMART](http://en.wikipedia.org/wiki/SMART_criteria)

#### A Format for Stories

```plain
As a(n) [user type]
In order to [extract business value]
When I [take some action]
  (and [take some other action])
Then I [observe an outcome]
  (and I [observe another outcome])
```

### Points! Points! Points

* 3 Points - A vague idea we don't understand
* 2 Points - A concept that we understand, but it's too big to start work on
* 1 Point - A story that is understood and ready for work

### Starting A Card

The order that cards appear in a Tracker project indicates their priority as determined by the product manager and/or project manager. No cards should be in progress unless all cards of higher priority are completed or also in progress. 

### In Progress

Any Tracker story card being worked on should be marked as in-progress by one of the members of the pair (or the solo dev) working on it. This lets other developers know not to duplicate the work going in to that card's feature. When the feature for a card is complete, that card should be marked as finished before moving on to the next card.

Although mulitple related cards may be marked as owned by a particular developer at the same time, having more than one card in progress at the same time should not be common and should likely indicate that one of the stories has been blocked by dependence on another feature.

### Story States

Story cards in Tracker go through several stages: "Not Yet Started", "Started", "Finished", "Delivered", "Accepted", and/or "Rejected".

Here are the transitions that each story card should progress through for your project.

#### Not Yet Started

The beginning state, these requirements have been gathered but no work has been done.

#### Started

The state of the card once someone begins working on it. From here, there are two paths:

* Decide not to work on the card. Put the card back into "Not Yet Started", and possibly remove your ownership.
* Complete work on the card and mark it as "Finished"

#### Finished

The card is believed to be complete and correct. The next action taken on it will be delivery. However, it may depend on other cards, and not be delivered until those are ready, too. When they are, "Deliver" all those cards.

#### Delivered

Put cards into this state when a pull request has been made that contains the commits implementing its story. Now it's time for the team to review the work, and make one of two choices.

* Accept the card's work as correct and merge it into the `master` branch.
* Reject the card's work as insufficient, incorrect, or simply not able to be merged cleanly. Include the reason in the rejection.

#### Accepted

The work has been completed and merged into master. The card should not change states again.

If you later realize a problem with that card's work, open a new bug card.

#### Rejected

There was some problem with the card preventing it from being merged to master. The card should be restarted, putting it back into the "Started" state. Correct the problem and procede through the stages again.

## Git/GitHub and Branching

Coordinating multiple concurrent work streams can be tricky without following smart source code management practices. That said, there is a tendency to over-complicate the process of managing the branching and merging of features in a project.

### Premise

We're going to follow a relatively simple workflow that gets the job done well without overcomplicating it, and has an added benefit of encouraging regular communication between coordinating parts of the team.

### Workflow

#### Establish a `master`

We start with a `master` branch, in this case, the branch we inherit from the previous project, that remains stable and **deployable at all times**. 

#### Create Feature Branches

To add a new feature, say, adding a background job for sending email, we would create a new feature branch called `email_background_jobs` and begin doing our work there.

#### Completing a Feature

When we think we have completed the feature, we pull in any new updates from the stable master branch into our feature branch and then push that feature branch up to GitHub. Once there, we open a GitHub pull request to pull our new feature into `master`

#### Evaluating a Feature

At this point, the other persons on the team will look at the pull request to review the code and decide if it is ready to be merged into `master`. 

If so, someone designated by the team can perform the merge, updating `master`. Now everyone that has work on a new feature, not yet in master, will update their in-progress feature branch to pull in the lastest code from `master`. In this way, we maintain a stable, deployable, up-to-date branch, `master`, while making progress on new features in branches that stay reasonably up to date. This reduces merge conflicts.

### References

For a similar but more advanced version of this workflow, see: http://reinh.com/blog/2009/03/02/a-git-workflow-for-agile-teams.html

