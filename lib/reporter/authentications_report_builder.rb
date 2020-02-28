require 'aws-sdk-cloudwatch'

require_relative './base_report_builder'

module Reporter
  class AuthenticationsReportBuilder < BaseReportBuilder
    def reports
      [
        { name: :authentications_this_week_by_hour, data: authentications_this_week_by_hour },
        { name: :authentications_today_by_hour, data: authentications_today_by_hour },
        { name: :authentications_today, data: total_authentications_today },
      ]
    end

    private

    def authentications_this_week_by_hour
      data = authentications_this_week_by_hour_hash
      data.keys.map do |label|
        {
          label: label,
          value: data[label],
        }
      end
    end

    def authentications_this_week_by_hour_hash
      data = empty_1_hour_period_hash_for_week
      cloudwatch_datapoints.each do |datum|
        key = datum.timestamp.in_time_zone(Time.zone).strftime('%Y-%m-%d %H:%M')
        next if data[key].nil?
        data[key] = datum.sum
      end
      data
    end

    def authentications_today_by_hour
      data = authentications_today_by_hour_hash
      data.keys.map do |label|
        {
          label: label,
          value: data[label],
        }
      end
    end

    def authentications_today_by_hour_hash
      data = empty_1_hour_period_hash_for_today
      cloudwatch_datapoints_for_today.each do |datum|
        key = datum.timestamp.in_time_zone(Time.zone).strftime('%H:%M')
        next if data[key].nil?
        data[key] = datum.sum
      end
      data
    end

    def total_authentications_today
      cloudwatch_datapoints_for_today.inject(0) { |sum, n| sum + n.sum }.to_i
    end

    def cloudwatch_datapoints_for_today
      cloudwatch_datapoints.select do |datum|
        datum.timestamp >= start_of_day
      end
    end

    def cloudwatch_datapoints
      @cloudwatch_datapoints ||= cloudwatch_client.get_metric_statistics(
        namespace: 'Authentication',
        metric_name: 'user-marked-authenticated',
        start_time: one_week_ago,
        end_time: Time.zone.now,
        period: 3600,
        statistics: ['Sum'],
      ).datapoints
    end

    def cloudwatch_client
      @cloudwatch_client ||= Aws::CloudWatch::Client.new
    end

    def empty_1_hour_period_hash_for_week
      result = {}
      current_time = one_week_ago
      (24 * 7 - 1).times do
        result[current_time.strftime('%Y-%m-%d %H:%M')] = 0
        current_time += 3600
      end
      result
    end

    def empty_1_hour_period_hash_for_today
      result = {}
      current_time = start_of_day
      24.times do
        result[current_time.strftime('%H:%M')] = 0
        current_time += 3600
      end
      result
    end

    def start_of_day
      @start_of_day ||= Time.zone.today.beginning_of_day
    end

    def one_week_ago
      @one_week_ago ||= 1.week.ago.change(min: 0)
    end
  end
end
