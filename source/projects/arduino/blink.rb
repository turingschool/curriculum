require 'dino'

board = Dino::Board.new(Dino::TxRx.new)
lower_led = Dino::Components::Led.new(pin: 11, board: board)
upper_led = Dino::Components::Led.new(pin: 10, board: board)

def blink(led)
  led.send(:on)
  sleep 0.1
  led.send(:off)
  sleep 0.1
end

def celebrate()
  led.send(:on)
  sleep 0.1
  led.send(:off)
  sleep 0.1
end

def celebrate(leds)
  10.times do
    leds.each do |led|
      led.send(:on)
    end

    sleep 0.05

    leds.each do |led|
      led.send(:off)
    end

    sleep 0.05
  end
end

secret = rand(101)
puts "Guess a number from 0 to 100:"
guess = gets.chomp.to_i
until guess == secret
  difference = secret-guess
  if difference < 0
    led = upper_led
  else
    led = lower_led
  end

  if difference.abs > 15
    3.times{ blink(led) }
  elsif difference.abs >= 5
    2.times{ blink(led) }
  else
    blink(led)
  end
  puts "Guess a number from 0 to 100:"
  guess = gets.chomp.to_i
end
celebrate([lower_led, upper_led])
