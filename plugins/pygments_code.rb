require 'rembrandt'

module HighlightCode
  def highlighter
    @highlighter ||= Rembrandt::Highlighter.new
  end

  def formatter
    @formatter ||= Rembrandt::Formatters::Table.new
  end

  def highlight(str, lang)
    highlighted_code = highlighter.highlight(code, language)
    formatter.format(highlighted_code, language)
  end
end
