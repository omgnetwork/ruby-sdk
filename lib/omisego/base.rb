module OmiseGO
  class Base
    class << self
      attr_accessor :attributes_list

      def attributes(*attrs)
        attr_accessor(*attrs)
        @attributes_list = attrs.map(&:to_sym)
      end

      def global_client
        Client.new
      end

      def request(client)
        (client || global_client).request
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
      @client = client || self.class.global_client
    end

    def inspect
      string = "#<#{self.class.name}:#{object_id} "
      fields = self.class.attributes_list.map do |field|
        "#{field}: #{send(field)}"
      end
      string << fields.join(', ') << '>'
    end

    def error?
      false
    end
  end
end
