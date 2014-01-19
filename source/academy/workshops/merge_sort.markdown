---
layout: page
title: Merge Sort Workshop
---

> Merge sort is an O(n log n) comparison-based sorting algorithm. Most implementations produce a stable sort, which means that the implementation preserves the input order of equal elements in the sorted output. Merge sort is a divide and conquer algorithm that was invented by John von Neumann in 1945.[1] A detailed description and analysis of bottom-up mergesort appeared in a report by Goldstine and Neumann as early as 1948.[2]

~ [Wikipedia](http://en.wikipedia.org/wiki/Merge_sort)

![Merge Sort in Action](/images/merge_sort.gif)

## Goals

The goal of this workshop is to create an implementation of the [merge sort](http://en.wikipedia.org/wiki/Merge_sort) algorithm.

During the course of the workshop the emphasis is *not* on completing the implementation within the timeframe provided. It is about choosing and following a path for growth.

Your path may be to understand the problem in a new way or to build an implementation in another language. You may find yourself drawn to a path which emphasizes the process or the tools you use as a craftsman. It may not even be a technical path but one in which you emphasize communication with your peer.

Use this workshop as an excuse to try something different and to fail. As the code itself you write today will not be useful, it's about the process.

## Schedule

* Introduction (15 minutes)
* First Session (40 minutes)
* Break (10 minutes)
* Second Session (40 minutes)
* Retrospective (15 minutes)

### Step 1: Setup

We've setup a repository to conduct your work. In this project you'll find several folders, each representing a path you might choose.

Clone the repository from GitHub:

```
git clone git://github.com/JumpstartLab/workshop_mergesort.git
```

{% archive jumpstartlab@workshop_mergesort setup Download a Zip %}
If you don't have Git, click here to download the repository as a zip file.
{% endarchive %}


### Step 2: Select a Path & Partner

We'd recommend you not go it alone, please find someone to pair with.

Either...

* choose a person that you want to work with and decide on a path, or
* choose a path and find someone willing to attempt it with you

#### Selection Suggestions

What will you practice?

* Consider a new language
  * Feel comfortable with Ruby? Maybe select a less common dialect like JRuby or Rubinius. What specialized tools or techniques could you take advantage of?
  * Interested in functional programming? Maybe try Scala.
  * What would it be like to implement some parts in Ruby, and some in a C extension?
  * In JavaScript? CoffeeScript?
* An emphasis on code [clarity](http://c2.com/cgi/wiki?TwoTypesOfCodeClarity) or structure
  * Could you build it with no methods?
  * Using only one-line methods?
  * Using no if or case statements?
* A test driven approach
  * Using Test::Unit
  * Using RSpec and pushing yourself into less-common syntax
  * Using Jasmine
  * Using Cucumber or Turnip
* Utilizing different development tools
  * If you're a SublimeText/Textmate person, what about Vim?
  * If you're a Vim person, what about Emacs?
  * If there were such a thing as an Emacs person, what about pencil & paper?
* Emphasizing the partnership
  * What if you didn't talk?
  * What if one person writes tests, the other writes implementation?

You are encouraged to define your own path if none of these options appeal to you.