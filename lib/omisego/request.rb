module OmiseGO
  class Request
    def initialize(client)
      @client = client
      @config = @client.config
    end

    def send(path, body, conn: new_conn)
      idempotency_token = body.delete(:idempotency_token)

      response = conn.post do |req|
        req.url path
        req.headers['Authorization'] = authorization
        req.headers['Accept'] = content_type
        req.headers['Content-Type'] = content_type
        req.headers['Idempotency-Token'] = idempotency_token if idempotency_token
        req.body = body.to_json
      end

      json = JSON.parse(response.body)
      Response.new(json, @client)
    end

    private

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
