class Camera
  ASPECT_RATIO = 3280.0 / 2464.0

  WIDTH = 600

  HEIGHT = (WIDTH / ASPECT_RATIO).round.to_i

  attr_accessor :id
  attr_accessor :thread
  attr_accessor :endpoint
  attr_accessor :token

  def initialize(endpoint:, token:)
    @token = token
    @endpoint = endpoint
  end

  def run!
    @thread = Thread.new do
      capture!

      id = SecureRandom.uuid

      HTTParty.post(
        "#{endpoint}/api/v2/photos",
        headers: {
          'Accept': 'application/json',
          'X-ApiToken': token
        },
        body: {
          photo: {
            access_key: id,
            file: File.open('photo.jpg')
          }
        }
      )

      @id = id

      sleep 10
    end
  end

  def capture!
    `raspistill -w #{WIDTH} -h #{HEIGHT} -o photo.jpg`
  end
end