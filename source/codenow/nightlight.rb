require 'dino'

board = Dino::Board.new(Dino::TxRx.new)
lower_led = Dino::Components::Led.new(pin: 11, board: board)
upper_led = Dino::Components::Led.new(pin: 10, board: board)
sensor = Dino::Components::Sensor.new(pin: 'A0', board: board)

on_data = Proc.new do |data|
  if data.to_i < 100
    #puts "It's light!"
    upper_led.send(:off)
  else
    #puts "It's dark!"
    upper_led.send(:on)
  end
end

sensor.when_data_received(on_data)

sleep