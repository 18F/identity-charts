require 'active_support'
require 'active_support/core_ext'
require 'logger'

require_relative './reporter/alb_errors_report_builder'
require_relative './reporter/authentications_report_builder'
require_relative './reporter/doc_auth_dropoff_report_builder'

TIME_ZONE = ActiveSupport::TimeZone.new('Eastern Time (US & Canada)')

module Reporter
  def self.start_reporting
    Thread.new do
      Time.zone = TIME_ZONE

      loop do
        run_reports
      rescue StandardError => error
        logger.error("Error running reports: #{error}")
      ensure
        sleep 450
      end
    end
  end

  def self.run_reports
    logger.info('Running ALB Errors report')
    AlbErrorsReportBuilder.new.save_reports
    logger.info('Running Authentications report')
    AuthenticationsReportBuilder.new.save_reports
    logger.info('Running doc auth dropoff report')
    DocAuthDropoffReportBuilder.new.save_reports
    logger.info('Finished running reports')
  end

  def self.logger
    @logger ||= Logger.new(STDOUT, level: :info)
  end
end
