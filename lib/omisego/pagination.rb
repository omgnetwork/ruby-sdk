module OmiseGO
  class Pagination < Base
    attributes :per_page, :is_last_page, :is_first_page, :current_page

    def first_page?
      is_first_page
    end

    def last_page?
      is_last_page
    end

    private

    def is_first_page
      @is_first_page
    end

    def is_last_page
      @is_last_page
    end
  end
end
