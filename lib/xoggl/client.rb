require 'togglv8'
require 'holidays'

module Xoggl
  class Client
    def initialize(toggl = TogglV8::API.new)
      @toggl = toggl
      @zone_offset = Time.now.utc_offset / 3600
    end

    def log_work(start_isodate, end_isodate, project_name)
      do_between(start_isodate, end_isodate) do |date|
        log_work_day(date, project_name)
      end
    end

    def log_vacation(start_isodate, end_isodate)
      do_between(start_isodate, end_isodate) do |date|
        log_vacation_day(date) unless to_skip?(date)
      end
    end

    private

    def do_between(start_isodate, end_isodate)
      date = DateTime.iso8601(start_isodate)
      end_date = DateTime.iso8601(end_isodate)

      raise ArgumentError.new('End date must be greater than or equal to start date') if end_date < date

      while date <= end_date
        yield(date)

        date = date.next_day
      end
    end

    def to_skip?(date)
      date.saturday? || date.sunday? || Holidays.on(date, :it, :observed).any?
    end

    def log_work_day(date, project_name)
      create_work_entry(date_time_from(date, 9), project_name)
      create_work_entry(date_time_from(date, 14), project_name)
    end

    def log_vacation_day(date)
      create_vacation_entry(date_time_from(date, 9))
      create_vacation_entry(date_time_from(date, 14))
    end

    def create_work_entry(start_time, project_name)
      @toggl.create_time_entry(
        'billable' => true,
        'description' => project_name,
        'tags' => [],
        'pid' => project_id_from(project_name),
        'duration' => 14_400,
        'start' => @toggl.iso8601(start_time)
      )
    end

    def create_vacation_entry(start_time)
      @toggl.create_time_entry(
        'billable' => false,
        'description' => 'Ferie',
        'tags' => ['Ferie'],
        'pid' => vacation_project_id,
        'duration' => 14_400,
        'start' => @toggl.iso8601(start_time)
      )
    end

    def date_time_from(date, hours)
      DateTime.new(date.year, date.month, date.day, hours - @zone_offset)
    end

    def workspace_id
      @workspace_id ||= @toggl.my_workspaces.first['id']
    end

    def vacation_project_id
      @vacation_project_id ||= @toggl.my_projects.select do |project|
        project['name'] == 'Assenza'
      end.first['id']
    end

    def project_id_from(project_name)
      @toggl.my_projects.select do |project|
        project['name'] == project_name
      end.first['id']
    end
  end
end
