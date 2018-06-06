module OmiseGO
  class Account < Base
    attributes :id, :parent_id, :name, :description, :mater, :avatar, :metadata,
               :encrypted_metadata, :created_at, :updated_at
  end
end
