---
layout: page
title: Team Notes
---

Write markers like `[PENDING]` or `[TODO: Double-check this syntax]`.

List all markers with `rake all` in the project directory. `rake -T` to see other available searches.

When you start working on a section, please mark it `[WIP:your name]` so we don't overlap effort. Check-in early and often!

### Schedule

* 9/14 - 9/16: Emphasis is on getting rough content written. Currently Day 3, 4, and 5 need significant work. Jeff is working on organization, Greg is continuing work on Day 4. Mike and Ryan will be joining the writing today/tonight. Gerred and Erik will be working on editing.
* 9/17 - 9/18: Editing and exercise writing/revision
* 9/18 - 9/19: Final tweaks, design
* Evening of 9/20: Goal Completion.

### Team Status

* Jeff / jcasimir: Working on approving sections that are marked REVIEW
* Greg / gjastrab (writer): Finished Local Authentication with Devise example (9/19 wee AM)
* Ryan / cookrn (writer): Rough draft of activeresource tutorial
* Mike / subelsky (writer): Finished heroku and config vars
* Gerred / gerred (editor): [ Fill me in ]
* Erik / thoraxe (editor): [ Fill me in, starting Thursday, mostly available Friday/Saturday ]
* Geoff / gmassanek (editor): Starting with editing
* Brandon / imathis (design): [ Fill me in ]
* Frank / burtlo
* Mark / markmcspadden (writer/editor): [ ]

### Notes for Editors

* If you notice sections that are more opinion than objective, I want to pull them into a side bar. Ideally, extract them into their own paragraph(s) and wrap them in an HTML DIV like this:

```html
<div class='opinion'>
  In my opinion, the better strategy is to...
</div>
```

* If there's something that needs more attention but you aren't sure what to do, just slap a to-do tag with explanation like this: `[TODO: It seems like there's a code snippet missing here]`
