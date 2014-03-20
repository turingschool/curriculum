---
layout: page
title: Java + Salesforce + Heroku
section: Salesforce Elevate
sidebar: true
alias: [ /elevate ]
---

## Welcome

### Schedule

* 8:00 - Doors Open & Systems Setup
* 9:00 - Intros & Opening
* 9:10 - How Heroku Works
* 10:00 - Deploying Java Applications to Heroku
* 12:00 - Lunch
* 1:00 - Integrating Salesforce
* 2:30 - Heroku Platform
* 3:30 - Q&A
* 4:00 - Class Ends

### Systems Setup

To get the most out of the workshop you should be working along with us. Before we get going, please go through the following setup steps.

#### Accounts

(Heroku and Salesforce Dev accounts)

#### Git

We'll need Git to handle source control and facilitate pushing code to Heroku. You can find installer packages for any platform at http://git-scm.com/downloads or:

* On Linux, use apt: `sudo apt-get install git-core`
* On MacOS [use Homebrew](http://brew.sh) if it's installed: `brew install git`
* On Windows, [download the installer](http://git-scm.com/download/win)

#### Java

#### Play

#### Sample Application

#### Heroku Toolbelt

Install the Heroku Toolbelt following the instructions here: https://toolbelt.heroku.com/

#### Verify Functionality

( run the application locally and make sure it's ok! )

## Hosting on Heroku

Heroku is a cloud hosting platform focused on serving developers. Before you can get your application up and running we should discuss how the platform works.

[Note: This will become / be supported by a slide deck]

### High Level

The Heroku platform supports applications written Ruby, Node.js, Java, Python, Clojure, and Scala. It falls in the domain of "Platform as a Service" (PaaS), allowing developers to focus on building their application while the platform deals with the intricacies of servers and deployment.

The power of Heroku is that you need to know, worry, and care *very little* about the systems that are used to run your application. Instead your energy goes into building your app.

### Git as Transport Mechanism

There are many options for moving code between servers. Many devs have used FTP, SCP, or network shares. But Heroku relies on Git.

#### Why Git?

Heroku made a big bet on Git back in the mid-2000s, and since then Git has come to dominate modern application development. It's the Source Control Management (SCM) option chosen by most new applications and teams.

#### Heroku as Git Remote

If you're using Git, then shipping code to Heroku is easy. A Git repository typically has one or more remotes. These often have names like `origin` and point to the places where you host and share code with colleagues, like Github.

You can think of Heroku as a big Git server. When you "create" an application, the end result is that you have a new Git server that you can push code to.

#### Just Like Any Other Remote

The SSH-style URL for an application looks like this:

```plain
git@heroku.com:name_of_your_application.git
```

When you create an app on Heroku, the toolbelt will add a remote named `heroku` with your app's correct URL. If you wanted to do it manually, however, it's just the same as any other Git remote:

{% terminal %}
$ git remote add heroku git@heroku.com:name_of_your_application.git
{% endterminal %}

#### Now It's Just Git

Once Heroku is a remote for your repo, you can:

1. Push code
2. *Pull* code
3. Use Heroku as the place where you store your code (instead of Github)

Typically, though, you're only going to exercise option 1.

### Building a Slug

Once the code is transferred, Heroku starts building a **slug**. A slug is a compressed archive containing your application code, configuration, and any dependencies (like external libraries).

This slug is then a self-contained, ready to run version of your application. It just needs to be started.

### Dynos Run Slugs

You can think of a dyno like a single-purpose computer. A dyno can take a slug and run it, making the application available to the world.

#### One Dyno, One Slug

A single dyno can only run one slug. You can still use techniques like threading to achieve some parallelism in your code, but a dyno cannot be shared by multiple slugs. You can't reliably start multiple processes on a single dyno.

#### One Slug, Many Dynos

The converse is not true. That slug is just a zipped up version of your application. It can be copied to and booted by multiple dynos. To support real-world traffic, many applications utilize eight or more dynos all running copies of the same slug.

### Responding to Requests

A slug is built and started up on one or more dynos, then what?

#### A Request Arrives

A request comes into Heroku's front end and, based on the requested domain, the router figures out that the it belongs to your application.

#### The Routing Mesh

Then the router has to find the dyno running your code. The "Routing Mesh" approach allows that request to be dispatched to any of the dynos running the application.

#### Routing is Random

There are several approaches to distributing work among multiple workers, which is the pattern in place here with dynos, each with their own advantages and drawbacks.

Heroku's chosen to randomize requests as they come through the mesh due to the low coordination overhead. When a request comes in you don't know and shouldn't care which of your dynos it gets routed to. The next request from the same user will likely get routed to a different dyno, and that shouldn't matter to your application.

#### External Data

Most web applications needs to store data in a traditional database, an in-memory store, on the filesystem, or some combination there of.

But if you have multiple dynos all responding to requests, that can be tricky. If my first request goes to Dyno A, stores data, then my next request goes to Dyno B, will the data be there?

Heroku separates the concept of the data store from the web application. If you were setting up a VPS you might run the application and database on the same machine and communicate over UNIX sockets. But you could also use TCP/IP.

Heroku hosts database instances, and in fact provisions an instance of PostgreSQL for your application when you first create it. That database instance is accessible over TCP/IP, so *all* your dynos can access it simultaneously.

And Heroku stores the location of the database in environment variables accessible to all your dynos, so once one dyno can reach the database then all of them can. You can scale up dynos with no additional configuration.

The same approach holds true for the filesystem. Heroku recommends you consider the dyno's filesystem to be "read only". If you need to store files, push them out to Amazon's S3. Put the credentials in your application configuration and they'll be shared by all dynos.

Need an in-memory store like Redis or Memcached? Install one of the many addons (which we'll talk about later) and all the dynos can reach it.

### Recap

* You transfer code to Heroku by using `git push`
* Heroku builds an archive of your ready-to-run application called a **slug**
* A slug gets copied to and run on one or more **dynos**. The more dynos you run, the more traffic you can support.
* Requests come in to Heroku's **Routing Mesh** and a dispatched to one of your dynos randomly
* All dynos can *share data* so you don't care which dyno is actually serving the request

## Deploying Java Applications on Heroku

### Using the Toolbelt

### Creating an Application

### Pushing via Git

### Checking Status

### Updating Your Application

## Integrating Salesforce

## Maximizing Heroku's Platform

### Scaling Web Processes

### Migrating Databases

### Collaborators and Other Configuration

### Understanding Add-Ons

### Measuring Application Performance

## Next Steps
