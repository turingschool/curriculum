# Search with WebSolr

( Using external service for search can be a performance win )
( Transparent to the user )

## Sunspot

( Sunspot is the preferred gem for Solr-backed search )

### Install

( add `sunspot_rails` to Gemfile and bundle )

### Heroku Setup

( `heroku addons:add websolr` )

### Configuration

( Sunspot looks for the `WEBSOLR_URL` env variable )
( When used on heroku, no setup necessary )
( For more control, run `rails generate sunspot` to create `config/sunspot.yml`)

### Indexing

( In the model, call the `searchable` method and pass a block of types/attributes )

```ruby
class Post < ActiveRecord::Base
  searchable do
    text    :title
    text    :body
    string  :permalink
    integer :category_id
    time    :published_at
  end
end
```

#### Available Methods and Settings

( `text` is for full text search, broken into individual keyworkds )
( adding `:default_boost` like this:
searchable do
    text :title, :default_boost => 2
    text :body
  end
Will cause matches in the title to be promoted more highly)

#### Using Workers

( You want to use background workers to do indexing )
( add `handle_asynchronously :solr_index` after the call to `searchable`)
( will transparently use Heroku workers )

### Searching

( call `Article.search { keywords 'hello' }`, then `@articles = @articles.results`)

### Search Results

( More info: https://github.com/sunspot/sunspot/wiki/Working-with-search )

#### `.results`

( gives the actual objects matches, like the set of articles )

#### `.hits`

( gives more metadata about the quality of the search match, highlights matches in the text, etc.)

### Maintaining the Index

( How to force a full refresh of the index on Heroku )

## References

* Heroku DevCenter on Websolr: http://devcenter.heroku.com/articles/websolr
* SunSpot quickstart: https://github.com/sunspot/sunspot/wiki/Adding-Sunspot-search-to-Rails-in-5-minutes-or-less
* Working with Sunspot Results: https://github.com/sunspot/sunspot/wiki/Working-with-search
