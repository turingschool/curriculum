FILE_SEARCH_PATTERN = "tutorials/**/*.{markdown, textile}"
MARKERS = {"todo" => :red, "pending" => :yellow, "edit" => :yellow, "review" => :green, "wip" => :red}
COLORIZE = true

MARKERS.keys.each do |marker|
  desc "Pull out #{marker.upcase} lines"
  task marker do
    print_lines_containing(marker)
  end
end

task :default => [:todo]
 
desc "Pull out all marked lines"
task :all do
  print_lines_containing(MARKERS.keys)
end

def print_lines_containing(*keywords)
  Dir.glob(FILE_SEARCH_PATTERN) do |filename|
    filename_printed = false
    File.open(filename).lines.each do |line|
      if line.downcase.match(/.*\[(#{keywords.join("|")})+.*\].*/)
        unless filename_printed
          puts "\n" + filename.underline
          filename_printed = true
        end
        puts line.chomp.send(MARKERS[$1.downcase])
      end
    end
  end
  puts ""
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