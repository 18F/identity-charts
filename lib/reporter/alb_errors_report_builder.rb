require 'aws-sdk-cloudwatch'

require_relative './base_report_builder'

module Reporter
  class AlbErrorsReportBuilder < BaseReportBuilder
    def reports
      [
        { name: :alb_4xx_errors, data: alb_4xx_errors },
        { name: :alb_5xx_errors, data: alb_5xx_errors },
      ]
    end

    def alb_4xx_errors
      data = empty_5_minute_period_hash
      alb_4xx_datapoints.each do |datum|
        data[datum.timestamp.in_time_zone(TIME_ZONE).strftime('%H:%M')] = datum.sum
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
        data[datum.timestamp.in_time_zone(TIME_ZONE).strftime('%H:%M')] = datum.sum
      end
      data.keys.map do |label|
        {
          label: label,
          value: data[label],
        }
      end
    end

    # rubocop:disable Metrics/MethodLength
    def alb_4xx_datapoints
      @alb_4xx_datapoints ||= cloudwatch_client.get_metric_statistics(
        namespace: 'AWS/ApplicationELB',
        metric_name: 'HTTPCode_Target_4XX_Count',
        dimensions: [
          {
            name: 'LoadBalancer',
            value: ENV['LOGIN_ALB_LOAD_BALANCER_NAME'],
          },
        ],
        start_time: twenty_four_hours_ago.dup.to_time,
        end_time: TIME_ZONE.now.to_time,
        period: 300,
        statistics: ['Sum'],
      ).datapoints.sort_by(&:timestamp)
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def alb_5xx_datapoints
      @alb_5xx_datapoints ||= cloudwatch_client.get_metric_statistics(
        namespace: 'AWS/ApplicationELB',
        metric_name: 'HTTPCode_Target_5XX_Count',
        dimensions: [
          {
            name: 'LoadBalancer',
            value: ENV['LOGIN_ALB_LOAD_BALANCER_NAME'],
          },
        ],
        start_time: twenty_four_hours_ago.dup,
        end_time: TIME_ZONE.now,
        period: 300,
        statistics: ['Sum'],
      ).datapoints.sort_by(&:timestamp)
    end
    # rubocop:enable Metrics/MethodLength

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
        time = (TIME_ZONE.now - 24.hours)
        # We need to round to 5 minute increments since epoch
        # to get the right start date for the cloudwatch metrics
        TIME_ZONE.at(time.to_i - (time.to_i % 300))
      end
    end
  end
end
