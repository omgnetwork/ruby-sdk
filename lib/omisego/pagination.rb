module OmiseGO
  class Pagination < Base
    attributes :per_page, :is_last_page, :is_first_page, :current_page
  end
end
