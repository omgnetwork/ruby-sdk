module OmiseGO
  class HTTPLogger
    LABEL = '[OmiseGO]'.freeze

    def initialize(logger = nil)
      @logger = logger
    end

    attr_reader :logger

    def log_request(request)
      info(format_request(request))
    end

    def log_response(response)
      info(format_response(response))
    end

    private

    def info(message)
      return unless @logger

      @logger.info(message)
    end

    def format_request(request)
      StringIO.open do |s|
        s.puts("#{LABEL} Request: #{request.method.to_s.upcase} #{request.path}")
        s.puts(format_headers(request.headers))
        s.puts
        s.puts(request.body) if request.body
        s.string
      end
    end

    def format_response(response)
      StringIO.open do |s|
        s.puts("#{LABEL} Response: HTTP/#{response.status}")
        s.puts(format_headers(response.headers))
        s.puts
        s.puts(response.body)

        s.string
      end
    end

    def format_headers(headers)
      headers.map do |name, value|
        name = name.split('-').map(&:capitalize).join('-')

        if name == 'Authorization'
          "#{name}: [FILTERED]"
        else
          "#{name}: #{value}"
        end
      end.join("\n")
    end

    def format_payload(payload)
      payload.map { |key, value| "#{key}=#{value}" }.join('&')
    end
  end
end
