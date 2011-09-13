# Query Strategy

( Most apps kick off too many queries, how do you fix it? )

As development on a project progresses it's likely that some actions will grow to kick off too many queries or some requests may be taking too long for some reason, but how does one fix this problem?

Two ways to improve the speed of the query time during a request are to:

1. Ensure the database is appropriately indexed
2. Combine separate queries together if possible

( NOTE: Is there a good place to talk about using EXPLAIN? I don't commonly use it. )

## Indices

( Queries run slowly because you don't have indices )

Database tables without indices will degrade in performance as more records get added to them over time, since the database engine will have to look through more records to find what it's looking for.  Adding an index to a table will ensure consistent long-term performance in querying against the table even as many thousands of records get added to it.

Indices are added to one or more columns of a table.

### What to Index

( Any column that you use find_by_x, then you should index X)

If a model uses the `find_by_x` method then the `x` column in the database should be indexed.  Thinking in terms of the application, the way users interact with your domain data will suggest what columns on your models could use indices.  Can they search for articles by keyword and written by a specific user?  Then indexing the user_id of the article author will be in order.

( Why not index everything? Building and maintaining indices has a performance cost of its own.)

One might ask why an index isn't added to every column since the performance for searching against indexed columns of a table will be improved.  Unfortunately, indices don't come for free as extra processing will be required of the database when records are inserted or updated in order to maintain the index.  For this reason indices should only be added to columns that are queried against in the application.

( Indexes are used automatically, once created we don't change the app at all )

One nice thing about applying indices to our tables is that the application will inherit the performance gains without having to alter our model code.  An example of this is getting a list of comments on an article.  If the article model contains `has_many :comments` then the comments database table will have an `article_id` column.  Adding an index on `article_id` will improve the speed of the query when processing something like `@article.comments.each ...` in a controller or view.

### Indexing a Single Column

( Example of using add_index in a migration)

Consider the comment model in a blogging application referred to in the previous section.  The model has the following fields:

* article_id
* author_name
* body
* created_at
* updated_at

To add an index on `article_id` to the `comments` table we'd generate a migration and edit it as follows:

```ruby
def AddIndexOnArticleIdToComments < ActiveRecord::Migration
  def self.up
    add_index :comments, :article_id
  end

  def self.down
    remove_index :comments, :article_id
  end
end
```

### Indexing Multiple Columns

( If you use find_by_x_and_y, then index on x and y)

Searching against multiple columns of a model (using something like `find_by_x_and_y`) would need a composite index in order to efficiently search against both columns.  To add a composite index to a table simply pass an array of the columns to index as the second parameter to `add_index`.  Adding a composite index on the `author_name` and `created_at` fields to the `comments` table would be look like the following:

( Example using add_index with multiple columns)

```ruby
def AddIndexOnArticleIdToComments < ActiveRecord::Migration
  def self.up
    add_index, :comments, [:author_name, :created_at]
  end

  def self.down
    remove_index :comments, [:author_name, :created_at]
  end
end
```

## Using `includes`

( Fewer queries but they are much heavier, sacrificing I/O load for query count )

Another way to improve the query time of a request is to reduce the number of queries being made.  This is accomplished by selecting more data in a single query instead of executing multiple queries.  In the [Measuring Performance](measuring) section we saw a log from showing an article page which displayed comments made on the article.

This type of loading should not be done in the controller.  Rather, a scope or method should be placed on the model so that the controller just calls a single method.  This way, if the model is used in another controller or elsewhere in the application that logic can be leveraged again without having to remember to copy it from the previous controller.

The `includes` query method is used to chain an ARel scope to note that an association should be eagerly loaded when the parent object is loaded.  Let's watch the development log as we interact with an article and its comments in the Rails console:

```text
 # commented below lines are output from the development.log file
ruby> a = Article.find(1)
 # Article Load (0.4ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = 1 LIMIT 1
ruby> a.comments.all
 # Comment Load (0.4ms)  SELECT "comments".* FROM "comments" WHERE ("comments".article_id = 1)

 # Now with includes
ruby> a = Article.includes(:comments).find(1)
 # Article Load (0.4ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = 1 LIMIT 1
 # Comment Load (0.3ms)  SELECT "comments".* FROM "comments" WHERE ("comments".article_id = 1)
```

Note that for the first two commands only a single SQL query shows up in the log file, yet when the `includes(:comments)` command is run it results in two SQL queries being executed.

There's not much performance gain using `includes` in this example, but let's see what happens when we add another `has_many` relationship to a `Comment`.  After creating a `Reply` model, adding `has_many :replies` to the `Comment` model, and editing and running the corresponding migration let's inspect the logs again:

```text
 # create an article and 3 corresponding comments, assume this article has an ID of 2
ruby> a = Article.find(2)
 # Article Load (0.4ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = 2 LIMIT 1
ruby> a.comments.each {|comment| comment.replies.all}
 # Comment Load (0.4ms)  SELECT "comments".* FROM "comments" WHERE ("comments".article_id = 2)
 # Reply Load (0.3ms)  SELECT "replies".* FROM "replies" WHERE ("replies".comment_id = 1)
 # Reply Load (0.3ms)  SELECT "replies".* FROM "replies" WHERE ("replies".comment_id = 2)
 # Reply Load (0.2ms)  SELECT "replies".* FROM "replies" WHERE ("replies".comment_id = 3)
```

We see that an additional SQL query gets executed for each comment the article has.  How many do you think there will be after using `includes` to load the nested replies as well?

```text
ruby> a = Article.includes(:comments => :replies).find(2)
 # Article Load (0.5ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = 1 LIMIT 1
 # Comment Load (0.4ms)  SELECT "comments".* FROM "comments" WHERE ("comments".article_id = 1)
 # Reply Load (0.4ms)  SELECT "replies".* FROM "replies" WHERE ("replies".comment_id IN (1,2,3,4))
```

Here we see a hash was passed to `includes` in order to specify the relationships that should be eagerly loaded when an `Article` is loaded.  `includes` can also take an array to specify that multiple `has_many` relationships should be eagerly loaded.

If the application is Rails 2.x the finder methods have an `:include` option to achieve the same result.

### Using `default_scope`

If an object is always going to load its child records then a `default_scope` can be setup on the model so that the child is always eagerly loaded whenever the parent object is loaded.  Continuing with our previous example, suppose we always want the comments for an article to be loaded.  Instead of having to remember to add `:include => :comments` to all finder calls just add the following to the `Article` model:

```ruby
default_scope :include => :comments
```

After the above has been added to the model, then code as simple as `Article.find(1)` will include the associated `comments`.  `default_scope` has the drawback that this `:include` will *ALWAYS* be included in any fetch of an `Article` object by default.  The `unscoped` method will need to be called in order to prevent the associated comments from being included when the object loads.

### Using a Scope

In order to avoid having `default_scope` polute all object loads of an `Article` an alternative is writing a custom scope to do the same thing:

```ruby
scope :with_comments, :include => :comments
```

The `Article` model now has a `with_comments` scope that can be used where associated `comments` are eagerly loaded, but other calls to the model will not pay the cost of loading these extra comments.  This alternative is nice since we now gain the convenience of loading the associated comments when desired, but arne't forced to always do so.  It's heavy when you want it, light when you don't.

## Counter Cache

( frequently want simple counts of child objects )
( ex: Article and number of comments )

### Add the Column

( sample migration to add column to articles table )
( rake db:migrate )

### Priming the Counts

( if there are existing records, I think you need to set the counts manually at first...?)

### Usage

( Normal usage -- I think `.count` will fetch the attribute rather than executing SQL Count )

## Rethinking Data Storage

( Maybe your data doesn't need to be in fully normalized database records )

### Static Data

( Just setup a hash in a constant in an initializer )
( EX: state abbreviations in a STATE_ABBREVIATIONS hash)

### ActiveHash

( One step more Active-Record like with ActiveHash https://github.com/zilkey/active_hash)

### Serialized Columns

( Elaborate on the section "Saving arrays, hashes, and other non-mappable objects in text columns" from http://api.rubyonrails.org/classes/ActiveRecord/Base.html)

## References

* https://github.com/zilkey/active_hash
* http://api.rubyonrails.org/classes/ActiveRecord/Base.html
