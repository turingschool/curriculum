---
layout: page
title: Controller Modules
---

If several controllers share a common logical abstraction, it might make sense to have them share a module of filters and other common code. For instance, this `module` could be defined in `application_controller.rb` or in its own `app/controllers/resource_controller.rb` file:

```ruby
module ResourceController
  extend ActiveSupport::Concern

  included do
    before_filter :find_resource, only: [:show, :edit, :update, :destroy]
  end

  module InstanceMethods
    def find_resource
      class_name = params[:controller].singularize
      klass = class_name.camelize.constantize
      self.instance_variable_set "@" + class_name, klass.find(params[:id])
    end
  end
end
```

Then in the `ArticlesController`:

```ruby
class ArticlesController < ApplicationController
  include ResourceController
  
  #...
end
```

Does this encapsulate the common concerns or obfuscate the use of the `before_filter`? You have to be the judge for your application.
