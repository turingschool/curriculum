module Jekyll
  class MarkdownConverter < Converter
    def convert(content)
      setup
      case @config['markdown']
      when 'redcarpet'
        Redcarpet.new(content, *@redcarpet_extensions).to_html.force_encoding("utf-8")
      else
        super
      end
    end
  end
end