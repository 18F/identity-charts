# rubocop:disable Style/FileName
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'charts_reporter/version'

Gem::Specification.new do |s|
  s.name = 'aamva'
  s.version = ChartsReporter::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = [
    'Jonathan Hooper <jonathan.hooper@gsa.gov>',
  ]
  s.summary = 'Reporter for the login charts server.'
  s.description = 'Reporter for the login charts server. This collects reports and uploads them to the charts server.'
  s.date = Time.now.utc.strftime('%Y-%m-%d')
  s.files = Dir.glob('app/**/*') + Dir.glob('lib/**/*') + [
    'LICENSE.md',
    'README.md',
    'Gemfile',
    'login-charts-reporter.gemspec',
  ]
  s.license = 'LICENSE'
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.rdoc_options = ['--charset=UTF-8']

  s.add_dependency('aws-sdk-cloudwatch')
  s.add_dependency('dotenv')
  s.add_dependency('faraday')

  s.add_development_dependency('pry-byebug')
end
