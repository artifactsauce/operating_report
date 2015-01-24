# coding: utf-8

require "thor"
require "operating_report/exec/create/base"
require "operating_report/exec/create/daily"
require "operating_report/exec/create/weekly"
require "operating_report/exec/create/monthly"

module OperatingReport
  class CLI < Thor
    class_option :config, :type => :string

    def initialize(*args)
      super
      OperatingReport::load_config(options[:config])
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

    desc "create [daily|weekly|monthly]", "create a report. (parameter required)"
    option :date, :type => :string
    def create(period)
      period_models = {
        'daily' => 'Daily',
        'weekly' => 'Weekly',
        'monthly' => 'Monthly',
      }
      unless period_models[period]
        abort("Undefined period.")
      end

      t = Time.now
      if options[:date] then
        date = *options[:date].split(/[-:\/\s]/)
        t = Time.new(*date)
      end

      OperatingReport::Exec::Create.const_get(period_attr[period]).new(
        :datetime => t
      ).run()
    end

    private
  end
end
