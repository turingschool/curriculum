require './plugins/pygments_code'
require './plugins/raw'

module HighlightCode
  def promptize(str)
    table = '<table><tr><td class="gutter"><pre class="line-numbers">'
    code = ''
    str.strip.lines.each do |line|
      if line.start_with? "$"
        line = line.sub("$","").strip
        table += "<span class='line-number'>$</span>\n"
        space_line(line, table)
        code  += "<span class='line command'>#{line.strip}</span>"
      else
        table += "<span class='line-number'>&nbsp;</span>\n"
        space_line(line, table)
        code  += "<span class='line output'>#{line.strip}</span>"
      end
    end
    table += "</pre></td><td class='code'><pre><code>#{code}</code></pre></td></tr></table>"
  end

  def irbize(str)
    table = '<table><tr><td class="gutter"><pre class="line-numbers">'
    code = ''

    index = 0

    str.strip.lines.each do |line|
      if line.start_with? "$"
        index = index + 1
        line = line.sub("$","").strip
        table += "<span class='line-number'>2.1.1 :#{index.to_s.rjust(3,'0')}&gt;</span>\n"
        space_line(line, table)
        code  += "<span class='line command'>#{line.strip.gsub(/</,'&lt;').gsub(/>/,'&gt;')}</span>"
      else
        table += "<span class='line-number'>&nbsp;</span>\n"
        space_line(line, table)
        code  += "<span class='line output'>#{line.strip.gsub(/</,'&lt;').gsub(/>/,'&gt;')}</span>"
      end
    end
    table += "</pre></td><td class='code'><pre><code>#{code}</code></pre></td></tr></table>"
  end

  def space_line(line, table)
    if line.length > 87
      breaks = line.length / 87
      breaks.times { table << "<br>" }
    end
  end
end
