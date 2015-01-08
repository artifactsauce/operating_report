# coding: utf-8
require "thor"
require "yaml"
require "awesome_print"
require "operating_report/tracker/api/toggl"

module OperatingReport
  class CLI < Thor
    def initialize(*args)
      super
      @config_file = ENV['HOME'] + '/.report'
      @config = _load_config(@config_file)
    end

    desc "init", "create a config file."
    def init
      puts "Create a configuration file at #{@config_file}."
      if File.exist?(@config_file) then
        is_overwritable = false;
        print "Sure you want to overwrite it? [y/n] "
        answer = STDIN.gets.chomp
        if /^(?:y)(?:es)?$/i =~ answer then
          is_overwritable = true;
        end

        unless is_overwritable then
          abort("Cofiguration file aleready exists.")
        end
      end

      config = Hash.new();

      print "Toggl API Token: "
      api_token = STDIN.gets.chomp

      config['tracker'] = {
        'api' => {
          'token' => api_token
        }
      }

      File.open(@config_file, 'w') do |f|
        f.write(YAML.dump(config))
      end
    end

    desc "create [daily|weekly]", "create a report. (parameter required)"
    option :date
    def create(period)
      t = Time.now
      if options[:date] then
        date = *options[:date].split(/[-:\/\s]/)
        t = Time.new(*date)
      end

      case period
      when 'daily' then
        start_date = Time.new(t.year, t.mon, t.day, 0, 0, 0)
        end_date =  Time.new(t.year, t.mon, t.day, 23, 59, 59)
      when 'weekly' then
        start_date = _find_monday(t)
        end_date = _find_friday(t)
      else
        abort("Undefined period.")
      end

      tog = OperatingReport::Tracker::Api::Toggl.new(
        'token' => @config['tracker']['api']['token']
      )
      response = tog.get_time_entries(start_date, end_date)

      body = {}
      total_time = 0
      response.each do |x|
        body[x['description']] = {} unless body[x['description']]
        body[x['description']]['start'] = x['start'] unless body[x['description']]['start']
        body[x['description']]['duration'] = 0 unless body[x['description']]['duration']
        body[x['description']]['duration'] += x['duration'].to_i
        total_time += x['duration'].to_i
      end

      if period == 'weekly' then
        title = _generate_title(start_date, end_date)
        puts "Title: #{title}"
      end

      body.each do |x, y|
        case period
        when 'daily' then
          dur = y['duration'].quo(60 * 60)
          printf "- %s （%.2fh）\n", x, dur
        when 'weekly' then
          ratio = y['duration'].to_f / total_time.to_f * 100
          printf "- %s （%.1f%%）\n", x, ratio
        end
      end
    end

    private
    def _load_config(config_file)
      unless File.exist?(config_file) then
        init()
      end
      return YAML.load_file(config_file)
    end

    def _find_monday(t)
      loop do
        return Time.new(t.year, t.mon, t.day, 0, 0, 0) if t.monday?
        t = t - (60 * 60 * 24)
      end
    end

    def _find_friday(t)
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

    def _get_formated_date(t)
      t.strftime('%Y/%m/%d')
    end
  end
end
