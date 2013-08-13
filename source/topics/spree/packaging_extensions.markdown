---
layout: page
title: Packaging Spree Extensions
section: Building Applications with Spree
---

[ to integrate ]


### Discussion

* Gems and Gemspec
* Bundler with paths and git repositories
* Engines vs Plain Old Gems

[/ to integrate]

With our changes complete and refined it is time to package the entire
experience into an extension which we can share with others and bring into our
future Spree projects that may require it.

Currently if we wanted to share our simple extension with others we would need
to have them create our two files. While this was a great way to iterate quickly
in our development it is not a sustainable practice when it comes to packaging
and sharing code with others.

### Creating Our New Extension

* Move outside of our current project

We want to move outside of our current project directory because we are about to
create a new ruby project.

* Run `spree extension admin_user_panel`

This will create our extension through the power of the **spree_cmd** gem. The
extension that it creates is a lot of boilerplate code that you do not have to
write to successfully integrate with an application running Spree.

* Move into the **spree_admin_user_panel** directory

* Run `git init`

* Run `git add .` and `git commit -m "Initial Extension"`

This new extension is like our original projet. We want to track the changes
that we make here and eventually share this repository with others.

* Open `spree_admin_user_panel.gemspec`

A gemspec file is ruby file that contains the details about a gem. This is a
manifest that is written in gem building DSL. Within the gemspec you are able
to define several important fields about your gem.

* Update the **summary** and **description** fields

A gem specification cannot have *TODO* values within the summary and the
description. The *summary* is short description about the gem while the
*description* is a longer explanation. In most cases a *summary* is suffice.

* Update the **author**, **email**, and **homepage** fields

These are essential for providing contact information and allowing for
individuals to find out more about your particular gem. The *homepage* is
probably the most important as this field is used on
[Rubygems](https://rubygems.org) and is the link most users follow to find out
more information about the gem. The *homepage* is most often the Github
repository.

* Enable the **files** and **test_files** fields

These two fields are essential when packaging the gem. The resulting array of
of the `git ls-files` command tells the gem to package these files and place
them in the gem.

* Run `git add spree_admin_user_panel.gemspec` and
  `git commit -m "Updated Gemspec"`

Now that we are all done with the editing of our Gem specification it is time
to save our work before moving on to the next step.

* Run `gem build spree_admin_user_panel.gemspec`

This is how you would build your gem for release. As our gem does very little
at the moment, we are simply using it here to test that we have defined
everything successfully within our gemspec.

### Moving the Override and the Partial to Our New Extension

Now that we have our extension created it is time to move the override and
the partial view we created in the main project into the extension.

* Create, within our new extension, `app/overrides/spree/admin/users/index.rb`

* Create, within our new extension, `app/views/spree/admin/users/_table.html.erb`

* Run `git add app` and `git commit -m "Added Override and Template"`

Now we want to save our new files so that when we use our gem these files
will be included.

* Remove the override and the partial template from our existing project

This is to ensure that we have gotten rid of all traces of our existing work.

### Using Our New Extension

Now that our extension is ready we need to test it within our application. We
include extensions the same way we include any gem with a Rails application.

* Open, within our project, the `Gemfile`:

* Add our new extension as a gem `gem 'spree_admin_user_panel', path: "../spree_admin_user_panel"

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

### Conclusion

Instead of initially creating the extension and building it there we built it
within our application. This allowed us to more quickly iterate on our design
and to make changes which were picked up immediately. Changes made to the
extension would now require us to restart the server.

We now have an extension that we can build, package and share with the
community.

### An Aside About Engines

A Spree Extension is an example of a Rails Engine.

When our extension is loaded within rails the `lib/spree_admin_user_panel.rb`
file load all of its requirements. One of those is the
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
application (i.e. routing, controller, models, or views) you want to be
creating a Spree extension. If the code you are writing is not manipulating
the Rails application then you likely want to make a plain old gem.