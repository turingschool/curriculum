require './plugins/pygments_code'
require './plugins/raw'

module HighlightCode
  def promptize(str)
    table = '<table><tr><td class="gutter"><pre class="line-numbers">'
    code = ''
    str.strip.lines.each_with_index do |line,index|
      if line.start_with? "$"
        line = line.sub("$","").strip
        table += "<span class='line-number'>$</span>\n"
        code  += "<span class='line command'>#{line.strip}</span>"
      else
        table += "<span class='line-number'>&nbsp;</span>\n"
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
        table += "<span class='line-number'>1.9.2p320 :#{index.to_s.rjust(3,'0')}&gt;</span>\n"
        code  += "<span class='line command'>#{line.strip.gsub(/</,'&lt;').gsub(/>/,'&gt;')}</span>"
      else
        table += "<span class='line-number'>&nbsp;</span>\n"
        code  += "<span class='line output'>#{line.strip.gsub(/</,'&lt;').gsub(/>/,'&gt;')}</span>"
      end
    end
    table += "</pre></td><td class='code'><pre><code>#{code}</code></pre></td></tr></table>"
  end
end
