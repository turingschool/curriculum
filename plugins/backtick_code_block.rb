require './plugins/pygments_code'

module BacktickCodeBlock
  include HighlightCode
  AllOptions = /([^\s]+)\s+(.+?)(https?:\/\/\S+)\s*(.+)?/i
  LangCaption = /([^\s]+)\s*(.+)?/i
  def render_code_block(input)
    @options = nil
    @caption = nil
    @lang = nil
    @url = nil
    @title = nil
    input.gsub /^(\s*)`{3} *([^\n]+)?\n(.+?)\n\s*`{3}/m do
      indentation = $1
      @options = $2 || ''
      str = $3

      if @options =~ AllOptions
        @lang = $2
        @caption = "<figcaption><span>#{$3}</span><a href='#{$4}'>#{$5 || 'link'}</a></figcaption>"
      elsif @options =~ LangCaption
        @lang = $2
        @caption = "<figcaption><span>#{$3}</span></figcaption>"
      end

      if str.match(/\A {4}/)
        str = str.gsub /^ {4}/, ''
      end
      
      figure = if @lang.nil? || @lang == 'plain'
        code = tableize_code(str.gsub('<','&lt;').gsub('>','&gt;'))
        "<figure class='code'>#{@caption}#{code}</figure>"
      else
        if @lang.include? "-raw"
          raw = "``` #{@options.sub('-raw', '')}\n"
          raw += str
          raw += "\n```\n"
        else
          code = highlight(str, @lang)
          "<figure class='code'>#{@caption}#{code}</figure>"
        end
      end
      indentation + figure
    end
  end
end
