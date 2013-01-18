---
layout: page
title: Using Source Control
---

Source control is a critical practice for any professional developer. In our community, Git has emerged as the preferred "Version Control Manager" or VCM.

### What is a VCM?

When you're writing code it's critical that you can have granular control over changes. The smallest error in one place can bring a whole system crashing down.

Have you every collaboratively edited a document in Microsoft Word where the participants are interacting over email? The name of the file usually devolves like this:

```
proposal.doc
proposal_revised.doc
proposal_revised_with_phils_changes.doc
proposal_revised_with_jens_changes.doc
proposal_v2.doc
proposal_final.doc
proposal_v2_edited_and_revised.doc
```

Pretty quickly you have no idea which version of the file is current, who made what changes, and where to look if you want to rollback changes. That's what a VCS does for you: it tracks the lifetime of your files, how they change over time, who made those changes, and when they were made.

### Git

The Git source control system has become tremendously popular. It's incredibly powerful, and at the same time challenging to use. The system was originally created to manage the development of the Linux Kernel, a project with thousands of developers working simultaneously on the same code base. When you ask the question "Can Git do [x]?" the answer is always yes, the harder question is "Can I figure out how to make git do [x]?"

You'll use the same small set of commands 98% of the time with Git, and mastering those is straighforward. Let's define some terms, then dive in.

#### Repository

A collection of files tracked by Git is called a *repository* or, often, a *repo*. Think of this like a filing cabinet. You'll create one repo per project you work on. On your system you might have one repo, you might have 100, depending how many projects you work on.

Because Git tracks versions and changes to files, once something is added to a repo it's there forever. Even if you delete an entire file or directory, the old versions will still remain in the repo.

When you're working, it'd be tremendously annoying to have hundreds of versions of files cluttering up your folder. At any time, all but one version of files are hidden from you in the repo. You only see what's referenced by *HEAD*.

#### HEAD

*HEAD* is the name Git uses to refer to "the version you're working with right now." Most of the time, that's going to be the most recent version of your files. You have your files, make some changes, then create a *commit*.

#### Commit

A *commit* is the act of entering your latest data into the repo. When you save files on your hard drive they're not automatically updated in the repo. When working with traditional files in a word process, you usually only open and edit one file at a time.

But when working with code, you might be editing a dozen interrelated files at the same time. You save them individually to disk, verify that things are working the way you want, then add them to the current *commit*. When all the changes are ready, you submit the commit with a message that describes why you made these file changes.

#### Source Control

* Git Immersion
* http://progit.org/book/
  * Branch strategies: http://progit.org/book/ch3-0.html
* Source Control Made Easy
* Peepcode
  * Git
  * Advanced Git