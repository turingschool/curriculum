---
layout: page
title: FeedEngine Custom Concepts
sidebar: true
---

## Hot Streak - Tracking Daily Progress

Today it seems like we're gamifying everything. Whether it's your consecutive days of commits on GitHub or the activity from a Fitbit, there's data everywhere.

Hot Streak allows you to aggregate those datapoints in one place.

#### GitHub Integration

Connect your GitHub account and Hot Streak will monitor your commits. Of course it'll display your current streak, just like GitHub does itself.

But, with Hot Streak, you can also set reminders and thresholds. Say it's not enough for you just to have "activity", you want to hit at least three commits per day. Hot Streak lets you set that threshold.

Or, say it's 9pm and you haven't had any activity that day. Hot Streak will send you a text reminder every 20 minutes until you fulfill the goal or dismiss the reminder.

#### FitBit/RunKeeper Integration

Set a daily exercise goal, and Hot Streak will chart your achievement. And, just like with GitHub, it'll send you reminders at specified times if your streak is in danger.

And, for even better coaching, you can set intermediate thresholds. Say your FitBit goal is 10,000 steps per day. A reminder at 9pm is going to be too late. With Hot Streak you can set a checkpoint, like 4,000 steps by noon. Miss that checkpoint and Hot Streak will send you a reminder, helping you get your day on track.

## SocialSmarts

Your business has a twitter account -- now what?

SocialSmarts is the tool to help you get the most out of it. SocialSmarts...

* Displays your full Twitter feed, especially your mentions
* Augments tweets with the user's Klout score
* Plots recent activity on a Google Map
* Helps you track which tweets need follow up and which are resolved
* Allows you to schedule tweets for future posting
* Finds your most influential followers
* Supports "interaction goals", for organizations that seek to post at least X tweets every Y time period

Your customers are talking. SocialSmarts helps you listen.

## Travel Hub - Aggregating Travel Memories

Traveling in a group is fun, but it's difficult to share all your different photos and memories. Travel Hub helps you build lasting memories. After creating an account on the site I can:

* Create a trip with start and end dates
* Visit the events feed for that single trip
* Register one or more Instagram usernames to track
* Register one or more Twitter usernames to track
* Register one or more FourSquare usernames to track

Then, while on the trip, any events from those three sources are automatically added and visible both within the feed for that individual trip and my aggregate feed of all my trips.

## Agility Board - An Event Tracker for Software Teams

Keeping track of agile software projects is hard. Let's create an activity feed that can bring it all together. After creating an account on the site I can:

* Create a project
* Register one Pivotal Tracker project
* Register one GitHub project
* Integrate with TravisCI
* Generate a unique email address for this feed

Then, while working on the project:

* Changes from tracker (stories added, completed, comments, etc) are reflected in the feed
* Activity from GitHub (pushes, issues, etc) is reflected in the feed
* Any emails sent to the project-specific address show up in the feed
* Build status updates from TravisCI show up in the feed

Given that our team is super-agile and constantly pushing code, these events have smart aggregation. If the same person pushes code three times within a few hours, Agility Board only displays one event in the stream that links to all three commits. Or delivering two features in Tracker shows up as just one entry with two links.

## Tuneline - A Music Timeline

Let's create an aggregator that can pickup all the data from our music listening trends. After creating an account on the site I can:

* Register one or more Last.fm accounts
* Register one or more Twitter accounts
* Register one or more YouTube channels
* Register one or more SoundCloud accounts

Then, as go through my daily listening, the feed will reflect:

* My "scrobbles" from Last.fm
* Tweets from the followed accounts that have the hashtag `#tl`
* YouTube videos posted to the followed channels
* New songs added to the SoundCloud accounts

As much as possible, the content should be accessible right in the feed. I don't want to click over to YouTube to play a video, I want to just click "Play" right in the feed.

## Photoline - A Photo Timeline

We love photography. Let's create an aggregator where a user can:

* Register one or more Instagram accounts or tags
* Register one or more Flickr accounts or keywords
* Register one or more 500px accounts or categories

Then, whenever a photo is posted to the matching account, aggregate it into the feed. Given that this site is all about the photos, it really needs to have a beautiful UI. The photos should be big, maybe full-bleed, so the emphasis is on the image.

## Fanboard - An Aggregator for Sports Fans

Sports fans want to keep track of their favorite teams and players across multiple sources.Fanboard allows you to create multiple feeds and, in each feed, add relevent search terms like "RedSox" and "David Ortiz" along with specific Twitter and Instagram accounts like `@davidortiz`.

When you view a Fanboard feed, you'll get the latest matching stories and boxscores that contain any of the watched terms from the following sources:

* ESPN
* USAToday
* NBA.com
* NFL.com
* MLB.com

## Runline - Running with Friends

Achieving a healthy lifestyle and fitness goals can be difficult without community support.  This app will help keep you motivated by joining your fitness data with your friends.

The app pulls data from:

* MapMyFitness
* RunKeeper
* TheDailyMile
* FitBit

With that data, as a registered user I:

* Have a daily feed of my aggregated activities
* Can "follow" my friends and see their activity
* Can compare my activity to those friends
* See trends/statistics comparing my activity to my past activity and my friends' activity

In addition to aggregating data, I can propose runs and distribute invitations to my "friends" -- the people who both I follow and they follow me. These invitations have the details about the run name, distance, start and end point, time, date, and group size. When someone accepts the invitation it is tracked until the group fills up. 

## Mile High - Find the Marijuana Retail Stores in Your Area

Now that weed is legal in Colorado, a lot of people are going to be looking for the nearest weed store! Let's create a service that:

*	Helps people find the nearest retail marijuana stores in their neighborhood. 
*	Users can see information about the strains available at their local shops
*	Users can see reviews of stores via Yelp.
*	Users can see what people are saying about the shops and strains on Twitter.

Integrate the following APIs to get information about store locations, strain details, reviews, and tweets:

* [Leafly](www.leafly.com/api/documentation)
* [Seedfinder](www.programmableweb.com/api/seedfinder)
* [Yelp](www.yelp.com/developers/documentation)
* [Twitter](dev.twitter.com)
