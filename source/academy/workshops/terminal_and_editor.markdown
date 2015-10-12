---
layout: page
title: Terminal and Editor
---

## UNIX Essentials

If this is your first time using UNIX then you'll need a few of the most essential pieces to be able to complete your work:

* Open Terminal by typing `command-spacebar` to open Spotlight, then type `Terminal` and hit enter
* You now have a single terminal window. This window can open multiple tabs by typing `command-t`
* The prompt on the left tells you a bit about what folder you're currently in. But try typing `pwd` in the terminal and hit enter to print out your "present working directory"

#### Listing Files

* `ls` will list the files in the current folder
* `ls -lA` will list the files in the current folder along with a bunch of info about them

#### Working with Files

* Files that start with a `.`, like the `.bash_profile` you'll work with later, are hidden files. If you just use `ls` they won't show up, but `ls -lA` will show them.
* `touch` is used to create blank files. Try `touch sample_file` then `ls`.
* `rm` is used to remove files. Remove that sample with `rm sample_file`
* `which` tells you where on the file system a program is. Try `which ruby` to see the full path to your Ruby executable.

#### Working with Directories

* `mkdir` will make a directory. Go ahead and enter `mkdir sample_directory` to create a directory
* `cd` stands for "change directory". Enter `cd sample_directory` to move into your new directory
* The tilde (`~`) is a shortcut for your "home" directory. You can enter `cd ~` from any folder on the system and you'll jump back to your home directory.
* The single period (`.`) is a reference to the current directory. If you enter `cd .` it won't go anywhere. But the period is useful especially with Git which you'll see soon.
* The double period (`..`) is a reference to the parent directory of the current directory (one step up the tree). Try entering `cd ..` then `ls` and you should see your user folder. `cd` back into that.
* Removing directories is a bit different. Try `rm -rf sample_directory` to remove our previously created sample directory.

## Customizing Your Terminal

A little bit of increased efficiency in your use of the Unix environment and your editor can pay significant dividends over time. Let's experiment with customizing and adding to your terminal and editor.

* Open `~/.bash_profile` in a text editor (ex: `atom ~/.bash_profile`)
* You can check out dotfiles on GitHub to see how serious people get: http://dotfiles.github.com/

### The Essentials

* `export` to set environment variables
* `alias` for shorthand commands, like I define `e` to launch my editor
* `source` to run scripts of bash commands

#### A sample .bash_profile

Snippets from Jeff's `.bash_profile` are below.
The top three lines setup a yellow lightning bolt as my prompt because, well, it's awesome.

```
export PS1="\W \[\033[0;33m\]⚡\[\033[0;39m\] "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

export EDITOR='/usr/local/bin/atom'
export CC=/usr/local/bin/gcc-4.2

# A shortcut for getting back to our "Module 1" directory
alias m1="cd ~/turing/1module"

# Enable git's tab-completion library
source /usr/local/etc/bash_completion.d/git-completion.bash

# shortcuts for git
alias ga="git add"
alias gb="git branch"
alias gd="git diff --patience --ignore-space-change"
alias gh="git log --pretty=format:\"%Cgreen%h%Creset %Cblue%ad%Creset %s%C(yellow)%d%Creset %Cblue[%an]%Creset\" --graph --date=short"
alias gc="git checkout"
alias gs="git status"

# programs that launch editors (e.g. git) will use Atom
export EDITOR="atom -w"
```

## Customizing Atom

Check out the Atom docs that explain how to start customizing it: https://atom.io/docs/latest/customizing-atom
