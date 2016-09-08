#### Public Visitor

As a public visitor to FeedEngine I can:

* View any public user feed at *example.com/username*
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

* View any public user feed at *example.com/username*
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