module OmiseGO
  class Client
    attr_accessor :config

    def initialize(options = nil)
      @config = load_config(options)
    end

    def call(path, params)
      request.call(path: path, body: params)
    end

    def request
      @request ||= Request.new(self)
    end

    private

    def load_config(options)
      return OmiseGO.configuration unless options

      config = Configuration.new
      config.merge(OmiseGO.configuration.to_hash.merge(options))
      config
    end
  end
end
