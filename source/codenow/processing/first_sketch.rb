require 'ruby-processing'
class FirstSketch < Processing::App

  def setup
    background(0, 0, 0)
  end

  def draw
    if @size.nil? || @size == 150
      @size = 1
    else
      @size = @size + 1
    end

    fill(255, 255, 255)
    rect(10, 10, @size, @size)
  end
end

FirstSketch.new(:width => 200, :height => 200,
  :title => "FirstSketch", :full_screen => false)