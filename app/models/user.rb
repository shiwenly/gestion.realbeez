class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :statut, presence: true
  has_many :companies, dependent: :destroy
  has_many :buildings, dependent: :destroy
  has_many :apartments, dependent: :destroy
  has_many :tenants, dependent: :destroy
  has_many :waters, dependent: :destroy
  has_many :rents, dependent: :destroy
end
