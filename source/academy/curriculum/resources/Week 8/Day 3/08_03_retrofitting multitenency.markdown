---
layout: page
title: Retrofitting Multi-Tenency
---

## Retrofitting Multi-Tenency

1. New domain model(s)
2. Which models will need a `store_id`?
  * What's accessed directly?
  * What's shared/global?
3. Scoping everything
4. Experiments with manual testing
5. Writing an integration test
6. Re-implementing with TDD
7. Well-factored code hides complexity
  * At the model level
  * At the controller level
  * At the view level