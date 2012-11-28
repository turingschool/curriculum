# encoding: UTF-8
require './plugins/pygments_code'

module BacktickCodeBlock
  def render_code_block(input)
    input.force_encoding("ASCII-8BIT").gsub(back_ticks_format_regex) do |back_tick_string|
      code_block_from(back_tick_string).to_html
    end
  end

  def back_ticks_format_regex
    @back_ticks_format_regex ||= /^`{3} *(?<options>[^\n]+)?\n(?<code>.+?)\n`{3}/m
  end

  def code_block_formats
    @code_block_formats ||= [ PlainCodeBlock, RawCodeBlock, HighlightedCodeBlock ]
  end

  def code_block_from(back_tick_string)
    match = back_ticks_format_regex.match back_tick_string
    options = CodeBlockOptions.from match['options']
    code = strip_leading_spaces match['code']

    format = code_block_formats.find {|format| format.match? options }
    format.new(code,options)
  end

  def strip_leading_spaces(string)
    string.match(/\A( {4}|\t)/) ? string.gsub(/^( {4}|\t)/, '') : string
  end

  class CodeBlockOptions

    #
    # Parses the string into an instance of CodeBlockOptions which contains
    # metadata about the code block.
    #
    # @param [String] string a string from the top of a code block that defines
    #   the language about the code and caption information.
    #
    # @return [CodeBlockString]
    #
    def self.from(string)
      caption = CodeBlockCaption.new *parse(string)
      new caption.language, caption
    end

    # The language of the code block
    attr_reader :language

    # The caption for the code block
    attr_reader :caption


    def initialize(language,caption)
      @language = language
      @caption = caption
    end

    private

    #
    # Parses a code block string and returns an array components found within
    # the specified string.
    #
    # @note this implementation simply returns the result of the matching
    #   format in the specified order that they are matched. If a new format
    #   is created which changes that format, this method will need to be
    #   updated.
    #
    def self.parse(string)
      formats.find { |format| format.match(string.to_s) }.match(string.to_s).to_a
    end

    #
    # The different acceptable formats of the code block string. All new formats
    # should be appended before the last one None.
    #
    #
    def self.formats
      [ LanguageCaptionAndLink, LanguageAndCaption, None ]
    end

    LanguageCaptionAndLink = /(?<language>[^\s]+)\s+(?<caption>.+?)(?<link>https?:\/\/\S+)\s*(?<link_title>.+)?/i
    LanguageAndCaption = /(?<language>[^\s]+)\s*(?<caption>.+)?/
    None = //

  end

  #
  # Each code block has a caption whether they specify one or not. That's how
  # things work around here.
  #
  class CodeBlockCaption

    attr_reader :raw_caption, :language, :caption, :link_url, :link_title

    #
    # This initializer is built to receive the input from the CodeBlockOptions
    # parse method. The simplicity there makes for an initializer designed in
    # a way only a mother of a MatchData, converted to an array, could love.
    #
    def initialize(raw_options = nil, language = nil,caption = nil,link_url = nil,link_title = nil)
      @raw_caption = raw_caption
      @language = language.to_s
      @caption = caption
      @link_url = link_url
      @link_title = link_title || 'link'
    end

    def to_s
      raw_caption
    end

    def to_html
      return "" unless caption

      html = "<figcaption><span>#{caption}</span>"
      html += "<a href='#{link_url}'>#{link_title}</a>" if link_url
      html += "</figcaption>"
    end
  end


  #
  # When the code block language has not been specified or is plain then you
  # have a plain old code block.
  #
  # @example Plain Old Code Block
  #
  #       ```
  #       This is PlainsVille? I thought it would be more exciting.
  #       ```
  #
  class PlainCodeBlock
    include HighlightCode

    def self.match?(options)
      options.language.to_s =~ /(^$|plain)/
    end

    attr_reader :codeblock, :caption

    def initialize(codeblock,options)
      @codeblock = codeblock
      @caption = options.caption
    end

    def to_html
      clean_code = codeblock.gsub('<','&lt;').gsub('>','&gt;')
      final_code = tableize_code clean_code
      "<figure class='code'>#{caption.to_html}#{final_code}</figure>"
    end

  end


  #
  # When the code block language has the suffix of -raw, then the block
  # will be displayed in raw format without the normal HTML formatting.
  #
  # @example Raw Ruby Code Block
  #
  #       ```ruby-raw
  #       class WelcomeToMondayNightRaw
  #         def self.raw ; puts "rawness" ; end
  #       end
  #       ```
  #
  class RawCodeBlock

    def self.match?(options)
      options.language.to_s =~ /-raw$/
    end

    attr_reader :codeblock, :caption

    def initialize(codeblock,options)
      @codeblock = codeblock
      @caption = options.caption
    end

    def to_html
      raw = "``` #{caption.to_s.sub('-raw', '')}\n"
      raw += raw_code
      raw += "\n```\n"
    end

  end


  #
  # This is your standard highlighted code block that uses the language to
  # generate a code block so spectacular in appeal and design it is bound to
  # impress all those that gaze upon it.
  #
  # @example Highlighted Code Block
  #
  #     ```ruby Gemfile
  #       gem 'this'
  #       gem 'that'
  #       gem 'clever-name-for-the-other-thing'
  #     ```
  #
  class HighlightedCodeBlock
    include HighlightCode

    def self.match?(options)
      options.language.to_s !~ /(^$|plain)/
    end

    attr_reader :codeblock, :caption, :language

    def initialize(codeblock,options)
      @codeblock = codeblock
      @caption = options.caption
      @language = options.language
    end

    def to_html
      syntax_highlighted_code = highlight(codeblock,language)
      "<figure class='code'>#{caption.to_html}#{syntax_highlighted_code}</figure>"
    end

  end

end
