module OmiseGO
  class Request
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
      body[:page] = params[:page] if params[:page]
      body[:per_page] = params[:per_page] if params[:per_page]
      body[:search_terms] = params[:search_terms] if params[:search_terms]
      body[:search_term] = params[:search_term] if !params[:search_terms] && params[:search_term]
      body[:sort_by] = params[:sort_by] if params[:sort_by]
      body[:sort_dir] = params[:sort_dir] if params[:sort_dir]
      body
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
      @conn = Faraday.new(url: @config.base_url)
    end
  end
end
