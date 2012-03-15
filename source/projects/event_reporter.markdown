---
layout: page
title: EventReporter
---

This project builds on the lessons learned in [EventManager](/projects/eventmanager.html) and is focused on practicing fundamental Ruby style/concepts.

### Learning & Practice Goals

* Achieve functional comfort with implementing classes and methods
* Demonstrate understanding of variable scope and lifecycle
* Create multiple coordinating methods
* Use default and named parameters
* Utilize effective debugging techniques

### Abstract

Let's take `EventManager` to the next level. Based on the same data file, build an interactive query and reporting tool which fulfills the expectations below. It is assumed that you will re-use data cleaning procedures from the original `EventManager` to handle dirty input and generate beautiful output.

### Data Supplied

* Source data file: [event_attendees.csv](/assets/eventmanager/event_attendees.csv)

### Base Expectations

As a user launching the program, I'm provided a command prompt where I can issue one of several commands, described below. After each command completes, the prompt returns, waiting for another instruction.

The program has a concept called the "queue". The queue holds the stored results from a previous search. As a user, I issue a search command to find records, then later issue another command to do something with those results. The queue is not cleared unless the user runs `queue clear` or a new `find`.

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

Export the current queue to the specified filename as a CSV. 

It must contain headers and be structured in such a way that your program could be restarted and the `load` instruction would successfully parse the previously output file.

##### `find <attribute> <criteria>`

Load the queue with all records matching the criteria for the given attribute. Example usages:

* `find zipcode 20011`
* `find last_name Johnson`
* `find state VA`

The comparison should:

* Be insensitive to case, so `"Mary"` and `"mary"` would be found in the same search
* Be insensitive to internal whitespace, but not external:
  * `"John"` and `"John "` are considered matches
  * `"John Paul"` and `"Johnpaul"` are not matches
* Not do substring matches, so a `find first_name Mary` does not find a record with first name `"marybeth"`

### Extensions

#### Improving `queue print`

* Modify your `queue print` command so it prints in left-aligned columns where the size of each column is determined by the longest entry in the column.
* If the queue is more than 10 lines, pause after ten until the user hits either the spacebar or enter keys

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

Which would find only the Johnsons in 20011 or 22182.

### Evaluation Criteria

These projects will be peer assessed using test scripts and the following rubric:

1. Correctness
  * 4: All results are correct
  * 3: One script resulted in incorrect results or an error
  * 2: Two or three scripts generated incorrect results or errors
  * 1: More than three scripts generate errors
  * 0: Program will not run
2. Style
  * 4: Source code consistently uses strong code style including lines under 80 characters, methods under 13 lines of code, correct indentation, etc.
  * 3: Source code uses good code style, but breaks the above criteria in two or fewer spots
  * 2: Source code uses mixed style, with three to five style breaks
  * 1: Source code is generally messy with six to ten issues
  * 0: Source code is unacceptable, containing more than 10 style issues
3. Effort
  * 5: Program fulfills all Base Expectations and five Extensions
  * 4: Program fulfills all Base Expectations and two Extensions
  * 3: Program fulfills all Base Expectations
  * 2: Program fulfills Base Expectations except for one or two features
  * 1: Program fulfills several Base Expectations, but more than two features are missing
  * 0: Program does not fulfill any of the Base Expectations

### Resources

* Source data file: [event_attendees.csv](/assets/eventmanager/event_attendees.csv)
* Check line length and some other formatting issues with the Cane gem: https://github.com/square/cane

### Evaluations for Base Expectations

Follow the instruction sequences below and compare the expected output to the actual output. Any Ruby exceptions are an automatic failure for that script.

#### A. Happy Path

1. `load event_attendees.csv`
2. `queue count` should return `0`
3. `find first_name John`
4. `queue count` should return `X` #TODO
5. `queue clear`
6. `queue count` should return `0`
7. `help` should list the commands
8. `help queue count` should explain the queue count function
9. `help print` should explain the printing function

#### B. Let's Try Printing

1. `load`
2. `queue count` should return `0`
3. `find first_name John`
4. `find first_name Mary`
5. `queue print` should print out the X attendees #TODO
6. `queue print by last_name` should print the same attendees sorted alphabetically by first name
7. `queue count` should return `X` #TODO

#### C. Saving

1. `load`
2. `find email_address x@jumpstartlab.com` #TODO
3. `queue print` should display X attendees #TODO
4. `queue save to email_sample.csv`
5. Open the CSV and inspect that it has correct headers and the data rows from step 3.
6. `find state DC`
7. `queue print by last_name` should print them alphabetically by last name
8. `queue save to state_sample.csv`
9. Open the CSV and inspect that it has the headers, the data from step 7, but not the data previously found in step 2.

#### D. Reading Your Data

1. `load`
2. `find state MD`
3. `queue save to state_sample.csv`
4. `exit`

_Restart the program and continue..._

5. `load state_sample.csv`
6. `find first_name John`
7. `queue count` should return `X` #TODO

#### E. Emptiness

Note that this set intentionally has no call to `load`:

1. `find last_name Johnson`
2. `queue count` should return `0`
3. `queue print` should not print any attendee data
4. `queue clear` should not return an error
5. `queue print by last_name` should not print any data
6. `queue save to empty.csv` should output a file with only headers
7. `queue count` should return `0`

### Evaluations for Extensions

#### 1. Improved `queue print`

#### 2. Improved `find`

#### 3. Improved `queue save to`

#### 4. Queue Math

#### 5. Nightmare-Mode Find
