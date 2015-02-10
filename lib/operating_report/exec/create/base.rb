# coding: utf-8

require "operating_report/tracker/api/toggl"

module OperatingReport
  module Exec
    module Create
      class Base
        def initialize(args)
          @t = args[:datetime]
          @tog = OperatingReport::Tracker::Api::Toggl.new(
            'token' => OperatingReport::config['tracker']['api']['token']
          )
        end

        def run()
          start_date = _get_start_date(@t)
          end_date = _get_end_date(@t)

          body, total_time = _get_entries(start_date, end_date)

          printf "日付: %s\n", _generate_title(start_date, end_date)
          printf "作業時間: %.2fh\n", total_time.quo(60 * 60)

          output_body(body, total_time)
        end

        def _get_entries(start_date, end_date)
          response = @tog.get_time_entries(start_date, end_date)
          body = {}
          total_time = 0
          response.each do |r|
            pid = r['pid'] || 0;
            desc = r['description'] || '【無記載】'
            body[pid] = {items:{}, duration:0} unless body[pid]
            body[pid][:items][desc] = {duration:0, tags:[]} unless body[pid][:items][desc]
            body[pid][:items][desc][:tags].concat(r['tags']) if r['tags']
            body[pid][:items][desc][:duration] += r['duration'].to_i
            body[pid][:duration] += r['duration'].to_i
            total_time += r['duration'].to_i
          end
          return body, total_time
        end

        def _get_project_name(pid)
          return 'その他' if pid == 0
          response = @tog.get_project_data(pid.to_s)
          return response['data']['name']
        end

        def _get_title()
          abort("Undefined method.")
        end

        def _get_start_date()
          abort("Undefined method.")
        end

        def _get_end_date()
          abort("Undefined method.")
        end

        def _get_formated_date(t)
          t.strftime('%Y/%m/%d')
        end
      end
    end
  end
end
