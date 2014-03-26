require 'net/http'
require 'uri'
require 'fileutils'
require 'digest/md5'
require 'redis'
require 'uri'

PYGMENTIZE_URL = URI.parse('http://pygmentize.herokuapp.com/')

module HighlightCode
  def highlight_store
    @highlight_store ||= connect_to_highlight_store
  end

  def connect_to_highlight_store
    host = ENV["REDISTOGO_URL"] || 'redis://localhost:6379'
    uri = URI.parse(host)
    store = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    puts "Connecting to highlight store #{store.inspect}"
    store
  end

  def highlight(str, lang)
    lang = 'ruby' if lang == 'ru'
    lang = 'objc' if lang == 'm'
    lang = 'perl' if lang == 'pl'
    lang = 'yaml' if lang == 'yml'
    begin
      str = pygments(str, lang).match(/<pre>(.+)<\/pre>/m)[1].to_s.gsub(/ *$/, '') #strip out divs <div class="highlight">
    rescue
    end
    tableize_code(str, lang)
  end

  def pygments(code, lang)
    key = 'highlight-' + Digest::MD5.hexdigest(lang + code)
    result = highlight_store.get(key)
    if result.nil?
      print "-"
      result = Net::HTTP.post_form(PYGMENTIZE_URL, {'lang'=>lang, 'code'=>code}).body
      highlight_store.set(key, result)
    end
    result
  end

  def tableize_code (str, lang = '')
    table = '<div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers">'
    code = ''
    str.lines.each_with_index do |line,index|
      table += "<span class='line-number'>#{index+1}</span>\n"
      code  += "<span class='line'>#{line}</span>"
    end
    table += "</pre></td><td class='code'><pre><code class='#{lang}'>#{code}</code></pre></td></tr></table></div>"
  end
end
