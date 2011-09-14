# Credentials and Configuration

( in the long run Both credentials and configuration change more than your application code )
( You don't want to be forced to deploy for simple config changes )
( You also want to be able to share source code across multiple deployments )
( So you should abstract credentials and configuration information )

## Centralizing Configuration and Credential Information

( A config object abstracts and centralizes access to configuration/credential information)

### Environment Variables

( ENV variables are great because they're secure yet easy to access )
( They're a pain to setup on new systems. Any good solutions to this? )
( It's the technique used by Heroku, the client's deployment platform )
( But if we call ENV all over the app that's not flexible for the future. What if we don't want to use ENV later? )

### Creating `Config`

( Create a config class, maybe in `app/system/config.rb` )
( For instance: `Config[:database_name]` to fetch the db name)
( Could just implement a `[]` method and map it to `ENV[]`)

### Future Ideas

( The config object could implement a fetch method that gets a JSON package from a secure URL )
( Then [] pulls from that instead of ENV)
( Other ideas? )

## Example Usages

### Reworking `database.yml`

( You've got it setup, now there are few places you can make use of it in your system )
( The most common use is the `database.yml`)
( Show example of hitting the Config object from the YML )

### Setting the Log Destination

( Sometimes systems want to centralizing logging across several apps )
( Set a config value for the log filename with path )
( Use that value in the application.rb )

### `ENV` Bootstrap

( What about a method that could check a set of environment variables )
( So when you deploy, you'd run a rake env:bootstrap, it's check for and create env variables)
( Then a rake env:list would display the current values of the relevent variables )
( The rake section comes *after* this one, so I guess punt on writing that task. But the Config class could implement the method and we could run it from the console )

## On Heroku

( Heroku uses ENV for credentials and config )
( So your config object can speak to ENV )
( Yet your app can be flexible to work on other hosts with minimal change -- just changing Config if necessary )
( ENV gets shared by new dynos, workers -- right? )

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