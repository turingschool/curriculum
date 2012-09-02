# Title: Simple Video tag for Jekyll
# Author: Brandon Mathis http://brandonmathis.com
# Description: Easily output MPEG4 HTML5 video with a flash backup.
#
# Syntax {% video url/to/video [width height] [url/to/poster] %}
#
# Example:
# {% video http://site.com/video.mp4 720 480 http://site.com/poster-frame.jpg %}
#
# Output:
# <video width='720' height='480' preload='none' controls poster='http://site.com/poster-frame.jpg'>
#   <source src='http://site.com/video.mp4' type='video/mp4; codecs=\"avc1.42E01E, mp4a.40.2\"'/>
# </video>
#

module Jekyll

  class WindowTag < Liquid::Block

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
          <div class="container"><div class="#{window_type}">#{output}</div></div>
        </div>}
    end
  end

end



Liquid::Template.register_tag('window', Jekyll::WindowTag)
