class Expense < ApplicationRecord
  belongs_to :building
  belongs_to :user

  mount_uploader :photo, PhotoUploader

  validates :apartment_name, :expense_type, :supplier, :amount_ttc, :amount_vat, presence: true

  include PgSearch::Model
  pg_search_scope :search_by_date_expense,
    against: [ :date],
  using: {
    tsearch: { prefix: true } # <-- now `superman batm` will return something!
  }

end
