require 'aws-sdk-cloudwatch'
require 'faraday'
require 'json'

module ChartsReporter
  class AuthenticationsReporter
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

    private

    def reports
      [
        { name: :authentications_today_by_hour, data: hourly_authentications_report.to_json },
        { name: :authentications_this_week_by_hour, data: weekly_authentications_report.to_json },
        { name: :authentications_today, data: total_authentications_today.to_json }
      ]
    end

    def total_authentications_today
      filtered_hourly_datapoints.inject(0) { |sum, n| sum + n.sum }.to_i
    end

    def hourly_authentications_report
      report = filtered_hourly_datapoints.map do |datapoint|
        {
          label: datapoint.timestamp.getlocal.strftime('%H:%M'),
          value: datapoint.sum,
        }
      end
      time = start_of_day
      24.times do |i|
        report += [{ label: time.strftime('%H:%M'), value: 0 }] unless report[i]
        time += 3600
      end
      report
    end

    def filtered_hourly_datapoints
      cloudwatch_datapoints.filter do |datapoint|
        datapoint.timestamp.getlocal.to_date == Time.now.to_date
      end.sort_by(&:timestamp)
    end

    def weekly_authentications_report
      report = cloudwatch_datapoints.sort_by(&:timestamp).map do |datapoint|
        {
          label: datapoint.timestamp.getlocal.to_s,
          value: datapoint.sum
        }
      end
      report.delete(report.last)
      report
    end

    def weekly_datapoints_grouped_by_day
      grouped_datapoints = {}
      cloudwatch_datapoints.each do |datapoint|
        key = datapoint.timestamp.getlocal.to_date.to_s
        grouped_datapoints[key] ||= 0
        grouped_datapoints[key] += datapoint.sum.to_i
      end
      grouped_datapoints
    end

    def cloudwatch_datapoints
      @cloudwatch_datapoints ||= cloudwatch_client.get_metric_statistics(
        namespace: "Authentication",
        metric_name: "user-marked-authenticated",
        start_time: start_of_week,
        end_time: Time.now,
        period: 3600,
        statistics: ["Sum"],
      ).datapoints
    end

    def cloudwatch_client
      @cloudwatch_client ||= Aws::CloudWatch::Client.new
    end

    def start_of_week
      offset_in_seconds = 7 * 24 * 3600
      start = Time.now - offset_in_seconds
      Time.new(
        start.year,
        start.month,
        start.day,
        start.hour,
      )
    end

    def start_of_day
      Time.new(
        Time.now.year,
        Time.now.month,
        Time.now.day,
      )
    end
  end
end
