# coding: utf-8

module OperatingReport
  module Exec
    module Create
      class Daily < OperatingReport::Exec::Create::Base
        def output_body(body, total_time)
          body.each_key do |pid|
            printf "\n### %s\n\n", _get_project_name(pid)
            body[pid][:items].each do |desc, d|
              duration = d[:duration].quo(60 * 60)
              tags = d[:tags].uniq.map {|s| "【#{s}】"} .join('') unless d[:tags].empty?
              printf "- %s %s （%.2fh）\n", desc, tags, duration
            end
          end
        end

        def _get_start_date(t)
          Time.new(t.year, t.mon, t.day, 0, 0, 0)
        end

        def _get_end_date(t)
          Time.new(t.year, t.mon, t.day, 23, 59, 59)
        end

        def _generate_title(start_date, end_date)
          _get_formated_date(start_date)
        end
      end
    end
  end
end
