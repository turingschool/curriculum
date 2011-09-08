require 'rubygems'
require 'bundler'
Bundler.require
require 'pygments/ffi'
require "sinatra/reloader" if development?
set :markdown, :layout_engine => :haml, :layout => :tutorial

module Tilt
  class RedcarpetTemplate < RDiscountTemplate
    def flags
      [:filter_html, :autolink, :fenced_code, :hard_wrap, :tables, :gh_blockcode]
    end
  end
end 

set :views, :scss => 'server/scss', :haml => 'server/views', :default => 'tutorials'
set :public, 'server'

helpers do
  def find_template(views, name, engine, &block)
    _, folder = views.detect { |k,v| engine == Tilt[k] }
    folder ||= views[:default]
    super(folder, name, engine, &block)
  end
end

get '/css/:sheet_name.css' do
  scss params[:sheet_name].to_sym
end
  
get '/' do
  @title = "Ruby on Rails Level 3 Tutorial"
  markdown(:index)
end

get '/tutorials/*' do
  path = params[:splat].first
  path = path[0..-2] if path[-1..-1] == "/"
  file = "tutorials/" + path + ".markdown"
  # html = Redcarpet.new(File.read(file)).to_html
  html = markdown(File.read(file))
  doc = Nokogiri::HTML.parse(html)
  doc.search('pre').each do |node|
    text = node.inner_text.strip
    lang = node['lang'] || "text"
    text = Albino.colorize(text, lang)    
    text.gsub!("<pre>", "<pre>\n      ")
    #text.gsub!("      ", "")
    node.replace(text)
  end
  doc.to_html
end