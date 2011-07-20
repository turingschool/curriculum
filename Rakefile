FILE_SEARCH_PATTERN = "tutorials/**/*.{markdown, textile}"
MARKERS = {"todo" => :red, "pending" => :green}
COLORIZE = true

MARKERS.each do |marker, color|
  desc "Pull out #{marker.upcase} lines"
  task marker do
    search_for(color, marker)
  end
end

task :default => [:todo]
 
desc "Pull out all marked lines"
task :all do
  search_for(:red, MARKERS.keys)
end

def search_for(color, *keywords)
  Dir.glob(FILE_SEARCH_PATTERN) do |filename|
    todos = File.open(filename).lines.select{|l| l.downcase.match(/.*\[(#{keywords.join("|")})+.*\].*/)}
    unless todos.empty?
      puts filename.underline
      todos.each{|todo| printf todo.send(color)}
      puts "\n\n"
    end
  end
end

class String
  def red; colorize(self, "\e[1m\e[31m"); end
  def yellow; colorize(self, "\e[1m\e[33m"); end
  def green; colorize(self, "\e[1m\e[32m"); end
  def underline; colorize(self, "\e[1m\e[4m"); end
  def colorize(text, color_code)
    COLORIZE ? "#{color_code}#{text}\e[0m" : text
  end
end