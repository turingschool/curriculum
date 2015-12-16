---
layout: page
title: Enigma
---

In this project you'll use Ruby to build a tool for cracking an encryption algorithm.

## Introduction

### Learning Goals / Areas of Focus

* Practice breaking a program into logical components
* Testing components in isolation and in combination
* Applying Enumerable techniques in a real context
* Reading text from and writing text to files

## Base Expectations

You are to build an encryption engine for encrypting, decrypting, and cracking
messages.

Additionally, your program will need to read messages from and output them to
the file system.

### Encryption Notes

The encryption is based on rotation. The character map is made up of all the
lowercase letters, then the numbers, then space, then period, then comma. New
lines will not appear in the message nor character map.

#### The Key

* Each message uses a unique encryption key
* The key is five digits, like 41521
* The first two digits of the key are the "A" rotation (41)
* The second and third digits of the key are the "B" rotation (15)
* The third and fourth digits of the key are the "C" rotation (52)
* The fourth and fifth digits of the key are the "D" rotation (21)

#### The Offsets

* The date of message transmission is also factored into the encryption
* Consider the date in the format DDMMYY, like 020315
* Square the numeric form (412699225) and find the last four digits (9225)
* The first digit is the "A offset" (9)
* The second digit is the "B offset" (2)
* The third digit is the "C offset" (2)
* The fourth digit is the "D offset" (5)

#### Encrypting a Message

* Four characters are encrypted at a time.
* The first character is rotated forward by the "A" rotation plus the "A offset"
* The second character is rotated forward by the "B" rotation plus the "B offset"
* The third character is rotated forward by the "C" rotation plus the "C offset"
* The fourth character is rotated forward by the "D" rotation plus the "D offset"

#### Decrypting a Message

The offsets and keys can be calculated by the same methods above. Then each character
is rotated backwards instead of forwards.

#### Cracking a Key

When the key is not known, the offsets can still be calculated from the message
date. We believe that each enemy message ends with the characters `"..end.."`. Use
that to determine when you've correctly guessed the key.

### Usage

Then we'll exercise the functionality from a Pry session:

```ruby
> require './lib/enigma'
> e = Enigma.new
> my_message = "this is so secret ..end.."
> output = e.encrypt(my_message)
=> # encrypted message here
> output = e.encrypt(my_message, "12345", Date.today) #key and date are optional (gen random key and use today's date)
=> # encrypted message here
> e.decrypt(output, "12345", Date.today)
=> "this is so secret ..end.."
> e.decrypt(output, "12345") # Date is optional (use today's date)
=> "this is so secret ..end.."
> e.crack(output, Date.today)
=> "this is so secret ..end.."
> e.crack(output) # Date is optional, use today's date
=> "this is so secret ..end.."
```

### Working with Files

In addition to the pry form above, we'll want to use the tool
from the command line like so:

```
$ ruby ./lib/encrypt.rb message.txt encrypted.txt
Created 'encrypted.txt' with the key 82648 and date 030415
```

That will take the plaintext file `message.txt` and create an encrypted file `encrypted.txt`.

Then, if we know the key, we can decrypt:

```
$ ruby ./lib/decrypt.rb encrypted.txt decrypted.txt 82648 030415
Created 'decrypted.txt' with the key 82648 and date 030415
```

But if we don't know the key, we can try to crack it with just the date:

```
$ ruby ./lib/crack.rb encrypted.txt cracked.txt 030415
Created 'cracked.txt' with the cracked key 82648 and date 030415
```

## Development Phases

As you work to implement the project here are ideas for some of your first iterations:

### 1. Key Generator

It'd be great if instead of random numbers we could generate a legitimate key. Starting from your runner:

* Create an instance of a key generator
* Figure out what, if anything, you'd need to pass in to the object
* Start writing tests for the key generator object based on the specs above
* Go through building the implementation
* Use it from your runner to generate and output a valid key

### 2. Offsets

Before we can start encrypting we probably need to calculate the offsets.

* From your runner, create an instance of an offset calculator
* Pass the current date and the generated key into the offset calculator
* Write tests and implementation around the idea of being able to pass in the date and key, then query the A, B, C, and D final rotations

### 3. Encryption

Now that you have all the components you're ready to encrypt a message.

* Create an encryptor object in your runner
* What information would the encryptor need to be "setup" and ready to encrypt messages? Pass that in.
* Call an encrypt method and pass in a string message. Get back the encrypted version.

### 4. Next Steps

Now you should have all the components in place such that your command-line encryption is working! Next up:

* Follow a similar flow to develop the decrypt script and functionality
* Swap some encrypted messages with a classmate and see if each other can decrypt them correctly
* Start experimenting with the cracking functionality

## Extensions

### 1. Character Support

Improve your system so it supports all of the following:

* all capital letters
* all lowercase letters
* all numbers
* spaces
* these symbols: `!@#$%^&*()[],.<>;:/?\|`

## Support Tooling

Please make sure that, before your evaluation, your project has each of the following:

* SimpleCov reporting accurate test coverage statistics
* TravisCI running your all your tests and they all pass
* CodeClimate evaluating the quality of your code (best to set it up early to see the change over time)

## Evaluation Rubric

The project will be assessed with the following rubric:

### 1. Overall Functionality

* 4: Application follows the complete spec and one extension
* 3: Application encrypts, decrypts, and cracks files as described
* 2: Application is missing one of the three operations
* 1: Application is missing two operations or crashes during normal usage

### 2. Fundamental Ruby & Style

* 4:  Application demonstrates excellent knowledge of Ruby syntax, style, and refactoring
* 3:  Application shows some effort toward organization but still has 6 or fewer long methods (> 8 lines) and needs some refactoring.
* 2:  Application runs but the code has many long methods (>8 lines) and needs significant refactoring
* 1:  Application generates syntax error or crashes during execution

### 3. Test-Driven Development

* 4: Application is broken into components which are well tested in both isolation and integration
* 3: Application uses tests to exercise core functionality, but has some gaps in coverage or leaves edge cases untested.
* 2: Application tests some components but has many gaps in coverage.
* 1: Application does not demonstrate strong use of TDD

### 4. Breaking Logic into Components

* 4: Application effectively breaks logical components apart with clear intent and usage
* 3: Application has multiple components with defined responsibilities but there is some leaking of responsibilities
* 2: Application has some logical components but divisions of responsibility are inconsistent or unclear and/or there is a "God" object taking too much responsibility
* 1: Application logic shows poor decomposition with too much logic mashed together
