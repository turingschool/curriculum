---
layout: page
title: Curriculum Building
---

## Goal

We need to organize the curriculum materials for publishing online and for revision towards future classes. Imagine that people are going to come and cherry pick an individual topic that we covered -- they should be able to easily find the outline, the text resources, and the video for that segment.

The end product will be a collection of files/folders like this:

```
curriculum/
  videos/
    [video_name.mpg]
  outlines/
    01 - week outline.markdown
    02 - week outline.markdown
    ...
  resources/
    0105 - Restful Resources.markdown
```

### Videos

#### Strategy

It would be nice for the videos to be cut small enough such that they match up one-to-one with the outline. So a morning of class might result in one, two, or in some rare case three videos.

#### `video_name.mpg`

Let's name the videos with the date, a sequence number within that date, and a description. For instance, Steve Akers was a guest speaker in Week 8 ("08") on Friday (day 5, "05"). He was video two of the day after lightning talks ("02"), so his video name would be "080502 - Steve Akers on Metrics.mov"

#### Video Format

Videos should be exported at 50% of the original recording resolution.

### Outlines

#### Source Files

The original outlines used in class are here:

https://github.com/JumpstartLab/curriculum/tree/master/source/academy/sessions

They'll be a good starting point, but will need tons of work to fit the format below and, most importantly, pull out the "Resources" which we often wrote right in the daily outline.

#### Desired Structure

For the outlines and resources we'll use plain markdown text like the existing outlines. These outlines should have as little content as possible, they're basically a set of references to the videos and "resources". Here's a sample from Week 8:

```
# Week 8

## Day 1

### Class: Simulating Load & Code Performance

* Tutorial: resources/080101 - Simulating Load and Code Performance.markdown
* Video: videos/080101 - Simulating Load and Code Performance.mov

### Reading Group: Book Name(?)

* Instructions: resources/080102 - Reading Group for (Book Name).markdown

### Project

* Assignment: resources/080103 - Son of Store Engine.markdown

## Day 2

### Measuring Performance

...
```

### Resources

The resources are the units of text. Anything that it it's own subject should be broken into an individual resource file.