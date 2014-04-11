---
layout: page
title: Why Heroku
section: Salesforce Elevate
sidebar: true
back: /elevate
---

Heroku claims to be "cloud computing designed and built for developers." But why do you care?

## Focused on Ease of Development

From the beginning Heroku has focused on being easy for developers. 

### Just Use a VPS?

Many developers can stumble through setting up a VPS, following a myriad of tutorials and blog posts to setup a functioning web server with:

* Linux
* NGINX or Apache front-end web server
* Their application
* Application Virtual Machine (JVM, Ruby VM, etc)
* Application dependencies
* PostgreSQL with user accounts and permissions
* Memcached or other secondary data stores
* Load balancing
* Init.d scripts to handle graceful restart
* A deployment system to receive code and restart the application

It'll likely take days to get that configured correctly.

### Fully Managed Platform

And now you have a management issue. Each of those components:

* Has potential security vulnerabilities to keep on top of
* Releases new versions and should be upgraded
* Can crash/restart and need attention

If you'd prefer to spend your time building your application rather than administrating a server, Heroku is for you.

### Quick to Provision, Quick to Deploy

You can provision a new application on Heroku in seconds. Deploying your code and restarting your processes typically takes just a few minutes.

### Industry Standards

And best of all, using Heroku doesn't mean compromising on your development tools or workflow. Typical Heroku apps rely industry-standard tools:

* Git for source control
* Applications written in a modern, open-source language
* A SQL database
* UNIX under the hood

### Rich Configurability with Add-Ons

Just because the platform takes care of the administration doesn't mean you're locked into a single pattern or set of defaults. You can customize your application to:

* use other databases like MongoDB or Hadoop
* integrate with services to send Email, SMS and push notifications to users
* shuttle runtime data to a variety of analytics and logging platforms
* work with third-party billing systems to handle one-time and subscription payments

There are over a hundred add-ons available on the platform with new ones constantly being added. Check out the full list at https://addons.heroku.com/.

## Use Cases

Heroku can be put to use in many scenarios.

### Web Applications of Any Scale

Thanks to the **dyno** approach, applications running on Heroku scale with ease. 

Need to serve just a few requests an hour? Spin up a pair of dynos and you're good to go.

Need to serve a hundred requests per second? Scale up to fifty dynos and watch the traffic fly.

### Rapid Development & Deployment

Heroku excels in situations where applications need to deploy quickly and often. Teams might individually deploy their latest changes or rely on a Continuous Integration server to deploy continuously. After issuing just a single command, applications typically deploy and are live in seconds. Backed by git, it's easy to avoid conflicts or rollback changes when something goes wrong.

Long story short, Heroku takes the pain out of running your web applications.

### Getting Started

Assuming you have an existing Salesforce dataset, your first Heroku applications might include:

* A one-page application to register people in a sweepstakes, funneling their information into Salesforce
* An analytics platform that pulls data out of Salesforce to generate visualizations using Node.js and D3
* A content-management system that authenticates users via your Salesforce login/password
* A web application that implements Salesforce's Canvas API, adding functionality into Salesforce itself

## Goals for Today

Our plan for today is to explore the platform and experiment with deployment. By the end of the day you will:

* understand how the platform works and what it can do for you
* provision and deploy a live Java-based application
* scale the production environment to handle more traffic
* install and configure an add-on to support your application
* see how Heroku Connect opens huge potential for your Salesforce data
