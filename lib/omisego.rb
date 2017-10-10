require 'omisego/version'
require 'omisego/configuration'

# :nodoc:
module OmiseGO
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
