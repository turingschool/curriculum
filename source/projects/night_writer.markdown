---
layout: page
title: Night Writer
---

## Before You Begin

The idea of [Night Writing](https://en.wikipedia.org/wiki/Night_writing) was first developed for Napoleon's army so soldiers could communicate silently at night without light. The concept of night writing led to Louis Braille's development of his [Braille tactile writing system](https://en.wikipedia.org/wiki/Braille).

In this project we'll implement systems for generating Braille-like text from normal characters and the reverse.

### Simulating Braille

Braille uses a two-by-three grid of dots to represent characters. We'll simulate that concept by using three lines of symbols:

```
0.0.0.0.0....00.0.0.00
00.00.0..0..00.0000..0
....0.0.0....00.0.0...
```

The `0` represents a raised dot. The period is an unraised space. The above code reads "hello world" in normal text. You can experiment with [converting other words](http://www.euroblind.org/resources/braille-converter/) yourself and share some samples with your classmates.

Let's also constrain our Braille files to eighty characters wide.

## Learning Goals / Areas of Focus

* Practice breaking a program into logical components
* Testing components in isolation and in combination
* Applying Enumerable techniques in a real context
* Reading text from and writing text to files

## Base Expectations

### An Interaction Model

The tool is used from the command line like so:

```
$ ruby ./lib/night_write.rb message.txt braille.txt
Created 'braille.txt' containing 256 characters
```

That will take the plaintext file `message.txt` and create a Braille simulation file `braille.txt`.

Then we can convert that Braille simulation back to normal text:

```
$ ruby ./lib/night_read.rb braille.txt output_message.txt
Created 'output_message.txt' containing 256 characters.
```

### Character Support

Use the [lowercase letters a-z here from the American Foundation for the Blind](http://braillebug.afb.org/braille_print.asp) for your project.

We also need to support capitalization. In Braille, capitalization comes from a shift character. You'll find that character at the end of the fourth row of the previous graphic. When that character appears, the next character (and only the next character) is a capital. So `e` comes out as one 2x3 set of Braille points, but `E` is 4x3: the shift character followed by the normal `e`. Consider how this will affect your line length restrictions.

## Development Phases

As you work to implement the project below are some ideas of how you might start into the problem.

If you'd like an example of how you might extract the File I/O into an external class, [check out this gist](https://gist.github.com/jcasimir/fd0ceaf731e79c9dd5da).

### 1. The Runner

Write a Ruby program that can just output a string like:

```
$ ruby ./lib/night_write.rb message.txt braille.txt
Created 'braille.txt' containing 256 characters
```

Then work to:

* Pull the specified output filename from the command line arguments and put it into the string output
* Get the actual number of characters from the `message.txt` and output it in the message

### 2. Echo Characters

Your Braille-simulation file will need three lines of output for every one line of input. Generate output that is the same as your input line three times.

### 3. Mapping

You'll need a component, a "machine" if you will, where you can put in a normal character and get out the Braille equivalent. It's time to build that now.

### 4. Triple Replacement

Bringing together the Echo Characters idea with the Mapping idea, you can actually output your Braille characters to the file. Consider building a component that would take in a plain-text letter and a position (maybe numbered 0-5) and would return either a `0` or `.`.

### 5. Next Steps

About this point, you should try Braille-ifying a message and exchange it with a classmate. Are your outputs identical?

Then it's time to dive into the reading.

## Extensions

### 1. Supporting Numbers

Return to the graphic referenced above and you'll find a the `#` in the bottom
left corner. Notice that the representations for 1-9 are actually the same as
a-i. This number sign is a "switch" which means that all of the following "letters",
up to the next space, are actually numbers. After the space it's assumed that
we're back to words/letters unless we see another number switch.

Add support for numbers to your program.

### 2. Supporting Contractions

There are contractions commonly understood in Braille. They're a single letter
symbol (so it has spaces on each side) which stands in for a common word.

Find the symbols [here on Wikipedia](https://en.wikipedia.org/wiki/English_Braille#One-letter_contractions)
and add support in your program for the following: a, but, can, do, every, from, go, have, just, knowledge, like, more, not, people, quite, rather, so, that, us, very, it, you, as, child, shall, this, which, out, will, enough, were, in

These should be used both when going from standard characters to Braille (ie, `from`
  is output as one character of Braille) and in your expansion from Braille to standard characters.

## Examples

Below are a few examples to help you develop your implementation. You're encouraged
to submit additional examples, especially for the extensions, as pull requests.

### lowercase character

    "a"

    0.
    ..
    ..

### two lowercase characters

    "ab"

    0.0.
    ..0.
    ....

### uppercase character

    "A"

    ..0.
    ....
    .0..

### two uppercase characters

    "AB"

    ..0...0.
    ......0.
    .0...0..

### 80 characters wide

    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

    0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.
    ................................................................................
    ................................................................................

### 82 characters wide (41 English letters)

    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

    0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.
    ................................................................................
    ................................................................................
    0.
    ..
    ..

### all characters

    " !',-.?abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

    ..............0.0.00000.00000..0.00.0.00000.00000..0.00.0..000000...0...0...00..
    ..00..0...000...0....0.00.00000.00..0....0.00.00000.00..0.00...0.0......0.......
    ..0.0...00.000....................0.0.0.0.0.0.0.0.0.0.0000.0000000.0...0...0...0
    00..0...00..00..0....0...0..0...0...00..00..0...00..00..0....0...0..0...0....0..
    .0...0..0...00..00..0...00......0........0...0..0...00..00..0...00......0...00..
    ...0...0...0...0...0...0...00..00..00..00..00..00..00..00..00..00..000.000.0.0.0
    00..00..0.
    .....0...0
    00.000.000

## Evaluation Rubric

The project will be assessed with the following rubric:

### 1. Overall Functionality

* 4: Application follows the complete spec and two extensions
* 3: Application follows the complete spec and one extension
* 2: Application converts to Braille and back successfully
* 1: Application only converts to Braille or from Braille

### 2. Fundamental Ruby & Style

* 4:  Application demonstrates excellent knowledge of Ruby syntax, style, and refactoring
* 3:  Application shows some effort toward organization but still has 6 or fewer long methods (> 8 lines) and needs some refactoring.
* 2:  Application runs but the code has many long methods (>8 lines) and needs significant refactoring
* 1:  Application generates syntax error or crashes during execution

### 3. Test-Driven Development

* 4: Application is broken into components which are well tested in both isolation and integration
* 3: Application uses tests to exercise core functionality but leaves many common edge cases untested.
* 2: Minor mutations to the implementation code, such as swaping characters, changing `<` to `<=`, placing `true` into a conditional, or deleting a line of code which break the functionality do not cause any tests to fail.
* 1: Application does not demonstrate strong use of TDD

### 4. Breaking Logic into Components

* 4: Application effectively breaks logical components apart with clear intent and usage
* 3: Application has multiple components with defined responsibilities but there is some leaking of responsibilities
* 2: Application has some logical components but divisions of responsibility are inconsistent or unclear and/or there is a "God" object taking too much responsibility
* 1: Application logic shows poor decomposition with too much logic mashed together
