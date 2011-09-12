# Query Strategy

( Most apps kick off too many queries, how do you fix it? )

( NOTE: Is there a good place to talk about using EXPLAIN? I don't commonly use it. )

## Indices

( Queries run slowly because you don't have indices )

### What to Index

( Any column that you use find_by_x, then you should index X)
( Why not index everything? Building and maintaining indices has a performance cost of its own.)
( Indexes are used automatically, once created we don't change the app at all )

### Indexing a Single Column

( Example of using add_index in a migration)

### Indexing Multiple Columns

( If you use find_by_x_and_y, then index on x and y)

( Example using add_index with multiple columns)

## Using `:include`

( Fewer queries but they are much heavier, sacrificing I/O load for query count )
( Don't do it in the controller directly, delegate to model )

### Using `default_scope`

( An object that always needs its child record )
( Has the drawback in that they are *ALWAYS* included any fetch of this object)

### Using a Scope

( Write a custom scope that just adds the include )
( Ex: `Article` model that has a `with_comments` scope )
( Heavy when you want it, light when you don't )

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