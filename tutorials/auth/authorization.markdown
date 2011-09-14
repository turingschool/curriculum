# Authorization with CanCan

( Explain that authorization comes after authentication: are they allowed to do what they're trying to do? )

## Getting Started

( CanCan was inspired by Declarative Authorization and has become the most popular authorization library )
( Created by Ryan Bates from Railscasts )

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