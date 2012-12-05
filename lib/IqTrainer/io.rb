require 'securerandom'

module IqTrainer
  class UploadIO < Faraday::UploadIO
    def initialize(filename, mime)
      super(filename, mime)
      @original_filename = SecureRandom.hex  
    end
  end
end