class Tenant < ApplicationRecord
  belongs_to :user
  belongs_to :apartment
  has_many :waters, dependent: :destroy
  has_many :rents, dependent: :destroy

  validates :last_name, :rent, :service_charge, presence: true
end
