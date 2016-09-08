require 'ruby-processing'
class FirstSketch < Processing::App

  def setup
    background(0, 0, 0)
  end

  def draw
    if @size.nil? || @size == 100
      @size = 1
      @color_index = 0
    else
      @size = @size + 1
      @color_index = @color_index + 2
    end

    fill(@color_index, 0, 0)
    rect(10, 10, @size, @size)
    rect(20, 20, @size, @size)
  end
end

FirstSketch.new(:width => 200, :height => 200,
  :title => "FirstSketch", :full_screen => false)