require 'dht-sensor-ffi'

RANDOMNESS = 15

class Temperature
  attr_accessor :temperature
  attr_accessor :humidity
  attr_accessor :thread

  def initialize(pin: 4, sensor: 22)
    @pin = pin
    @sensor = sensor
  end

  def has_value?
    temperature.present?
  end

  def run!
    @thread = Thread.new do
      while true
        value = DhtSensor.read(@pin, @sensor)

        self.temperature = value.temp_f
        self.humidity = value.humidity

        sleep 1
      end
    end
  end

  def temperature_with_randomness
    return nil unless temperature

    [[15, temperature + rand(-RANDOMNESS..RANDOMNESS)].max, 110].min
  end

  def humidity_with_randomness
    return nil unless humidity

    [[20, humidity + rand(-RANDOMNESS..RANDOMNESS)].max, 100].min
  end
end