require './plugins/window_tag'

#
# Generates a Mac OS X window around the specified content.
#
# Example:
# {% terminal %}
# $ gem install rails
# {% endterminal %}
#
# Output:
# <div class="window">
#   <nav class="control-window">
#   <a href="#finder" class="close" data-rel="close">close</a>
#   <a href="#" class="minimize">minimize</a>
#   <a href="#" class="deactivate">deactivate</a>
#   </nav>
#   <h1 class="titleInside">Terminal</h1>
#   <div class="container">
#     <div class="terminal">
#     ...
#     </div>
#   </div>
# </div>
#
module Jekyll

  class TerminalTag < WindowTag

    def format(output)
      promptize(output)
    end

    def title
      @window_type.capitalize
    end

  end

end

Liquid::Template.register_tag('terminal', Jekyll::TerminalTag)