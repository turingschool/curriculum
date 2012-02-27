---
layout: page
title: Attend-Interactive
---

This project builds on the lessons learned in [JSAttend](/projects/jsattend.html) and is focused on practicing fundamental Ruby style/concepts.

### Learning & Practice Goals

* Achieve functional comfort with implementing classes and methods
* Demonstrate understanding of variable scope and lifecycle
* Create multiple coordinating methods
* Use default and named parameters
* Utilize effective debugging techniques

### Abstract

Let's take JSAttend to the next level. Based on the same data file, build an interactive query and reporting tool which fulfills the expectations below. It is assumed that you will re-use data cleaning procedures from the original JSAttend to handle dirty input and generate beautiful output.

### Data Supplied

* Source data file: [event_attendees.csv](/assets/jsattend/event_attendees.csv)

### Base Expectations

As a user launching start the program I'm provided a command prompt where I can issue one of several commands, described below. After each command completes, the prompt returns, waiting for another instruction.

The program has a concept called the "queue". Think of the queue as the stored results from a previous search. As a user, I issue a search command to find records, then later issue another command to do something with those results. The queue is not cleared unless the user runs `queue clear` or a new `find`.

#### Command Prompt Instructions

##### `load <filename>`

Erase any loaded data and parse the specified file. If no filename is given, default to `event_attendees.csv`.

##### `help`

Output a listing of the available individual commands
 
##### `help <command>`

Output a description of how to use the specific command. For example:

```
help queue clear
help find
```

##### `queue count`

Output how many records are in the current queue

##### `queue clear`

Empty the queue

##### `queue print`

Print out a tab-delimited data table with a header row following this format:

```
LAST NAME  FIRST NAME  EMAIL  ZIPCODE  CITY  STATE  ADDRESS
```

##### `queue print by <attribute>`

Print the data table sorted by the specified `attribute` like `zipcode`.

##### `queue save to <filename.csv>`

Export the current queue to the specified filename as a CSV

##### `find <attribute> <criteria>`

Load the queue with all records matching the criteria for the given attribute. Example usages:

* `find zipcode 20011`
* `find last_name Johnson`
* `find state VA`

### Extensions

#### Improving `queue print`

* Modify your `queue print` command so it prints in left-aligned columns where the size of each column is determined by the longest entry in the column.
* If the queue is more than 10 lines, pause after ten until the user hits the spacebar or enter keys

#### Improving `find`

* Modify your `find` instruction so all searches are case insensitive
* Modify your `find` instruction to allow compound searches using a single `and` such as:

```
find zipcode 20011 and last_name Johnson
```

#### Improving `queue save to`

* Modify the instruction to respect the filename extension so that:
  * `csv` generates comma-separated values
  * `txt` generates tab-delimited values
  * `json` generates valid, parsable JSON
  * `xml` generates valid, parsable XML

#### Implementing Queue Math

Assuming I have results currently in the queue, implement queue math like this:

```
find state DC
subtract find zipcode 20011
```

That would find me all entries for DC that are _not_ in `20011`. Similarly:

```
find state DC
add find zipcode 22182
```

Would load the queue with all entries from DC or the `22182` zipcode.

#### Nightmare-Mode `find`

Modify your `find` method to allow multiple attribute values in parentheses like this:

```
find zipcode (20011, 22182) and last_name (Johnson, Patrick, Smith)
```

Support an `or` operation:

```
find zipcode (20011, 22182) or last_name (Johnson, Patrick, Smith)
```

And support `find` only within the queue:

```
find zipcode (20011, 22182)
queue find last_name Johnson
```

Which would find only the Johnson's in 20011 or 22182.

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

### Resources

* Source data file: [event_attendees.csv](/assets/jsattend/event_attendees.csv)
* Check line length and some other formatting issues with the Cane gem: https://github.com/square/cane
