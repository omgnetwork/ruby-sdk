require 'faraday'
require 'json'

require 'omisego/error_handler'

require 'omisego/response'
require 'omisego/request'
require 'omisego/client'

require 'omisego/base'
require 'omisego/error'
require 'omisego/user'
require 'omisego/authentication_token'

require 'omisego/version'
require 'omisego/configuration'

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
