require 'openssl'
require 'faraday'

module IqTrainer
  class Api
    def initialize(api_key,api_secret)
      @api_key = api_key
      @api_secret = api_secret

      raise "Api key required" if @api_key.empty?
      raise "Api secret required" if @api_secret.empty?

      @connection = Faraday.new(url: "http://api.iqengines.com/") do |conn|
        conn.request :multipart
        conn.request :url_encoded
        conn.adapter :net_http
      end
    end

    def build_signature(fields)
      digest = OpenSSL::Digest::Digest.new('sha1')

      keys = fields.keys.sort
      rawstr='';

      keys.each do |key|
        field = fields[key]
        field = field.original_filename if field.is_a?(UploadIO)

        rawstr << key.to_s << field.to_s
      end
      puts @api_secret

      OpenSSL::HMAC.hexdigest(digest,@api_secret,rawstr)
    end

    def upload_image(image_path,name) 
      image_io = IqTrainer::UploadIO.new(image_path, 'image/jpeg')
 
      data = {
        images: image_io,
        name: name,
        api_key: @api_key,
        time_stamp: Time.now.strftime("%Y%m%d%H%M%S")
      }

      data["api_sig"] = build_signature(data)

      @connection.post '/v1.2/object/', data
    end
  end
end