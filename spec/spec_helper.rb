require 'database_cleaner/active_record'
require 'pry-byebug'
require 'timecop'
require 'webmock/rspec'

require 'dotenv'

require_relative '../app'
require_relative '../lib/reporter'

Dotenv.load('.env.test')

## Require all rb files in spec/support
Dir[File.join(__dir__, 'support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  ## Default RSpec configuration as of RSpec 3.9
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  ## Allow use of describe globally
  config.expose_dsl_globally = true

  ## Setup DatabaseCleaner
  DatabaseCleaner.strategy = :transaction
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

## Disallow external HTTP requests
WebMock.disallow_net_connect!

## Disallow invocation of Timecop.freeze without a block
Timecop.safe_mode = true
