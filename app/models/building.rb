class Building < ApplicationRecord
  belongs_to :user
  belongs_to :company
  has_many :apartments, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :liasses, dependent: :destroy
  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, message: " : Cette référence existe déjà" }

  include PgSearch::Model
  pg_search_scope :search_by_company,
    against: [ :company_name ],
  using: {
    tsearch: { prefix: true } # <-- now `superman batm` will return something!
  }
end
