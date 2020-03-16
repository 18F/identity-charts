require 'dotenv/load'

require_relative './app.rb'
require_relative './lib/reporter.rb'

Reporter.start_reporting
run App.run!
