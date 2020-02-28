describe Reporter::BaseReportBuilder do
  describe '#save_reports' do
    context 'when #reports is overriden' do
      let(:reports) do
        [
          { name: 'report-1', data: { 'hello' => 'world' } },
          { name: 'report-2', data: %w[this is an array] },
        ]
      end

      before do
        allow(subject).to receive(:reports).and_return(reports)
      end

      it 'creates the reports in the database if they do not exist' do
        subject.save_reports

        report1 = Report.find_by(name: 'report-1')
        report2 = Report.find_by(name: 'report-2')

        expect(Report.count).to eq(2)
        expect(report1).to_not be_nil
        expect(report1.data).to eq('hello' => 'world')
        expect(report2).to_not be_nil
        expect(report2.data).to eq(%w[this is an array])
      end

      it 'updates the reports in the database if they do exist' do
        old_report_date = Time.now - 3600
        Report.create(
          name: 'report-1', data: { 'old' => 'data' },
          created_at: old_report_date, updated_at: old_report_date
        )
        Report.create(
          name: 'report-2', data: %w[old data],
          created_at: old_report_date, updated_at: old_report_date
        )
        Report.create(
          name: 'report-3', data: 'should not change',
          created_at: old_report_date, updated_at: old_report_date
        )

        subject.save_reports

        report1 = Report.find_by(name: 'report-1')
        report2 = Report.find_by(name: 'report-2')
        report3 = Report.find_by(name: 'report-3')

        expect(Report.count).to eq(3)

        expect(report1).to_not be_nil
        expect(report1.data).to eq('hello' => 'world')
        expect(report1.updated_at.to_i).to be_within(2).of(Time.now.to_i)

        expect(report2).to_not be_nil
        expect(report2.data).to eq(%w[this is an array])
        expect(report2.updated_at.to_i).to be_within(2).of(Time.now.to_i)

        expect(report3).to_not be_nil
        expect(report3.data).to eq('should not change')
        expect(report3.updated_at.to_i).to be_within(2).of(old_report_date.to_i)
      end
    end

    context 'when #reports is not overriden' do
      it 'renders an error' do
        expect { subject.save_reports }.to raise_error(
          NotImplementedError,
          'Reporter::BaseReportBuilder does not implement #reports',
        )
      end
    end
  end
end
