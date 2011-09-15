# Authorization with CanCan

Authorization is an important aspect to any enterprise-scale application. As a system, it is put in place to determine whether the current user has the permission to perform the requested action. Based on this, it typically happens after a user is authenticated during regular application flow. The important question to ask is, is the user allowed to do what they're trying to do?

## Getting Started

When considering implementing an authorization system in Rails, there are two libraries that have really taken the stage. The first, [Declarative Authorization](https://github.com/stffn/declarative_authorization) has been around since 2008. [CanCan](https://github.com/ryanb/cancan), the second, was inspired by `decl_auth` and created by Ryan Bates of Railscasts. It provides an intuitive interface to define your authorization rules and integrates into Rails seamlessly. As it has become the most popular authorization library, the following tutorial pertains to its implementation.

### Setup

(gem, bundle)

### `current_user`

( CanCan is expecting there to be a current_user helper method provided by your authentication system )

## Creating Abilities

( Explain what abilities are )

### Generate the Ability File

( `rails generate cancan:ability`)

### Defining Abilities

( Go over the basic structure of ability definitions)
( model examples from https://github.com/ryanb/cancan/wiki/defining-abilities )
( Just the basic style, no need to get fancy )

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
