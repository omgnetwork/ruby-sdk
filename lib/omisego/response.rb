module OmiseGO
  class Response
    def initialize(body, client)
      @body = body
      @client = client
      @config = @client.config
    end

    def success?
      @success ||= @body['success'] == true
    end

    def version
      @version ||= @body['version']
    end

    def data
      type = @body['data']['object'].to_sym
      raise 'Unknown Object' unless @config[:models].keys.include?(type)

      klass = @config[:models][type]
      klass.new(@body['data'], client: @client)
    end
  end
end
