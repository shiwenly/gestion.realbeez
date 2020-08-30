class Apartment < ApplicationRecord
  belongs_to :building
  belongs_to :user
  has_many :tenants, dependent: :destroy
end
