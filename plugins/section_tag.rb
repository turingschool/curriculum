#
# The `section` tag is to be used with 
#
#

require 'pathname'
require './plugins/octopress_filters'

module Jekyll

  class SectionTag < Liquid::Tag
    include OctopressFilters
    def initialize(tag_name, markup, tokens)
      super
      @file, @image, @title_text = markup.split(" ",3)
    end
    
    def fullpath_to_file(context,file)
      file_dir = (context.registers[:site].source || 'source')
      file_path = Pathname.new(file_dir).expand_path
      [ file_path + file, file_path ]
    end

    def render(context)
      
      file, file_path = fullpath_to_file(context,@file)

      unless file.file?
        return "File #{file} could not be found"
      end
      
      Dir.chdir(file_path) do
        contents = file.read
        if contents =~ /\A-{3}.+[^\A]-{3}\n(.+)/m
          contents = $1.lstrip
        end
        contents = pre_filter(contents)
        partial = Liquid::Template.parse(contents)
        
        context.stack do
          @content = partial.render(context)
        end
        
        converter = context.registers[:site].converters.find do |converter| 
          converter.is_a? MarkdownConverter 
        end
        
        @content = converter.convert(@content) if converter
        
      end
      
      %{
<div class="section">
  <div class="prime">
    <img src="#{@image}" />
    <h2>#{@title_text}</h2>
  </div>
  <div class="second">
    #{@content}
  </div>
  <div style="clear:both;"></div>
</div>
      }

    end
  end
end

Liquid::Template.register_tag('section', Jekyll::SectionTag)
