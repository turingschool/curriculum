---
layout: page
title: Securing an API
---

## Security: Username and Password

HTTP has [basic access authentication](http://en.wikipedia.org/wiki/Basic_access_authentication).

### Questions

* Would this security system correctly identify a user?
* What would happen if another user intercepted the request?
* Would other users be able to impersonate this user?
* What kinds of data would you allow be transported with this security model?

### Implementation

Implement the security method described using the questions and resources below to assist your development process.

* How would you implement basic auth in the [client](https://github.com/lostisland/faraday#usage)?
* How would you implement basic auth in the [server](http://railscasts.com/episodes/82-http-basic-authentication)?

## Security: Unique Key

Imagine a security model where each request includes a unique key that identifies the user.

```
http://feedengine.com/feed.json?user=ME&key=1ADF2AGADFHGHAGRHTTJS544YOJ9JIJ9
```

### Questions

* Would this security system correctly identify a user?
* What would happen if another user intercepted the request?
* Would other users be able to impersonate this user?
* What kinds of data would you allow be transported with this security model?

### Implementation

Implement the security method described using the questions and resources below to assist your development process.

* How would you generate this unique key for each user?
* How would you store the unique key for each user?
* Imagine keys for two different users may be generated at the same time, how would ensure the key was unique? (i.e. is `rand` really random enough)

## Security: Message Signatures

Imagine a security model where each and every request includes a unique signature key.

```
GET http://feedengine.com/feeds.json?user=ME&key=1ADF2AGADFHGHAGRHTTJS544YOJ9JIJ9

POST http://feedengine.com/feeds.json?user=ME&post=IWantToTellTheWorld&key=1ADF2AGADFHGHAGRHTTJVKNVKNSFWE
```

### Questions

* Would this security system correctly identify a user?
* What would happen if another user intercepted the request?
* Would other users be able to impersonate this user?
* What kinds of data would you allow be transported with this security model?

### Implementation

Implement the security method described using the questions and resources below to assist your development process.

* How would you generate a unique message signature for each request on the client?
* On the server, how would you ensure the message was from the client using the signature provided?

Ruby's library comes equipped with an OpenSSL library that allows you to sign data:

```
require 'openssl'
 
key = "A USER'S UNIQUE KEY"
data = "THE REQUEST INFORMATION"
p OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), key, data)
```

## Security: Message Signatures with Timestamps

Imagine a security model where each and every request includes a unique signature key and a timestamp
when it was signed.

```
GET http://feedengine.com/feeds.json?user=ME&timestamp=1368543634&key=1ADF2AGADFHGHAGRHTTJS544YOJ9JIJ9

POST http://feedengine.com/feeds.json?user=ME&post=IWantToTellTheWorld&timestamp=1368543634&key=1ADF2AGADFHGHAGRHTTJVKNVKNSFWE
```

### Questions

* How does adding a timestamp address issues in the previous implementation?
* What range of timestamps should be allowed?
* What happens when you allow a wide range of timestamps?
* What happens when you allow a very narrow range of timestamps?

### Implementation

Implement the security method described using the questions and resources below to assist your development process.

* How would you generate the timestamp on the client?
* How would you decide if the timestamp is within the correct range on the server?