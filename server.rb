require 'bundler/setup'
require 'sinatra'
require "sinatra/subdomain"

$root = ::File.dirname(__FILE__)

subdomain :live do
  get '/' do
    send_sinatra_file('events/heroku-performance.html') {404}
  end
end

get(/.+/) do
  send_sinatra_file(request.path) {404}
end

not_found do
  send_sinatra_file('404.html') {"Sorry, I cannot find #{request.path}"}
end

def send_sinatra_file(path, &missing_file_block)
  file_path = File.join(File.dirname(__FILE__), 'public',  path)
  file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i
  File.exist?(file_path) ? send_file(file_path) : missing_file_block.call
end