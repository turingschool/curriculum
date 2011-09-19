# Consuming REST with ActiveResource

( What AResource is all about )
( Best for matching against Rails apps )
( Should match against other apps which follow the pattern )

## Creating a Resource

( ARes is already a part of Rails, no gem to setup )
( Configuration is handled in the model itself )

### Define the Class

```ruby
class Person < ActiveResource::Base

end
```

### Specify the Remote Address

```ruby
self.site = "http://api.people.com:3000"
```

## Interacting with the Resource

( depends which methods are implemented on the other side )
( but in general you can use ... )

### `find`

### Creating New Records with `new`

### Updating with `save`

### `delete`

## Exercises

[TODO: Setup JSBlogger]

1. If you haven't already, follow the instructions/exercises from the "Exposing an API" section to make `ArticlesController` work with XML for all actions.
2. Generate a second Rails application and write a `RemoteArticle` model that inherits from `ActiveResource`
3. Start a console for this second application and try finding, creating, updating, and destroying articles in the remote application.
4. Experiment with fetching the comments attached to an `Article`. What does the data look like? How would this affect your implementation?

## References

* `ActiveResource` README: http://api.rubyonrails.org/files/activeresource/README_rdoc.html
* `ActiveResource` API: http://api.rubyonrails.org/classes/ActiveResource/Base.html