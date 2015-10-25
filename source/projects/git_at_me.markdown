## Git at Me

We all love [Git](https://git-scm.com/) for managing source control in our
projects. But sometimes the Git command line interface can be a bit daunting.
Additionally, it would be neat if we could go a little bit deeper with stats or analysis
of our projects than Git's CLI really allows.

Fortunately, git makes its data pretty accessible. If we have a good data
source for the commits in a repository, we could build our own
interface that exposes some of these functions.

In this project, we'll be building our own CLI to perform additional
analysis on git projects.

### Data Source

[This file](https://www.dropbox.com/s/5mpmaa56fusowvd/curriculum_git_repo.json?dl=0)
contains a JSON dump of the commits from the Turing [Curriculum](https://github.com/turingschool/curriculum)
repository. We'll use it to build our own Command Line Interface that lets us
answer questions about this data.

### JSON

[JSON](https://en.wikipedia.org/wiki/JSON) stands for JavaScript Object Notation,
and is a popular data serialization and interchange format.

Its serialization format is based on JavaScript's object model, where
objects are simply Hash-like structures of properties and associated
values.

For this project, we won't need to know much about JSON beyond accepting the basic
premise that JSON allows us to encode data as a string (often for the purposes of storing
it in a file or sending it over the network), and then de-serialize this information
back into an actual language data structure (i.e. a `Hash` or `Array` in Ruby).

When de-serializing (i.e. parsing) JSON, we'll encounter 1 of 2 standard data structures:

1. An array
2. A Hash

Here's a nice tutorial on using the JSON facilities built into Ruby's standard library:

https://hackhands.com/ruby-read-json-file-hash/

It should get you up to speed on the basics you need to be productive working with
JSON from Ruby.

### Project Functionality

Our goal is to add some basic analytics functionality on top of a standard
git repository. Imagine GitHub's repo graphing and analysis functionality
but via a CLI.

Here are the basic questions we want to be able to answer

* Find commits by user
* Find commits by date
* Find total number of branches
* Find average number of insertions and deletions per commit
* Find aveage number of files changed per commit
* Find number of "merge" commits vs. number of standard commits
* Find top N contributors by number of commits
* Find top day of the week for commits
* Find top date for commits

### Interface

We're going to expose this via a CLI. Your application will be written in
Ruby, but it will need to allow the user to interact with it by entering
commands in the terminal.

Additionally, we'd like to be able to ask multiple questions during a single
session, so we'll want the interface to "persist" until we ask it to quit.

First, work through this [basic CLI tutorial](http://tutorials.jumpstartlab.com/topics/cli.html)
to get a feel for the process.

### Generating Additional Git JSON dumps

If you'd like to try it out with a different git repository, you can use this
[python script](https://github.com/paulrademacher/gitjson) to generate
JSON dumps for other git repositories.
