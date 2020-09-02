class Tenant < ApplicationRecord
  belongs_to :user
  belongs_to :apartment
  has_many :waters, dependent: :destroy
  has_many :rents, dependent: :destroy
  # has_one_attached :contract
  # has_one_attached :inventory

  mount_uploader :contract, PhotoUploader
  mount_uploader :inventory, PhotoUploader

  validates :last_name, :rent, :service_charge, presence: true
end
