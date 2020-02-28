require 'aws-sdk-s3'

require_relative './base_report_builder'

module Reporter
  class DocAuthDropoffReportBuilder < BaseReportBuilder
    def reports
      [
        { name: :weekly_doc_auth_dropoff_rates, data: weekly_doc_auth_dropoff_rates },
      ]
    end

    def weekly_doc_auth_dropoff_rates
      parsed_s3_report_rows.map do |row|
        name = row[0]
        next if name == 'step' # skip the header
        percentage = row[2].gsub('%', '').to_i
        { label: name, value: percentage }
      end.compact
    end

    def parsed_s3_report_rows
      most_recent_report_data = raw_s3_report_data.split(/^.*date user starts doc auth.*$/).last
      trimmed_report_data = most_recent_report_data.gsub(/^\s+\n/, '')
      trimmed_report_data.split("\n").map do |raw_row|
        raw_row.gsub(/^\s*/, '').gsub(/\s*$/, '').split(/\s+/)
      end
    end

    def raw_s3_report_data
      @raw_s3_report_data ||= s3_client.get_object(
        # TODO: Make this configurable as an environment variable
        bucket: ENV['LOGIN_REPORTS_S3_BUCKET'],
        key: 'prod/doc-auth-drop-offs-report/latest.doc-auth-drop-offs-report.json',
      ).body.read
    end

    def s3_client
      @s3_client ||= Aws::S3::Client.new
    end
  end
end
