---
layout: page
title: Attend-Interactive
---

This project builds on the lessons learned in JSAttend and is focused on practicing fundamental Ruby style/concepts.

### Learning & Practice Goals

* Achieve functional comfort with implementing classes and methods
* Demonstrate understanding of variable scope and lifecycle
* Create multiple coordinating methods
* Use default and named parameters
* Utilize effective debugging techniques

### Functional Description

Let's take JSAttend to the next level. Based on the same data file, build an interactive query and reporting tool which fulfills the expectations below.

### Base Expectations

As a user, when I start the program I'm provided a command prompt where I can issues one of several commands, described below. After each command, the prompt returns for more instructions.

The program has a concept called the "queue". Think of the queue as the results from a previous search. As a user, I issue a search command to find records, then later issue another command to do something with those results.

#### Command Prompt Instructions

##### `help`

Output a listing of the available individual commands
 
##### `help <command>`

Output a description of how to use the specific command. For example:

```
help queue clear
help find
```

##### `queue stats`
Output how many records are in the current queue

`queue clear`
Empty the queue

`queue print`
Print out a tab-delimited data table with a header row following this format:

```
LAST NAME  FIRST NAME  EMAIL  ZIPCODE  CITY  STATE  ADDRESS
```

`queue print by <attribute>`
Print the data table sorted by the specified `attribute`, like `zipcode`.

`queue save to <filename.csv>`
Export the current queue to the specified filename as a CSV


`find <attribute> <criteria>`
Load the queue with all records matching the criteria for the given attribute. Example usages:

* `find zipcode 20011`
* `find last_name Johnson`
* `find state VA`

`data load <filename>`
Erase any loaded data and parse the specified file. If no filename is given, default to `event_attendees.csv`.

### Extensions

* Modify your `queue print` command so it prints in left-aligned columns where the size of each column is determined by the longest entry in the column.
* Modify your `find` instruction so all searches are case insensitive
* Modify your `find` instruction to allow compound searches using `and` such as:

```
find zipcode 20011 and last_name Johnson
```

### Evaluation Criteria

These projects will be peer assessed using a test script and the following rubric:

1. Correctness
  * 4: All results are correct
  * 3: One script resulted in incorrect results or an error
  * 2: Two or three scripts generated incorrect results or errors
  * 1: More than three scripts generate errors
  * 0: Program will not run
2. Style
  * 4: Source code consistently uses strong code style including lines under 80 characters, methods under 10 lines of code, correct indentation, etc.
  * 3: Source code uses good code style, but breaks the above criteria in two or fewer spots
  * 2: Source code uses mixed style, with two to five style breaks
  * 1: Source code is generally messy with five to ten issues
  * 0: Source code is unacceptable, containing more than style issues
3. Effort
  * 5: Program fulfills all Base Expectations and five Extensions
  * 4: Program fulfills all Base Expectations and two Extensions
  * 3: Program fulfills all Base Expectations
  * 2: Program fulfills Base Expectations except for one or two features.
  * 1: Program fulfills many Base Expectations, but more than two features.
  * 0: Program does not fulfill any of the Base Expectations
