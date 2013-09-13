---
layout: page
title: Building an Identity
---

It's important that you start to build a representative and consistent identity. The Ruby world is very network dependent, and your identity/network will have a significant impact on your future.

Several to-do items for you:

* Take your new headshot and associate it with all your email addresses on [Gravatar](http://gravatar.com)
* Setup an account on [Twitter](http://www.twitter.com) if you haven't already
* Make sure your Github profile is complete and has your email and twitter accounts
* Create a professional blog using the notes below

### Setting Up Your Class/Professional Blog

* Create a [Github Account](http://github.com)
* [Generate](https://help.github.com/articles/generating-ssh-keys) and add an [SSH Key](https://github.com/settings/ssh) to your account.

* Visit [https://github.com/JumpstartLab/gschool-blog](GSchool Blog)
* Fork the Repository
* Using your Terminal, use `cd` to switch to a folder where you store your projects. During the next step, the `git clone` command will create a folder in that directory called "gschool-blog"
* Clone the Repository you forked to your system

{% terminal %}
$ git clone git@github.com:YOURNAME/gschool-blog.git
{% endterminal %}

* Download all the project dependencies

{% terminal %}
$ cd gschool-blog
$ bundle install
{% endterminal %}

* Run the Middleman Blog

{% terminal %}
$ middleman
{% endterminal %}

* Visit the [blog](http://localhost:4567) in your browser

* Remove the existing articles

{% terminal %}
$ git rm source/2012-01-01-example-article.html.markdown
$ git rm source/2013-01-23-introduction.html.markdown
$ git commit -m "Removed sample articles"
{% endterminal %}

* Create your first article

{% terminal %}
$  middleman article "gSchool - Week 0"
{% endterminal %}

* Write an article with your recap/reflections of the first week.

* Save the article

{% terminal %}
$ git add source
$ git commit -m "Wrote First Article"
{% endterminal %}

* Push your changes back to Github

{% terminal %}
$ git push origin master
{% endterminal %}

* Create a Heroku Account
* Download the [Heroku Toolbelt](https://toolbelt.heroku.com/)

{% terminal %}
$ heroku login
Enter your Heroku credentials.
Email: adam@example.com
Password:
Could not find an existing public key.
Would you like to generate one? [Yn]
Generating new SSH public key.
Uploading ssh public key /Users/adam/.ssh/id_rsa.pub
{% endterminal %}

* Create a Heroku application

{% terminal %}
$ heroku create
$ git push heroku master
{% endterminal %}