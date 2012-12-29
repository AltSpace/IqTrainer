#!/usr/bin/env ruby
require 'iq_trainer'
require 'micro-optparse'

options = Parser.new do |p|
  p.banner = "Iq trainer uploads all jpg in --dir to iqengines database"
  p.option :dir, 'directory with images', default: Dir.pwd
  p.option :key, 'api key', default: ""
  p.option :secret, 'api secret', default: ""
end.process!

files = []
Dir.foreach(options[:dir]) do |filename|
  file_path = File.join(options[:dir],filename)
  name = File.basename(file_path,".jpg")
  files << [file_path,name] if File.file?(file_path)
end

api = IqTrainer::Api.new(options[:key],options[:secret])


files.each do |file,name|
  puts "uploading image: #{name}"
  resp = api.upload_image(file,name)
  raise "API error: #{resp.body}" if resp.status!=201
  puts "done"
end

