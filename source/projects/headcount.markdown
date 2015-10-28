---
layout: page
title: Headcount
sidebar: true
---

Federal and state governments publish a huge amount of data. You can find
a large collection of it on [Data.gov](http://data.gov) -- everything from land surveys
to pollution to census data.

As programmers, we can use those data sets to ask and answer questions. Starting
with CSV data we will eventually:

* build a "Data Access Layer" which allows us to query/search the underlying data
* build a "Relationships Layer" which creates connections between related data
* build an "Analysis Layer" which uses the data and relationships to draw conclusions

We'll build upon a dataset centered around schools in Colorado provided by the Annie E. Casey foundation.

## Project Overview

### Goals

* Use tests to drive both the design and implementation of code
* Decompose a large application into components such as parsers, repositories, and analysis tools
* Use test fixtures instead of actual data when testing
* Connect related objects together through references
* Learn an agile approach to building software

### Getting Started

1. One team member forks the repository at https://github.com/turingschool-examples/headcount and adds the others as collaborators.
1. Everyone on the team clones the repository
1. Create a [Waffle.io](http://waffle.io) account for project management.
   Just play with it a bit to see what kinds of things it can do,
   identify things that seem like they will be useful (eg to coordinate your work)
   and then use it for those things.

## Base Expectations

### Iteration 1

For an agile approach to this project, we'll start out by building out the "Data Access Layer", "Relationships Layer", and "Analysis Layer" for a single CSV file.

#### Data Access Layer

##### `DistrictRepository`

The `DistrictRepository` is responsible for holding and searching our `District`
instances. It offers the following methods:

* `find_by_name` - returns either `nil` or an instance of `District` having done a *case insensitive* search
* `find_all_matching` - returns either `[]` or one or more matches which contain the supplied name fragment, *case insensitive*

There is no one data file that contains just the districts. The data must be extracted from one of the other files.

##### `District`

The `District` is the top of our data hierarchy. It has the following methods:

* `name` - returns the upcased string name of the district
* `enrollment` - returns an instance of `Enrollment`

##### `Enrollment`

For iteration 1, the instance of this object represents data from this file:

* `Kindergartners in full-day program.csv`

An instance of this class offers the following methods:

###### `.kindergarten_participation_by_year`

This method returns a hash with years as keys and a truncated three-digit floating point number representing a percentage.

*Example*:

```ruby
enrollment.kindergarten_participation_by_year
# => { 2010 => 0.391,
#      2011 => 0.353,
#      2012 => 0.267,
#      2013 => 0.487,
#      2014 => 0.490,
#    }
```

###### `.kindergarten_participation_in_year(year)`

This method takes one parameter:

* `year` as an integer for any year reported in the data

A call to this method with any unknown `year` should return `nil`.

The method returns a truncated three-digit floating point number representing a percentage.

*Example*:

```ruby
enrollment.kindergarten_participation_in_year(2010) # => 0.391
```

#### Relationships Layer

Assume we start with loading our data and finding a school district like this:

```ruby
dr = DistrictRepository.from_csv('./data')
district = dr.find_by_name("ACADEMY 20")
```

Then each `district` now has a single child object loaded with data allowing us to ask questions like this:

```ruby
district.enrollment.kindergarten_participation_in_year(2010) # => 0.391
```

#### Analysis Layer

Our analysis is centered on answering questions about the data.

Who will answer those questions? Assuming we have a `dr` that's an instance of `DistrictRepository` let's initialize a `HeadcountAnalyst` like this:

```ruby
ha = HeadcountAnalyst.new(dr)
```

Then ask/answer these questions:

##### Does Kindergarten participation affect outcomes?

In many states, including Colorado, Kindergarten is offered at public schools but is not free for all residents. Denver, for instance, will charge as much as $310/month for Kindergarten. There's then a disincentive to enroll a child in Kindergarten. Does participation in Kindergarten with other factors/outcomes?

###### `How does a district's kindergarten participation rate compare to the state average?`

First, let's ask how an individual district's participation percentage compares to the statewide average:

```ruby
ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO') # => 0.766
```

Where `0.766` is the result of the district average divided by state average. (i.e. find the district's average participation across all years and didvide it by the average of the state participation data across all years.) A value less than 1 implies that the district performs lower than the state average, and a value greater than 1 implies that the district performs better than the state average.

###### `How does a district's kindergarten participation rate compare to another district?`

Let's next compare this variance against another district:

```ruby
ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1') # => 1.234
```

Where `1.234` is the result of the district average divided by 'against' district's average. (i.e. find the district's average participation across all years and didvide it by the average of the 'against' district's participation data across all years.) A value less than 1 implies that the district performs lower than the against district's average, and a value greater than 1 implies that the district performs better than the against district's average.

### Iteration 2: Adding more CSVs

Next, now that we have the pieces working for a single CSV file of Kindergarteners, let's add some more data to the equation in Interaton 2.

#### `Enrollment`

Back in the `Enrollment` class, let's add another CSV file:

* `High school graduation rates.csv`

And let's add the following methods:

##### `.graduation_rate_by_year`

This method returns a hash with years as keys and a truncated three-digit floating point number representing a percentage.

*Example*:

```ruby
enrollment.graduation_rate_by_year
# => { 2010 => 0.895,
#      2011 => 0.895,
#      2012 => 0.889,
#      2013 => 0.913,
#      2014 => 0.898,
#    }
```

##### `.graduation_rate_in_year(year)`

This method takes one parameter:

* `year` as an integer for any year reported in the data

A call to this method with any unknown `year` should return `nil`.

The method returns a truncated three-digit floating point number representing a percentage.

*Example*:

```ruby
enrollment.graduation_rate_in_year(2010) # => 0.895
```

#### Analysis

##### How does kindergarten participation variation compare to the high school graduation variation?

There's thinking that kindergarten participation has long-term effects. Given our limited data set, let's *assume* that variance in kindergarten rates for a given district is similar to when current high school students were kindergarten age (~10 years ago). Let's compare the variance in kindergarten participation and high school graduation.

For a single district:

```ruby
ha.kindergarten_participation_against_high_school_graduation('ACADEMY 20') # => 1.234
```

Call *kindergarten variation* the result of dividing the district's kindergarten participation by the statewide average. Call *graduation variation* the result of dividing the district's graduation rate by the statewide average. Divide the *kindergarten variation* by the *graduation variation* to find the *kindergarten-graduation variance*.

If this result is close to `1`, then we'd infer that the *kindergarten variation* and the *graduation variation* are closely related.

##### Does Kindergarten participation predict high school graduation?

Let's consider the `kindergarten_participation_against_high_school_graduation` and set a correlation window between `0.6` and `1.5`. If the result is in that range then we'll say that they are correlated. For a single district:

```ruby
ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'ACADEMY 20') # => true
```

Then let's look statewide. If more than 70% of districts across the state show a correlation, then we'll answer `true`. If it's less than `70%` we'll answer `false`.

```ruby
ha.kindergarten_participation_correlates_with_high_school_graduation(:for => 'COLORADO') # => true
```

Then let's do the same calculation across a subset of districts:

```ruby
ha.kindergarten_participation_correlates_with_high_school_graduation(:across => ['district_1', 'district_2', 'district_3', 'district_4']) # => true
```

## Evaluation Rubric

NOTE: Update this rubric when the project settles more.

The project will be assessed with the following guidelines:


### 0. Influence points!

An influence point may be used by your evaluator to influence their decision on a score in a positive direction.
So, if they were unsure about whether to give a `2` or a `3` on "Overall Functionality", they could use
the influence point on that category and make it a 3.

* You achieve an influence point if you submit at least one pull request to improve this project description, and it is merged in
  [Example](https://github.com/turingschool/curriculum/pull/1092).
* Currently this project is very new and needs us to give it our consideration, attention, and love.
  A pull request that identifies a requirement that cannot be satisfied, and reinterprets it to make sense
  will show that you are helping take ownership over the project and improve it for the rest of your class,
  and everyone who comes after you. Don't let everyone suffer through whatever you suffered through,
  take your insights and improve the project for everyone after you!

  This influence point can be acheived by pushing the "cursor of consensus" forward.
  The **"cursor of consensus"** is the current interpretation of the requirements,
  as agreed upon by enough people to assume that it is the most reasonable way to make sense of it.
  You can basically think of it as the project description + the test harness.
  To prove that the consensus exists, you need at least 5 students to "+1" the pull request.
  [Example](https://github.com/turingschool/curriculum/pull/1094)


### 1. Overall Functionality

Currently, the analysis layer contains a lot of functionality that needs to be figured out
(go figure it out, update it, and get an influence point!)

* 4: Passes the Test Harness (you'll get this later in the project, to discourage you from using the test harness)
* 3: Satisfied the "cursor of consensus" in the Analysys Layer (we need a lot more thought put into this area).
* 2: Completes the Data Access Layer
* 1: Passes that test in the "getting started" section that you should write first


### 2. Enumerables

You may get 1 point for each of these, your score for this category is the sum of your points.

* Fewer than 5 calls to `each`
* Uses each of the following methods on `Array` at least once: `map`, `group_by`, `to_h`, `select`, `reject`
* Uses each of the following methods on `Hash` at least once: `Hash`: `fetch`, `[]`, `map` (note that this gives back an array that you can call `to_h` on)
* At least 1 use of "symbol to proc"


### 3. Fundamental Ruby & Style

* 4:  Application demonstrates excellent knowledge of Ruby syntax, style, and refactoring
* 3:  Application shows strong effort towards organization, content, and refactoring
* 2:  Application runs but the code has long methods, unnecessary or poorly named variables, and needs significant refactoring
* 1:  Application generates syntax error or crashes during execution


### 4. Test-Driven Development

* 4: Application is broken into components which are well tested in both isolation and integration
* 3: Application uses tests to exercise core functionality, but has some gaps in coverage or leaves edge cases untested.
* 2: If I edit the code to be broken, then a test fails (in other words, the tests prove that the code is correct by failing when I add bugs to the code)
* 1: Application does not demonstrate strong use of TDD


### 5. Breaking Logic into Components

* 4: I can look at your code for the `DistrictRepository`, `District`, `Enrollment`, `StatewideTesting`, and not know whether you got your data from the CSV, or the JSON, or a test, or anywhere else.
* 3: Application has multiple components with defined responsibilities but there is some leaking of responsibilities
* 2: Application has some logical components but divisions of responsibility are inconsistent or unclear and/or there is a "God" object taking too much responsibility
* 1: Application logic shows poor decomposition with too much logic mashed together


### 6. Code Sanitation

The output from `rake sanitation:all` shows... (assuming I figure out how this thing works and get it working :P)

* 4: Zero complaints
* 3: Five or fewer complaints
* 2: Six to ten complaints
* 1: More than ten complaints


## References

### Data Sources

* [Search Index](http://datacenter.kidscount.org/data#CO/10/0)
* [Median Household Income](http://datacenter.kidscount.org/data/tables/6228-median-household-income?loc=7&loct=10#detailed/10/1278-1457/false/1376,1201,1074,880,815/any/12960)
* [School Aged Children in Poverty](http://datacenter.kidscount.org/data/tables/435-school-aged-children-in-poverty?loc=7&loct=10#detailed/10/1278-1457/false/36,868,867,133,38/any/11775,1084)
* [Pupil Enrollment](http://datacenter.kidscount.org/data/tables/5678-pupil-enrollment?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/any/12280)
* [Special Education](http://datacenter.kidscount.org/data/tables/5314-special-education?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/any/14675,11828)
* [Title 1 Students](http://datacenter.kidscount.org/data/tables/5325-title-i-students?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,38/any/11841)
* [Students Qualifying for Free and Reduced Price Lunch](http://datacenter.kidscount.org/data/tables/469-students-qualifying-for-free-or-reduced-price-lunch?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/109,110,111/11515,7665)
* [Kindergarteners in Full-Day Program](http://datacenter.kidscount.org/data/tables/449-kindergartners-in-full-day-program?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/any/11012)
* [High School Graduation Rates](http://datacenter.kidscount.org/data/tables/6134-high-school-graduation-rates?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/any/12806)
* [Dropout Rates by Race and Ethnicity](http://datacenter.kidscount.org/data/tables/7296-dropout-rates-by-race-and-ethnicity?loc=7&loct=10#detailed/10/1278-1457/false/868,867/785,786,787,788,789,790,791,792,3494,2302/14353)
* [Online Pupil Enrollment](http://datacenter.kidscount.org/data/tables/7141-online-pupil-enrollment?loc=7&loct=10#detailed/10/1278-1457/false/36,868,867/any/14171)
* [Remediation in Higher Education](http://datacenter.kidscount.org/data/tables/7663-remediation-in-higher-education?loc=7&loct=10#detailed/10/1278-1457/false/867,133,38/any/14818)
* [3rd Grade Students Scoring Proficient or Above on the CSAP/TCAP](http://datacenter.kidscount.org/data/tables/5651-3rd-grade-students-scoring-proficient-or-above-on-the-csap-tcap?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/129,130,145/12252)
* [8th Grade Students Scoring Proficient or Above on the CSAP/TCAP](http://datacenter.kidscount.org/data/tables/5657-8th-grade-students-scoring-proficient-or-above-on-the-csap-tcap?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/129,130,145/12262)
* [Pupil Enrollment by Race & Ethnicity](http://datacenter.kidscount.org/data/tables/3736-pupil-enrollment-by-race-ethnicity?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/84,87,86,85,88,1849,185,13/11661,7630)
* [AVERAGE PROFICIENCY ON THE CSAP/TCAP BY RACE/ETHNICITY: READING](http://datacenter.kidscount.org/data/tables/6727-average-proficiency-on-the-csap-tcap-by-race-ethnicity-reading?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867/2756,2161,2159,2819,2157,2158,2820,2160/13821)
* [AVERAGE PROFICIENCY ON THE CSAP/TCAP BY RACE/ETHNICITY: MATH](http://datacenter.kidscount.org/data/tables/6567-average-proficiency-on-the-csap-tcap-by-race-ethnicity-math?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867/2756,2161,2159,2819,2157,2158,2820,2160/13563)
* [AVERAGE PROFICIENCY ON THE CSAP/TCAP BY RACE/ETHNICITY: WRITING](http://datacenter.kidscount.org/data/tables/6729-average-proficiency-on-the-csap-tcap-by-race-ethnicity-writing?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867/2756,2161,2159,2819,2157,2158,2820,2160/13823)
