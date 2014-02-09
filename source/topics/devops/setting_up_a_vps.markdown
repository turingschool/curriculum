---
layout: page
title: Setting Up a VPS
section: DevOps
sidebar: true
---

You built an app, got excited and deployed it easily on Heroku. But after several thousand users, you ended up paying thousand of dollars to keep it running. You looked for other alternatives, and you decided to give a VPS a try.

## What is a VPS?

A VPS, or virtual private server, is a virtual machine that runs on someone else's infrastructure.

A VPS can run it's own OS and applications indepedently of other virtual machines that live in the in the same infrastructure. This allows companies to sell access, space and time in their servers to various customers without conflicting to each other.

There are many VPS prodivers, such as DigitalOcean and Linode out there. Just make sure to read reviews online and ask your peers before making a choice.

## Setup

1. Install CentOS (it might be preinstalled)
2. Initial Setup
  1. SSH (Secure Shell) into Server
  2. Change your password
  3. Create a new user
  4. Give your new user root privilages
  5. Configure SSH (optional)
  6. Reload SSH (Secure Shell)
3. Preparing the Server for Deployment
  1. Update your OS
  2. Install the development tools
  3. Add the EPEL (Extra Packages for Enterprise Linux)software repository
  4. Install `curl-devel`
  5. Install `sqlite-devel`
  7. Install `libyaml-devel`
  8. Install nano text editor (optional)
4. Install Postgres (if necessary)
  1. Exclude CentOS postgres packages
  2. Add Postgres repositories
    1. Find the repository
    2. Dowload the repository
    3. Install the repository
  3. Install `postres-server` via yum
  4. Configure postgres to start on boot
5. Setting Up Ruby Environment and Rails
  1. Install RVM (Ruby Version Manager)
  2. Install Ruby
  3. Install Node.js
  4. Install Rails
6. Install the server applications
  1. Install Phusion Passenger
  2. Install Nginx via Passenger
  3. Install Git
  4. Clone your app to /var/www/application_name
  5. Create Nginx Management Script
7. Configure Nginx
  1. Open Configuration file: nano /opt/nginx/conf/nginx.conf
  2. Define your application root
  3. Restart NGinx