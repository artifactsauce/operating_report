# coding: utf-8
require "thor"
require "yaml"
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

    desc "create [PERIOD]", "create a report. (parameter required)"
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
      else
        abort("Undfined period.")
      end

      tog = OperatingReport::Tracker::Api::Toggl.new(
        'token' => @config['tracker']['api']['token']
      )
      response = tog.get_time_entries(start_date, end_date)

      body = {}
      response.each do |x|
        body[x['description']] = {} unless body[x['description']]
        body[x['description']]['start'] = x['start'] unless body[x['description']]['start']
        body[x['description']]['duration'] = 0 unless body[x['description']]['duration']
        body[x['description']]['duration'] += x['duration'].to_i
      end

      body.each do |x, y|
        dur = y['duration'] / (60 * 60)
        printf "- %s （%.1fh）\n", x, dur
      end
    end

    private
    def _load_config(config_file)
      unless File.exist?(config_file) then
        init()
      end
      return YAML.load_file(config_file)
    end
  end
end
