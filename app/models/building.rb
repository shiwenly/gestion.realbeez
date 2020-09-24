class Building < ApplicationRecord
  belongs_to :user
  belongs_to :company
  has_many :apartments, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :liasses, dependent: :destroy
end
