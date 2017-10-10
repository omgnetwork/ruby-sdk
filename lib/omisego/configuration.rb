module OmiseGO
  # :nodoc:
  class Configuration
    OPTIONS = {
      access_key: -> { ENV['OMISEGO_ACCESS_KEY'] },
      secret_key: -> { ENV['OMISEGO_SECRET_KEY'] },
      base_url: 'https://example.com'
    }.freeze

    OMISEGO_OPTIONS = {
      version: '1.0.0'
    }.freeze

    attr_accessor(*OPTIONS.keys)
    attr_reader(*OMISEGO_OPTIONS.keys)

    def initialize
      OPTIONS.merge(OMISEGO_OPTIONS).each do |name, val|
        value = val.respond_to?(:lambda?) && val.lambda? ? val.call : val
        instance_variable_set("@#{name}", value)
      end
    end

    def [](option)
      send(option)
    end

    def to_hash
      OPTIONS.keys.each_with_object({}) do |option, hash|
        hash[option.to_sym] = send(option)
      end
    end

    def merge(options)
      OPTIONS.each_keys do |name|
        instance_variable_set("@#{name}", options[name]) if options[name]
      end
    end
  end
end
