TEST_API_TOKEN = '9b07c50c5126baf8c2d263b3dbfde3ee'

describe Xoggl::Client do
  before :all do
    @client = Xoggl::Client.new(TEST_API_TOKEN)
    @toggl = TogglV8::API.new(TEST_API_TOKEN)
    @workspace_id = @toggl.workspaces.first['id']

    @toggl.create_project('name' => 'Assenza', 'wid' => @workspace_id)
    @toggl.create_project('name' => 'A project', 'wid' => @workspace_id)
  end

  after :all do
    delete_projects
  end

  after :each do
    delete_entries
  end

  context 'vacation' do
    it 'creates the entry' do
      start_date = '2016-01-04'
      end_date = '2016-01-04'

      @client.log_vacation(start_date, end_date)

      expect(entries.count).to eq(2)
      expect(entries.first).to include('description' => 'Ferie')
    end

    it 'does not create the entry on weekends' do
      start_date = '2016-01-09'
      end_date = '2016-01-09'

      @client.log_vacation(start_date, end_date)

      expect(entries).to be_empty
    end

    it 'does not create the entry on holidays' do
      start_date = '2016-01-06'
      end_date = '2016-01-06'

      @client.log_vacation(start_date, end_date)

      expect(entries).to be_empty
    end
  end

  context 'work' do
    it 'does not create an entry with a start date greater than end date' do
      start_date = '2016-10-05'
      end_date = '2016-10-04'

      expect do
        @client.log_work(start_date, end_date, 'A project')
      end.to raise_error(ArgumentError)
    end

    it 'creates an entry' do
      start_date = '2016-01-04'
      end_date = '2016-01-04'

      @client.log_work(start_date, end_date, 'A project')

      expect(entries.count).to eq(2)
      expect(entries.first).to include('description' => 'A project')
    end
  end

  context 'sick leave' do
    it 'creates an entry' do
      start_date = '2016-01-04'
      end_date = '2016-01-04'

      @client.log_sick_leave(start_date, end_date)

      expect(entries.count).to eq(2)
      expect(entries.first).to include('description' => 'Malattia')
    end
  end

  private

  def delete_entries
    entries.each do |entry|
      @toggl.delete_time_entry(entry['id'])
    end
  end

  def entries
    @toggl.get_time_entries(start_date: '2016-01-01', end_date: '2016-01-09')
  end

  def delete_projects
    projects = @toggl.projects(@workspace_id)
    project_ids = projects.map { |p| p['id'] }
    return if project_ids.empty?

    @toggl.delete_projects(project_ids)
  end
end
