---
layout: page
title: Encryptor
---

Have you ever wanted to send a secret message?

### The Plan

Today we use computers to mask messages every day. When you connect to a website that uses "https" in the address, it is running a special encoding on your transmissions that makes it very difficult for anyone to listen in between you and the server.

The science of masking and unmasking data is called *cryptography*. When you take readable data and mask it, we say that you're "encrypting" the data. When you turn it back into readable text, you're "decrypting" the data.

Let's build a tool named "Encryptor" that can take in our messages, encrypt them for transmission, then decrypt messages we get from others.

#### Encryption Algorithms

An "algorithm" is a series of steps used to create an outcome. For instance, a recipie is a kind of algorithm -- you follow steps and, hopefully, create some food.

There are many algorithms used in cryptography. One of the easiest goes back to the days of Ancient Rome.

Julius Caesar need to send written instructions from his base in Rome to his soldiers thousands of miles away. What if the messenger was captured or killed? The enemy could read his plans!

Caesar's army used an algorithm called "ROT-13". Here's how it works.

#### Building a Cipher

ROT-13 is an algorithm that uses a cipher. A cipher is a tool which translates one piece of data to another. If you've ever used a "decoder ring", that's a cipher. The cipher has an input and an output.

Let's make a cipher for ROT-13:

1. Take a piece of lined paper
2. In a column, write the letters A through Z in order down the left side.
3. On the first line, start a second column by writing the letter N next to your A
4. Continue down the alphabet, so you now write "O" to the right of "B"
5. When your second column gets to "Z", start over again with "A"

The left side of your cipher is the input, the right side is the output. 

#### Using the Cipher

You take each letter of your secret data, find it in the left column, and write down the letter on the right. Now you have an encrypted message.

To decrypt a secret message, find the letter on the right side and write down the letter on the left.

#### Exercises

1. What is the result when you encrypt the phrase "Hello, World"?
2. What is the decrypted version of a message ""