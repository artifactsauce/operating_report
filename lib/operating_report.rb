require "yaml"
require "operating_report/version"
require "operating_report/cli"

module OperatingReport
  def self.load_config(config)
    @config_file = config.nil? ? ENV['HOME'] + '/.report' : config
    unless File.exist?(@config_file) then
      abort("Configuration file not founds.")
    end
    @config = YAML.load_file(@config_file)
  end

  def self.config()
    @config
  end
end
