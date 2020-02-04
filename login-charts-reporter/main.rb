$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'login-charts-reporter'

ChartsReporter::AuthenticationsReporter.new.upload_reports
ChartsReporter::AlbErrorsReporter.new.upload_reports
