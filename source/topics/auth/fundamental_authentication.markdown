---
layout: page
title: Fundamental Authentication
sidebar: true
---

## Goals

When you're done with this session you should:

* Be able to explain the concepts authentication, password/secret, hash
function, digest, rainbow table, and salt
* Understand why we use hashing and store digests rather than passwords
* Have experimented with the BCrypt library to generate salts and digests
* Have implemented a basic database-backed authentication system using
per-user salts

## Discussion

### Big Picture

* Authentication - are you who you say you are?
* Authorization - are you allowed to do what you're attempting to do?
* Authentication typically involve an identifier (login, email, etc) and
a secret
* The secret could be a password, retina scan, hardware token, thumb print, etc

### Secrets & Hashing

Let's talk about secrets and hashing.

* You should never store a password itself
* Instead you store an digest of the password
* A hash function is a one-way mathematic function that creates a nearly unique
digest
* A given input always gives the same digest, but given an digest you cannot
calculate the input
* Compare two digests to determine if the inputs were identical
* Rainbow tables list huge sets of hashed passwords
* Salts are used to further obfuscate the inputs
* The salt is added to the input before hashing
* Application-wide salts are good, per-user salts are better

## Experiments

### Try out BCrypt

Try the instructions below to see some of what you can do
with the [bcrypt-ruby gem](https://github.com/codahale/bcrypt-ruby).

```
require 'bcrypt'
salt = BCrypt::Engine.generate_salt
password = "hello, world"
hashed = BCrypt::Engine.hash_secret(password, salt)
puts hashed
guess = "Hello, World"
hashed == BCrypt::Engine.hash_secret(guess, salt)
hashed == BCrypt::Engine.hash_secret(password, salt)
```

### Try BCrypt's `Password` Class

BCrypt also has a specialized class for handling passwords. Try this out:

```ruby
require 'bcrypt'
my_password = "hello, world!"
bcrypt_password = BCrypt::Password.create(my_password)
the_hash = bcrypt_password.to_s
bcrypt_password == "HELLO, WORLD!"
bcrypt_password == "hello, world!"

new_attempt = BCrypt::Password.new(the_hash)
new_attempt == "HELLO, WORLD!"
new_attempt == "hello, world!"
```

### Building Authentication in Rails

Got the theory? Try and implement the model side of a password-based
authentication system into a Rails app:

* Generate a new Rails 4 application
* Uncomment bcrypt in the `Gemfile` and bundle
* Create a users table with `:login`, `:digest`, and `:salt`
* Write a model test like this:

```ruby
def test_user_authenticates_via_password
  original_user = User.create(:username => "john",
                              :password => "bossman")

  authenticated_user = User.authenticate(:username => "john",
                                         :password => "bossman")
  assert_equal original_user, authenticated_user
end
```

And for the failed login case:

```ruby
def test_user_fails_authentication
  original_user = User.create(:username => "john",
                              :password => "bossman")

  failed_user = User.authenticate(:username => "john",
                                  :password => "bossman")
  refute failed_user, "User should have failed authentication."
end
```

Build the implementation with the following considerations:

* Your `User` model doesn't have a `password` column in the database
* You need to generate a salt for each user (using BCrypt) and store it in the
database
* The `authenticate` method will have to fetch the salt from the database,
hash it with the supplied password, and see if the result matches the stored digest
* If the calculated digest matches the stored digest, return the user. If not
return `nil`.

## Resources

There are many libraries that can help you with authentication including:

* Devise: https://github.com/plataformatec/devise
* Authlogic: https://github.com/binarylogic/authlogic
* Sorcery: https://github.com/NoamB/sorcery
* Omniauth: https://github.com/intridea/omniauth
* Cancan: https://github.com/ryanb/cancan
