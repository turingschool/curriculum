---
layout: page
title: Intro to CSV - Level II
sidebar: true
---

This exercise builds on [Intro to CSV - Level I](/academy/workshops/csv/i.html).

We will use the [csv-exercises](https://github.com/JumpstartLab/csv-exercises)
repository to practice using test-driven development and working with objects.

There are five exercises, each one leaves more and more up to you.

## Getting Started

If you do not have the repository on your local machine, start by cloning it:

{% terminal %}
$ git clone git@github.com:JumpstartLab/csv-exercises.git
$ cd csv-exercises
{% endterminal %}

If you do have it, then you're fine. Make sure that you've committed any
changes, so that your working directory is clean.

Fetch the latest changes from the upstream repository:

{% terminal %}
$ git fetch origin
{% endterminal %}

Then create a new branch that tracks the `level-ii` branch from origin:

{% terminal %}
$ git checkout -t origin/level-ii
{% endterminal %}

## Phonebook

Start with the `person_test.rb` test suite. Part-way through that, there's a comment that tells you to jump over to the `phone_number_test.rb`. Do that :)

### `PhoneNumber` hints

To remove unwanted things from a string, you can use `String#gsub`.

If you want to get fancy, figure out what the regex is for _everything that is
not a number_, since `gsub` accepts regexes. A great website for experimenting
with regexes is [Rubular](http://rubular.com/).

You're also going to need to split strings. There are many ways to do that.

Here's one:

```ruby
"hello"[0,3]
# => "hel"
"hello"[2,3]
# => "llo"
```

Or, look up `String#slice`, `String#scan`, and `String#split`.

You're also going to need to loop through the digits and sum them together.

Here's the pattern for that using each:

```ruby
sum = 0
[1, 2, 3, 4, 5].each do |number|
  sum = sum + number
end
sum
# => 15
```

You can use the
[`Enumerable#reduce`](http://ruby-doc.org/core-2.0.0/Enumerable.html#method-i-reduce)
method (or its alias `inject`) like this:

```ruby
[1, 2, 3, 4, 5].reduce(0) do |sum, number|
  sum + number
end
# => 15
```

When you finish `phone_number_test.rb` jump back into `person_test.rb`.
Finally, when you've completed both of those, go do the `phone_book_test.rb`.

For the searching, you can use `Enumerable#each` in this way:

```ruby
# find all the even numbers
selected = []
[1, 2, 3, 4, 5].each do |number|
  if number % 2 == 0
    selected << number
  end
end
selected
# => [2, 4]
```

Or, you could use the
[`Enumerable#select`](http://ruby-doc.org/core-2.0.0/Enumerable.html#method-i-select)
method or its alias `find_all`, like this:

```ruby
[1, 2, 3, 4, 5].select do |number|
  number % 2 == 0
end
# => [2, 4]
```

## `ShoppingList`

Start with the `item_test.rb`, then move on to the `shopping_list_test.rb`.

A couple things that will help you along the way:

* [`String#to_i`](http://ruby-doc.org/core-2.0.0/String.html#method-i-to_i)
* [`String#to_f`](http://ruby-doc.org/core-2.0.0/String.html#method-i-to_f)

## `DoctorsOffice`

TODO: add notes

## `ReportCard`

TODO: add notes

## `Calendar`

You're pretty much on your own on this one.

Create a test suite for `Birthday`, which has two attributes: `name` and
`date_of_birth`.

Then implement the following functionality:

* Get birthday as a Date object
* Calculate age
* Calculate gigasecond (assume born at midnight, just get the date)

To create a ruby Date object from a String, try this:

```ruby
require 'date'
Date.strptime('1987', "%Y-%m-%d")
```

A gigasecond is 1 billion seconds. Don't worry about getting the exact moment,
just assume that the person is born at midnight, and calculate the day on
which they turn 1 gigasecond old.

Implement the calendar class to manage the collection of birthdays.

Once you have the basic functionality that loads the CSV data and creates the
birthday objects, add the following functionality:

* Find everyone who is a certain age
* Find everyone who has a birthday on a certain date (regardless of year)
* Given two names, figure out who is older
* Given two names, figure out who has a birthday earlier in the year than the other

