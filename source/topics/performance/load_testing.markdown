---
layout: page
title: Load Testing
section: Performance
---

Imagine that you are launching a national health care website. You need to make sure that *a lot* of people can use the site at the same time without it falling
over.

## Load Testing

Load testing is one approach to figuring out how quickly pages load under different conditions, in particular when several users are using the site
concurrently.

### Apache Bench

A popular tool is ApacheBench. It was originally developed to test the Apache server, but it is generic enough that it can test any server, whether it is running locally on your machine, or out on the internet. It comes pre-installed on MacOS.

### How Reliable Are The Results?

If you use ApacheBench to test a server that is *not* on the local network, you will also be seeing network latency. On one hand you can't control those middle-men in the network, but on the other hand you're seeing the results as the user will see them.

When you do benchmarking of any kind you need to run the tests many times to reduce the impact of secondary factors (like your computer's memory swapping, other processes taking CPU time, etc). Make sure to close other applications running on the test system.

The hardware of the test machine matters. The more CPU power you have the more requests you can churn out.

## Getting Started

We will be using the [dissaperf](https://github.com/JumpstartLab/dissaperf) repository for these exercises. Start by cloning this repository:

{% terminal %}
$ git clone git@github.com:JumpstartLab/dissaperf.git
$ cd dissaperf
{% endterminal %}

Then `bundle.`

## Comparing Ruby Web Servers

Let's start by benchmarking the different options for Ruby web servers. We'll run tests against the following:

* `WEBrick`
* `unicorn`
* `thin`
* `puma`

### Beginning with WEBrick

Let's start simple with `WEBrick`. 

#### Start the Server

Boot the app using `rackup`:

{% terminal %}
$ rackup -s webrick -p 9000
{% endterminal %}

#### Simulating Users

Now, with the server running, open another tab in your terminal window using `CMD+T`.

Imagine that 10 users are accessing your app at the same time, each of them making 10 requests. Let's mimic the load with ApacheBench:

{% terminal %}
$ ab -n 100 -c 10 http://0.0.0.0:9000/
This is ApacheBench, Version 2.3 <$Revision: 655654 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 0.0.0.0 (be patient).....done


Server Software:        WEBrick/1.3.1
Server Hostname:        0.0.0.0
Server Port:            9000

Document Path:          /
Document Length:        13 bytes

Concurrency Level:      10
Time taken for tests:   0.320 seconds
Complete requests:      100
Failed requests:        0
Write errors:           0
Total transferred:      29000 bytes
HTML transferred:       1300 bytes
Requests per second:    312.81 [#/sec] (mean)
Time per request:       31.968 [ms] (mean)
Time per request:       3.197 [ms] (mean, across all concurrent requests)
Transfer rate:          88.59 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       1
Processing:    12   29  11.1     26      66
Waiting:        6   27  11.1     23      61
Total:         12   29  11.1     26      66

Percentage of the requests served within a certain time (ms)
  50%     26
  66%     30
  75%     33
  80%     34
  90%     48
  95%     57
  98%     59
  99%     66
 100%     66 (longest request)
{% endterminal %}

### Understanding the Parameters

When we run ApacheBench like this:

{% terminal %}
$ ab -n 100 -c 10 http://0.0.0.0:9000/
{% endterminal %}

We're specifying:

* `-n` configures the number of total requests
* `-c` configures the number of concurrent requests
* `-t` configures the maximum wait for responses
* `-p` sends a file containing data via a POST request
* `-u` sends a file containing data via a PUT request
* `-T` specifies the content-type for POSTing or PUTing when sending a file
* `-e` specifies an output file to save results

### Triggering Failure

Increase the number of total requests and concurrent requests until you cause the server to crash. Make sure the total requests are larger than the number of concurrent requests, like this:

{% terminal %}
$ ab -n 500 -c 100 http://0.0.0.0:9000/
{% endterminal %}

### Saving the Results

You may want to generate the results to a CSV file, so that you can graph the results:

{% terminal %}
$ ab -n 10 -c 2 -e filename.csv http://0.0.0.0:9000/
{% endterminal %}

After you run the command, a `filename.csv` file will be created in the directory that you executed the command. Open it to see all the response data.

{% terminal %}
$ open filename.csv
{% endterminal %}

### Testing Other Servers

At this point, swap in the other server options (Thin, Puma, and Unicorn) and run your tests. Which respond fastest? Which are the most fault-tolerant?

### Slower Requests

Choose one web server and run some extra tests against a slower endpoint:

{% terminal %}
$ ab -n 10 -c 2 http://0.0.0.0:9000/slow
{% endterminal %}

And compare the results to the faster page:

{% terminal %}
$ ab -n 100 -c 10 http://0.0.0.0:9000/
{% endterminal %}

How do the stats compare? What implications can you draw about the overhead involved?

### Sending Data

The `-p` flag lets you perform `POST` requests, passing a file that contains the data that will be submitted as the POST body. The `-T` lets you specify the data you are sending.

We have included some JSON data in the `/data` folder:

* `small.json`
* `medium.json`
* `large.json`
* `huge.json`
* `ginormous.json`

Let's send a POST request to your your app with the `small.json` file.

{% terminal %}
$ ab -n 10 -c 2 -p data/small.json -T 'application/json' http://0.0.0.0:9000/
This is ApacheBench, Version 2.3 <$Revision: 655654 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 0.0.0.0 (be patient).....done


Server Software:        WEBrick/1.3.1
Server Hostname:        0.0.0.0
Server Port:            9000

Document Path:          /
Document Length:        41 bytes

Concurrency Level:      2
Time taken for tests:   0.051 seconds
Complete requests:      10
Failed requests:        0
Write errors:           0
Total transferred:      3180 bytes
Total POSTed:           8970
HTML transferred:       410 bytes
Requests per second:    197.99 [#/sec] (mean)
Time per request:       10.101 [ms] (mean)
Time per request:       5.051 [ms] (mean, across all concurrent requests)
Transfer rate:          61.49 [Kbytes/sec] received
                        173.44 kb/s sent
                        234.92 kb/s total

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       0
Processing:     6   10   3.1      9      14
Waiting:        5    9   2.9      9      14
Total:          6   10   3.1     10      15

Percentage of the requests served within a certain time (ms)
  50%     10
  66%     10
  75%     13
  80%     15
  90%     15
  95%     15
  98%     15
  99%     15
 100%     15 (longest request)
{% endterminal %}

Experiment with the various `json` files, and also vary the number of total requests and concurrent requests.

How does the server hold up?

## Optional: Plotting Data

You can use d3 to plot data in csv files (`-e`), or GNUplot to plot data in tab delimited files (`-g`) if you're happier on the command line.

## For Further Reading

* Checkout [JMeter](http://jmeter.apache.org/), also from Apache, for more advanced test suites
