# Authorization with CanCan

Authorization is an important aspect to any enterprise-scale application. As a system, it is put in place to determine whether the current user has the permission to perform the requested action. Based on this, it typically happens after a user is authenticated during regular application flow. The important question to ask is, is the user allowed to do what they're trying to do?

## Getting Started

When considering implementing an authorization system in Rails, there are two libraries that have really taken the stage. The first, [Declarative Authorization](https://github.com/stffn/declarative_authorization) has been around since 2008. [CanCan](https://github.com/ryanb/cancan), the second, was inspired by `decl_auth` and created by Ryan Bates of Railscasts. It provides an intuitive interface to define your authorization rules and integrates into Rails seamlessly. As it has become the most popular authorization library, the following tutorial pertains to its implementation.

### Setup

To get started, let's add `cancan` to the `Gemfile`.

```ruby
gem "cancan"
```

Now, to install the gem, run `bundle install` from the command line.

### The Current User

It is convention in a Rails application to implement a definition of `current_user` in your controllers. This should simply return an instance of the `User` model that is currently active in the session. `CanCan` is expecting `current_user` to be available for its controller includes to work, which are available automatically in descendants of `ActionController::Base` once the `CanCan` gem is installed. 

## Creating Abilities

To define an application's authorization rules, we'll think in terms of abilities. For example, is the `current_user` able to update their own information? Typically abilities are defined on a per model basis unless and can get as specific as you need.

### Generate the Ability File

As of version 1.5, `CanCan` includes a generator to create our `Ability` file. This is where all of your ability definitions will live. To execute the generator, run the following from the command line: `rails generate cancan:ability`.

### Defining Abilities

( Go over the basic structure of ability definitions)
( model examples from https://github.com/ryanb/cancan/wiki/defining-abilities )
( Just the basic style, no need to get fancy )

`CanCan` provides a succint DSL for defining abilities. Let's dive in and look at a simple example:

```ruby
# Our Ability class is just a plain old ruby object
class Ability

  # Add in CanCan's ability definition DSL
  include CanCan::Ability

  def initialize( user )

    # Handle the case where we don't have a current_user i.e. the user is a guest
    user ||= User.new

    # Define a few sample abilities
    can :manage , Foo
    can :read , Bar , released: true

  end

end
```

The `CanCan` generator will provide the structure for your Ability class. At a basic level then, all you need to do is implement the constructor. Here we can see a few things...

* As is recommended in the `CanCan` documentation, the case where a `current_user` is `nil` is handled.
* A user can perform all actions on the `Foo` model. This is function of the `:manage` incantation.
* Users can read instances of the `Bar` model where `bar.released` is `true`

### Building Roles

( CanCan does not do anything to handle "roles" )
( For maintainability, you probably want to implement the concept of Role groups )
( A user gets added to Roles by the admin )
( Then in the ability file you query something like `current_user.is?(:admin)` )
( Check out the notes here: https://github.com/ryanb/cancan/wiki/Role-Based-Authorization )

## Checking Abilities

( Once abilities are defined, you can check those abilities throughout the app )

### `can?`

( how do you use it )

#### `cannot?`

( how do you use it )

### `load_and_authorize_resource`

( ref: https://github.com/ryanb/cancan/wiki/authorizing-controller-actions )

### Handling Authorization Failure

( When the user is not authorized, an exception will be raised )
( Catch this exception and redirect them, send a warning message, or whatever )
( ref: https://github.com/ryanb/cancan/wiki/exception-handling )

( ## Usage Patterns )
( Is there anything else to say about tips for effectively using `can?` in models, controllers, views? )

## References
