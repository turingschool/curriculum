---
layout: page
title: Command-Line Interface (CLI)
date: 2013-11-06
---

## I1: Persisting beyond a single request.

We can create ideas, but any ideas we create now are ephemeral. They last only
as long as the program is running... which in the case of our tests is less
than 200 milliseconds. If we make ideas in IRB they'll last until we quit IRB.

That's not very useful.

We need to be able to persist ideas beyond just the current running process.

TODO: Introduce YAML::Store
