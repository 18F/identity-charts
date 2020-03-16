require 'aws-sdk-cloudwatch'

require_relative '../models/report'

module Reporter
  class BaseReportBuilder
    def save_reports
      reports.each do |report|
        Report.find_or_create_by!(
          name: report[:name],
        ).update!(
          data: report[:data],
        )
      end
    end

    def reports
      raise NotImplementedError, "#{self.class.name} does not implement ##{__method__}"
    end
  end
end
