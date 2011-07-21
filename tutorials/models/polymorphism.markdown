# Polymorphism

Sometimes relationships need to be flexible, and that's where we look to polymorphism. Say we want to implement:

* A `Person`
* A `Company`
* A `PhoneNumber` that can connect to a `Person` or a `Company`

## At the Database Level

A naive implementation would be to add both `person_id` and `company_id` columns to the `phone_numbers` table. Then in the model:

```ruby
class PhoneNumber < ActiveRecord::Base
  belongs_to :person
  belongs_to :company
end
```

This is *wrong* because it implies that a single `PhoneNumber` can connect to *both* a `Person` and a `Company`. Furthermore, as you add more contact types down the road, you'll have to keep adding columns to `phone_numbers`.

### Setup for Polymorphism

Instead, Rails' implementation of polymorphism relies on a two-factor foreign key. Instead of just having a single `something_id` column pointing to the external record, we'll use a `something_id` and `something_class` to record the `id` number and the class name of the foreign object.

In this domain, `contact` would be an adequate generalization of `Person` and `Company`. Our `phone_numbers` table should then have columns `contact_id` and `contact_type`. The records will then look like this:

```
-------------------------------------------
|id| number       |contact_id|contact_type|
| 1| "2223334444" | 2        | "Person"   |
| 2| "5554443333" | 3        | "Person"   |
| 3| "6667774444" | 3        | "Company"  |
-------------------------------------------
```

Note that the `contact_id` values won't be unique. Phone numbers with IDs 2 and 3 can share the same `contact_id` and have different `contact_type`s, thus connecting them to different objects.

## In the Rails Models

With the data tables setup, we need to tell Rails how to understand these relationships.

### Implementation using One-to-One

First, let's consider a one-to-one connection that limits a `Person` or `Business` to having just one `PhoneNumber`.

Looking just at the `Person`, we'd normally write:

```ruby
class Person < ActiveRecord::Base
  has_one :phone_number
end
```

But that *won't work* because Rails will expect to find a `person_id` column in `phone_numbers`. We tell it to look, instead, for named polymorphic columns:

```ruby
class Person < ActiveRecord::Base
  has_one :phone_number, :as => :contact
end
```

Rails will then anticipate `phone_numbers` to have `contact_id` and `contact_type`. The implementation in `Company` would be exactly the same.

In `PhoneNumber`, we tell it about the relationship to contacts:

```ruby
class PhoneNumber < ActiveRecord::Base
  belongs_to :contact, :polymorphic => true
end
```

#### Usage

Assuming we have an instances of these classes like `@phone_number`, `@person`, or `@company`:

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
  has_many :phone_numbers, :as => :contact
end
```

Nothing tricky, just change `has_one` to `has_many` and pluralize the object name to `:phone_numbers`. Nothing else changes!

#### Usage

Usage stays just about the same:

```ruby
@company.phone_numbers
@person.phone_numbers
@phone_number.contact
```

Now the `.phone_numbers` method returns an array. You can just think of it as a normal one-to-many!

## Exercises

[TODO: Add Exercises]

## References

* Rails Guide on Polymorphic Associations: http://guides.rubyonrails.org/association_basics.html#polymorphic-associations