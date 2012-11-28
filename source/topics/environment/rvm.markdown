---
layout: page
title: RVM
section: Environment & Source Control
---

[RVM](https://rvm.beginrescueend.com/), or Ruby Version Manager, has revolutionized how we install and manage Ruby. Given the rapid pace of development in our community, it is common that a developer will need to have access to both Ruby 1.8.7 for older projects and Ruby 1.9.2 for newer ones. They might also choose to use alternative Ruby interpreters like [JRuby](http://jruby.org/) or [Rubinius](http://rubini.us/). Installing and maintaining all these by hand is extremely difficult.

Enter RVM. The RVM system actually contains no Ruby code -- it's a collection of terminal scripts that can make managing multiple versions of Ruby transparent and easy. Even if you are only using one version of Ruby today, you'll still gain great benefits from RVM.

<div class="opinion"><p>Let me put it this way: if you're on a Unix-based system (including, of course, OSX) and not using RVM, <em>you are doing it wrong!</em></p></div>

### Quick Setup

Generally RVM can be setup in three steps. (Detailed installation/setup instructions can be found on the [RVM site](https://rvm.beginrescueend.com/rvm/install/).)

1. Install from source (in the terminal)

    ```
    bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)
    ```

2. Add these lines to your `~/.bashrc`

    ```
    [[ -s $HOME/.rvm/scripts/rvm ]] && . $HOME/.rvm/scripts/rvm
    [[ -r $HOME/.rvm/scripts/completion ]] && . $HOME/.rvm/scripts/completion
    ```

3. Re-process your profile (in the terminal): `source ~/.bashrc`

Validate RVM is installed by running `rvm info` and you should see lots of information about your environment.

### Setup Global Gems

You can setup RVM to add certain gems to all versions of Ruby and all gemsets. Use restraint here, but generally all Ruby apps should use Bundler (<http://gembundler.com/>) for dependency management. Create a file `~/.rvm/gemsets/global.gems` and just add this line:

    bundler

Bundler will now be setup for new Rubies and added to new gemsets.

### Installing Rubies

Once you have access to the RVM system you're ready to install Ruby. To see what versions of Ruby are available you can run `rvm list known` in the terminal.

For these tutorials we'll be using Ruby 1.9.2, install it with the following commands. Note that `$` is the terminal prompt:

{% terminal %}
$ rvm install 1.9.2
{% endterminal %}

Then tell RVM to make it our default Ruby:

{% terminal %}
$ rvm use 1.9.2 --default
{% endterminal %}

Test it by displaying the Ruby version and you should see something like this:

{% terminal %}
$ ruby -v
ruby 1.9.2p290 (2011-07-09 revision 32553) [i686-linux]
{% endterminal %}

Once your RVM ruby version is selected, just run `ruby` and `gem` like normal.

<div class="note">
<p>RVM installs Ruby into the user space, so you <strong>do not need to use `sudo`, ever</strong>. If you're following an older book or tutorial and it has `sudo` in an instruction, just omit the `sudo`.</p>
</div>

