# coding: utf-8

module OperatingReport
  module Exec
    module Create
      class Weekly < OperatingReport::Exec::Create::Base
        def output_body(body, total_time)
          body.each_key do |pid|
            printf "\n### %s （%.1f%%）\n\n",
                   _get_project_name(pid),
                   body[pid][:duration].to_f / total_time.to_f * 100
            body[pid][:items].each do |desc, d|
              tags = d[:tags].uniq.map {|s| "【#{s}】"} .join('') unless d[:tags].empty?
              printf "- %s %s\n", desc, tags
            end
          end
        end

        def _get_start_date(t)
          loop do
            return Time.new(t.year, t.mon, t.day, 0, 0, 0) if t.monday?
            t = t - (60 * 60 * 24)
          end
        end

        def _get_end_date(t)
          loop do
            return Time.new(t.year, t.mon, t.day, 23, 59, 59) if t.friday?
            if t.saturday? || t.sunday? then
              t = t - (60 * 60 * 24)
            else
              t = t + (60 * 60 * 24)
            end
          end
        end

        def _generate_title(start_date, end_date)
          _get_formated_date(start_date) + ' - ' + _get_formated_date(end_date)
        end
      end
    end
  end
end
