require 'aws-sdk-cloudwatch'
require 'faraday'
require 'json'

module ChartsReporter
  class AlbErrorsReporter
    def upload_reports
      reports.each do |report|
        resp = Faraday.post(
          ENV['REPORTS_URL'],
          { report: report }.to_json,
          'Content-Type' => 'application/json',
          'X-API-TOKEN' => ENV['API_TOKEN']
        )
        next if resp.status == 201
        warn resp.body
        raise "Unexpected response #{resp.status}"
      end
    end

    def reports
      [
        { name: :alb_4xx_errors, data: alb_4xx_errors.to_json },
        { name: :alb_5xx_errors, data: alb_5xx_errors.to_json },
        { name: :alb_errors_by_code, data: alb_errors_by_code.to_json },
      ]
    end

    def alb_4xx_errors
      data = empty_5_minute_period_hash
      alb_4xx_datapoints.each do |datum|
        data[datum.timestamp.getlocal.strftime('%H:%M')] = datum.sum
      end
      data.keys.map do |label|
        {
          label: label,
          value: data[label],
        }
      end
    end

    def alb_5xx_errors
      data = empty_5_minute_period_hash
      alb_5xx_datapoints.each do |datum|
        data[datum.timestamp.getlocal.strftime('%H:%M')] = datum.sum
      end
      data.keys.map do |label|
        {
          label: label,
          value: data[label],
        }
      end
    end

    def alb_errors_by_code
      {
        '4XX' => alb_4xx_datapoints.inject(0) { |sum, n| sum + n.sum }.to_i,
        '5XX' => alb_5xx_datapoints.inject(0) { |sum, n| sum + n.sum }.to_i,
      }
    end

    def alb_4xx_datapoints
      @alb_4xx_datapoints ||= cloudwatch_client.get_metric_statistics(
        namespace: "AWS/ApplicationELB",
        metric_name: "HTTPCode_Target_4XX_Count",
        dimensions: [
          {
            name: "LoadBalancer",
            value: "app/login-idp-alb-prod/46125f90e3d396ab",
          }
        ],
        start_time: twenty_four_hours_ago.dup,
        end_time: Time.now,
        period: 300,
        statistics: ["Sum"],
      ).datapoints.sort_by(&:timestamp)
    end

    def alb_5xx_datapoints
      @alb_5xx_datapoints ||= cloudwatch_client.get_metric_statistics(
        namespace: "AWS/ApplicationELB",
        metric_name: "HTTPCode_Target_5XX_Count",
        dimensions: [
          {
            name: "LoadBalancer",
            value: "app/login-idp-alb-prod/46125f90e3d396ab",
          }
        ],
        start_time: twenty_four_hours_ago.dup,
        end_time: Time.now,
        period: 300,
        statistics: ["Sum"],
      ).datapoints.sort_by(&:timestamp)
    end

    def cloudwatch_client
      @cloudwatch_client ||= Aws::CloudWatch::Client.new
    end

    def empty_5_minute_period_hash
      result = {}
      current_time = twenty_four_hours_ago
      (24 * 3600 / 300).times do
        result[current_time.strftime('%H:%M')] = 0
        current_time += 300
      end
      result
    end

    def twenty_four_hours_ago
      @twenty_four_hours_ago ||= begin
        time = Time.now - 24 * 3600
        Time.at(time.to_i - (time.to_i % 300)).getlocal # Round down to 5 minute interval
      end
    end
  end
end
