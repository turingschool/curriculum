---
layout: page
title: Older MacOS Platforms
section: Environment & Source Control
---

If you're not on the latest version of MacOS you should probably update that, first. It's usually free.

If, for some reason, you have to stay on an older version, the below notes may be helpful:

## OS X 10.7.x (Lion) or OS X 10.8.x (Mountain Lion)

Installing ruby on Mac OS requires the Command Line Tools that XCode gives you
access to.

### If you have XCode installed

* Open XCode and go to Preferences > Downloads > Install Command Line Tools.

### If you don't have XCode installed

* [Create or Register](https://developer.apple.com/programs/register/) an Apple ID.
  Register with the same Apple ID you use for other Apple services, such as
  iTunes, iCloud, and the Apple Online Store.
* [Login](http://developer.apple.com/downloads/index.action) to the Apple
  Developer Portal.
* In the pane on the right, look for "command line tools" and choose the
* package appropriate to your version of OS X.
  ** Mac OS X 10.7.x - Lion
  ** Mac OS X 10.8.x - Mountain Lion
* Download this package
* When the download completes, you'll have a .dmg file. Double-click this
  file.
* Then double-click the .mpkg file that appears
* A dialog pops up. Accept the Terms.
* Accept the default install location (probably Macintosh HD) by clicking
  "install" or "continue"
* You'll be asked to enter your password, which is the password you use to log
  in to your account on the computer.
* When it has completed the installation, click "close".

You're good to go. You won't have to go looking for the program that got
installed, it's just going to be used by other things you'll be installing
later.

### GCC

You're going to need a C compiler in order to install Ruby. We can use
homebrew to get the official Apple gcc program that is distributed with XCode.

First we need to tell brew to add some extra formulae:

{% terminal %}
$ brew tap homebrew/dupes
{% endterminal %}

When that completes, type:

{% terminal %}
brew install apple-gcc42
{% endterminal %}

### Manipulating the Path

Your computer has something called a PATH, which is basically a big list of
places that it will look for programs on your computer. For example, it might
have a list like this (except much longer):

* `/usr/bin`
* `/usr/local/bin`
* `~/bin`

When you type a command in the terminal, the computer goes to the first place,
`/usr/bin` and looks for a program with the name you typed. If it finds it,
fine, it will go ahead and run that program. If not, it will move to the next
location in the list and try again.

Right now, `/usr/bin` is before `/usr/local/bin` in your PATH, and Apple's
version (which is installed under `/usr/bin` is taking precedence over the one
we just installed (which is installed under `/usr/local/bin`.

We need to switch the order so the computer looks in `/usr/local/bin` first.

Go to your terminal and paste in the following (hit enter to run the command):

{% terminal %}
$ echo 'export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"' >> ~/.bash_profile
{% endterminal %}

#### What does all that mean?

`echo` is a command that just repeats whatever comes after it. For example:

{% terminal %}
$ echo "Hello, World!"
Hello, World!
{% endterminal %}

The `>>` means _append the output of the previous thing to the file that comes
after this_.

Here we're appending to `~/.bash_profile` which is a file that contains
configuration for your terminal. Every time you open a new terminal window,
that file gets read so that your terminal behaves the way you want it to.

#### Moving On

Now that we've changed the `~/.bash_profile` file, we need to update our
terminal session to read the new information. This is called _sourcing_ a
file:

{% terminal %}
source ~/.bash_profile
{% endterminal %}

To make sure that everything is the way you want it, run the `git --version`
and `which git` commands again:

{% terminal %}
which git
{% endterminal %}

{% terminal %}
git --version
{% endterminal %}
