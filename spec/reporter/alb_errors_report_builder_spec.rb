describe Reporter::AlbErrorsReportBuilder do
  # These reports are a pisces, just like me :)
  let(:current_time) { Time.parse('1993-03-18T12:00:00') }
  let(:report_start_time) { Time.parse('1993-03-17T12:00:00') }
  let(:report_end_time) { Time.parse('1993-03-18T11:55:00') }

  around do |example|
    Timecop.freeze current_time do
      example.run
    end
  end

  let(:cloudwatch_client) { instance_double(Aws::CloudWatch::Client) }
  let(:get_metric_statistics_response_4xx) do
    GetMetricStatisticsResponse.new(
      [
        GetMetricStatisticsDatapoint.new(Time.parse('1993-03-17T20:00:00'), 10),
        GetMetricStatisticsDatapoint.new(Time.parse('1993-03-17T13:00:00'), 20),
        GetMetricStatisticsDatapoint.new(Time.parse('1993-03-18T09:00:00'), 30),
      ],
    )
  end
  let(:get_metric_statistics_response_5xx) do
    GetMetricStatisticsResponse.new(
      [
        GetMetricStatisticsDatapoint.new(Time.parse('1993-03-17T20:00:00'), 5),
        GetMetricStatisticsDatapoint.new(Time.parse('1993-03-17T14:00:00'), 20),
        GetMetricStatisticsDatapoint.new(Time.parse('1993-03-18T10:00:00'), 30),
      ],
    )
  end

  before do
    allow(Aws::CloudWatch::Client).to receive(:new).and_return(cloudwatch_client)
    mock_get_metric_statistic(
      metric_name: 'HTTPCode_Target_4XX_Count',
      response: get_metric_statistics_response_4xx,
    )
    mock_get_metric_statistic(
      metric_name: 'HTTPCode_Target_5XX_Count',
      response: get_metric_statistics_response_5xx,
    )
  end

  describe '#reports' do
    it 'returns a well formed 4xx report' do
      report = subject.reports[0]
      data = report[:data]

      expect(report[:name]).to eq(:alb_4xx_errors)
      expect(data.length).to eq(288)
      expect(data.first[:label]).to eq(report_start_time.in_time_zone(TIME_ZONE).strftime('%H:%M'))
      expect(data.last[:label]).to eq(report_end_time.in_time_zone(TIME_ZONE).strftime('%H:%M'))

      stat1 = get_report_datapoint_for_timestamp(
        timestamp: Time.parse('1993-03-17T20:00:00'), data: data,
      )
      stat2 = get_report_datapoint_for_timestamp(
        timestamp: Time.parse('1993-03-17T13:00:00'), data: data,
      )
      stat3 = get_report_datapoint_for_timestamp(
        timestamp: Time.parse('1993-03-18T09:00:00'), data: data,
      )

      expect(stat1).to_not eq(nil)
      expect(stat1[:value]).to eq(10)
      expect(stat2).to_not eq(nil)
      expect(stat2[:value]).to eq(20)
      expect(stat3).to_not eq(nil)
      expect(stat3[:value]).to eq(30)
    end

    it 'returns a well formed 5xx report' do
      report = subject.reports[1]
      data = report[:data]

      expect(report[:name]).to eq(:alb_5xx_errors)
      expect(data.length).to eq(288)
      expect(data.first[:label]).to eq(report_start_time.in_time_zone(TIME_ZONE).strftime('%H:%M'))
      expect(data.last[:label]).to eq(report_end_time.in_time_zone(TIME_ZONE).strftime('%H:%M'))

      stat1 = get_report_datapoint_for_timestamp(
        timestamp: Time.parse('1993-03-17T20:00:00'), data: data,
      )
      stat2 = get_report_datapoint_for_timestamp(
        timestamp: Time.parse('1993-03-17T14:00:00'), data: data,
      )
      stat3 = get_report_datapoint_for_timestamp(
        timestamp: Time.parse('1993-03-18T10:00:00'), data: data,
      )

      expect(stat1).to_not eq(nil)
      expect(stat1[:value]).to eq(5)
      expect(stat2).to_not eq(nil)
      expect(stat2[:value]).to eq(20)
      expect(stat3).to_not eq(nil)
      expect(stat3[:value]).to eq(30)
    end
  end

  def mock_get_metric_statistic(metric_name:, response:)
    allow(cloudwatch_client).to receive(:get_metric_statistics).with(
      namespace: 'AWS/ApplicationELB',
      metric_name: metric_name,
      dimensions: [
        {
          name: 'LoadBalancer',
          value: ENV['LOGIN_ALB_LOAD_BALANCER_NAME'],
        },
      ],
      start_time: report_start_time,
      end_time: current_time,
      period: 300,
      statistics: ['Sum'],
    ).and_return(response)
  end

  def get_report_datapoint_for_timestamp(timestamp:, data:)
    data.find { |d| d[:label] == timestamp.in_time_zone(TIME_ZONE).strftime('%H:%M') }
  end
end
