---
layout: page
title: Heroku Configuation & Setup
section: Environment & Source Control
---

[Heroku](http://www.heroku.com/) is an application platform in the cloud which takes care of managing servers, deployment, and scaling, allowing you to focus your attention solely on your application code.  We love deploying code to Heroku because the whole system was built to be easy. There are just a few steps to get going.

### SSH Keys

Heroku authenticates using SSH keys.

#### On Windows

If you've used RailsInstaller then it generated and saved SSH keys for you; there's nothing to do!

#### MacOS and Linux

If you're on MacOS or Linux there's a decent chance you've already created a set of SSH keys. Look in `~/.ssh/` and if you see files like `id_rsa` and `id_rsa.pub` then you're good to go!

If those files *aren't* present, generate new keys like this:

{% terminal %}
$ ssh-keygen -t rsa
{% endterminal %}

If you choose to use a passphrase, you'd better remember it. If you forget it then you can't use your keys and you might not be able to access important resources like your code and server!

Once that setup completes you're ready to continue.

### Heroku Gem

Heroku has created a gem (https://github.com/heroku/heroku) that makes it ridiculously easy to interact with their service. If you use Heroku for all your projects, consider adding it to your global gemset (in `~/.rvm/gemsets/global.gems`).  Here's how you use it:

{% terminal %}
$ rvm gemset use global
$ gem install heroku
$ bundle install
{% endterminal %}

### Authenticate

Now you're ready to submit your credentials to Heroku. Start by attempting to list your applications:

{% terminal %}
$ heroku list
{% endterminal %}

You'll be prompted for your Heroku.com username and password. If you don't have one, create one: http://www.heroku.com/signup

Once those credentials are entered, you should upload your SSH keys to allow password-less access in the future:

{% terminal %}
$ heroku keys:add
{% endterminal %}


Once that upload completes, you can try `heroku list` again and it should complete *without* asking for a username/password.

## Heroku Basics

Here are some of the most common commands you'll use on Heroku:

{% terminal %}
$ heroku create [<name>] # create a new app; if you omit the 'name' one will be provided for you
$ heroku list            # list your apps
{% endterminal %}

Within the root directory of a project you can use the following `heroku` commands:

{% terminal %}
$ info                         # show app info, like web url and git repo
open                         # open the app in a web browser
rename <newname>             # rename the app
rake <command>               # remotely execute a rake command
console                      # start an interactive console to the remote app
config                       # display the app's config vars (environment)
config:add key=val [...]     # add one or more config vars
db:pull [<database_url>]     # pull the app's database into a local database
db:push [<database_url>]     # push a local database into the app's remote
{% endterminal %}

For more information use `heroku help` or `heroku help TOPIC` (e.g. `heroku help config`).  You can also check out the full list on Cheat (http://cheat.errtheblog.com/s/heroku/) or install the Cheat gem (`gem install cheat`) then display it with `cheat heroku`.

## Heroku Deployment ##

Applications are deployed to Heroku through git.  In order to push to Heroku, you'll need to add it as a remote (repository):

{% terminal %}
$ git remote add heroku git@heroku.com:appname.git
{% endterminal %}

If you don't know what your "appname" is, you can find it easily:

{% terminal %}
$ heroku info --app appname
{% endterminal %}

Now when you're ready to deploy, simply push to your `heroku` remote's `master` branch:

{% terminal %}
$ git push heroku master
{% endterminal %}

You can push any number of branches to Heroku:

{% terminal %}
$ git push heroku my_topic_branch:my_topic_branch
{% endterminal %}


This will create a new "remote" branch in your `heroku` repository.  The `my_topic_branch:my_topic_branch` bit means "push my local branch named 'the-branch-name -_before_-the-colon' and name it 'the-branch-name-_after_-the-colon'".  Most often when you push remote branches those two names will be identical.

Importantly, only the `master` branch on your `heroku` remote triggers deployment.  All other branches are essentially ignored by Heroku.
