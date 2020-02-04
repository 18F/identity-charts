$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'login-charts-reporter'

while true
  puts "[#{Time.now}] Uploading reports..."
  ChartsReporter::AuthenticationsReporter.new.upload_reports
  ChartsReporter::AlbErrorsReporter.new.upload_reports
  puts "[#{Time.now}] Upload complete."
  sleep 600
end
