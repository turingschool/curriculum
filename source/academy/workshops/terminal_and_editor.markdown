---
layout: page
title: Terminal and Editor
---

A little bit of increased efficiency in your use of the Unix environment and your editor can pay significant dividends over time. Let's experiment with customizing and adding to your terminal and editor.

## Customizing Your Terminal

* Open `~/.bash_profile` in a text editor (ex: `subl ~/.bash_profile`)
* You can check out dotfiles on GitHub to see how serious people get: http://dotfiles.github.com/

### The Essentials

* `export` to set environment variables
* `alias` for shorthand commands, like I define `e` to launch my editor
* `source` to run scripts of bash commands

#### Some Examples

Snippets from my `.bash_profile` are below. The top three lines setup a yellow lightning bolt as my prompt because, well, it's awesome.

```
export PS1="\W \[\033[0;33m\]⚡\[\033[0;39m\] "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

export EDITOR='/Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl -w'
export CC=/usr/local/bin/gcc-4.2

# My general projects directory:
alias cdp="cd /Users/jcasimir/Dropbox/Projects/"

# My most commonly used project, "curriculum":
alias cdc="cd /Users/jcasimir/Dropbox/Projects/curriculum/source"

# Use "be" instead of "bundle exec" for Rails
alias be="bundle exec $1"

# Use "e" and a folder/file to launch SublimeText
alias e="/Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl $1"

# Enable git's tab-completion library
source /usr/local/etc/bash_completion.d/git-completion.bash
```

## SublimeText 

### Editor Settings

"Settings - Default" will be overwritten when you upgrade to a new version of SublimeText, but it's useful to see what options are available.

"Settings - User" is where you should put your customizations. It will not be overwritten.

#### Some Recommended Settings

```
{
  "font_size": 16.0,
  "tab_size": 2,
  "translate_tabs_to_spaces": true,
  "save_on_focus_lost": true,
  "hot_exit": false,
  "remember_open_files": false,
  "ensure_newline_at_eof_on_save": true
}
```

### Keyboard Shortcuts

Over time you want to start using keyboard shortcuts to improve your development speed.

There's a great [printer-ready cheat sheet available](http://www.ractoon.com/2012/10/sublime-text-2-keyboard-shortcuts-printable/).

#### Essential Shortcuts

Some of the most important, which we'll expect you to use in evaluations, include:

* Command-P: Fuzzy search for a file by name
* Command-R: Jump to Symbol in current file
* Command-F: Find in file
* Shift-Command-F: Find in project
* Command-D: Select word
* Command-[ and Command-]: Indent / Unindent
* Command-/: Comment / Uncomment

### SublimeText Plugins & Themes

There are a bunch of plugins and themes that try to make SublimeText more powerful/beautiful. Be wary of installing more than a handful at a time -- you'll probably never use the features and they might even make the editor more crash-prone.

#### PackageControl

You know how `brew` makes it easy to install terminal applications in OS X? Well Sublime has a similar system called PackageControl which can install plugins from within the app.

PackageControl: http://wbond.net/sublime_packages/package_control

#### Visual Themes

* Soda Theme: https://github.com/buymeasoda/soda-theme/
* Colour Schemes: https://github.com/daylerees/colour-schemes

#### Functional Add-Ons

* SidebarEnhancements: https://github.com/titoBouzout/SideBarEnhancements
* BracketHighlighter: https://github.com/facelessuser/BracketHighlighter
* SublimeText2Git: https://github.com/kemayo/sublime-text-2-git/wiki
* SublimeLinter: https://github.com/SublimeLinter/SublimeLinter
* SublimeCodeIntel: https://github.com/Kronuz/SublimeCodeIntel
* Detect Syntax: https://github.com/phillipkoebbe/DetectSyntax
* SublimeGuard: https://github.com/cyphactor/sublime_guard