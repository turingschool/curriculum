---
layout: page
title: CompleteMe
---

## Introduction

Everyone in today's smartphone-saturated world has had their
share of interactions with textual "autocomplete." You
may have sometimes even wondered if autocomplete is even
worth the trouble, given the ridiculous completions it
sometimes attempts.

But how would you actually __make__ an autocomplete system?
In this project, __CompleteMe__ we'll be exploring this idea by
building such a system. Perhaps in the process we will develop
some sympathy for the developers who built the seemingly
incompetent systems on our phones...

### Data Structure -- Introduction to Tries

A common way to solve this problem is using a data structure
called a __Trie__. The name comes from the idea of a Re__trie__val
tree, and it's useful for storing and then fetching paths through
arbitrary (often textual) data.

A Trie is somewhat similar to the binary trees you may have seen before,
but whereas each node in a binary tree points to up to 2 subtrees,
nodes within our retrieval tries will point to `N` nodes, where `N`
is the size of the alphabet we want to complete within.

Thus for a latin-alphabet text trie, each node will potentially
have 26 children, one for each potential character that could follow
the text entered thus far.
(In graph theory terms, we could classify this as a Directed, Acyclic
graph of order 26, but hey, who's counting?)

Take a moment and read more about Tries:

* [Tries writeup in the DSA Repo](https://github.com/turingschool/data_structures_and_algorithms/tree/master/tries)
* [Tries Wikipedia Article](https://en.wikipedia.org/wiki/Trie)

### Input File

Of course, our Trie won't be very useful without a good dataset
to populate it. Fortunately, our computers ship with a special
file on them containing a list of standard dictionary words.
It lives at `/usr/share/dict/words`

Using the unix utility `wc` (word count), we can see that the file
contains 235886 words:

```
$ cat /usr/share/dict/words | wc -l
235886
```

Should be enough for us!

### Interaction Model

### Extensions

#### Usage Frequency Weighting
