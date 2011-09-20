# Credentials and Configuration

As your application matures, you may find that API credentials and configuration details
change as much or more than your application code. If you tie these details to closely
to your source code then you'll be forced to redeploy for even simple configuration changes.
You may also want to share access to your source code among many developers without
disclosing private credential details. For the reasons you should usually abstract
credentials and configuration details.

## Centralizing Configuration and Credential Information

Using a high-level `Config` abstraction will let you encapsulate where and how this 
information is stored. You may start out using only environment variables, but
may also want to pull some information out of a YAML file. If you notice some
details changing frequently, you might decide to store that data in a database
table.

### Environment Variables

ENV variables are a great option for storing configuration data because they are secure yet easy to access.
This is [Heroku's preferred method](http://devcenter.heroku.com/articles/config-vars) for storing configuration
data.

You can set ENV variables on your local machine by running a command like this:

```bash
export SECRET_KEY=shazbot
```

That command is typically run in your `.bash_profile` so the value persists between reboots. You can
also set different values for ENV variables on a per-command basis, like so:

```bash
SECRET_KEY=shazbot bin/utility_script
```

You can access ENV values directly from ruby using the ENV global object, which is a Hash of all
ENV values. But doing this is not future-proof: as your app becomes more complex you may
want to switch to a more fine-grained solution. Relying on ENV as your configuration 
abstraction does not afford enough flexibility.

### Creating `Config`

Here's an approach that will keep things simple but will allow you future flexibility. Create
a file called `config.rb` which you might place in `app/system` or in `lib` or even in
`config/initializers`:

```ruby
module Config
  extend self

  def [](key)
    ENV[key]
  end
end
```

This Config module encapsulates configuration details stored in ENV variables. Later you can
add other sources of data like this:

```ruby
module Config
  extend self

  def [](key)
    if respond_to?(key)
      self.send(key)
    else
      ENV[key]
    end
  end

 def banned_domains
   YAML.load(Rails.root.join("lib/config/banned_domains.yml")
 end
end

# now when you run Config[:banned_domains] you'll get the array defined in banned_domains.yml
```

### Future Ideas

Your Config object could query a secure URL for a chunk of JSON containing all of the 
necessary configuration/credential information needed for a new deployment. In this case,
you might only use ENV variables to store authentication details for that URL. Here's what
your Config module might look like:

```ruby
# lib/app_config.rb
require "open-uri"
require "json"

class AppConfig
  def initialize(url)
    @data = {}
    # skipping error handling details here for clarity
    open(url) do |f| 
      data = JSON.parse(f.read)
    end
  end

  def [](key)
    @data[key]
  end
end

# config/initializers/load_config_data.rb

require "app_config"
Config = AppConfig.new(ENV["CONFIG_URL"])
# CONFIG_URL looks like "https://USERNAME:PASSWORD@secure.example.com/config.json"
```

## Example Usages

### Reworking `database.yml`
[TODO: not sure what you are driving at here -- how to build a DB interface outside of Rails setup?]

( You've got it setup, now there are few places you can make use of it in your system )
( The most common use is the `database.yml`)
( Show example of hitting the Config object from the YML )

### Setting the Log Destination

[TODO: you can't log to a file in Heroku. Is this still a relevant example?]

( Sometimes systems want to centralizing logging across several apps )
( Set a config value for the log filename with path )
( Use that value in the application.rb )

### `ENV` Bootstrap

If you like the simplicity of ENV variables and don't want to bother with the Config abstraction
outlined here, you can still ensure cross-app flexibility and ease of deployment by creating a bootstrap Rake task 
(see [Automated Tasks with Cron and Rake](systems/automation.markdown) for an explanation of Rake).

This could take the form of a `rake env:bootstrap` task fetches and sets any unset ENV variables using a JSON 
file from a secure URL (like we did with the `config.json` example previously). You could pair this task with 
a `rake env:list` task to display the current values of those variables.

## On Heroku

To display current [Heroku config variables](http://devcenter.heroku.com/articles/config-vars), run:

```bash
$ heroku config
BUNDLE_WITHOUT                => development:test
DATABASE_URL                  => postgres://USERNAME:PASSWORD@example.com/dbname
GEM_PATH                      => vendor/bundle/ruby/1.9.1
PATH                          => vendor/bundle/ruby/1.9.1/bin:/usr/local/bin:/usr/bin:/bin
RACK_ENV                      => production
RAILS_ENV                     => production
```

All Heroku apps start out with a few basic settings like these.

### Changing Heroku Settings

To add or change a setting, use `heroku config:add VARIABLE_NAME=VARIABLE_VALUE`. One value you might
change is RAILS_ENV. If you create a separate Heroku staging app you may want to create a separate
staging environment to prevent your staging app from affecting production data. The change would look
like this:

```bash
heroku config:add RAILS_ENV=staging
```

### Security Considerations

Currently anyone who can push to your Heroku app can fetch and set ENV values. If you would like
to share deployment responsibilities but still protect sensitive credentials you would need to implement
your own security controls (perhaps through the Config object).

## References
(http://devcenter.heroku.com/articles/config-vars)
