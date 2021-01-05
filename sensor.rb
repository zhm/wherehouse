require 'httparty'

require_relative './gps'
require_relative './camera'
require_relative './temperature'

class Sensor
  attr_accessor :token
  attr_accessor :endpoint
  attr_accessor :id
  attr_accessor :name
  attr_accessor :gps
  attr_accessor :temperature

  FORM = '6586964b-6a1d-427c-b84b-916eaf957b96'

  NAME = '52b1'

  TEMPERATURE = '22b6'

  HUMIDITY = 'a173'

  SPEED = 'ee24'

  FIX_QUALITY = '125b'

  HDOP = 'ce8a'

  SATELLITES = '4601'

  LATITUDE = '011f'

  LONGITUDE = '8a91'

  ALTITUDE = '4568'

  MESSAGE_TYPE = '12b3'

  MESSAGE = '5a5a'

  PHOTO = '7dec'

  def initialize(token:, endpoint:, id:, name:, camera:)
    @token = token
    @endpoint = endpoint
    @id = id
    @name = name
    @gps = GPS.new
    @temperature = Temperature.new
    @camera = camera
  end

  def run!
    @gps.run!
    @temperature.run!

    while true
      begin
        update_record if temperature.has_value?
      rescue => e
        puts e.message
      end

      sleep 3
    end
  end

  def update_record
    headers = { 'Content-Type' => 'application/json',
                'User-Agent' => 'Fulcrum Wherehouse',
                'X-ApiToken' => token }

    body = {
      record: {
        id: id,
        form_id: FORM,
        status: 'Normal',
        latitude: @gps.latitude,
        longitude: @gps.longitude,
        altitude: @gps.altitude,
        form_values: {
          NAME => name,
          TEMPERATURE => temperature.temperature_with_randomness.round(2).to_s,
          HUMIDITY => temperature.humidity_with_randomness.round(2).to_s,
          SPEED => @gps.speed.to_s,
          FIX_QUALITY => @gps.quality.to_s,
          HDOP => @gps.hdop.to_s,
          SATELLITES => @gps.satellites.to_s,
          LATITUDE => @gps.latitude.try(:round, 6).to_s,
          LONGITUDE => @gps.longitude.try(:round, 6).to_s,
          ALTITUDE => @gps.altitude.to_s,
          MESSAGE_TYPE => @gps.message.try(:data_type),
          MESSAGE => @gps.raw,
          PHOTO => @camera.id && [ { photo_id: @camera.id } ]
        }
      }
    }

    response = HTTParty.post(
      "#{ENDPOINT}/api/v2/records",
      body: body.to_json,
      headers: headers
    )

    if ![200, 201].include?(response.code)
      raise response.body.to_s
    end

    puts [
      name,
      "temperature: #{temperature.temperature_with_randomness.round(2).to_s}",
      "humidity: #{temperature.temperature_with_randomness.round(2).to_s}",
      "latitude: #{temperature.temperature_with_randomness.round(2).to_s}",
      "longitude: #{temperature.temperature_with_randomness.round(2).to_s}"
    ].join(', ')

    JSON.parse(response.body.to_s)
  end
end
