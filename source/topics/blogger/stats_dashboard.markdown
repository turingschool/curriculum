---
layout: page
title: Stats Dashboard
section: Blogger
---

When the hard work of composing articles is done blog maintainers often want
to start collecting statistics about their accomplishments. Gathering
information about the total articles published, comments across all the articles,
the most popular article and other details.

We want to be a responsible developer so we are going to build this feature
with tests. This will help ensure that we know that the statistics are correct
when we display them.

The goal of this tutorial is to add a "statistics dashboard" to an existing
blog in a test-driven development way.

<div class="note">
<p>This tutorial is open source. Please contribute fixes or additions to <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/topics/blogger/stats_dashboard.markdown">the markdown source on Github.</a></p>
</div>

{% include custom/sample_project_blogger.html %}

## I0: Total Articles

First we want to display the total number of articles that we have written.
This is not a hard statistic to calculate. We want to start with a simple
statistic because we have a lot of other things to learn about testing.

* Creating the `Statistics` object
* Write test to that initializes the object and tests `total_articles`

## I1: Total Comments

* Write test that tests `total_comments`

## I2: Most Popular Article

* Write test that tests `most_popular_article`

## I3: Word Count

* Write test that tests `article_word_counts`
* Write test that tests `article_average_word_count`
* Write test that tests `article_max_word_count`
* Write test that tests `article_min_word_count`

## I4: Building our Dashboard

* Add the route
* Add the controller
* Create our Statistics object instance
* Add the views with the statistics object instance
