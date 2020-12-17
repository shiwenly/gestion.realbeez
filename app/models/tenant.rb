class Tenant < ApplicationRecord
  belongs_to :user
  # belongs_to :apartment
  has_many :waters, dependent: :destroy
  has_many :rents, dependent: :destroy
  # has_one_attached :contract
  # has_one_attached :inventory

  mount_uploader :contract, PhotoUploader
  mount_uploader :inventory, PhotoUploader

  validates :first_name, :last_name, :rent, :service_charge, presence: true

  include PgSearch::Model
  pg_search_scope :search_by_company,
    against: [ :company_name ],
  using: {
    tsearch: { prefix: true } # <-- now `superman batm` will return something!
  }

  include PgSearch::Model
  pg_search_scope :search_by_building,
    against: [ :building_name ],
  using: {
    tsearch: { prefix: true } # <-- now `superman batm` will return something!
  }
end
