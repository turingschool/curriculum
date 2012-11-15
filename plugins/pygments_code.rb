# with patches for pygments from http://jasongarber.com/blog/2012/01/10/deploying-octopress-to-heroku-with-a-custom-buildpack
require 'net/http'
require 'uri'
require 'fileutils'
require 'digest/md5'

PYGMENTIZE_URL = URI.parse('http://pygmentize.herokuapp.com/')
PYGMENTS_CACHE_DIR = File.expand_path('../../.pygments-cache', __FILE__)
FileUtils.mkdir_p(PYGMENTS_CACHE_DIR)

module HighlightCode
  def highlight(str, lang)
    lang = 'ruby' if lang == 'ru'
    lang = 'objc' if lang == 'm'
    lang = 'perl' if lang == 'pl'
    lang = 'yaml' if lang == 'yml'
    str = pygments(str, lang).match(/<pre>(.+)<\/pre>/m)[1].to_s.gsub(/ *$/, '') #strip out divs <div class="highlight">
    tableize_code(str, lang)
  end

  def pygments(code, lang)
    if defined?(PYGMENTS_CACHE_DIR)
      path = File.join(PYGMENTS_CACHE_DIR, "#{lang}-#{Digest::MD5.hexdigest(code)}.html")
      if File.exist?(path)
        highlighted_code = File.read(path)
      else
        highlighted_code = Net::HTTP.post_form(PYGMENTIZE_URL, {'lang'=>lang, 'code'=>code}).body
        File.open(path, 'w') {|f| f.print(highlighted_code) }
      end
    else
      highlighted_code = Net::HTTP.post_form(PYGMENTIZE_URL, {'lang'=>lang, 'code'=>code}).body
      
    end
    highlighted_code
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
