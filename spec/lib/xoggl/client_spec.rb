describe Xoggl::Client do
  let(:toggl) { TogglV8::API.new('9b07c50c5126baf8c2d263b3dbfde3ee') }
  let(:client) { Xoggl::Client.new(toggl) }

  after :each do
    entries.each do |entry|
      toggl.delete_time_entry(entry['id'])
    end
  end

  it 'creates a vacation entry' do
    start_date = '2016-01-04'
    end_date =  '2016-01-04'

    client.log_vacation(start_date, end_date)

    expect(entries.count).to eq(2)
    expect(entries.first).to include("description" => "Ferie")
  end

  it 'does not create a vacation entry on weekends' do
    start_date = '2016-01-09'
    end_date =  '2016-01-09'

    client.log_vacation(start_date, end_date)

    expect(entries).to be_empty
  end

  it 'does not create a vacation entry on hoildays' do
    start_date = '2016-01-06'
    end_date =  '2016-01-06'

    client.log_vacation(start_date, end_date)

    expect(entries).to be_empty
  end

  def entries
    toggl.get_time_entries(start_date: '2016-01-01', end_date: '2016-01-09')
  end
end
