require 'bundler/setup'
require 'sinatra'
# The project root directory
$root = ::File.dirname(__FILE__)

post /generate/ do
  generate
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

def generate
  system 'git pull upstream master'
  system 'rake generate'
end

#configure do
#  generate
#end
