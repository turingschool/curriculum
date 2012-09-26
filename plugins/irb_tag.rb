require './plugins/window_tag'

#
# Generates a Mac OS X window around the specified content.
#
# Example:
# {% irb %}
# $ gem install rails
# {% endirb %}
#
# Output:
# <div class="window">
#   <nav class="control-window">
#   <a href="#finder" class="close" data-rel="close">close</a>
#   <a href="#" class="minimize">minimize</a>
#   <a href="#" class="deactivate">deactivate</a>
#   </nav>
#   <h1 class="titleInside">IRB</h1>
#   <div class="container">
#     <div class="irb">
#     ...
#     </div>
#   </div>
# </div>
#
module Jekyll

  class IrbTag < WindowTag

    def title
      window_type.upcase
    end

    def format(output)
      irbize(output)
    end

  end

end

Liquid::Template.register_tag('irb', Jekyll::IrbTag)