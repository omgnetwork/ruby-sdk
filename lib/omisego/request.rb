module OmiseGO
  class Request
    PARAM_FIELDS = %i[page per_page search_term search_terms sort_by sort_dir].freeze

    def initialize(client)
      @client = client
      @config = @client.config
    end

    def send(path, body, params: {}, conn: new_conn)
      idempotency_token = body.delete(:idempotency_token)
      body = add_params(body, params)

      response = conn.post do |req|
        req.url path
        req.headers['Authorization'] = authorization
        req.headers['Accept'] = content_type
        req.headers['Content-Type'] = content_type
        req.headers['Idempotency-Token'] = idempotency_token if idempotency_token
        req.body = body.to_json if body
        logger.log_request(req)
      end

      logger.log_response(response)

      unless [200, 500].include?(response.status)
        return error('invalid_status_code',
                     "The server returned an invalid status code: #{response.status}")
      end

      json = JSON.parse(response.body)
      Response.new(json, @client)
    rescue JSON::ParserError => e
      error('json_parsing_error',
            "The JSON received from the server could not be parsed: #{e.message}")
    rescue Faraday::Error::ConnectionFailed => e
      error('connection_failed', e.message)
    end

    private

    def add_params(body, params)
      params = params.select { |key, _| PARAM_FIELDS.include?(key) }
      body.merge(params)
    end

    def error(code, description)
      Response.new({
                     'success' => false,
                     'version' => @config.api_version,
                     'data' => {
                       'object' => 'error',
                       'code' => code,
                       'description' => description,
                       'messages' => []
                     }
                   }, @client)
    end

    def logger
      @logger ||= HTTPLogger.new(@config.logger)
    end

    def content_type
      "application/vnd.omisego.v#{@config.api_version}+json"
    end

    def authorization
      keys = "#{@config.access_key}:#{@config.secret_key}"
      encoded = Base64.encode64(keys).delete("\n")
      "#{@config.auth_scheme} #{encoded}"
    end

    def new_conn
      @conn = Faraday.new(url: "#{@config.base_url}#{@config.api_prefix}")
    end
  end
end
