class Liasse < ApplicationRecord
  belongs_to :user
  belongs_to :building
  validates :year2, uniqueness: { scope: :building_id }
end
