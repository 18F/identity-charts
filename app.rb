require 'sinatra/activerecord'
require 'sinatra/base'
require 'sinatra/reloader'

require_relative './lib/models/report'





class App < Sinatra::Base
  CHARTS = %i[authentications alb_errors doc_auth].freeze

  configure :development do
    register Sinatra::Reloader
    ActiveRecord::Base.logger&.level = :info
  end

  configure :test do
    ActiveRecord::Base.logger&.level = :warn
  end

  configure :production do
    ActiveRecord::Base.logger&.level = :info
  end

  get '/' do
    chart_index = Time.now.to_i / 60 % CHARTS.length
    chart = CHARTS[chart_index]
    render_chart(chart)
  end

  get '/chart/:chart_name' do
    chart = params[:chart_name]
    status 404 and return 'Not Found' unless CHARTS.include?(chart.to_sym)
    render_chart(chart)
  end

  REPORT_NAMES = %i[
    alb_4xx_errors alb_5xx_errors authentications_this_week_by_hour authentications_today_by_hour
    authentications_today weekly_doc_auth_dropoff_rates
  ].freeze

  def render_chart(chart)
    ERB.new(File.read("templates/#{chart}.html.erb")).result(binding)
  end

  def reports_json
    reports = {}
    REPORT_NAMES.each do |report_name|
      report = Report.order(:created_at).where(name: report_name).first
      reports[report_name] = report.data
    end
    reports.to_json
  end

  def host_name
    ENV['HOST_NAME']
  end

end



