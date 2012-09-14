---
layout: page
title: Creating a Logger
---

## Understanding and Debugging Ruby

As a developer you spend some small fraction of your time writing code, the rest of it is spent understanding what's already been written and debugging. Today we're going to go through a few techniques to make that easier. Ruby tries to help you read error messages. Let's intentionally create a few errors and breakdown the issues in a pairing exercise.

### Creating a Logger

Those approaches all involve outputting text in the middle of your display, which can be distracting and difficult to read. It also doesn't provide a historical record.

How could we send messages to a log file in the background? Let's try building a customized logger for our application.

[API Reference](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/logger/rdoc/Logger.html)