require 'togglv8'
require 'holidays'

module Xoggl
  class Client
    def initialize(toggl = TogglV8::API.new)
      @toggl = toggl
      @zone_offset = Time.now.utc_offset / 3600
    end

    def log_vacation(start_isodate, end_isodate)
      date = DateTime.iso8601(start_isodate)
      end_date = DateTime.iso8601(end_isodate)

      raise ArgumentError.new('End date must be greater than or equal to start date') if end_date < date

      while date <= end_date do
        if log_on?(date)
          create_vacation_entry(date_time_from(date, 9))
          create_vacation_entry(date_time_from(date, 14))
        end

        date = date.next_day
      end
    end

    private

    def log_on?(date)
      !date.saturday? and !date.sunday? and Holidays.on(date, :it, :observed).empty?
    end

    def date_time_from(date, hours)
      DateTime.new(date.year, date.month, date.day, hours - @zone_offset)
    end

    def create_vacation_entry(start_time)
      @toggl.create_time_entry({
        'description' => 'Ferie',
        'tags' => ['Ferie'],
        'pid' => vacation_project_id,
        'duration' => 14400,
        'start' => @toggl.iso8601(start_time)
      })
    end

    def workspace_id
      @workspace_id ||= @toggl.my_workspaces.first['id']
    end

    def vacation_project_id
      @vacation_project_id ||= @toggl.my_projects.select { |project| project['name'] = 'Assenza' }.first['id']
    end
  end
end
