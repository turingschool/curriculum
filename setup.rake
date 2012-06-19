require 'yaml'

desc "Find and replace git urls"
task :setup do
  file_name = "server.rb"
  config = YAML.load_file("config.yml")
  text = File.read(file_name)
  text.gsub!(/##git_post_receive_url##/, config["git_post_receive_url"])
  File.open(file_name, "w") {|file| file.write(text) }
end

task :default => [:setup]
