# coding: utf-8

module OperatingReport
  module Exec
    module Create
      class Daily < OperatingReport::Exec::Create::Base
        def output_body(data, total_time)
          data.each do |cid, d1|
            duration = d1[:duration].quo(60 * 60)
            printf "\n## %s （%.2fh）\n", _get_client_name(cid), duration
            d1[:items].each do |pid, d2|
              printf "\n### %s\n\n", _get_project_name(pid)
              d2[:items].each do |desc, d|
                duration = d[:duration].quo(60 * 60)
                tags = d[:tags].uniq.map {|s| "【#{s}】"} .join('') unless d[:tags].empty?
                printf "- %s%s （%.2fh）\n", desc, tags, duration
              end
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
