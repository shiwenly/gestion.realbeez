class Building < ApplicationRecord
  belongs_to :user
  belongs_to :company
end
