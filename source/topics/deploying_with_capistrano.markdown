---
layout: page
title: Deployment with Capistrano
---

Writing code is one thing, getting it into production is another. Let's look at Capistrano, the most widely-used and mature deployment solution for Ruby applications.

## Prerequisites

Capistrano is a deployment tool, not a server management tool. You still need to build up your VPS on your own. To proceed with this tutorial you should:

* Have a Linux-based VPS which has...
  * A user who will own the web processes
  * A folder setup with full write access where code will be deployed
  * SSH keys stored to allow you to login without password


## Introducing Capistrano

Capistrano is not magic. There's not even anything particularly fancy about it. Everything you do in Capistrano could just be done in Bash shell commands.

So why bother? Capistrano...

* Uses an easy-to-understand Ruby DSL
* Helps you write deployment tools that can change and grow easily
* Is widely used and understood

### Getting Started

Capistrano is a gem, so let's install it manually:

{% terminal %}
$ gem install capistrano
{% endterminal %}

Then use the gem's executable to generate a `Capfile`:

{% terminal %}
$ capify .
[add] writing './Capfile'
[add] writing './config/deploy.rb'
[done] capified!
{% endterminal %}

### Digging Into the `Capfile`

Open that `Capfile` and you should see this:

```
load 'deploy'
# Uncomment if you are using Rails' asset pipeline
    # load 'deploy/assets'
load 'config/deploy' # remove this line to skip loading any of the default tasks
```

This file, much like a `Rakefile` **can** hold all the details of your tasks. But, like the `Rakefile`, it's most often used just to load libraries, extensions, or code for Capistrano itself.

If you're using Rails 3 or 4 then you probably *are* making use of the Asset Pipeline, though, so let's uncomment the third line and pull out unneeded comments:

```
load 'deploy'
load 'deploy/assets'
load 'config/deploy'
```

### Digging Into `config/deploy.rb`

This is where it gets interesting. 

The first thing to remember is that **there is no magic**. You're reading, writing, and running a Ruby file. Use all the same techniques you'd use to write great Ruby to write great deploy scripts.

See `set` and `role`? What are they? Just Ruby methods defined by the library.

From here we have to get opinionated. Let's imagine we're deploying our [Blogger project]({% page_url blogger %}) to a Linux VPS running NGINX on the front end and Puma as the Ruby server.

If we strip away all the comments and a less-frequently used secondary Database, our `deploy.rb` is just:

```
set :application, "set your application name here"
set :repository,  "set your repository location here"

role :web, "your web-server here"
role :app, "your app-server here"
role :db,  "your primary db-server here", :primary => true
```

#### `set :application`

Nothing too surprising here, just give it a name without spaces.

```
set :application, "blogger"
```

#### `set :repository`

Capistrano is going to default to using Git. Here you should give an SSH URL like so:

```
set :repository, "git@github.com:JumpstartLab/blogger.git"
```

Now, it's unlikely that the app you're deploying is a public project on GitHub like that Blogger.

Remember that, under the hood, Capistrano is executing shell commands. What would you have to do to clone the project yourself, like...

```
git clone somethingsomethingsomething
```

If you can figure out what the `somethingsomethingsomething` is for your particular setup, then that's what should be passed into `set :repository`.

#### `role :web`

If you're bothering with Capistrano then you're likely smart enough to be running a reverse-proxy web server on your VPS, like Apache or NGINX. The latter is a bit more popular, so let's modify the line to this:

```
role :web, "nginx"
```

##### Install `capistrano-nginx`

https://github.com/ivalkeen/capistrano-nginx

#### `role :app`

The reverse proxy has to send your requests somewhere. We're fans of the [Puma web server](https://github.com/puma/puma):

```
role :app, "puma"
```

##### Install `Capistrano::Puma`

https://github.com/xijo/capistrano-puma

## Setup the Server

{% terminal %}
$ cap nginx:setup
$ cap deploy:setup
{% endterminal %}

## References

* http://guides.beanstalkapp.com/deployments/deploy-with-capistrano.html
