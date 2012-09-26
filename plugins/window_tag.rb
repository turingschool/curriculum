require './plugins/highlight_code'
#
# Generates a Mac OS X window around the specified content.
#
# @see TerminalTag
# @see IrbTag
#
module Jekyll

  class WindowTag < Liquid::Block
    include HighlightCode
    include TemplateWrapper

    attr_reader :window_type

    def initialize(tag_name, markup, tokens)
      @window_type = tag_name
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
          <h1 class="titleInside">#{title}</h1>
          <div class="container"><div class="#{window_type}">#{format(output)}</div></div>
        </div>}
    end

    def format(output)
      promptize(output)
    end

    def title
      @window_type.capitalize
    end

  end

end
