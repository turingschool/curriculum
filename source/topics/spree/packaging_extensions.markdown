---
layout: page
title: Packaging Spree Extensions
section: Building Applications with Spree
---

With our changes refined it is time to package the entire
experience into an extension which we can share with others and bring into our
future Spree projects that may require it.

Currently, if we wanted to share our simple extension with others we would need
to have them recreate our two files in their project. While this was a great way to iterate quickly
in our development it is not a sustainable practice when it comes to packaging
and sharing code with others.

### Creating Our New Extension

* Move outside of our current project

We want to move outside of our current project directory because we are about to
create a new ruby project.

#### Generate the Extension

* Run `spree extension admin_user_panel`

This will create our extension through the power of the `spree_cmd` gem. The
extension that it creates has a lot of boilerplate code that's necessary to successfully integrate with an application running Spree.

* Move into the `spree_admin_user_panel` directory
* Run `git init`
* Run `git add .` and `git commit -m "Initial Extension"`

This new extension is like our original projet. We want to track the changes
that we make here and eventually share this repository with others.

#### Modify the `.gemspec`

* Open `spree_admin_user_panel.gemspec`

Jump over to our [Creating a Gem tutorial]({% page_url creating_a_gem %}) to learn more about the `.gemspec` file.

* Edit the relevent fields in your `.gemspec`
* Run `git add spree_admin_user_panel.gemspec` and
  `git commit -m "Updated Gemspec"`

Now that we are all done with the editing of our Gem specification it is time
to save our work before moving on to the next step.

* Run `gem build spree_admin_user_panel.gemspec`

This is how you would build your gem for release. Our gem does nothing yet, we are simply using it here to test that we have defined
everything successfully within our `.gemspec`.

### Moving the Override and the Partial to Our New Extension

Now that we have our extension created it is time to move the override and
the partial view we created in the main project into the extension.

* Create `app/overrides/spree/admin/users/index.rb` within our new extension
* Create `app/views/spree/admin/users/_table.html.erb` within our new extension

Now we want to save our new files so that when we use our gem these files
will be included.

* Run `git add app` and `git commit -m "Added Override and Template"`

#### Stripping the Original Project

* Remove the override and the partial template from our Spree project

### Using Our New Extension

Now that our extension is ready we need to test it within our application. We
include extensions the same way we include any gem with a Rails application.

* Open the `Gemfile` within the project
* Add our new extension as a gem:

```
gem 'spree_admin_user_panel', path: "../spree_admin_user_panel"
```

Bundler allows you to specify a gem version, a git path, and a local filepath.
Using a filepath is extremely handy when you are developing or modifying a gem
internally and not yet ready to release it.

* Run `bundle install`

Within the output you should see the following entry:

```
Using spree_admin_user_panel (2.0.3) from source at ../spree_admin_user_panel
```

* Run `rails server`
* Visit `http://localhost:3000/admin/users`
* See your amazing feature!

### Conclusion

First building the extension within the app then extracting it allowed us to more quickly iterate on our design and to make changes which were picked up immediately. Changes made to the
extension would now require us to restart the server.

We now have an extension that we can build, package, and share with the
community.

### An Aside About Engines

A Spree Extension is an example of a Rails Engine.

When our extension is loaded within Rails the `lib/spree_admin_user_panel.rb`
file loads all of its requirements. One of those is the
`lib/spree_admin_user_panel/engine.rb`.

* Open `lib/spree_admin_user_panel/engine.rb`

```
module SpreeAdminPanel
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_admin_user_panel'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
```

Any time your application needs to change any of the existing code of a Rails
application (i.e. routing, controller, models, or views) you want to 
create a Spree extension. If the code you are writing is not manipulating
the Rails application then you likely want to make a plain old gem.