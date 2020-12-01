class Company < ApplicationRecord
  belongs_to :user
  has_many :buildings, dependent: :destroy
  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, message: " : Cette société existe déjà" }
end
