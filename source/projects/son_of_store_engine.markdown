---
layout: page
title: SonOfStoreEngine
---

In this project you'll extend your previous work on StoreEngine to make it multi-tenant, so that it can run multiple storefronts at the same time, make it more robust and perform gracefully under load, and make it more pleasant to deal with both as a user of its services and as a developer extending or maintaining it.

<div class="note">
<p>Consider the requirements fluid until 11:59PM, Sunday, April 29th.</p>
</div>

### Learning Goals

* Coordinate as a team to produce quality code and product.
* Extend and improve an existing codebase and design while adding substantial functionality.
* Practice techniques for scalable application architecture including caching, pre-rendering, database optimization, and background workers.
* Continue using TDD to drive all layers of Rails development.
* Continue to improve User Interface concepts and skills.

### Teams and Process

Teams consist of four developers. The group rosters are:

* Mike Silvis, Chris Anderson, Michael Verdi, Elise Worthy
* Melanie Gilman, Andrew Thal, Daniel Kaufman, Conan Rimmer
* Jan Koszewski, Jonan Scheffler, Nisarg Shah, Mary Cutrali
* Andrew Glass, Mark Tabler, Austen Ito, Tom Kiefhaber
* Christopher Maddox, Horace Williams, Jacqueline Chenault, Michael Chlipala
* Charles Strahan, Travis Valentine, Darrel Rivera, Edward Weng

#### Project Starting Point

You must as a group decide to move forward with a codebase from the previous StoreEngine project that one of your group members produced. Once you've chosen the StoreEngine codebase you want to use, there are a few pieces of set up that must be done.

1. If the codebase your team is using is of your previous implementation of StoreEngine, you must create a fork of [JumpstartLab's SonOfStoreEngine project](https://github.com/JumpstartLab/son_of_store_engine), merge your previous StoreEngine code into it, and push it to your fork.
2. Create a git tag called `store_engine_v1` that denotes the starting point of the code with the command `git tag -a store_engine_v1` and push it to your new SonOfStoreEngine repo on GitHub with the command `git push --tags`. (Make sure you're pointed at the correct remote, i.e., your forked repo.)
3. Add each of your other team members as collaborators on the new repo.

#### Authoritative Requirements - Important!

In addition to outlining the project requirements in this document, the features to be implemented are captured as user stories in a Pivotal Tracker project for each team. The Pivotal Tracker project _specifically for your team_ should be considered the **canonical** version of the requirements, and questions or requests for clarification about the requirements should be raised as comments in the appropriate Tracker stories. More about Tracker workflow is covered at the end of this document.

This does mean that the requirements for your team may drift slightly from others' over the duration of the project. Keep this in mind. If we encounter recurring questions or ambiguity around a particular requirement, or find legitimate error with one, we will make all teams aware of the clarifications or changes.

#### Shipping Early

Rapid and frequent feedback about the work we produce is a central tenant of agile software development and lean product delivery. We're incorporating this reality in the same way that most agile software teams do in practice, by holding a show and tell session with the project stakeholders early on in the process. We'll do this to verify that the work done so far is in line with the product manager's expectations and to sanity check your team's progress toward delivery.

This show and tell meeting will be on the afternoon of April 26th and last about 15 minutes. Please verify this on the calendar. To emphasize the importance of this session, there will be a release milestone card in Pivotal Tracker that indicates about how many features should be completed by then. There will be 2 points of your total score assigned to meeting the milestone.

Prior to the meeting, please create a git tag for your most recent commit (or a commit that covers the stories relevant to the show and tell milestone) that we can reference it. Use the command `git tag -a show_and_tell` to create it and push it to your repo with `git push --tags`.

#### Pairing and Rotation

The intention remains from previous projects that most work be done in the context of pairing. In fact, more heed should be paid to the practice because with teams of four it becomes increasingly more important to coordinate work streams and changes to the code base. Heed it, lest ye suffer the pain of duplicate work, gaps in functionality, hellacious merge conflicts, and mild to murderous rage. The Pivotal Tracker and GitHub/git branching workflows discussed at the end of this document will help you stay sane.

Choosing the pairing is left to the teams, and rotating pairs is allowed. Do not rotate pairs more frequently than daily, however, and it is recommended that in practice pairings remain stable for at least a few days at a time. Rotating pairs is not a requirement but probably a good idea.

#### Communication and Standups

It's difficult to put too much importance on good communication among your team members, but it can be difficult to find the right balance. You've probably encountered some of the pain points and pitfalls of communication with your pairs on previous projects. Try to treat communication with your team members as you ideally would any close personal relationship: communicate often, be proactive, actively listen, and don't take things for granted. All problems are less costly tackled sooner rather than later.

Although there's no need to ensnare yourselves in heavy process, it is generally good to have regular, lightweight check-ins. It's a common practice for agile software teams to hold a session known as a "standup meeting", or just "standup", daily. It's called a standup because you should be able to have the entire thing standing comfortably. We recommend taking 5 minutes at the beginning or ending of each day to have everyone quickly cover two things: what I'm working on, and what problems have I run into getting it done.

It seems a small thing, and fortunately it is, but it provides a lot of value for its minor cost.

### Restrictions &amp; Outside Code

Project implementations must move forward with the codebase they start with. You can and should evolve, refactor, and clean up the code you inherit, including deleting redudant, broken, or obsolete code, but you should not throw out the previous work wholesale.

Furthermore, at no point should a regression in existing functionality be introduced, except when explicitly called for by new requirements.

### Base Expectations

You are to extend StoreEngine so that it can handle running multiple stores, each with their own name, unique URL, product stock, order queue, and administrators simultaneously. Each store must maintain the functionality previously required for the StoreEngine project in addition to the new requirements or enhancements defined here. At least for the base requirements, all StoreEngine stores share single sign-on.

You are to put effort into the application's performance under load, in order to accommodate the additional stores, traffic, users, and revenue that this functionality with generate. To do so, you will implement various caching techniques and introduce background workers into the system.

You will also need to focus on an excellent user experience.

For the sake of the following requirements, where necessary, assume the domain for the StoreEngine application to be `storeengine.com`. In practice, you may use whatever domain you choose, including a `herokuapp.com` one.

### Functional Requirements

Individual stores can be accessed by specifying their store name as the path prefix.

* So for example, given a store named _Slick Bike Shoppe_:
    * I could visit `http://storeengine.com/slick-bike-shoppe` and see products and branding for _Slick Bike Shoppe_ only
    * I could browse its categories at `http://storeengine.com/slick-bike-shoppe/categories`

#### Public Visitor

As a public visitor to a StoreEngine store I can:

* Create a single sign-on account for use with all StoreEngine stores
    * Account creation always results in a welcome email being sent
* Log in to the StoreEngine system with single sign-on for all stores
* First-time user experience:
    * I may proceed through the process of adding an item to my cart and checking out
    * I may then create an account or simply enter my email, billing, shipping, and credit card info
        * If I create an account, I will immediately resume the checkout process
        * If I do not create an account
            * My order confirmation email will include a link with a unique hash to view my order details
            * The unique link will be displayed on the confirmation page for the order

#### Authenticated Store Shopper

As an authenticated shopper I can:

* Manage my account information on all stores centrally on my account page
    * Shipping addresses
    * Billing addresses
    * Credit cards associated with my account
    * Basic account info like name and password, as managed previously in StoreEngine v1
* Create a new store, pending admin approval, via my account page
  * Specify basic store info: name, URL identifier, and description
  * Automatically become store admin
* Maintain a separate shopping cart for each store I browse
* Make purchases on any store I am browsing
    * Recieve an email confirmation of my order with basic order details and a link to the order detail page
* View and manage my purchase history centrally

#### Authenticated Store Stocker

As an authenticated store stocker, I can:

* Add products, edit products, and retire products in my store only

#### Authenticated Store Administrator

As an authenticated store admin, by using a dedicated admin area, I can:

* Do everything a stocker for my store can do
* Update the details of my store such as the: name, URL identifier, and description
* Add or remove store stocker accounts
    * Adding a stocker account automatically emails the account holder with a link to confirm their account and status
* Add or remove other admins for the store
    * There can never be fewer than 1 admin for a store
* Perform the admin actions available to administrators in the current StoreEngine version

#### Authenticated StoreEngine Administrator

As an authenticated Administrator, I can:

* Approve or decline the creation of new stores
* Take a store "offline" temporarily so that attempting to browse it redirects its root and displays a maintenance message
    * Bring an offline store back online
* Override/assist store admins in any functionality available to them via the admin portion of their store pages

#### Friendly validation and error messages

Any submitted forms should validate the submitted data as is appropriate and display friendly error messages when allowing the user to resubmit

### Non-Functional Requirements

The non-functional requirements are based around maintaining or improve site performance as data and users scale up. The primary metric for this is in keeping response time&mdash;the elapsed time between a browser making a web request and when a "usable" page has been loaded&mdash; below some threshold. 200ms is probably a good first-pass target for the upper end of your request times. It's also important to consider consistency of response times in a holistic view of the user experience. Maintaining sub-100ms times for 9 requests but allowing the 10th to take a full second should be considered a reduced user experience.

Implement two common methods for reducing response times: caching and background workers.

#### Caching

Response time and caching are critically imporant. Your improved StoreEngine should make significant use of:

* data caching
* fragment caching
* page caching
* query consolidation
* database optimizations (query count, using indicies, join)

Using an external data store such as Redis when appropriate is encouraged. If you are running on Heroku, take a look at the [RedisToGo addon](https://addons.heroku.com/redistogo).

#### Out of Process Work (Background Workers)

Use background workers as appropriate, but specifically, send all email in a background process.

### Example Data

The example data or, more likely, scripts to generate it will be made available by Wednesday, April 25th, by 11:59 PM.

The data will look roughly like the following:

* 3 stores, with necessary attributes
* Various shoppers, store admins, stockers, and StoreEngine global administrators
* On the order of 100,000 products for the stores

These details in particular should be considered fluid until the 4/25, but this list is intended to be representative.

### Extensions

In this project you as developers are expected to take a more active role in shaping the product. Although there are a few potential extensions proposed at the outset, you are encouraged to propose additional extensions, in the form of new features and user stories describing them, to your product manager and project manager, namely, Jeff and/or Matt. (Jeff and Matt will at various times play both roles at once.)

If you have an idea for a killer feature for your application, pitch it to your stakeholders for refinement. If they are convinced of its value, they'll work with your team to create one or more user stories in Pivotal Tracker and prioritize those stories in the context of the rest of the requirements. You may be able to convince them to prioritize your feature ahead of current base requirements if it is sufficiently compelling or necessary. The product manager and project manager will work with you to determine the point value of any extension user stories.

Here are some possible example extensions, but you are encouraged to dream up your own as well:

#### Custom CSS per store

Provide a mechanism so that store administrators may provide custom a CSS sheet to change the appearance of their store. This custom styling should not affect any other store's appearance.

#### Use Sub-Domains To Distinguish Stores

In order to give greater precedence and more SEO-juice to each individual store, as well as pave the way for stores to use custom domains, change your application so that, instead of using a path prefix per request to identify individual stores in the system, use unique sub-domains instead.

So instead of `http://www.storeengine.com/slick-bikes/products` pointing to the products belonging to the store _Slick Bikes_, allow `http://slick-bikes.storeengine.com/products` to be used instead.

#### Separate Per-store Sign In

So that each store can optionally create the impression of being independent by cordoning off their user experience, it should be possible for a store to require a unique sign on and account management that is not shared across stores. Shipping, billing, credit card info, and order history must be uniquely managed through this store's management interface alone. The user should be able to provide an email address already in use in the StoreEngine system.

How would this work if stores can use custom domains?

### Evaluation Criteria

In SonOfStoreEngine, there are MOAR POINTS to earn. However, the point allocation has been refined from the previous project, reflecting lessons learned. The points should better reward energy spent producing value.

The evaluation of the project is broken into three areas:

1. Evaluation of the user stories for each feature of the application. (40 points possible for the basic requirements, up to 12 additional extension points available)
2. Code critique and review by instructors and LivingSocial engineers according to rubric. (42 points possible)
3. Non-functional requirements and metrics according to rubric. (18 points possible)

The breakdown puts a lot of emphasis on the effort put into the quality of the code for your app. But also note that it's possible to earn 12 "bonus" points by building extensions. This means that "full" credit can be earned without building any extensions and that extensions can make up for points lost elsewhere.

#### Evaluation of User Stories for Base and Extensions

Each user story for the base expectations will be worth the point value they have been assigned in Pivotal Tracker. Points for a story will be awarded if that story can be exercised without crash or error.

Extension stories will also be worth their story point value in Tracker, but no story's points will count toward the total score unless all other stories of higher priority have been delivered. This means, in effect, that you must have delivered the base expecations to receive credit for any extensions.

#### Code Critique by Instructors and Engineers

The rubric used to review each team's code, taken as the latest commit in the `master` branch of your GitHub repo at the time the project is due, is still fluid but will be nailed down by Wedensday, April 25th at 11:59 PM. It is known that reviewers will compare the state of the code before the project began and the state of the code at the end, looking for improvement and evolution. Because of this, it may make sense to choose a codebase to start with that falls in the upper-middle of quality and functionality so that you have a clear ideas for and good opportunities to clean up the code. But then again, it may not.

The high-level outline for the rubric is:

1. Good object-oriented and general application design practices, such as SOLID and DRY. (10 points)
2. Use of Ruby and Rails idioms and features. (6 points)
3. Good testing practices and coverage. (8 points)
4. Improvement and evolution of the code, use of refactoring. (4 points)
5. Adherence to the intent of project-specific non-functional requirements, such as background workers and caching. (10 points)
6. Application correctness and robustness. (4 points)

The rubric will be applied by at least two reviewers and the mean score of their totals will be used. Please review [the full rubric](http://tutorials.jumpstartlab.com/projects/son_of_store_engine_code_review_rubric.html) and keep it in mind as you're building your app.

#### Non-Functional Metrics

Here are the criteria for the non-functional requirements. Please read this rubric carefully, as not all point values are linear.

1. Performance Under Load (0-5 points)
  * 5: 90% or more of requests < 120ms and all requests < 200ms
  * 3: All requests sub 200ms
  * 2: 90% or more of requests < 200ms and all requests < 500ms
  * 0: more than 10% requests > 200ms or any requests > 1s
2. User Interface & Design (0-4 points)
  * 4: WOW! This site is beautiful, functional, and clear.
  * 2: Very good design and UI that shows work far beyond dropping in a library or Bootstrap.
  * 1: Some basic design work, but doesn't show much effort beyond "ready to go" components/frameworks/etc
  * 0: The lack of design makes the site difficult / confusing to use
3. Test Coverage (0-2 points)
  * 2: Testing suite covers > 85% of application code
  * 1: Testing suite covers 70-84% of application code
  * 0: Testing suite covers < 70% of application code
4. Code Style (0-2 points)
  * 2: Source code generates no complaints from Cane or Reek, or only whitespace/comments warning.
  * 1: Source code generates five or fewer warnings about line-length or method statement count
  * 0: Source code generates more than five warnings about line-length or method statement count
5. Show And Tell Milestone (0-2 points)
  * 2: Delivered the features that were prioritized above the show and tell milestone before the meeting
  * 0: Did not deliver all features prior to show and tell

Additionally, each member of the team has 3 points that they may distribute, asymmetrically if they wish, to the other members of their team. Award the points based on each member's overall effort and contribution on the project. If you think all your teammates contributed comparably, award 1 point to each of them.

### Evaluation Protocol

**NOTE:** The following outline is still very rough.

Projects will be evaluated the afternoon of Wednesday, May 2nd at 1:00 PM.

* *1:00 - 2:30* User Story Evaluations
* *2:30 - 3:45* Project Presentations and Walkthroughs
* *3:45 - 4:00* Best Overall Shipper Awarded
* *4:00 - 4:30* Wrapup / Retrospective

#### Tagging the Final Release

Prior to 12:30 PM on the 2nd, please create a git tag to mark the commit signfying the release of your project to "production". Use the command `git tag -a release_v1` to create it and push it to your repo (with `git push --tags`).

#### User Story Evaluations

In this section you'll break into two groups of three teams each.

* Group 1 in the main room
  * Teams 1, 2, 3
* Group 3 in the fishbowl
  * Teams 4, 5, 6

Use the following protocol:

* Each pair presents their code/project for 5 or fewer minutes. Make sure to highlight any non-standard features or extensions and highlight and custom prioritizations in your Tracker project.
* Teams then evaluate both other projects for 30 minutes each:
    * Work through the evaluation user stories
    * Run the code metrics
    * Subjectively measure the UI and design
    * Submit one evaluation per project http://eval.jumpstartlab.com (so your team submits a total of two evals, one for each project you examine)

Be sure to split the responsibilities that can be done in parallel, but have at least two team members pairing on walking through the user stories.

While this is happening, code reviewers will be doing final assessments and scoring of the codebases.

#### Project Presentations and Walkthroughs

Each team will present to the whole group and guests. You have seven minutes to show off:

* The basics
* What makes your project exceptional?
* What code or design refectoring did you perform, or testing improvements did you make to better the codebase?
* Anything else you're proud of?

Audience members will then be invited to try out your store for five minutes.

#### Best Overall Shipper Awarded

Based on tallying various scores, the end product and its delivery, and the reading of tea leaves, one team will be chosen as the Best Overall Shipper of code.

#### Wrapup / Retrospective

* Award your team points to each of your teammates
* What was challenging about this project?
* What came easy?
* What would you have done differently?
* Did you reach your goals? Why or why not?
* Any lessons learned for the next project?

### Required Workflows In Detail

#### Pivotal Tracker

As mentioned above, the Pivotal Tracker project for your multi-tenant StoreEngine project is **the** authoritative source for the requirements of the project. The stories contained within it will ultimately determine how your implementation's correctness is evaluated and its points are tallied.

The order that cards appear in a Tracker project indicates their priority as determined by the product manager and/or project manager. No cards should be in progress unless all cards of higher priority are completed or also in progress. At **no time** may any member of your implementation team change the prioritization of user stories in Tracker. Only the product or project managers may do so.

Any Tracker story card being worked on should be marked as in-progress by one of the members of the pair (or the solo dev) working on it. This lets other developers know not to duplicate the work going in to that card's feature. When the feature for a card is complete, that card should be marked as finished before moving on to the next card.

Although mulitple related cards may be marked as owned by a particular developer at the same time, having more than one card in progress at the same time should not be common and should likely indicate that one of the stories has been blocked by dependence on another feature.

Story cards in Tracker go through several stages: "Not Yet Started", "Started", "Finished", "Deliverd", "Accepted", and/or "Rejected".

Here are the transitions that each story card should progress through for your project:

* "Not Yet Started" - The beginning state.
* "Started" - The state of the card once someone begins working on it. From here, there are two paths:
    * Decide not to work on the card. Put the card back into "Not Yet Started", and possibly remove your ownership.
    * Complete work on the card and mark it as "Finished"
* "Finished" - this means that the card is believed to be complete and correct. The next action taken on it will be delivery. However, it may depend on other cards, and not be delivered until those are ready, too. When they are, "Deliver" all those cards.
* "Delivered" - Put cards into this state when a pull request has been made that contains the commits implementing its story. Now it's time for the team to review the work, and make one of two choices.
    * Accept the card's work as correct and merge it into the `master` branch.
    * Reject the card's work as insufficient, incorrect, or simply not able to be merged cleanly. Include the reason in the rejection.
* "Accepted" - This means the work has been completed and merged into master. The card should not change states again.
    * If you later realize a problem with that card's work, open a new bug card.
* "Rejected" - There was some problem with the card preventing it from being merged to master. The card should be restarted, putting it back into the "Started" state. Correct the problem and procede through the stages again.

Understand that this workflow is almost certainly a bit different than what you'll encounter on the engineering teams. It may even be different than for future Hungry Academy projects. You may have to retrain yourselves, but that's okay. If someone yells at you, blame your Hungry Academy instructors.

#### Git/GitHub and Branching

Coordinating multiple concurrent work streams can be tricky at best without following smart source code management practices. That said, there is a tendency in the wild to over-complicate the process of managing the branching and merging of features in a project.

We're going to follow a relatively simple workflow that gets the job done well without overcomplicating it, and has an added benefit of encouraging regular communication between coordinating parts of the team.

We start with a `master` branch, in this case, the branch we inherit from the previous project, that remains stable and deployable at all times. To add a new feature, say, adding a background job for sending email, we would create a new feature branch called `email_background_jobs` and begin doing our work there.

When we think we have completed the feature, we pull in any new updates from the stable master branch into our feature branch and then push that feature branch up to GitHub. Once there, we open a GitHub pull request to pull our new feature into `master`

At this point, the other persons on the team will look at the pull request to review the code and decide if it is ready to be merged into `master`. If so, someone designated by the team can perform the merge, updating `master`. Now everyone that has work on a new feature, not yet in master, will update their in-progress feature branch to pull in the lastest code from `master`. In this way, we maintain a stable, deployable, up-to-date branch, `master`, while making progress on new features in branches that stay reasonably up to date. This reduces merge conflicts, and that is a Good Thing&trade;.

<insert image of workflow here>

Additional explanation, including slightly advanced optional components, and a live demonstration of the workflow is forthcoming. For a similar but more advanced version of this workflow, see: http://reinh.com/blog/2009/03/02/a-git-workflow-for-agile-teams.html

