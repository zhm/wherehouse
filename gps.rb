require 'serialport'
require 'nmea_plus'

class GPS
  PORT = '/dev/serial0'

  attr_accessor :port
  attr_accessor :thread
  attr_accessor :raw
  attr_accessor :message
  attr_accessor :latitude
  attr_accessor :longitude
  attr_accessor :altitude
  attr_accessor :hdop
  attr_accessor :quality
  attr_accessor :satellites
  attr_accessor :speed

  def initialize(port: PORT)
    @port = SerialPort.new(port, baud: 9600)
    @port.read_timeout = 5

    @decoder = NMEAPlus::Decoder.new
  end

  def run!
    @thread = Thread.new do
      while true
        lines = @port.readlines("\r\n")

        if lines.length > 0
          lines.each do |line|
            message = @decoder.parse(line) rescue nil

            if message
              @raw = line
              @message = message

              @latitude = message.latitude if message.respond_to?(:latitude)
              @longitude = message.longitude if message.respond_to?(:longitude)
              @altitude = message.altitude if message.respond_to?(:altitude)
              @hdop = message.horizontal_dilution if message.respond_to?(:horizontal_dilution)
              @speed = message.speed_over_ground_knots if message.respond_to?(:speed_over_ground_knots)
              @satellites = message.satellites if message.respond_to?(:satellites)
            end
          end
        end
        
        sleep 1
      end
    end
  end
end