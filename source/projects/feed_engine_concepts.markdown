---
layout: page
title: FeedEngine Custom Concepts
sidebar: true
---

## Traveline - A Family Travelogue

Families love to travel together. Let's create a site the builds lasting memories. After creating an account on the site I can:

* Create a trip with start and end dates
* Visit the events feed for that single trip
* Register one or more Instagram usernames to track
* Register one or more Twitter usernames to track
* Register one or more FourSquare usernames to track

Then, while on the trip, any events from those three sources are automatically added and visible both within the feed for that individual trip and my aggregate feed of all my trips. I'd also like to subscribe to other people's trips to peek in on their trips.

## Softline - An Event Tracker for Software Teams

Keeping track of agile software projects is hard. Let's create an activity feed that can bring it all together. After creating an account on the site I can:

* Create a project
* Register one Pivotal Tracker project
* Register one Github project
* Generate a unique email address for this feed

Then, while working on the project:

* Changes from tracker (stories added, completed, comments, etc) are reflected in the feed
* Activity from Github (pushes, issues, etc) are reflected in the feed
* Any emails sent to the project-specific address show up in the feed

Given that our team is super-agile and constantly pushing code, it's important that these events have some aggregation. Like if the same person pushes code three times within a few hours, it should just show up with one event in the stream that links to all three commits. Or delivering two features in Tracker shows up as just one entry with two links.

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

## Chatline - Talking with Friends

It's hard to keep track of so many conversations across multiple sites. Let's create an aggregator site where I can:

* Register my Twitter account
* Register my Facebook account
* Register my Gmail account

Then:

* When a tweet mentioning me is written, it appears in the feed
* When I post a tweet mentioning someone else, it appears in the feed
* I can reply to tweets in the feed and they're posted to Twitter
* When a Facebook message is sent to me, it appears in the feed
* I can respond to Facebook messages in the feed
* When I get an email it appears in the feed
* I can reply to the email directly from the feed

That way I can keep in touch with all my friends, all in one place.

## Sportsline - An Aggregator for Sports Fans

I love my sports. Let's create an aggregator where I can:

* Create multiple named feeds
* In each feed, I can easily add a list of relevent terms like like "RedSox" and "David Ortiz"

Then, when I view the feed, I see recent matching stories and boxscores that contain any of the watched terms from the following sources:

* ESPN
* USAToday
* NBA.com
* NFL.com
* MLB.com

As a user, sometimes I just want to focus on one sport. So I need to ability to view my feed of just one set of terms (ex: "RedSox" and "David Ortiz") to get just my baseball stories, then a higher-level feed that pull together all my sub-feeds into one place. I also will want to subscribe to feeds that other users create.

## Runline - Running with Friends

Achieving a healthy lifestyle and fitness goals can be difficult without community support.  This app will help keep you motivated by joining your fitness data with your friends.

The app pull data from:

* MapMyFitness
* RunKeeper
* TheDailyMile

With that data, as a registered user I:

* Have a daily feed of my aggregated activities
* Can "follow" my friends and see their activity
* Can compare my activity to those friends
* See trends/statistics comparing my activity to my past activity and my friends' activity

In addition to aggregating data, I can propose runs and distribute invitations to my "friends" -- the people who both I follow and they follow me. These invitations have the details about the run name, distance, start and end point, time, date, and group size. When someone accepts the invitation it is tracked until the group fills up. 
