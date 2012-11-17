---
layout: page
title: Consuming REST with ActiveResource
section: Web Services
---

`ActiveResource` is a library that aims to provide an `ActiveRecord` (or `ActiveModel`) style interface to remote resources or objects. It is almost strictly RESTful and works optimally with other Rails applications that are using resource routing. Although not all RESTful APIs use Rails style routing, `ActiveResource` is built to expect it.

## Creating a Resource

Setting up `ActiveResource` is simple. It is included with Rails and all configuration happens in the model itself.

### Define the Class

Remote resource classes defined by ActiveResource are meant to be treated as models by your application and live in the `app/models` directory.

```ruby
# app/models/person.rb
class Person < ActiveResource::Base
end
```

Instead of inheriting from `ActiveRecord::Base`, they inherit from `ActiveResource::Base`.

### Specify the Remote Address

The only configuration that is necessary is to specify the remote server which will be called. 

```ruby
# app/models/person.rb
class Person < ActiveResource::Base
  self.site = "http://api.people.com:3000"
end
```

#### HTTP Basic Authentication

If the remote resource requires security, the ideal situation is to use HTTP Basic Authentication, embedding the username/password in the URL string, like this:

```ruby
# app/models/person.rb
class Person < ActiveResource::Base
  self.site = "http://username:password@api.people.com:3000"
end
```

#### Certificate Authentication

Alternatively, you can use SSL certificates to ensure trust between the servers:

```ruby
class Person < ActiveResource::Base
  self.site = "https://secure.api.people.com/"
  self.ssl_options = {cert:        OpenSSL::X509::Certificate.new(File.open(pem_file))
                      key:         OpenSSL::PKey::RSA.new(File.open(pem_file)),
                      ca_path:     "/path/to/OpenSSL/formatted/CA_Certs",
                      verify_mode: OpenSSL::SSL::VERIFY_PEER}
end
```

## Interacting with the Resource

The functionality available to your `ActiveResource` class is ultimately decided by what is implemented in the remote API. In general though, the following standard methods should be available.

### `find`

The `find` method will issue a `GET` request to what would normally be the `show` route in a resourceful Rails controller. If it receives a 404 response, an exception will be thrown.

```ruby
Person.find 1
```

### Creating New Records with `new` or `create`

New objects are created as usual and fields are defined automatically upon instantiation using the data hash passed in. The `save` and `create` calls both issue `POST` requests to the remote resource.

```ruby
# Create a new person inline
Person.create first_name: "John", last_name: "Doe"

# Create a new person then save them
p = Person.new first_name: "Jane", last_name: "Doe"
p.save
```
### Updating with `save`

Changing fields on an object and saving it will issue a `PUT` request with the updated data.

```ruby
person = Person.find 1
person.first_name = "Joe"
person.save
```
### Using `delete` and `destroy`

Both the `delete` and `destroy` methods can be used to remotely delete records. `delete` is used at the class level, while `destroy` is used on instances. These will issue `DELETE` requests and expect an empty body 20X response.

```ruby
# Delete the person record with an id of 1
person = Person.find 1
person.destroy

# Delete the person record with an id of 2
Person.delete 2
```

## Exercises

{% include custom/sample_project.html %}

1. If you haven't already, follow the instructions/exercises from the "Exposing an API" section to make `ArticlesController` work with XML for all actions.
2. Generate a second Rails application and write a `RemoteArticle` model that inherits from `ActiveResource`
3. Start a console for this second application and try finding, creating, updating, and destroying articles in the remote application.
4. Experiment with fetching the comments attached to an `Article`. What does the data look like? How would this affect your implementation?

## References

* `ActiveResource` README: http://api.rubyonrails.org/files/activeresource/README_rdoc.html
* `ActiveResource` API: http://api.rubyonrails.org/classes/ActiveResource/Base.html
