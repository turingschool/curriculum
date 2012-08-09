
One of the next big projects is to curate the curriculum for Hungry Academy. That means combining the videos, daily text outlines, and information from Google Calendar into one archive of files that explains how every day of the class ran.

The end product should be like this:

curriculum/
  videos/
    [video_name.mpg]
  outlines/
    01 - week outline.markdown
    02 - week outline.markdown
    ...
  resources/
    0105 - Restful Resources.markdown

video_name.mpg:
Let's name the videos with the date, a sequence number within that date, and a description. For instance, Steve Akers was a guest speaker in Week 8 ("08") on Friday (day 5, "05"). He was video two of the day after lightning talks ("02"), so his video name would be "080502 - Steve Akers on Metrics.mov"

Outlines:

For the outlines and resources we'll use plain markdown text like the existing outlines. These outlines should have as little content as possible, they're basically a set of references to the videos and "resources". Here's a sample from Week 8:

==== BEGIN SAMPLE ====

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
==== END SAMPLE ====


---
Jeff Casimir
Principal, Jumpstart Lab
http://jumpstartlab.com