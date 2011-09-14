# Managing Credentials

( Don't want to hard code credentials in your app because it is hard to ever get out of source control )

## Storage Strategies

( you want to store them somewhere reachable from your app, but not in the source code itself )

### Environment Variables

( ENV variables are great because they're secure yet easy to access )
( They're a pain to setup on new systems. Any good solutions to this? )
( It's the technique used by Heroku, the client's deployment platform )

### Creating a `Config` Object

( Create a config class )
( In that class, access the config data, so it's abstracted/centralized )
( For instance: `Config[:database_name]` to fetch the db name rather than `ENV[:database_name]` or something)
( That way it is flexible for the future if ENV variables are no longer the way to go )

### Alternative Ideas

( Maybe the config could fetch a JSON package from a secure URL )
( Other ideas? )

### Example Usage: `database.yml`

( You've got it setup, now there are few places you can make use of it in your system )
( The most common use is the `database.yml`)
( Show example of hitting the Config object from the YML )

### (Another example...?)

## On Heroku

( Heroku uses ENV for credentials )
( So your config object can speak to ENV )
( Yet your app can be flexible to work on other hosts with minimal change -- just changing Config if necessary )

### What's There

( Use the Heroku CLI to display ENV variables on server )
( Explain what the various keys are )

### Changing Heroku Settings

( What are some scenarios where you're going to monkey with these settings -- like moving between database levels, etc)
( Probably need to look at Heroku dev center for ideas/notes here )

### Creating Custom Keys

( Ex: Master password for your app or something )
( Create the key on the CLI )
( Set it through the CLI )
( Access it through the config object )
( It might be fun to write a "check_keys" method on the Config class that would iterate through the env keys and make sure each of them is set to a value)

### Security Considerations

( I think anyone who can push to Heroku can also fetch the ENV )
( 6 months ago they were talking about granularizing these permissions a bit, not sure if there's been progress )

## References