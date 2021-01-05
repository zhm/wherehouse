require 'bundler'

Bundler.setup

require 'active_support/all'
require_relative './sensor'
require_relative './camera'

TOKEN = ENV['TOKEN']
ENDPOINT = ENV['ENDPOINT']

camera = Camera.new(token: TOKEN, endpoint: ENDPOINT)
camera.run!

sensors = [
  Sensor.new(id: '186f407c-a41b-4528-94bc-1254a9199a56', name: 'Office', camera: camera, token: TOKEN, endpoint: ENDPOINT),
  Sensor.new(id: '0eab4c37-0f90-4abc-8ee6-526458bb35df', name: 'Living Room', camera: camera, token: TOKEN, endpoint: ENDPOINT),
  Sensor.new(id: '5bc8dce1-17ed-4188-be10-47497a6681fa', name: 'Bedroom', camera: camera, token: TOKEN, endpoint: ENDPOINT),
  Sensor.new(id: '2825ab7b-b3f1-4966-bab8-c6c31a39ec45', name: 'Garage', camera: camera, token: TOKEN, endpoint: ENDPOINT),
  Sensor.new(id: 'acc70bd7-e6ed-4269-bbf1-c7c1fe07394b', name: 'Kitchen', camera: camera, token: TOKEN, endpoint: ENDPOINT),
  Sensor.new(id: 'f2f9484e-9403-4e7d-b667-cbc0485ad131', name: 'Back Porch', camera: camera, token: TOKEN, endpoint: ENDPOINT)
]

sensors.map do |sensor|
  Thread.new do
    sensor.run!
  end
end.map(&:join)