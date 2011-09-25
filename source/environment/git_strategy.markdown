---
layout: page
title: Common Git Practices
section: Environment & Source Control
---

The Git Version Control System has taken over most of the Ruby world. Simply put, if you're going to develop with Ruby you have to learn Git.

### Getting Started

A full Git tutorial is beyond scope here, but there are many great resources out there:

* ProGit by Scott Chacon is available free online: http://progit.org/book/
* Help.GitHub: http://help.github.com/
* PeepCode's Git Video: http://peepcode.com/products/git

### Why Git Is Great

If you aren't used to version control then the whole concept of merging can feel like magic.  If you are used to tools like Subversion (SVN), then you have developed a (necessary) fear of the conflicts that can come up.  It might take a few tries to get used to the idea, but branching and merging with Git is amazing!  Here's the basic idea:

1. Start with an existing repository
2. Create and checkout a branch
3. Commit your work to that branch
4. When the branch is ready, merge it back into the known version you started with.

That's the simplest case, and it works every time.

#### Multiple Branches

Where it gets more complex is when there are multiple branches out at the same time:

1. Start with an existing repository branch
2. Create and checkout a local branch
3. Commit your work to that local branch
4. "Jim" comes along and creates his own local branch from the same original branch
5. He commits on his branch, finishes his work before you do, and merges it back into the "shared" original
6. When your branch is ready, you merge it back into the known version you started with.
7. You commit a little bit more work to your branch and go to merge it back into `master`... but wait!  Jim's code is in there!  What happens?!?  One of three things:
  * It just works.  You and Jim worked on different files, and the changes just merge together with no issue.
  * It just works, version #2.  Even though you and Jim touched the same file, maybe even the same line of code, git was able to merge the changes.
  * Git merges 99% of the work, but realizes it isn't smart enough on one piece of code... maybe you changed a variable name Jim refactored away.  It alerts you.  You fix this problem, run your tests, commit the change, and continue with the merge.

That last part is what causes nightmares in people that come from other version control tools, but in git there is a lot less pain associated with it.  Because Git tracks *changes*, and not *versions of files*, there is a subtle but powerful difference in the quality of information you have to help resolve the conflict.

#### More Advanced Management

Just about anything you can imagine is possible with git. Want to rewrite the commit history? Do it. Want to pretend you branched off Jim's code instead of `master`? Use `rebase` and make it so. Git was written and is used to control the Linux kernel source code which involves tens of thousands of contributors -- whatever you need for *your* project can happen!

### Managing Development and Releases

Beyond the tool itself, you need a strategy for managing a Git repository. In general:

* Do not develop any code on the `master` branch, only merge in other branches
* Create a new local branch for every feature
* Merge and prune branches when the feature is done
* Do not check in code unless the tests are passing

While those guidelines can get you started, you should consider a robust release management process outlined in extensive detail here: http://nvie.com/posts/a-successful-git-branching-model/

If that sounds appealing, then you can run the process using GitFlow (https://github.com/nvie/gitflow/). There is a great introduction tutorial to using GitFlow put together by Dave Bock at CodeSherpas here: http://codesherpas.com/screencasts/on_the_path_gitflow.mov

Alternatively, you can follow GitHub's own, more streamlined, git workflow: http://scottchacon.com/2011/08/31/github-flow.html

### GitHub

Git is great, but GitHub is totally amazing. If there is any way for you to use GitHub, do it. If you're developing open source, then the free public repositories are fine. If you need some privacy, individual and organization accounts provide private repositories for a few dollars a month. And if you need more comprehensive security, consider GitHub:FI (http://fi.github.com/) which you can run on your server inside your firewall. 

GitHub supports code review, collaboration, and organization tools that are completely game changing.