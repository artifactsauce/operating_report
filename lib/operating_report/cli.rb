require "thor"
require "yaml"

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

      config['tracking'] = {
        'api' => {
          'token' => api_token
        }
      }

      File.open(@config_file, 'w') do |f|
        f.write(YAML.dump(config))
      end
    end

    desc "create [PERIOD]", "create a report. (parameter required)"
    def create(period)
      t = Time.now

      case period
      when 'daily' then
        start_date = Time.new(t.year, t.mon, t.day, 0, 0, 0)
        end_date =  Time.new(t.year, t.mon, t.day, 23, 59, 59)
      else
        abort("Undfined period.")
      end
    end

    private
    def _load_config(config_file)
      unless File.exist?(config_file) then
        init()
      end
      return YAML.load_file(config_file)
    end

    def _fetch_via_api(path)
    end
  end
end
