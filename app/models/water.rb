class Water < ApplicationRecord
  belongs_to :user
  # belongs_to :tenant

  # has_one_attached :photo
  # mount_uploader :photo, PhotoUploader
end
