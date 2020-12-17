class Apartment < ApplicationRecord
  # belongs_to :company
  belongs_to :user
  # has_many :tenants, dependent: :destroy
  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, message: " : Cette référence existe déjà" }

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
