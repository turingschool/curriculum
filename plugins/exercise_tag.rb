module Jekyll

  class ExerciseTag < Liquid::Block

    def initialize(tag_name, markup, tokens)
      super
      @archive = GithubCodeSampleArchive.new(markup)
    end

    def render(context)
      content = super(context)

      converter = context.registers[:site].converters.find do |converter| 
        converter.is_a? MarkdownConverter 
      end
        
      content = converter.convert(content) if converter

      "<div class='exercise'>
        #{content}
       </div>"
    end

  end

end

Liquid::Template.register_tag('exercise', Jekyll::ExerciseTag)