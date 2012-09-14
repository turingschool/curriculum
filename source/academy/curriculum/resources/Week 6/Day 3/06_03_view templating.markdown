---
layout: page
title: View Templating
---

## View Templating

* The history of ERB
* The history of HAML
* Deriving HAML
* Slim is HAML, the next generation
* Experimenting with Slim

```
doctype
h1 First Header
h2
  | Second Header
    With two lines
= pluralize(2, "cat")
== render :partial => 'user'
div.some_class#some_id
h3 Inline content #{ "rocks".upcase } with Slim
/ comments are easy
markdown:
  # My H1
    Hello from #{"Markdown!"}
```

### Reference

* [HAML](http://haml-lang.com/)
* [Slim](http://slim-lang.com/)