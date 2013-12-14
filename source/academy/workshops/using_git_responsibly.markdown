---
layout: page
title: Using Git Responsibly
---

## Intro

Watch the lightning talk [Do Your Commit Messages Suck?](http://www.confreaks.com/videos/744-rockymtnruby2011-lightning-talk-do-your-commit-messages-suck) by [Ryan McGeary](https://twitter.com/rmm5t) from Rocky Mountain Ruby Conference 2011

## Exercise 1

Check out the [bundler](https://github.com/bundler/bundler) source code. Katrina Owen has exactly one commit.

Go through the log to find Katrina's commit.

* What is it?
* Why does it matter?

Read the article linked to in the commit message.

### Hints

Use the man page for git-log to figure out how to get the commit hash and author name / email to output in a single line.

Once you have the correct commit hash, use the man page for git-log to figure out how to look at

* the actual change that was committed, also known as the 'patch'
* the full commit message for a given commit hash

## Exercise 2

Check out your individual project, and look through all the commit messages.

* What is the best commit message? Why does it qualify?
* What are the worst 3 to 5 commit messages? Why?

#### Fixing the commit messages

Do a `git rebase -i` back to the beginning of your project and compose commit messages that follow Tim Pope's recommendations regarding git commit messages.

* Is this difficult? If so, why?
* Should you do this on a project that you are collaborating with other developers on? Why or why not?

### Stats

#### `git log`

Use the man page for git-log and some unix commands to show you how many git commits you have per day.

* How many commits did you typically have per day?
* How far apart are they?

**hint**: you can use the unix commands `sort` and `uniq` to help you out. Both `sort` and `uniq` have command line switches that you will need to complete this task. Use the man pages to find them.

#### `git diff`

In the bundler project, I picked two commits at random:

```plain
a7031aa thor thor thor
7411b80 heeyyy list CAN do exit status
```

What are the stats for the change between those two commits?

Now try the same thing with `git diff --shortstat`.

`git diff HEAD..HEAD~1` will show you the stats for the most recent commit.

#### `git rev-list`

Use the man page to figure out what rev-list does, and how to use it.

Write a shell script that gives you the shortstat diff for each commit in your history.

Here's a small bash script that might be helpful getting you started:

```bash
#/bin/bash

echo "abc" > data.txt
echo "123" >> data.txt
echo "xyz" >> data.txt

function main() {
  lines | while read line
  do
    echo "OMG IT IS $line"
  done
}

function lines() {
  cat data.txt
}

main
```

Make sure that when the script is done it resets the repository to a reasonable state.

## Exercise 3

Check out the [snifficult](https://github.com/JumpstartLab/snifficult) repo from github.

### Foul Language

Unfortunately a couple of the commits added data to the `data/stuff.txt` log file that contains swearing.

Use your mad git skillz to figure out exactly which commits added the bad data, and then use `git rebase -i` to make those commits disappear from the history forever.

#### Hint

Since we know that the swear words are in `data/stuff.txt`, we can simply `git blame` that file and find the offending line in the output (try `grep`). The commit hash is on the start of that line of output.


### When did the slowness happen?

At one point in time the tests slowed down significantly.

Check the time it takes for the test to finish at HEAD, and then check out commit `c4dea03` and run the tests.

Now say `git reset --hard origin/master` to get back to the tip of the master branch.

Use `git-bisect` to find the commit that introduced the slowness.

To start

{% terminal %}
git bisect start
{% endterminal %}

We need to tell git bisect that the current commit is slow:

{% terminal %}
git bisect bad
{% endterminal %}

Next we need to tell git which commit is the last known commit with fast tests. Find the commit hash for the commit called "Implement basic work algorithm"

{% terminal %}
git bisect good THE_COMMIT_HASH
{% endterminal %}

Now, run rake. If the tests are fast, say `git bisect good` and if they're slow, say `git bisect bad`. Continue doing this until the output tells you what the first bad commit was.

Remember to check out master again, since your repository will have checked out the bad commit at this point.

### Fixing the bad commit

When you've found it, use git rebase -i to edit the commit so you get rid of the slowness without losing any of the other changes that were added in the same commit.

## Squashing Commits

The last two commits should really be a single change. Use `rebase -i` to squash the two commits together.

