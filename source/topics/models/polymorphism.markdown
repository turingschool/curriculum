---
layout: page
title: Polymorphism
---

Sometimes relationships need to be flexible, and that's where we look to polymorphism. Say we want to implement:

* A `Person`
* A `Company`
* A `PhoneNumber` that can belong to a `Person` or a `Company`

## At the Database Level

A naive implementation would be to add both `person_id` and `company_id` columns to the `phone_numbers` table. Then in the model:

```ruby
class PhoneNumber < ActiveRecord::Base
  belongs_to :person
  belongs_to :company
end
```

This is *wrong* because it implies that a single `PhoneNumber` can connect to *both* a `Person` and a `Company`. Furthermore, as you add more classes that can have phone numbers, you'll have to keep adding columns to `phone_numbers`.

### Setup for Polymorphism

Instead, Rails' implementation of polymorphism relies on a two-factor foreign key. Instead of just having a single `foreign_id` column pointing to the external record, we'll use a `foreign_id` and `foreign_type` to record the `id` number and the class name of the foreign object.

In this domain, `contact` would be an adequate generalization of `Person` and `Company`. Our `phone_numbers` table should have columns `contact_id` and `contact_type`. The records will then look like this:

```
-------------------------------------------
|id| number       |contact_id|contact_type|
| 1| "2223334444" | 2        | "Person"   |
| 2| "5554443333" | 3        | "Person"   |
| 3| "6667774444" | 3        | "Company"  |
-------------------------------------------
```

Since we're now using a composite foreign key, the `contact_id` values don't have to be unique. Phone numbers with IDs 2 and 3 can share the same `contact_id` and have different `contact_type`s, thus connecting them to different objects.

## In the Rails Models

With the data tables setup, we need to tell Rails how to understand these relationships.

### Implementation using One-to-One

First, let's consider a one-to-one connection that limits a `Person` or `Company` to having just one `PhoneNumber`.

Looking just at the `Person`, we'd normally write:

```ruby
class Person < ActiveRecord::Base
  has_one :phone_number
end
```

But that *won't work* because Rails will expect to find a `person_id` column in `phone_numbers`. Instead, we tell it to look for named polymorphic columns:

```ruby
class Person < ActiveRecord::Base
  has_one :phone_number, as: :contact
end
```

Rails will then anticipate `phone_numbers` to have `contact_id` and `contact_type`. The implementation in `Company` would be exactly the same.

In `PhoneNumber`, we tell it about the relationship to contacts:

```ruby
class PhoneNumber < ActiveRecord::Base
  belongs_to :contact, polymorphic: true
end
```

#### Usage

Assuming we have an instance of these classes like `@phone_number`, `@person`, or `@company`:

```ruby
@company.phone_number
@person.phone_number
@phone_number.contact
```

For the first two, there's no apparent difference between the polymorphic usage and a normal has-one. That's the beauty of it!

For `@phone_number.contact`, you'll get back the actual related object, so it could be an instance of `Person` or `Company`.

### Implementation using One-to-Many

But what about when a `Person` or `Company` relates to many `PhoneNumber` objects?

```ruby
class Person < ActiveRecord::Base
  has_many :phone_numbers, as: :contact
end
```

We change `has_one` to `has_many` and pluralize the object name to `:phone_numbers`. Nothing else changes!

#### Usage

Usage stays just about the same:

```ruby
@company.phone_numbers
@person.phone_numbers
@phone_number.contact
```

Now the `.phone_numbers` method returns an array. You can just think of it as a normal one-to-many.

## Exercises

{% include custom/sample_project.html %}

In the Blogger sample application, you already have `Article` and `Comment` classes. As it stands, a `Comment` belongs to an `Article`. 

Now we decide that we want to implement comment threads, so that a `Comment` can belong to *either* an `Article` or another `Comment`. 

Don't bother with the web interface, but restructure the database and relationships so that, in the console, you can:

1. Create an article

2. Create two comments on that article

3. Create two comments on each of those comments

4. Print out a text representation of the tree using the article title and the first 6 words of the comment, like this:
  ```yaml
  My Sample Article
    - A First Comment
      - A comment on comment 1
      - Another comment on comment 1
    - A Second Comment
      - A comment on comment 2
      - A second comment on comment 2
  ```

### Challenges

1. Change the view templates to display the nested comments in the web interface.

2. Make it so the comment form can post comments to the original article or any comment in the tree. Here are two approaches:
  * Build an "add comment" link on each entity, then bounce to a new comment page
  * Add a select box to the comment form which has the article and all comments selectable as the target

## References

* Rails Guide on Polymorphic Associations: http://guides.rubyonrails.org/association_basics.html#polymorphic-associations
