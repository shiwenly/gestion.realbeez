class Apartment < ApplicationRecord
  belongs_to :building
  belongs_to :user
  has_many :tenants, dependent: :destroy
  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, message: " : Cette référence existe déjà" }
end
