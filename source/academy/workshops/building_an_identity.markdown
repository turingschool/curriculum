---
layout: page
title: Building an Identity
---

It's important that you start to build a representative and consistent identity. The Ruby world is very network dependent, and your identity/network will have a significant impact on your future.

Several to-do items for you:

* Take your new headshot and associate it with all your email addresses on [Gravatar](http://gravatar.com)
* Setup an account on Twitter if you haven't already
* Make sure your Github profile is complete and has your email and twitter accounts
* Create a professional blog using the notes below

### Setting Up Your Class/Professional Blog

* Create a [Github Account](http://github.com)
* [Generate](https://help.github.com/articles/generating-ssh-keys) and add an [SSH Key](https://github.com/settings/ssh) to your account.

* Visit [https://github.com/JumpstartLab/gschool-blog](GSchool Blog)
* Fork the Repository
* Clone the Repository to your system

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
$ git commit -m "Removed old articles"
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

* Create a Heroku Account
* Add your SSH key to your [Heroku account](https://dashboard.heroku.com/account)

* Install the heroku tools
* Create a heroku server

{% terminal %}
$ gem install heroku
$ heroku create --stack cedar
$ git push heroku master
{% endterminal %}

* Push your changes back to Github

{% terminal %}
$ git push origin master
{% endterminal %}