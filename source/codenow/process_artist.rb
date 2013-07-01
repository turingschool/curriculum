require 'ruby-processing'
class ProcessArtist < Processing::App

  def setup
    background(0, 0, 0)
  end

  def draw
    # Do Stuff
  end

  def key_pressed
    warn "A key was pressed! #{key.inspect}"
    if @queue.nil?
      @queue = ""
    end
    if key != "\n"
      @queue = @queue + key
    else
      warn "Time to run the command: #{@queue}"
      run_command(@queue)
      @queue = ""
    end
  end

  def run_command(command)
    puts "Running Command #{command}"
    if command.start_with?("b")
      puts "Changing Background"
      colors = command[1..-1].split(",")
      background(colors[0].to_i, colors[1].to_i, colors[2].to_i)
    end
  end
end

ProcessArtist.new(:width => 600, :height => 600,
  :title => "ProcessArtist", :full_screen => false)