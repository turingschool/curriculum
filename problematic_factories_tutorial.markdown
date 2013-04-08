---
layout: page
title: Creating Objects with Factories
section: Internal Testing
---

In the beginning there were fixtures. We'd write huge YAML files containing sample objects, often by hand.

They worked great, until the object structure changed. When you decide that your article now needs a `"published_on"` timestamp, you'd go through all your fixtures and manually add the given YAML attribute to each entry in the fixtures file. Boring!

<div class='note'>
<p>During this tutorial section, have a copy of the Blogger sample project open. You'll be able to install the library, create factories, and experiment with them.</p>
</div>

## Factories

Effective testers today use factories. There are several popular options: FactoryGirl, Machinist, and Fabrication. We'll use Fabrication (http://fabricationgem.org/) because it has a powerful yet concise API.

### Setup Fabrication

To use the library, add `gem 'fabrication'` to your `Gemfile`, then run `bundle` from the command line.

#### Replacing Fixtures

When you use the built in Rails generators they'll create fixture files for you that you'll never use. Instead, we can have the generators create stub fabricator patterns for us.

Open `config/application.rb` and within the `class Application` definition, add this:

```ruby
config.generators do |g|
  g.test_framework      :rspec, fixture: true
  g.fixture_replacement :fabrication
end
```

Next time you run a generator you'll get the fabricator stub.

## Defining Patterns

A factory works by defining a pattern, then stamping instances from that pattern. Let's look at the tools Fabrication lays out for you.

### Basic Attributes

By default, your patterns will live in `spec/fabricators/` and be named after the corresponding object type. So to create a pattern for an `Article` model we'd create `spec/fabricators/article_fabricator.rb`

Within that file we could define a pattern like this:

```ruby
Fabricator(:article) do
  title "Sample Title"
  body  "Sample Body"
end
```

The first parameter, `:article`, specifies which model the factory should create an instance of. Then, inside the block, we specify the attributes. First is the attribute name, here `title`, then the value for that attribute.

So every time we use this pattern we'll get an `Article` with the title set to `"Sample Title"` and the body to `"Sample Body"`.

### Generative Data with Faker

Creating sample object with titles like `"Sample Title"` is lame. But at the same time we don't want to use truly "random" data or it might cause intermittent testing issues. We need realistic data without the annoyance of creating it by hand.

Designers have faced this problem for decades. Their solution? _Lorem Ipsum_. It's a chunk of realistic-looking text that's actually Latin gibberish (not a poem as often rumored).

In Ruby, we have a gem named Faker which can generate placeholder data for you. Add `"faker"` to your `Gemfile`, `bundle`, and start creating fake data! Here are some handy methods it provides you:

* `Faker::Name.name` might generate `"Arden Kuhic"`
* `Faker::Internet.email` might generate `"dangelo@legros.uk"`
* `Faker::Lorem.sentence` might generate `"Doloribus tempora dolores fugiat."`

This is really awesome power. Adapting our previous Fabricator pattern, we can take advantage of Faker:

```ruby
Fabricator(:article) do
  title { Faker::Lorem.sentence }
  body  { Faker::Lorem.paragraphs(3).join("\n") }
end
```

And get more unique data.  Notice that we're now passing a _block_ to each attribute.  Doing so causes the block to be evaluated, producing dynamic values.

### Sequences

But maybe Faker doesn't give you enough predictability to your randomness. You might want to give each instance created by the factory a unique number. That's where a sequence comes in.

Create a sequence by calling the `sequence` method:

```ruby
Fabricator(:article) do
  title { sequence }
  body  { sequence }
end
```

Both sequences will start at zero and increment for each article created, so we'll get titles and bodies like "0", "1", "2". Not very realistic!

Sequences will take a block and return the return value of that block. Use blocks to create more reasonable data, like numbering our objects created with Faker data:

```ruby
Fabricator(:article) do
  title { sequence{|i| "#{Faker::Lorem.sentence} (#{i})" }}
  body  { Faker::Lorem.paragraphs(3).join("\n") }
end
```

When building a sequence, you can give it a name for reuse across multiple Fabricators:

```ruby
published_year { sequence(:year) }
```

And you can add a second parameter to begin with a certain value, like this:

```ruby
published_year { sequence(:year, 2000) }
```

The first article generated would get `2000`, the second `2001`, and so on.

### Associated Objects

Fabrication can also build associated objects for you on the fly. For instance, when an `Article` has associated _comments_:

```ruby
Fabricator(:article) do
  title { sequence(:title_counter) {|i| "#{Faker::Lorem.sentence} (#{i})" } }
  body  { Faker::Lorem.paragraphs(3).join("\n") }
  comments(count: 3) {|article, index| Fabricate(:comment, article: article)}
end
```

To build an associated object:

* specify the name of the association, just like we have the other attributes
* specify the number you want with `count: x`
* supply a block which receives two parameters:
  1. the parent object being generated
  2. the index number (here 0, 1, or 2) of the child object being generated

The child objects are lazily generated, so they're not actually created until accessed. 

<div class="note">
Sometimes this feature will give you confusing results. To force instant generation, add a <code>!</code> so, in the above, <code>comments(:count)...</code>  becomes <code>comments!(:count)...</code>
</div>

### Inheritance

Now we're generating "heavy" articles that each have three comments attached. Chances are that many of my examples don't actually need comments, they're focused on the article itself. It'd be nice to have a way to generate light articles most of the time, and heavier ones when working with the comments.

We can break the previous example up into a base pattern and an extension using inheritance:

```ruby
Fabricator(:article) do
  title { sequence(:title_counter) {|i| "#{Faker::Lorem.sentence} (#{i})" } }
  body  { Faker::Lorem.paragraphs(3).join("\n") }
end

Fabricator(:article_with_comments, from: :article) do
  comments(count: 3) {|article, index| Fabricate(:comment, article: article)}
end
```

The second pattern has a unique name as its first parameter, then `from: ` which names the pattern from which it inherits. You could thus have multiple steps of inheritance, if necessary.

You'll notice that the inheriting pattern leaves out the `title` and `body`. It gets those for _free_ from the parent, then adds on the `comments`. If we were to re-define `title` or `body` in the inheriting pattern, it would override the parent's values.

## Usage

Once you've got your patterns defined, creating objects is easy. When developing your patterns, it's helpful to load up `rails console`. Fabricator is available to you there. 

<pre class="note">
  Keep in mind that it may be saving data to your development database, though, so tread carefully.  If you want to play around in the console but not persist and changes you might make, load the console with the `--sandbox` or `-s` flag, which will rollback database modifications on exit.
</pre>

Here's an example of using them from console:

```irb
> light = Fabricate(:article)
# => #<Article id: 17, title: "Vel omnis suscipit magnam atque vero accusantium. (...", body: "Quos sed sequi inventore quisquam et temporibus dol...", created_at: "2011-06-30 19:45:21", updated_at: "2011-06-30 19:45:21", junk: nil> 
> light.comments
# => [] 
> heavy = Fabricate(:article_with_comments)
# => #<Article id: 18, title: "Enim aut error asperiores sunt ex sit enim. (1)", body: "Cum earum voluptatem reprehenderit. Magnam rerum et...", created_at: "2011-06-30 19:45:33", updated_at: "2011-06-30 19:45:33", junk: nil> 
> heavy.comments
# => [#<Comment id: 5, article_id: 18, author_name: "Lorenzo Fritsch I", body: "Saepe soluta minus est consequatur id ratione. Rati...", created_at: "2011-06-30 19:45:39", updated_at: "2011-06-30 19:45:39">, #<Comment id: 6, article_id: 18, author_name: "Treva Haley", body: "Et et autem tenetur sit. Voluptatibus labore in aut...", created_at: "2011-06-30 19:45:39", updated_at: "2011-06-30 19:45:39">, #<Comment id: 7, article_id: 18, author_name: "Miss Kim Gottlieb", body: "Aut numquam quam quisquam officia sequi molestiae f...", created_at: "2011-06-30 19:45:39", updated_at: "2011-06-30 19:45:39">] 
```

### Overrides

For some test cases you want to override the pattern rules. Say we want to create an `Article` with a title that includes a JavaScript injection. We could do it the long way:

```ruby
article = Fabricate(:article)
article.title = "<script type='javascript'>alert('hacked!')</script>"
```

Or use an ActiveRecord-like syntax for specifying the attribute:

```ruby
article = Fabricate(:article, title: "<script type='javascript'>alert('hacked!')</script>")
```

That's everything you need to know to create flexible, easy sample data with Fabricator.

## Exercises

{% include custom/sample_project.html %}

1. Follow the examples in the tutorial to create a fabricator for `Article` and test it from the console.
2. Write a fabricator for `Comment` that just generates the `Comment` object. Use appropriate generators from `Faker`
3. Use inheritance to extend that pattern to create a `Comment` with a parent `Article`
4. From your console, use the override style to create a comment with the body `"Hello, World!"`
5. Flip the `Article` patterns so `Fabricate(:article)` gives you an article with comments, and `Fabricate(:article_without_comments)` gives an `Article` with no comments
