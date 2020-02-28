describe Reporter::DocAuthDropoffReportBuilder do
  describe '#reports' do
    let(:s3_client) { instance_double(Aws::S3::Client) }
    let(:raw_drop_off_data) { File.read('spec/support/fixtures/doc-auth-drop-offs-report.json') }
    let(:s3_client_response) do
      response = double
      allow(response).to receive(:body).and_return(StringIO.new(raw_drop_off_data))
      response
    end

    before do
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
      allow(s3_client).to receive(:get_object).with(
        bucket: ENV['LOGIN_REPORTS_S3_BUCKET'],
        key: 'prod/doc-auth-drop-offs-report/latest.doc-auth-drop-offs-report.json',
      ).and_return(s3_client_response)
    end

    it 'returns a well formed dropoff report' do
      report = subject.reports.first
      data = report[:data]

      expect(report[:name]).to eq(:weekly_doc_auth_dropoff_rates)
      expect(data).to eq([
                           { label: 'welcome', value: 100 },
                           { label: 'upload_option', value: 91 },
                           { label: 'front_image', value: 77 },
                           { label: 'back_image', value: 71 },
                           { label: 'ssn', value: 52 },
                           { label: 'verify_info', value: 52 },
                           { label: 'doc_success', value: 44 },
                           { label: 'phone', value: 44 },
                           { label: 'encrypt', value: 42 },
                           { label: 'personal_key', value: 41 },
                           { label: 'verified', value: 41 },
                         ])
    end
  end
end
