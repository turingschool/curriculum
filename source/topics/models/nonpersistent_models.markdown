---
layout: page
title: Nonpersistent Models
---

The most pervasive issue I see in Rails projects that grow to any significant size is a fixation on "models" meaning "database tables". There are many ways that we can use "Plain Old Ruby Objects" (POROs) to simplify our code while making it easier to test and maintain.

## Basics

How do we create a model that doesn't relate to a table? It looks like this:

```ruby
class ModelName
end
```

Nothing fancy, no inheritance necessary. Just save it as `app/models/model_name.rb` and it'll be auto-loaded like your `ActiveRecord` models. Create normal unit tests and they're find the model just fine.

### Business Logic

## Modules

## The Facade Pattern

## Exercises

## References