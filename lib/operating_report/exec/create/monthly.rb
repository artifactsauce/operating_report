# coding: utf-8

module OperatingReport
  module Exec
    module Create
      class Monthly < OperatingReport::Exec::Create::Base
        def output_body(body, total_time)
          body.each_key do |pid|
            printf "\n### %s （%.1f%%）\n\n",
                   _get_project_name(pid),
                   body[pid][:duration].to_f / total_time.to_f * 100
            body[pid][:items].each do |desc, d|
              ratio = d[:duration].to_f / total_time.to_f * 100
              printf "- %s （%.1f%%）\n", desc, ratio
            end
          end
        end

        def _get_start_date(t)
          return Time.new(t.year, t.mon, 1, 0, 0, 0)
        end

        def _get_end_date(t)
          day = 31
          loop do
            # 指定した日付が無い場合にout of rangeになるのではなく、
            # 次の月に繰り越した日付を返す（例：11/31 -> 12/1）。
            # そのため、現在の月と一致することを確認する。
            end_of_month = Time.new(t.year, t.mon, day, 23, 59, 59)
            if t.mon == end_of_month.mon then
              return end_of_month
            else
              day -= 1
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
