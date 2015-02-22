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
          @map = {}
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
          if response.count == 100 then
            abort "[\e[31mError\e[0m] The record number in the period is possibly over 100."
          end

          body = {}
          total_time = 0
          pids = []
          response.each do |r|
            pid = r['pid'] || 0;
            pids << pid if pid != 0
            desc = r['description'] || '【無記載】'
            body[pid] = {items:{}, duration:0} unless body[pid]
            body[pid][:items][desc] = {duration:0, tags:[]} unless body[pid][:items][desc]
            body[pid][:items][desc][:tags].concat(r['tags']) if r['tags']
            body[pid][:items][desc][:duration] += r['duration'].to_i
            body[pid][:duration] += r['duration'].to_i
            total_time += r['duration'].to_i
          end
          pids.uniq!
          _store_project_map(pids)

          data = {}
          body.each do |pid, d|
            cid = 0
            if @map[:pid][pid] && @map[:pid][pid]['cid']
              cid = @map[:pid][pid]['cid']
            end
            data[cid] = {duration:0, items:{}} unless data[cid]
            data[cid][:items][pid] = d
            data[cid][:duration] += d[:duration]
          end
          return data, total_time
        end

        def _get_project_name(pid)
          return 'その他' if pid == 0
          return @map[:pid][pid]['name']
        end

        def _get_client_name(cid)
          return 'その他' if cid == 0
          return @map[:cid][cid]['name']
        end

        def _store_project_map(pids)
          cids = []
          pids.each do |pid|
            next if pid == 0
            response = @tog.get_project_data(pid.to_s)
            @map[:pid] = {} unless @map[:pid]
            @map[:pid][pid] = response['data']
            cids << response['data']['cid'] if response['data']['cid']
          end
          _store_client_map(cids)
        end

        def _store_client_map(cids)
          cids.each do |cid|
            next if cid == 0
            response = @tog.get_client_data(cid.to_s)
            @map[:cid] = {} unless @map[:cid]
            @map[:cid][cid] = response['data']
          end
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
