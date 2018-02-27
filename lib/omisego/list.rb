module OmiseGO
  class List < Base
    attributes :data, :pagination

    def first
      data.first
    end

    def last
      data.last
    end

    def [](i)
      data[i]
    end

    def pagination
      @_pagination ||= if (pag = @original_payload['pagination'])
                         Pagination.new(pag)
                       end
    end

    def data
      @_data ||= @data.map do |element|
        klass = @client.config[:models][element['object'].to_sym]
        klass.new(element, client: @client)
      end
    end
  end
end
