require './plugins/highlight_code'
#
# Generates a Mac OS X window around the specified content.
#
# Example:
# {% terminal %}
# $ gem install rails
# {% endterminal %}
#
# {% window terminal %}
# $ gem install rails
# {% endwindow %}
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
#     $ gem install sunlight
#     </div>
#   </div>
# </div>
#
module Jekyll

  class WindowTag < Liquid::Block
    include HighlightCode
    include TemplateWrapper

    attr_reader :window_type

    def initialize(tag_name, markup, tokens)
      @window_type = markup.to_s == "" ? "terminal" : markup.to_s
      super
    end

    def render(context)
      output = super(context)

      %{<div class="window">
          <nav class="control-window">
            <a href="#finder" class="close" data-rel="close">close</a>
            <a href="#" class="minimize">minimize</a>
            <a href="#" class="deactivate">deactivate</a>
          </nav>
          <h1 class="titleInside">#{window_type.capitalize}</h1>
          <div class="container"><div class="#{window_type}">#{promptize(output)}</div></div>
        </div>}
    end
  end

end



Liquid::Template.register_tag('terminal', Jekyll::WindowTag)
Liquid::Template.register_tag('window', Jekyll::WindowTag)