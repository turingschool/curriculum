title: Hashing Data
output: hashing.html
controls: true
theme: JumpstartLab/cleaver-theme

--

# Hashing Data

--

## Why Hash?

* I transferred a large file, how do I know if the two are identical?
* I want to transmit data and make sure it's not tampered with
* I want to authenticate users, but not store their password. Possible?
* I want to create a "name" for a chunk of arbitrary data

--

## What Already Uses Hashes?

* User authetication systems
* Encrypted data systems
* "Signed" HTTP Cookies

--

## What's a Hash Function?

* A hashing function takes in data and outputs a "digest"
* It's not random, it's deterministic
* The function is highly sensitive

--

## A Good Function

* Is not reversible
* Has low overlap in possible outputs ("perfect hashing")
* Is implemented in many languages
* Is either fast or slow, depending on application
* Was built by professionals

--

## Well-Known Functions

* MD5
* SHA2
* BCRYPT

--

## MD5

* An algorithm built for speed
* Very quick to hash even multi-gigabyte inputs
* Implemented in every language you'd want to use

--

## MD5 Example

```ruby
require 'digest/md5'
digest = Digest::MD5.hexdigest("Hello World")
```

--

## A SHA2 Example

```ruby
require 'digest/sha2'
digest = Digest::SHA2.hexdigest("Hello World")
```

--

## Sensitivity

```bash
> digest1 = Digest::MD5.hexdigest("Hello World")
 => "b10a8db164e0754105b7a99be72e3fe5" 
> digest2 = Digest::MD5.hexdigest("Hello World.")
 => "d7527e2509d7b3035d23dd6701f5d8d0" 
```

--

## Rainbow Tables

* Take a dictionary
* Generate combinations of words and letters
* Run those through a hashing function
* Store the input and output

--

## Cracking with Rainbows

* Get a set of hashed password
* Compare against the known hashes in your table
* Now you know the input passwords

--

## Salting

* Share a "secret"
* Add that secret to everything you hash

--

## Salting in Practice

```bash
> salt = "I love to hash"
 => "I love to hash" 
> digest1 = Digest::MD5.hexdigest("truelove")
 => "deb06d2508b80d2ad76b3f19c33dcd77" 
> digest2 = Digest::MD5.hexdigest("truelove" + salt)
 => "c68b33f85eb69a8f545ea30279473ec0" 
```

--

## Per-User Salting

```bash
> salt = "I love to hash"
 => "I love to hash" 
2.0.0-p247 :004 > user_salt = rand(1000..9999).to_s
 => "9325" 
2.0.0-p247 :005 > digest = Digest::MD5.hexdigest("truelove" + salt + user_salt)
 => "2e5c2dfabe49105993216055f393d87f" 
```

--

## Ways You Can Use Hashes

* User uploads an image, generate a unique file name
* Rails "Russian-Doll Caching"
* Verifying large uploads to Amazon S3
* Dropbox-style de-duplication
* Uniquely identifing a chunk of text, like a revision in a CMS

--

## Learning about Hashes

* Beginner: Load MD5 in IRB and try it out!
* Intermediate: Look into the source of Rails' `has_secure_password`
* Difficult: Implement MD5 yourself and compare with Ruby's implmentation

--

## Thanks!

* Jeff Casimir, ED Turing School of Software & Design
* @j3 / jeff@jumpstartlab.com
* `http://turing.io`
* Next class starts June 2
