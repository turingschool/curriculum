require 'rubygems'
require 'bundler'
Bundler.require
set :markdown, :layout_engine => :haml, :layout => :tutorial

module Tilt
  class RedcarpetTemplate < RDiscountTemplate
    def flags
      [:filter_html, :autolink, :fenced_code, :hard_wrap, :tables, :gh_blockcode]
    end
  end
end 

set :views, :scss => 'server/scss', :haml => 'server/views', :default => 'tutorials'
set :public, 'server/images'

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

get '/favicon.ico' do
  
end

get '/tutorials/:page_name/' do
  @title = params[:page_name]
  doc = Nokogiri::HTML.parse(markdown(:"#{params[:page_name]}"))
  doc.search('pre').each do |node|
    next unless lang = node['lang']
    html = Albino.colorize(node.inner_text, lang)
    node.replace(html)
  end
  doc.to_html
end