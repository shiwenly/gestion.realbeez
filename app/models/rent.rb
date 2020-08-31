class Rent < ApplicationRecord
  belongs_to :user
  belongs_to :tenant

  validates :rent_paid, :service_charge_paid, :rent_ask, :service_charge_ask, presence: true

  include PgSearch::Model
  pg_search_scope :search_by_date,
    against: [ :period ],
  using: {
    tsearch: { prefix: true } # <-- now `superman batm` will return something!
  }

end
