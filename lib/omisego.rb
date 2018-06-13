require 'faraday'
require 'json'
require 'base64'

require 'omisego/invalid_configuration'
require 'omisego/error_handler'

require 'omisego/http_logger'
require 'omisego/response'
require 'omisego/request'
require 'omisego/client'

require 'omisego/base'
require 'omisego/error'
require 'omisego/pagination'
require 'omisego/list'
require 'omisego/token'
require 'omisego/setting'
require 'omisego/balance'
require 'omisego/wallet'
require 'omisego/user'
require 'omisego/authentication_token'
require 'omisego/exchange'
require 'omisego/transaction_source'
require 'omisego/transaction'

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
