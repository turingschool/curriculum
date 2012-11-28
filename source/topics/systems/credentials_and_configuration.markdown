---
layout: page
title: Credentials and Configuration
section: Systems Management
---

As your application matures, you may find that API credentials and configuration details change as much or more than your application code. If you tie these details too closely to your source code then you'll be forced to redeploy for even simple configuration changes.

You may also want to share access to your source code among many developers without disclosing private credential details. For the reasons you should abstract credentials and configuration details.

## Centralizing Configuration and Credential Information

Using a high-level `Config` abstraction will let you encapsulate where and how this information is stored. 

### Environment Variables

ENV variables are a great option for storing configuration data because they are secure yet easy to access.

This is [Heroku's preferred method](http://devcenter.heroku.com/articles/config-vars) for storing configuration data.

You can set ENV variables on your local machine by running a command like this:

{% terminal %}
$ export SECRET_KEY=shazbot
{% endterminal %}

That command is typically run in your `.bash_profile` so the value persists between reboots. You can
also set different values for ENV variables on a per-command basis, like so:

{% terminal %}
$ SECRET_KEY=shazbot bin/utility_script
{% endterminal %}

You can access ENV values directly from ruby using the ENV global object, which is a Hash of all ENV values. 

But doing this is not future-proof: as your app becomes more complex you may want to switch to a more fine-grained solution. Relying on ENV as your configuration abstraction does not afford enough flexibility.

### Creating `Config`

Here's an approach that will keep things simple but will allow you future flexibility. Create a file named `config.rb` in
`app/lib`:

```ruby
module Config
  extend self

  def [](key)
    ENV[key]
  end
end
```

This Config module encapsulates configuration details stored in ENV variables. Later you can add other sources of data like this:

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
   YAML.load(Rails.root.join("app/lib/banned_domains.yml")
 end
end
```

Now when you run `Config[:banned_domains]` you'll get the array defined in `banned_domains.yml`.

### Other Ideas

Your Config object could query a secure URL for a chunk of JSON containing all of the necessary configuration/credential information needed for a new deployment. 

In this case, you might only use ENV variables to store authentication details for that URL. Here's what your `Config` module might look like:

```ruby
# app/lib/app_config.rb
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
```

Where the `CONFIG_URL` looks like `"https://USERNAME:PASSWORD@secure.example.com/config.json"`

## On Heroku

To display current [Heroku config variables](http://devcenter.heroku.com/articles/config-vars), run:

{% terminal %}
$ heroku config
BUNDLE_WITHOUT                => development:test
DATABASE_URL                  => postgres://USERNAME:PASSWORD@example.com/dbname
GEM_PATH                      => vendor/bundle/ruby/1.9.1
PATH                          => vendor/bundle/ruby/1.9.1/bin:/usr/local/bin:/usr/bin:/bin
RACK_ENV                      => production
RAILS_ENV                     => production
{% endterminal %}

All Heroku apps start out with a few basic settings like these.

### Changing Heroku Settings

To add or change a setting, use this command line instruction:

{% terminal %}
$ heroku config:add VARIABLE_NAME=VARIABLE_VALUE
{% endterminal %}

If you create a separate Heroku staging app you may want to create a separate staging environment to prevent your staging app from affecting production data. The change would look like this:

{% terminal %}
$ heroku config:add RAILS_ENV=staging
{% endterminal %}

### Security Considerations

Currently anyone who can push to your Heroku app can fetch and set ENV values. If you would like to share deployment responsibilities but still protect sensitive credentials you would need to implement your own security controls (perhaps through the Config object).

## References

* ENV Variables on Heroku Dev Center: http://devcenter.heroku.com/articles/config-vars
