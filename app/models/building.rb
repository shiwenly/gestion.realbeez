class Building < ApplicationRecord
  belongs_to :user
  belongs_to :company
  has_many :apartments, dependent: :destroy
end
