class Tenant < ApplicationRecord
  belongs_to :user
  belongs_to :apartment
  has_many :waters, dependent: :destroy
  has_many :rents, dependent: :destroy
end
