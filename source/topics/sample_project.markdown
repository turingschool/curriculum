---
layout: page
title: Sample Project - Blogger
---

For these tutorials we've built a very simple three-model sample project named Blogger. You can use it to complete all the exercises and experiments described.

## Check Out the Code

From your terminal, change to a directory where you want to store your project. Then, checkout the code from GitHub:

```
git clone http://github.com/JumpstartLab/blogger_advanced.git
cd blogger
```

<div class="note">
  <p>If you're using RVM, it will ask if you want to trust the include <code>.rvmrc</code> file. Type <code>yes</code> and hit enter.</p>
</div>

### Setup Initial Dependencies

Then you'll want to run the Bundler system to resolve and install dependencies:

{% terminal %}
$ bundle
{% endterminal %}

### Development Database

The repository has a database with a few sample articles in it to make your testing easier. But we don't want to bother with committing that file every time we change the data. Tell Git to ignore changes to that file with this instruction:

{% terminal %}
$ git update-index --assume-unchanged db/development.sqlite3
{% endterminal %}

## Use Pattern

Unless otherwise specified, the exercises for a single section are designed to be completed independently of the other sections. You should always start with this original copy of Blogger.

### Starting a Branch

The easiest way to manage that is by creating a branch. If we are starting the section entitled "Local Authentication with Devise", you could create and checkout a branch like this:

{% terminal %}
$ git checkout -b local_authentication
{% endterminal %}

### Bring Up a Server, Console, and Terminal

It's a good idea to open three command windows or tabs:

1. Run your server with `bundle exec rails server`
2. Run your console with `bundle exec rails console`
3. Have available for command-line operations like running generators, Rake, etc.

### Completing the Exercises

You can then work through the exercises. It'd be a good idea to commit your results after each exercise, like this:

{% terminal %}
$ git add -A .
$ git commit -m "Completed local_authentication exercise 1"
{% endterminal %}

<div class="note">
<p>The `-A` flag above will cause any files deleted from the filesystem to be removed from the branch in Git.</p>
</div>

### Reset

When you complete a section, run `git status` to make sure there are no un-committed changes. 

Then switch back to the master branch so you're ready to start the next section:

{% terminal %}
$ git checkout master
{% endterminal %}

## Other Git Tips

* Want to trash everything since your last commit? Run `git reset --hard`
* Want to try an experiment while doing exercises? You can branch from a branch using the same `git checkout -b branch_name` when you're on the source branch.
* Forget the name of your branch? Run `git branch` and you'll see a list of all branches with an `*` next to the current one.
* Curious what files have been changed? Run `git status`
