# Local Authentication with Devise

( Devise is used to build authentication into the app locally, as opposed to OmniAuth which uses an external service )

( Uses modular approach to cherry pick functionality )

## Setup

( Gemfile and bundle )

### Create the Initializer

( rails generate devise:install )
( used to configure the library )

### Create Users

( rails generate devise User )
( run rake db:migrate)

### Routes

( devise adds the ability to just write `devise_for :users` in your routes.rb )
( after authentication, devise will send the user to your `root` path, so you need to define one. Show how to do it )

## Using Authentication

( you want to trigger authentication at the controller )

### Using Before Filters

( devise provides `:authenticate_user!` )
( if just protecting a few controllers, put it in the controller itself )

### Example: `ArticlesController`

( use the ArticlesController from JSBlogger )
( add a before filter to trigger auth )
( but this will cover all methods, oh no! )
( add an `:except => [:show, :index]` so those are public accessible)

### Checking User Status

( you can use `user_signed_in?` to see if there is a user currently signed in )
( you can use `current_user` to fetch the actual user object )
( saying `if current_user` is probably more common than using `user_signed_in` )

### Configuring Email

( if you want devise to send email, you need to setup options for action_mailer )
( and they're probably different per environment )
( show a typical setup for development.rb and production.rb )

( NOTE: Client had a specific question: is it possible to have devise email an auto-generated password, similar to what Google Apps does? So you'd register an email address, then go to the email to get your password or a one time token. I think the email_verifiable module might do this...? )

## Customizing Views

( devise uses views built into the gem by default )
( you can override them )

### Generating Views

( `rails generate devise:views` )
( explain the output )

### Customizations

( Give some ideas for things they might customize )

## References

