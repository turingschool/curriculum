---
layout: page
title: "Load Testing"
---


Imagine that you are launching a health care website, and you need to make
sure that a lot of people can use the site at the same time without it falling
over.

Load testing is one approach to figuring out how quickly pages load under
different conditions, in particular when several users are using the site
concurrently.

A popular tool that ships with Mac OS X by default is called apachebench. It
was originally developed to test the Apache server, but it is generic enough
that it can test any server, whether it is running locally on your machine, or
out on the internet.

Note that if you use apachebench to test a server that is not on the local
network, you will also be seeing network latency effects, and so the
measurement won't necessarily point you to problems in your own application.

When you design a test, you will want to run each command 3-5 times.

Notice the variance.

Hardware matters. Also other applications on your computer will be using
resources simultaneously, and this will also affect the outcome.

## Exercises

We will be using the [dissaperf](https://github.com/JumpstartLab/dissaperf) repository for these exercises.

Do the setup.

### Comparing Ruby Web Servers

Each exercise should be run against the following servers:

* `WEBrick`
* `unicorn`
* `thin`
* `puma`

#### Baseline

Do 5 measurements against the `GET /` endpoint for each server.

* `-n` configures the number of total requests
* `-c` configures the number of concurrent requests

You can increase the total requests. It should always be more than number of
concurrent requests.

```plain
ab -n 10 -c 2 http://0.0.0.0:9000/
```

Vary the number of total requests and concurrent requests.

You may want to generate the results to a CSV file, so that you can graph the
results:

```plain
ab -n 10 -c 2 -e filename.csv http://0.0.0.0:9000/
```

How do the servers compare?

When do the servers start failing hard?

#### Slower Requests

Choose one web server and run some extra tests against a slower endpoint:

```plain
ab -n 10 -c 2 http://0.0.0.0:9000/slow
```

How do the stats compare to the baseline measurements?

#### Accepting Data

There are a number of `json` files containing contact information:

* `small.json`
* `medium.json`
* `large.json`
* `huge.json`
* `ginormous.json`

The `-p` flag lets you perform `POST` requests, passing a file that contains
the data that will be submitted as the POST body. The `-T` lets you specify
the data you are sending..

```plain
ab -n 10 -c 2 -p data/small.json -T 'application/json' http://0.0.0.0:9000/
```

Experiment with the various `json` files, and also vary the number of total
requests and concurrent requests.

How does the server hold up?

### Optional: Plotting Data

You can use d3 to plot data in csv files (`-e`), or GNUplot to plot data in tab
delimited files (`-g`) if you're happier on the command line.

