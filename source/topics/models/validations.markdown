---
layout: page
title: Validations
section: Models
---

Data integrity is an underrated part of proper application architecture. Many of the bugs in production systems are triggered by missing or malformed user data. If a user can possibly screw it up or screw with it, they will. Validations in the model can help!

## On Syntax

Before we begin, let's talk about syntax. There are two primary syntaxes for writing validations in Rails 3:

```ruby
validates_presence_of :price
validates :price, presence: true
```

These have the exact same functionality. The first is the older style and the second a newer "Rails 3 style". The Rails 3 style shines when we add in a second validation on the same field:

```ruby
# Rails 2 Style
validates_presence_of :price
validates_numericality_of :price

# Rails 3 Style
validates :price, presence: true, numericality: true
```

The newer syntax allows you to condense multiple validations into a single line of code.

<div class="opinion">
<p>In my opinion, the newer syntax is not good. Clean Ruby reads like English. To read the second set of examples aloud:</p>

<p><strong>Rails 2 Style</strong>: "validates presence of price, validates numericality of price"</p>

<p><strong>Rails 3</strong>: "validates price presence true numericality true"</p>

<p>The Rails 2 sentence isn't poetry, but you can understand what it means. The Rails 3 syntax sounds like computer talk. Ruby is about developers not computers, and for that reason I recommend you <strong>not</strong> use the new syntax.</p>

<p>Aaron Patterson on the Rails core team confirms that there are no plans to deprecate the older syntax.</p>
</div>

## Most Valuable Validations

There are many validations available to you, check out the full API here: http://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html

Let's take a closer look at the most commonly used methods.

### Presence

`validates_presence_of`

Declare that the field must have some value. Note that an empty string (`""`) is *not* considered a value.

#### Usage

```ruby
validates_presence_of :title
```

Also, you can declare the validation on multiple fields at once:

```ruby
validates_presence_of :title, :price, :description
```

### Numericality

`validates_numericality_of`

Check that the value in the field "looks like" a number. It might be a string, but does it look like a number? `"123"` does, `"3.45"` does, while `"hello"` does not. Neither does `"a928"`. I'll tend to apply this to every field that is a number in the database (ex: `price`) and ones that look like a number but are stored as a string (ex: `zipcode`).

#### Usage

```ruby
validates_numericality_of :price
```

That basic usage will allow anything that's "number-like" including integers or floats.

#### Options

We can add a few options to add criteria to our "numbers":

* `:only_integer` will only accept integers

```ruby
validates_numericality_of :price, only_integer: true
```

* Control the range of values with these options:
  * `:greater_than`
  * `:greater_than_or_equal_to`
  * `:less_than`
  * `:less_than_or_equal_to`  
  For example:
  
```ruby
validates_numericality_of :price, greater_than: 0
validates_numericality_of :price, less_than: 1000
validates_numericality_of :price, greater_than: 0, less_than: 1000
```

### Length

`validates_length_of`

Check the length of a string with `validates_length_of`.

#### Usage & Options

`validates_length_of` obviously needs to know what the length should be. Here are a few examples of the common specifiers:

```ruby
validates_length_of :zipcode, is: 5
validates_length_of :title, minimum: "10"
validates_length_of :title, maximum: "1000"
validates_length_of :title, in: (10..1000)
```

### Format

`validates_format_of`

The `validates_format_of` method is the Swiss Army knife of validations. It attempts to match the input against a regular expression, so anything you can write in a regex you can check with this validator.

<div class="opinion">
<p>I always like to share Jamie Zawinski's quote when talking about this topic: "Some people, when confronted with a problem, think 'I know, I'll use regular expressions.' Now they have two problems."</p>

<p>But if you're comfortable and capable with regular expressions, have at it!</p>
</div>

#### Usage

The canonical example is email address format validation:

```ruby
validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
```

It's important to note that this regex is not compliant with the grammar described in RFC 822. A regex that is compliant would be [considerably more complex](http://www.ex-parrot.com/pdw/Mail-RFC822-Address.html).

Or reject based on a regex using the `:without` option:

```ruby
validates_format_of :comment, without: /(<script>|<\/script>)/
```

### Inclusion

`validates_inclusion_of`

Check that a value is in a given set with `validates_inclusion_of`.

#### Usage

```ruby
validates_inclusion_of :birth_year, in: (1880..2011)
```

The `:in` parameter will accept a Ruby range like this example or any other `Enumerable` object (like an `Array`).

### Custom Validations

For custom validations, call the `validate` method with a symbol specifying the instance method to be called. When a record is saved, that method will be called.

```ruby
validate :not_spammy

def not_spammy
  if self.description.downcase.include?("enhancement")
    errors.add(:base, "The description sounds spammy")
  end
end
```

Rails will not respect the return value of that method, it determines pass/fail based on whether any error messages were added to the object. To make the validation fail by call `errors.add(:base, message)`. If no errors are added, the validation passes.

## Validations in the User Interface

Having expressed validations in the model, let's see how to make use of them in the user interface.
 
### Understanding Errors

As an example, assume we have this model:

```ruby
class Product < ActiveRecord::Base
  validates_presence_of :title
end
```

#### In the Console

Trigger the validation:
 
{% irb %}
$ p = Product.new
 => #<Product id: nil, title: nil, price: nil, description: nil, image_url: nil, created_at: nil, updated_at: nil, stock: 0> 
$ p.valid?
 => false 
{% endirb %}

Calling the `valid?` method on an instance will run the validations and return `true` or `false`. From there, we can dig into the errors:

{% irb %}
$ p.errors
 => {title:["can't be blank"]} 
$ p.errors.full_messages
 => ["Title can't be blank"] 
{% endirb %}

The `.errors` method returns an `ActiveRecord::Errors` collection, which looks like a hash, with the attribute name as the key and the message(s) in an array. The convenience method `.full_messages` on that object returns an array of nicely formatted sentence fragments.

#### Save vs. Save!

While looking at validation failures, let's highlight the difference between `.save` and `.save!`. Both methods run your validations, of course, but the consequences of a failure are different.

For example:

{% irb %}
$ p = Product.new
 => #<Product id: nil, title: nil, price: nil, description: nil, image_url: nil, created_at: nil, updated_at: nil, stock: 0> 
$ p.save
 => false 
$ p.save!
ActiveRecord::RecordInvalid: Validation failed: Title can't be blank
{% endirb %}

A call to `save` will return `true` if the save succeeds and `false` if it fails. In your application code, you should react to this return value to determine next steps. For example:

```ruby
def create
  @product = Product.new(params[:product])
  if @product.save
    redirect_to @product, notice: "Successfully created product."
  else
    render action: 'new'
  end
end
```

The `if`/`else` switches based on the success/failure of the `save`.

Alternatively, when we use `save!`...

{% irb %}
$ p = Product.new
 => #<Product id: nil, title: nil, price: nil, description: nil, image_url: nil, created_at: nil, updated_at: nil, stock: 0> 
$ p.save!
ActiveRecord::RecordInvalid: Validation failed: Title can't be blank
{% endirb %}

When `.save!` succeeds it will also return `true`, but when it fails it will *raise an exception*. Well architected Ruby treats exceptions as extremely abnormal cases. For that reason, saving a model should only raise an exception when something *very strange* has happened, like the database has crashed. Users entering junky input is not unexpected, so we shouldn't typically raise exceptions on a validation.

So when should you use `save!`? When you expect the validations to always pass. For instance, if your application is creating objects with no user input, it'd be very strange to have invalid data. Then use `save!` and skip the redirect. In such a scenario, redirecting someplace probably isn't going to help, so your application should raise an exception.

### Displaying Errors

Typically we react to `.save` in the controller and re-render the form if it returned `false`. Then in the UI we can display the errors for the user to correct.

#### Back in Rails 2

In the olden days, this was very easy. All you had to write in the helper was call `error_messages_for`:

```erb
<%= error_messages_for @product %>
```

You'd get a box saying that there were errors and a bulleted list of the error messages. Assuming your form is using the `form_for` helper, the fields with the validation errors will automatically be wrapped with a `<div class='field_with_error></div>`. 

But the markup was not customizable, so most production apps would end up rewriting it.

With Rails 3 the `error_messages_for` helper was removed.

#### Writing a Helper Method

But now we can write our own `error_messages_for`, imitate Rails 2, and leave the door open for easy customization at the design stage. Here's an implementation from Ryan Bates of RailsCasts:

```ruby
def error_messages_for(*objects)
  options = objects.extract_options!
  options[:header_message] ||= I18n.t(:"activerecord.errors.header", default: "Invalid Fields")
  options[:message] ||= I18n.t(:"activerecord.errors.message", default: "Correct the following errors and try again.")
  messages = objects.compact.map { |o| o.errors.full_messages }.flatten
  unless messages.empty?
    content_tag(:div, class: "error_messages") do
      list_items = messages.map { |msg| content_tag(:li, msg) }
      content_tag(:h2, options[:header_message]) + content_tag(:p, options[:message]) + content_tag(:ul, list_items.join.html_safe)
    end
  end
end
```

It's CSS-compatible with the original Rails 2 implementation and respects i18n message definitions.

#### Custom Messages & Internationalization

<div class="opinion">
<p>All the validations support a <code>:message</code> parameter in the model where you can specify a custom message. But this is the wrong way to do it, and I hope that option is soon deprecated.</p>
</div>

Error messages can be specified in our locale file. These files live in `config/locales/` and have names corresponding to the language code, like `en.yml` for English or `es.yml` for Spanish.

In that translation file you can override the default messages either globally for all uses of a validation or on a per-model basis. Check out the Rails source code for lots of details on implementation: https://github.com/rails/rails/blob/master/activerecord/lib/active_record/locale/en.yml

Here's an example based on `validates_presence_of :title` for a `Product`:

```yaml
en:
  activerecord:
    errors:
      models:
        product:
          attributes:
            title:
              blank: "Please enter a title."
```

### Client-Side Validation

Web applications generally do a terrible job of coaching their users. You fill out a big form, click submit, then it'll have an uninformative message at the top of the form like "Form Had Errors".

To treat users with respect, we should run validations and give feedback as soon as possible. That means handling it on the client-side in JavaScript.

Should we re-implement all our model validations in JavaScript? No!

The Client-Side Validations gem (https://github.com/bcardarella/client_side_validations) will take care of everything for you. It will read your model validations, wrap them up into a JSON package, and send it to the client along with the form. Combined with a small JavaScript engine to process that JSON, you get a great user experience with very little work.

Check out the project page and readme for details on setup and usage.

## Database Validations

For truly bullet-proof data integrity you'll need to implement validations at the database level, too.

* The `foreigner` gem gives you the ability to add foreign key constraints to MySQL, PostgreSQL, and SQLite: https://github.com/matthuhiggins/foreigner
* `validates_uniqueness_of` could, in theory, run into a race condition if there are two concurrent requests creating the same data. To protect against that, you can create a database index on the field and specify that it must be unique:

```ruby
# in your migration...
t.index(:title, unique: true)
```
  
  Then the database would reject a second submission with an existing title if it got past the Rails model validation
  
## Exercises

{% include custom/sample_project.html %}

1. Write validations to check that an `Article` object must have both a title and a body.
2. Validate that a `Comment` has a body of less than 250 characters.
3. Validate that neither articles nor comments have your name in them.
4. Validate that a comment must have an associated article. Test it in your console and make sure it works as expected.
5. Build a module of `TextValidations` that can be shared by `Article` and `Comment`, then `include` it from both models.

## References

* Rails API for `validates_X_of` methods: http://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html
* Rails API for `validates` syntax: http://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates
* Tricks and techniques for Ruby exceptions: http://exceptionalruby.com/
* Client-Side Validations Gem: https://github.com/bcardarella/client_side_validations
* RailsCast on Client-Side Validations: http://railscasts.com/episodes/263-client-side-validations
* ActiveRecord i18n Validation Messages: https://github.com/rails/rails/blob/master/activerecord/lib/active_record/locale/en.yml
* Rails Guide on i18n for Models: http://guides.rubyonrails.org/i18n.html#translations-for-active-record-models
* Rails migration methods including `index`: http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html
