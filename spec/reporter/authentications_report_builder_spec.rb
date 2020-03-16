describe Reporter::AuthenticationsReportBuilder do
  # These reports are a pisces, just like me :)
  let(:current_time) { Time.parse('1993-03-18T12:00:00-04:00') }
  let(:report_start_time) { Time.parse('1993-03-11T12:00:00-04:00') }
  let(:report_end_time) { Time.parse('1993-03-18T11:00:00-04:00') }

  around do |example|
    Timecop.freeze current_time do
      example.run
    end
  end

  let(:cloudwatch_client) { instance_double(Aws::CloudWatch::Client) }
  let(:get_metric_statistics_datapoints) do
    GetMetricStatisticsResponse.new(
      [
        GetMetricStatisticsDatapoint.new(Time.parse('1993-03-12T20:00:00-04:00'), 10),
        GetMetricStatisticsDatapoint.new(Time.parse('1993-03-14T13:00:00-04:00'), 20),
        GetMetricStatisticsDatapoint.new(Time.parse('1993-03-18T09:00:00-04:00'), 30),
        GetMetricStatisticsDatapoint.new(Time.parse('1993-03-18T10:00:00-04:00'), 40),
      ],
    )
  end

  before do
    allow(Aws::CloudWatch::Client).to receive(:new).and_return(cloudwatch_client)
    allow(cloudwatch_client).to receive(:get_metric_statistics).with(
      namespace: 'Authentication',
      metric_name: 'user-marked-authenticated',
      start_time: report_start_time,
      end_time: current_time,
      period: 3600,
      statistics: ['Sum'],
    ).and_return(get_metric_statistics_datapoints)
  end

  describe '#reports' do
    it 'returns a well formed report with authentications in the week' do
      report = subject.reports[0]
      data = report[:data]

      expect(report[:name]).to eq(:authentications_this_week_by_hour)
      expect(data.length).to eq(167)
      expect(data.first[:label]).to eq(
        report_start_time.in_time_zone(TIME_ZONE).strftime('%Y-%m-%d %H:%M'),
      )
      expect(data.last[:label]).to eq(
        (report_end_time - 3600).in_time_zone(TIME_ZONE).strftime('%Y-%m-%d %H:%M'),
      )

      stat1 = get_weely_report_datapoint_for_timestamp(
        timestamp: Time.parse('1993-03-12T20:00:00-04:00'), data: data,
      )
      stat2 = get_weely_report_datapoint_for_timestamp(
        timestamp: Time.parse('1993-03-14T13:00:00-04:00'), data: data,
      )
      stat3 = get_weely_report_datapoint_for_timestamp(
        timestamp: Time.parse('1993-03-18T09:00:00-04:00'), data: data,
      )

      expect(stat1).to_not eq(nil)
      expect(stat1[:value]).to eq(10)
      expect(stat2).to_not eq(nil)
      expect(stat2[:value]).to eq(20)
      expect(stat3).to_not eq(nil)
      expect(stat3[:value]).to eq(30)
    end

    it 'returns a well formed report with authentications today' do
      report = subject.reports[1]
      data = report[:data]

      expect(report[:name]).to eq(:authentications_today_by_hour)
      expect(data.length).to eq(24)
      expect(data.first[:label]).to eq('00:00')
      expect(data.last[:label]).to eq('23:00')

      stat1 = get_daily_report_datapoint_for_timestamp(
        timestamp: Time.parse('1993-03-18T09:00:00-04:00'), data: data,
      )
      stat2 = get_daily_report_datapoint_for_timestamp(
        timestamp: Time.parse('1993-03-18T10:00:00-04:00'), data: data,
      )

      expect(stat1).to_not eq(nil)
      expect(stat1[:value]).to eq(30)
      expect(stat2).to_not eq(nil)
      expect(stat2[:value]).to eq(40)
    end

    it 'returns a well formed report with total authentications today' do
      report = subject.reports[2]

      expect(report[:name]).to eq(:authentications_today)
      expect(report[:data]).to eq(70)
    end
  end

  def get_weely_report_datapoint_for_timestamp(timestamp:, data:)
    data.find { |d| d[:label] == timestamp.in_time_zone(TIME_ZONE).strftime('%Y-%m-%d %H:%M') }
  end

  def get_daily_report_datapoint_for_timestamp(timestamp:, data:)
    data.find { |d| d[:label] == timestamp.in_time_zone(TIME_ZONE).strftime('%H:%M') }
  end
end
