require "thor"
require "yaml"

module OperatingReport
  class CLI < Thor
    def initialize(*args)
      super
    end

    desc "init", "create a config file."
    def init
    end

    desc "create [PERIOD]", "create a report. (parameter required)"
    def create(period)
    end

    private
    def _load_config
    end

    def _fetch_via_api(path)
    end
  end
end
