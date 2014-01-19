---
layout: page
title: Git for Pairs
---

There is only one person who *knows* Git: Linus Torvalds. The rest of us just know enough to *use* Git.

When working in a pair, your usage of Git can be the difference between successful collaboration and total frustration.

## Your Local Machine

### The Latest Git

You can use Homebrew to confirm that you've got the latest version of Git:

{% terminal %}
$ brew update
$ brew install git
{% endterminal %}

Git does a great job of version compatability. It typically only adds features over time, so even if developers on the same team are using different versions, there isn't an issue.

### Global Ignore

One small thing you want to do locally is make sure you're not **that** developer who checks in the `.DS_Store` file into your repository. Add it to your _global ignore_ file:

{% terminal %}
$ git config --global core.excludesfile ~/.gitignore
$ echo .DS_Store >> ~/.gitignore
{% endterminal %}

### Autocomplete

Git has a library which can be loaded into your terminal to add autocomplete to many Git commands, branches, etc. You want this line in your `.bash_profile`:

```
source /usr/local/etc/bash_completion.d/git-completion.bash
```

You can add it there and reload your `.bash_profile` like this:

{% terminal %}
$ echo 'source /usr/local/etc/bash_completion.d/git-completion.bash' >> ~/.bash_profile
$ source ~/.bash_profile
{% endterminal %}

## Reviewing Git Theory

* A repo is a repo
* Progress is tracked through history
* Git remotes share a common history connection
* Git tracks changes, not files

### Branches

Git "won" because of branching and merging

#### The `master` Branch

* `master` branch should always be runnable
* Only commit to master when a feature is "done" - written & tested

#### Feature Branches

When you start working on a new feature or component, the first thing you should do is start a feature branch.

Say I'm starting a feature about tracking customer contact information. I could start a branch like this:

{% terminal %}
$ git checkout -b customer_contact_info
{% endterminal %}

Then make my commits to that branch as normal. If I want to push that branch to a remote, such as GitHub, I could do this:

{% terminal %}
$ git push origin customer_contact_info
{% endterminal %}

Let's say that, while I'm working on that feature, my team is also working on their own features. Maybe their features finish and get committed to master. I want to merge the latest code from `master` into my feature branch:

{% terminal %}
$ git merge master
{% endterminal %}

Then, finally, my feature is complete and is ready to merge into `master`:

{% terminal %}
$ git checkout master
$ git merge customer_contact_info
{% endterminal %}

Then I can delete the feature branch after the merge:

{% terminal %}
$ git branch -d customer_contact_info
{% endterminal %}

##### Merge Conflicts

Uh oh. You and another developer changed the same lines of the same files and Git can't figure out how to resolve the changes.

Your best bet is to jump into the files with conflicts and attempt to resolve them manually.

You can try running the visual merge tool available on your system:

{% terminal %}
$ git mergetool
{% endterminal %}

If you get into `vimdiff` and want to get out, try `:q`.

#### Next Steps and Topics

That's pretty much all you'll need for now. Some topics for future learning include:

* Rebasing
* Tracking Remote Branches
* Cherry Picking
