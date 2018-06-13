module OmiseGO
  class Token < Base
    attributes :id, :symbol, :subunit_to_unit, :name, :metadata, :encrypted_metadata
  end
end
