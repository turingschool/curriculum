---
layout: page
title: Securing an API
---

## Security: Username and Password

HTTP has [basic access authentication](http://en.wikipedia.org/wiki/Basic_access_authentication).

#### Answer the Questions

* Would this security system correctly identify a user?
* What would happen if another user intercepted the request?
* Would other users be able to impersonate this user?
* What kinds of data would you allow be transported with this security model?
* How would you implement basic auth in the client?
* How would you implement basic auth in the [server](http://railscasts.com/episodes/82-http-basic-authentication)?

## Security: Unique Key

Imagine a security model where each request includes a unique key that identifies the user.

```
http://feedengine.com/feed.json?key=1ADF2AGADFHGHAGRHTTJS544YOJ9JIJ9
```

### Answer The Questions

* Would this security system correctly identify a user?
* What would happen if another user intercepted the request?
* Would other users be able to impersonate this user?
* What kinds of data would you allow be transported with this security model?
* How would you generate this unique key for each user?

## Security: Message Signatures

Imagine a security model where each and every request includes a unique signature key.

```
GET http://feedengine.com/feeds.json?key=1ADF2AGADFHGHAGRHTTJS544YOJ9JIJ9

POST http://feedengine.com/feeds.json?post=IWantToTellTheWorld&key=1ADF2AGADFHGHAGRHTTJVKNVKNSFWE
```

* Would this security system correctly identify a user?
* What would happen if another user intercepted the request?
* Would other users be able to impersonate this user?
* What kinds of data would you allow be transported with this security model?
* How would you generate a unique signature for each request?
* How would you generate a unique signature for each request for each user?
