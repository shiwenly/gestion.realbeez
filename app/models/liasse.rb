class Liasse < ApplicationRecord
  belongs_to :user
  belongs_to :building
  validates :year, uniqueness: true
end
