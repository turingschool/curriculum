---
layout: page
title: Creating a Theme System
section: Building Applications with Spree
---

The first spree extension that we created added very little to the current
experience. We relied on the existing infrastructure with very few changes.
Now we want to create an extension that will require us to add additional
database migrations, models, controllers, and views.

The goal of this exercise is to allow admins to provide some creative control
over their ecommerce platform through the admin panel. An admin would be able
to login, view the admin section, select the theme menu, and be able to choose
and set various colors.

### Adding a New Menu Item

Lets start by adding the "Theme" as a menu item as one of the sub-sections of
the "Configuration" section. First we need to find how that menu is rendered
so that we know how we can insert our new menu item.

* Open `http://localhost:3000/admin` and select the "Configuration" tab.

The initial page of the configuration section is "General Settings". The url,
"http://localhost:3000/admin/general\_settings/edit", tells us that we are in
fact editing the general settings.

If we review the logs we we see that the following:

```
Started GET "/admin/general_settings/edit" for 127.0.0.1 at 2013-08-12 14:26:56 -0500
Processing by Spree::Admin::GeneralSettingsController#edit as HTML
```

* Open the **spree_backend** gem and find the controller and associated view.

In the file `app/views/spree/admin/general_settings/edit.html.erb` the first
line renders the configuration menu.

```erb
<%= render :partial => 'spree/admin/shared/configuration_menu' %>
```

Within that template,
`app/views/spree/admin/shared/_configuration_menu.html.erb`, we see entries for
each menu listed.

* Within our Spree application create a partial template that mirrors the
  configuration menu within the **spree_backend** gem and copy in the contents.

* Add a new entry for our theme page.

```erb
<%= configurations_sidebar_menu_item Spree.t(:theme_settings), edit_admin_theme_settings_path %>
```

When we refresh the page we will see an error that we have not defined the
helper method `edit_admin_theme_settings_path`.

* Open the **spree_backend** gem's `config/routes.rb` file.

* Within our Spree application create a new resource to support our theme
  settings.

Traditionally in a Rails application we can simply would create a route that
mirrors the one that we found as an example within the **spree_backend** gem.
However, when you refresh the page you will see the same error again.

That is because the url is routed within the `Spree::Core::Engine.routes`
because it is mounted at the base "/" of our application. Any routes we define
within our application, `Jslstore::Application.routes`, will not be detected
within our Spree Application.

To successfully add our new route and our route helper we need to define our
route within the `Spree::Core::Engine.routes`.

```ruby
Jslstore::Application.routes.draw do

  mount Spree::Core::Engine, :at => '/'

  Spree::Core::Engine.routes.draw do
    namespace :admin do
      resource  :theme_settings
    end
  end
end
```

This is not an ideal solution but it is one that we will remedy when we
extract our work into an extension.

* Refresh the Page

We should now successfully have the "Theme Settings" appear within our
configurations sub menu.

* Visit `http://localhost:3000/admin/theme_settings/edit`

We should receive an entirely new error which states we do have the controller
required to handle this request defined.

### Adding the Theme Page

Now we have our working link to the destination we need to define the
controller and associated views.

* Create `app/controllers/spree/admin/theme_settings_controller.rb`

We will model our controller on the GeneralSettingsController,
`app/controllers/spree/admin/general_settings_controller.rb` defined within
the **spree_backend** gem.

```ruby
module Spree
  module Admin
    class ThemeSettingsController < Spree::Admin::BaseController

      def edit
      end

      def update
        redirect_to edit_admin_theme_settings_path
      end

    end
  end
end
```

We want our `ThemeSettingsController` to have both an *edit* and the
corresponding *update* action. And we have already gone ahead and made it so
when the *update* action completes it simply redirects back to the edit page
again.

* View `http://localhost:3000/admin/theme_settings/edit`

We now receive an error message that we have a missing template. It is time
to create the edit template.

* Create `app/views/spree/admin/theme_settings/edit.html.erb`

We again want to base the edit template on the existing general settings edit
template, `app/views/spree/admin/general_settings/edit.html.erb`, defined
within the **spree_backend** gem.

```erb
<%= render :partial => 'spree/admin/shared/configuration_menu' %>

<% content_for :page_title do %>
  <%= Spree.t(:theme_settings) %>
<% end %>

<%= form_tag admin_theme_settings_path, :method => :put do %>
  <div id="preferences" data-hook>

    <fieldset class="general no-border-top">

      <div class="row">

        <div class="alpha twelve columns">
          <fieldset class="security no-border-bottom">
            <legend align="center"><%= Spree.t(:theme_settings)%></legend>
          </fieldset>
        </div>

      </div>

      <div class="form-buttons filter-actions actions" data-hook="buttons">
        <%= button Spree.t('actions.update'), 'icon-refresh' %>
        <span class="or"><%= Spree.t(:or) %></span>
        <%= link_to_with_icon 'icon-remove', Spree.t('actions.cancel'), edit_admin_theme_settings_url, :class => 'button' %>
      </div>

    </fieldset>

  </div>

<% end %>
```

Our template is a fair bit simplier at the moment because we have no fields
we need to represent.

### Which Elements Should an Admin Control

We want to allow an admin to configure and control most of their website. With
that in mind, we could simply allow an admin to copy-and-paste an entirely new
set of css overrides into an text area and call it done.

However, we might also want to only them to configure a small subset of the
features (e.g. background colors, font colors, font sizes) through a variety of
smaller textfields or controls to ensure that the stores have a sane look and
feel and possibly have a similar branding across multiple sites.

For this exercise lets start with providing the admin with the ability to
configure a small set of features. We could always later implement a system
that allows the admin to provide complete overrides with what we learn with the
more restrictive system.

### How to Control the Themes

Starting with the background color we want to allow the admin to specify a color
value within a text field. When the admin is done specifying the color they
will press the submit button and the details will be saved in a controller
action.

* Open `app/views/spree/admin/theme_settings/edit.html.erb` and define a label
  and text field that will allow the background color to be specified.

### Storing the Details in the Spree Preferences

Our controller action receives the setting changes and it is our job to save
them. At the moment our most readily available data store is the database
that contains all the other information about our platform.

Spree maintains a list of preferences. This is something we saw in the **edit**
template for the `GeneralSettingsController`. Throughout the template the
`Spree::Config` was being accessed and being rendered. The `Spree::Config` seems
like a good place to store our theme settings.

* Run `rails console` and type in `Spree::Config`

```
1.9.3p429 :005 > Spree::Config
 => #<Spree::AppConfiguration:0x007ffa6dfbb750>
```

To find out more about the `Spree::Config` we need to find
`Spree::AppConfiguration`.

* Run `bundle open spree_core` and search for **app_configuration.rb**

Within this file are a number of application preferences defined.

```
module Spree
  class AppConfiguration < Preferences::Configuration

    preference :address_requires_state, :boolean, default: true # should state/state_name be required
    # ... other preferences ...

  end
end
```

We want to add a similar preference for our background color. The `Spree::AppConfiguration` class defines a class method `preference` which is
being used here to set up the preference. Ruby will use class methods, often
referred to as class macros, to define configuration. This is similar to
the functionality within Rails models and controllers.

* Open, within our Spree project, `config/initializers/spree.rb` and add the
  following preference:

```ruby
Spree::AppConfiguration.preference :theme_background_color, :string, default: "#FFFFFF"
```

* Run `rails console` and type `Spree::Config.theme_background_color` or
  `Spree::Config[:theme_background_color]`.

Our new preference should output correctly. We can even now even set our new
preference:

* Type `Spree::Config.theme_background_color = "#CF0CF0"`

This should persist our new setting.

### Specifying the Background Color Property in the Edit View

We can set and retrieve our background property programmatically. Now it is
time to add it to view.

* Open `app/views/spree/admin/theme_settings/edit.html.erb` and update the form
  to specify the new property:

```erb
<fieldset class="security no-border-bottom">
  <legend align="center"><%= Spree.t(:theme_settings)%></legend>
  <% [ :theme_background_color ].each do |key|
    type = Spree::Config.preference_type(key) %>
    <div class="field">
      <%= label_tag(key, Spree.t(key) + ': ') + tag(:br) if type != :boolean %>
      <%= preference_field_tag(key, Spree::Config[key], :type => type) %>
      <%= label_tag(key, Spree.t(key)) + tag(:br) if type == :boolean %>
    </div>
  <% end %>
</fieldset>
```

Again we start by copying the format of the view we found for the General
Settings. Here we have an array of one element, our property, that we iterate
over and display based on the type of the property.

* Open `http://localhost:3000/admin/theme_settings/edit`

There is our new property. We can edit the value but any changes we make will
not be saved. Before we address the saving part, first we need to make one
minor adjustment.

Storing data, like `[ :theme_background_color ]`, in the view is a bad practice.
Later when we want to add more properties to this list we will have to find them
in the view. It is a better practice to assign this list of properties as an
instance variable in the controller and use it in the view.

* Open `app/controllers/spree/admin/theme_settings_controller.rb` and add a
  update the **edit** action to set up an instance variable to store the theme
  settings:

```ruby
def edit
  @theme_settings = [ :theme_background_color ]
end
```

* Open `app/views/spree/admin/theme_settings/edit.html.erb` and replace the
  array with the instance variable.


### Setting the Background Color Property

Now lets store the changes to the color property. First, we need to know how the
data is being sent back to the server.

* Visit `http://localhost:3000/admin/theme_settings/edit`

* Specify a new background color

* Press the **Update** button to submit the data.

* View the logs to see the parameters that have been submitted.

The first way to figure out what content is being sent back to the server is
through the logs.

```
Started PUT "/admin/theme_settings" for 127.0.0.1 at 2013-08-12 19:48:55 -0500
Processing by Spree::Admin::ThemeSettingsController#update as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"LB2SLxgG8yovqFp3yeX+c7/YTUnuwIFmjI9UUva2StE=", "theme_background_color"=>"#000000", "button"=>""}
```

Within the `params` hash we have a number of parameters. The important one, of
course, is our `theme_background_color` which has our new value that we are
wanting to have set.

* Open `app/controllers/spree/admin/theme_settings_controller.rb` and update
  the **update** action to `fail`.

```ruby
def update
  fail
  redirect_to edit_admin_theme_settings_path
end
```

Another strategy that quite a few developers use is to set to have the request
fail and to review the parameters that are displayed on the error page.

* Open `app/controllers/spree/admin/theme_settings_controller.rb` and update
  the **update** action to set the background property.

```ruby
def update
  params.each do |name, value|
    next unless Spree::Config.has_preference? name
    Spree::Config[name] = value
  end
  flash[:success] = Spree.t(:successfully_updated, :resource => Spree.t(:theme_settings))
  redirect_to edit_admin_theme_settings_path
end
```

Again we are borrowing from the `Spree::Admin::GeneralSettingsController` logic
that we saw before. Within the huge list of parameters we are finding only the
ones that we have a preference for, `has_preference?`, and setting those values.

We finally do some nice things like display a success flash message and again
redirect back to the edit page.

Now if we attempt to set the background property it will be saved successfully.

### Overriding the Base Theme with a Style Tag

With our overrides defined we now need to add our style overrides to the page.
The simpliest method would require us to define a style tag and add our custom
styles to the page.

The style tag that we define would need to be present on every page of the
customer facing front end of our application. This means we need to override the
core application layout that is defined in the **spree_frontend** gem.

* Run `bundle open spree_frontend` and find `app/views/spree/layouts/spree_application.html.erb`.

This is the core layout file that all of the front end view templates use. We
need to copy the contents of this file into our projet and make the
modifications to include our style tag.

* Create, within our Spree application,
  `app/views/spree/layouts/spree_application.html.erb` and copy the contents
  of the original template file.

Now we have a copy that will override the one defined within the gem. We can
make changes to this one to include our special theme requirements. Lets add
a partial, to the end of the body tag within the template, that will contain
all of our style overrides.

* Open `app/views/spree/layouts/spree_application.html.erb` and update the
  template to add the following to the partial:

```erb
    <!-- all the tags and content prior to the this point -->
    <script>
      Spree.api_key = <%= raw(try_spree_current_user.try(:spree_api_key).to_s.inspect) %>;
    </script>
    <%= render partial: "spree/layouts/theme" %>
  </body>
</html>
```

* Create `app/views/spree/layouts/_theme.html.erb` and our style tag:

```erb
<style>
  body {
    background-color: <%= Spree::Config.theme_background_color %>;
  }
</style>
```

* Visit `http://localhost:3000/`

The new background settings is applied.

If you return to the admin panel, make adjustments to the background and revisit
the root path you should see the background color change appropriately.

This solution does raise some concerns. To provide the theme support we require
we had to override a fundamental template to the Spree Store. While we did not
augment the contents of the template all that greatly we would need to be aware
of changes of this core template as future versions of Spree are released.

In the next two sections we explore some possible alternatives to this very
brutal approach. Unfortunately none of them will produce the results we are
after.

### Overriding the Base Theme with Deface

An alternative would be to use Deface to find the body tag and append a style
tag with our data.

> This path to override style ultimately does not work, however, it may be
> useful in seeing for yourself that this path does not work in this instance.

* Create `app/overrides/theme.rb` and add the following:

```ruby
Deface::Override.new virtual_path: "spree/layouts/spree_application",
  name: "theme",
  insert_bottom: "body",
  text: %{
<style>
  body {
    background-color: #{Spree::Config.theme_background_color};
  }
</style>
}
```

The new background setting is applied.

However, if you change the value again and reload the page your new settings
will not take effect. It seems that the deface overrides do not recompile if
the data creating those templates is modified.

While this is a very minimal invasive tactic of implmenting an override, it
appears it is one that will not work unless we plan on restarting the server
every time the styles are changed.

### Overriding the Base Theme with a Stylesheet

An alternative would be to render a stylesheet and allow for our settings to
be applied in-line to the stylesheet.

> This path to override style ultimately has problems but provides some useful
> instruction on how you can apply **erb** templating to even stylesheets.

Stylesheets within the asset pipeline can have the **erb** extension applied
similar to how we defined templates. Rails will process these stylesheets first
as **erb**, processing any of our escape tags which we will use to apply our
settings.

* Create `app/assets/stylesheets/theme.css.erb` and add the following:

```css
body {
  background-color: <%= Spree::Config.theme_background_color %>;
}
```

* View `http://localhost:3000/admin/theme_settings/edit`

The new background setting is applied.

However, if you change the value again and reload the page your new settings
will not take effect. This is because Rails only recompiles the assets based on
changes to stylesheet. So if that file changes, if the content of the file is
modified, then the new value will be loaded.

This unfortunately barely works in development mode and will not work in
production mode where the assets are precompiled. So this method of providing
theme overrides unfortunately would not work in the long term. But it is an
interesting example of being able to use erb templating within stylesheets.

### Adding Another Theme Property

Select another property that you would like to theme within your Spree
application and implement it.

> This section is for exploration and allows you the opportunity to reinforce
> the concepts we have finished demonstrating.

### Adding Yet Another Theme Property

Our overly simple property field does not immediately provide a great
interface for interacting with all the possible fields that we may want to
provide support to customize. Every time we add/remove a setting we need
to add or create a property. Instead we could store all the properties
within one field and build a plain old Ruby object to wrap the results.

> This section is for exploration and allows you the opportunity to explore
> object-orient programming concepts.

### Extracting Into An Extension

Now that we are done with our theming it is time to extract all the contents
of the theme out of our current Spree project and move it into an extension.

> This section is for exploration and allows you the opportunity to reinforce
> the concepts of creating an extension.

* While creating the extension remember that we have additional routing
  information that needs to be transfered into the extension along with all
  the source code.

### Conclusion

We were able to add an entirely new configuration menu with its new route,
controller and associated actions. We leveraged the existing preferences
data structure to allow us the ability to generate a theme system which would
now allow an admin to configure the look of the site through their admin
interface.