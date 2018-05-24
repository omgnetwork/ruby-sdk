module OmiseGO
  class Configuration
    OPTIONS = {
      access_key: -> { ENV['OMISEGO_ACCESS_KEY'] },
      secret_key: -> { ENV['OMISEGO_SECRET_KEY'] },
      base_url: -> { ENV['OMISEGO_BASE_URL'] },
      logger: nil
    }.freeze

    OMISEGO_OPTIONS = {
      api_version: '1',
      auth_scheme: 'OMGServer',
      models: {
        user: OmiseGO::User,
        error: OmiseGO::Error,
        authentication_token: OmiseGO::AuthenticationToken,
        wallet: OmiseGO::Wallet,
        balance: OmiseGO::Wallet,
        token: OmiseGO::Token,
        list: OmiseGO::List,
        setting: OmiseGO::Setting,
        transaction: OmiseGO::Transaction,
        exchange: OmiseGO::Exchange,
        transaction_source: OmiseGO::TransactionSource
      }
    }.freeze

    attr_accessor(*OPTIONS.keys)
    attr_reader(*OMISEGO_OPTIONS.keys)

    def initialize(options = {})
      OPTIONS.each do |name, val|
        value = options ? options[name] || options[name.to_sym] : nil
        value ||= val.call if val.respond_to?(:call)
        instance_variable_set("@#{name}", value)
      end

      OMISEGO_OPTIONS.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end

    def [](option)
      instance_variable_get("@#{option}")
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
