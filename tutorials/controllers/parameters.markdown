# Handling Parameters

[TODO: Are we activating data or doing something with data? Do we mean "determine how to activate the domain logic, and determine the data to respond with for requests"? If so, we need some commas and some adjustments to the opening sentence]

The controller's job is to work with the request parameters and determine how to activate the domain logic and data to respond to requests. The parameters are key to completing that job.

At the same time, parameters are the cause of the most problems in a typical controller. A great action method should be about eight lines of Ruby, but many actions spiral out of control with all kinds of switching based on the input parameters.

## `params` Helper

First, a small point of order: people commonly refer to `params` as a variable but it isn't -- it is a helper method provided by `ActionController` which returns a hash containing the request parameters.

### Hash Structure

Developers new to Rails often struggle with the nested hashes inside `params`. When processing a form, `params` might look like this:

```ruby
{"utf8"=>"✓", "authenticity_token"=>"id7z1vIP1N2e0I8QtXQjflsNwcWdBwcyUuOrywEV52c=", 
"product"=>{"title"=>"Apples", "price"=>"5.99", "stock"=>"12", "description"=>"Bag of apples.", 
"image_url"=>"apples.jpg"}, "commit"=>"Create Product"}
```

It's a little easier to understand the structure by converting to YAML (using `.to_yaml`):

```ruby
---
utf8: "✓"
authenticity_token: id7z1vIP1N2e0I8QtXQjflsNwcWdBwcyUuOrywEV52c=
product:
  title: Apples
  price: '5.99'
  stock: '12'
  description: Bag of apples.
  image_url: apples.jpg
commit: Create Product
action: create
controller: products
```

The outer hash has these keys:

* `utf8` - this marker is in all form submissions to force Internet Explorer to properly encode UTF-8 data
* `authenticity_token` - a security mechanism used by the `protect_from_forgery` method called in `ApplicationController`
* `product` - the sub-hash containing the real form data
* `commit` - the label text of the button that was clicked. HTML forms with multiple buttons still all submit to the same URL, so this parameter is the only way to tell which button the user clicked
* `action` - which action is being run, setup by the router
* `controller` - which controller is being run, setup by the router

## Implementation Patterns

Given those parameters, asking for `params[:product]` will return the nested hash:

```ruby
{"title"=>"Apples", "price"=>"5.99", "stock"=>"12", "description"=>"Bag of apples.", "image_url"=>"apples.jpg"}
```

The `create` action can use those values to build the `Product`

### `ActiveSupport::HashWithIndifferentAccess`

The original hash had a key `"product"`, but I accessed it by calling `params[:product]` with a symbol. What's up with that?

```irb
ruby-1.9.2-p290 :001 > params1 = {"product" => {"title" => "Apples"}}
 => {"product"=>{"title"=>"Apples"}} 
ruby-1.9.2-p290 :002 > params1.class
 => Hash 
ruby-1.9.2-p290 :003 > params1["product"]
 => {"title"=>"Apples"} 
ruby-1.9.2-p290 :004 > params1[:product]
 => nil
```

A Ruby `Hash` with key `"product"` will not respond to `:product`.

Within the Rails internals there are (almost) no hashes. Instead, what look like hashes are actually instances of `ActiveSupport::HashWithIndifferentAccess`:

```irb
ruby-1.9.2-p290 :001 > params2 = ActiveSupport::HashWithIndifferentAccess.new({"product" => {"title" => "Apples"}})
 => {"product"=>{"title"=>"Apples"}} 
ruby-1.9.2-p290 :002 > params2.class
 => ActiveSupport::HashWithIndifferentAccess 
ruby-1.9.2-p290 :003 > params2["product"]
 => {"title"=>"Apples"} 
ruby-1.9.2-p290 :004 > params2[:product]
 => {"title"=>"Apples"} 
```

The *IndifferentAccess* is because it allows us to do lookups with either string or symbol versions of the keys. Our `params` keys are really strings, but most often we'll access them using a symbol.

#### Symbols vs. Strings

If we can use either symbols or strings, why prefer symbols?

* It's one fewer character to type
* Strings are for *users*. They're things we take in from the form, data we store in the database, output we show in the view.
* Symbols are for *programs*. They're used for internal messaging and data structures like traversing a hash

Not everyone agrees with these opinions and many Rails developers don't have any convention, so you'll see a random mix of strings and symbols. My rule is to use a symbol whenever I can, then strings when I have to.

### `params` in a Simple Action 

The most straightforward usage of `params` is to lookup a single key and do something with the retrieved value:

```pre
def show
  @product = Product.find(params[:id])
end
```

### `params` with Mass Assignment

Typically in a `create` action we'll make use of mass-assignment:

```ruby
def create
  @product = Product.new(params[:product])
  #...
```

That is equivalent, given our example `params`, to this:

```ruby
@product = Product.new(:title => params[:product][:title],
                       :description => params[:product][:description],
                       :price => params[:product][:price],
                       :stock => params[:product][:stock],
                       :image_url => params[:product][:image_url])
```

In this long form, we're building up a hash with keys `:title`, `:description`, etc. But it's pointless! We saw that when we query for `params[:product]` we get back the nested hash. That hash has keys `:title`, `:description` -- exactly as we're building up here. So when we use this form:

```ruby
def create
  @product = Product.new(params[:product])
  #...
```

We're passing in a hash of data. This method is preferred because it is shorter to read/write and, more importantly, it doesn't need alteration if we add new attributes to the model.

### `params` Gone Wrong

Here's one of the common ways that developers abuse parameters and controller actions:

```ruby
def index
  if params[:order_by] == 'name'
    @products = Product.order('title')
  elsif params[:order_by] == 'price'
    @products = Product.order('price ASC')
  else
    @products = Product.all
  end
end
``` 

We're anticipating a parameter named `:order_by` and want to do some sorting based on that. Here's a cleanup of just the Ruby syntax to use a `case` statement:

```ruby
def index
  @products = case params[:order_by]
    when 'name'  then Product.order('title')
    when 'price' then Product.order('price ASC')
    else              Product.all
  end
end
```

Whenever I'm tempted to write `variable = case #...` or `variable = if #...`, I know that I really need to encapsulate the right side into a method. In the "Mass Assignment" section, we said that sending the parameters down to the model in bulk was a maintenance win because the controller won't have to change when the model adds attributes.

If changes to one component of the system necessitate changes in another then those objects are *coupled*. By having all this logic for sorting in the controller, we increase the coupling between controller and model which, in the long run, hurts. What if we emulated the idea of proxying to the model?

```ruby
def index
  @products = Product.ordered_by(params[:order_by])
end
```

Imagine we have a class method on `Product` named `ordered_by`. We send the parameter down to the model and let it figure out what that string means in the context of our domain and data -- which is exactly the job of the model. The implementation there looks familiar:

```ruby
class Product < ActiveRecord::Base
  #...
  
  def self.ordered_by(param)
    case param
      when 'name'  then Product.order('title')
      when 'price' then Product.order('price ASC')
      else              Product.all
    end
  end
end
```

This isn't about writing less code, it's about writing code in the right place. The model is responsible for logic and working with data. Don't let it leak up into your controllers!
 
## Exercises

[TODO: Add Exercises]

## References

* Rails Guide on Parameters: http://guides.rubyonrails.org/action_controller_overview.html#parameters
* `ActiveSupport::HashWithIndifferentAccess`: http://as.rubyonrails.org/classes/HashWithIndifferentAccess.html
* UTF-8 Hacks for Internet Explorer: http://stackoverflow.com/questions/3222013/what-is-the-snowman-param-in-rails-3-forms-for/3348524#3348524
