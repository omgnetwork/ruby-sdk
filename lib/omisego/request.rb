module OmiseGO
  class Request
    def initialize(client)
      @client = client
      @config = @client.config
    end

    def call(path:, body:, conn: new_conn)
      response = conn.post do |req|
        req.url path
        req.headers['Authorization'] = authorization
        req.headers['Content-Type'] = content_type
        req.body = body.to_json
      end

      Response.new(response.body, @client)
    end

    private

    def content_type
      "application/vnd.omisego.v#{@config.api_version}+json"
    end

    def authorization
      keys = Base64.encode64("#{@config.access_key}:#{@config.secret_key}")
      "#{@config.auth_scheme} #{keys}"
    end

    def new_conn
      @conn = Faraday.new(url: @config.base_url)
    end
  end
end
