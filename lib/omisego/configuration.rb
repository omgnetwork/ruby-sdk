module OmiseGO
  class Configuration
    OPTIONS = {
      access_key: -> { ENV['OMISEGO_ACCESS_KEY'] },
      secret_key: -> { ENV['OMISEGO_SECRET_KEY'] },
      base_url: 'https://example.com'
    }.freeze

    OMISEGO_OPTIONS = {
      api_version: '1',
      auth_scheme: 'OMGServer',
      models: {
        user: OmiseGO::User
      }
    }.freeze

    attr_accessor(*OPTIONS.keys)
    attr_reader(*OMISEGO_OPTIONS.keys)

    def initialize(options = {})
      OPTIONS.merge(OMISEGO_OPTIONS).each do |name, val|
        value = options ? options[name] || options[name.to_sym] : nil
        value ||= val.respond_to?(:call) ? val.call : val
        instance_variable_set("@#{name}", value)
      end
    end

    def [](option)
      send(option)
    end

    def to_hash
      OPTIONS.keys.each_with_object({}) do |option, hash|
        hash[option.to_sym] = self[option]
      end
    end

    def merge(options)
      OPTIONS.each_key do |name|
        instance_variable_set("@#{name}", options[name]) if options[name]
      end
    end
  end
end
