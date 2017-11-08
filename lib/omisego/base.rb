module OmiseGO
  class Base
    class << self
      attr_accessor :attributes_list

      def attributes(*attrs)
        attr_accessor(*attrs)
        @attributes_list = attrs.map(&:to_sym)
      end
    end

    attr_accessor :client, :original_payload

    def initialize(attributes, client: nil)
      self.class.attributes_list ||= []

      self.class.attributes_list.each do |name|
        instance_variable_set("@#{name}", attributes[name.to_sym] ||
                                          attributes[name.to_s])
      end

      self.original_payload = attributes
      @client = client || Client.new
    end
  end
end
