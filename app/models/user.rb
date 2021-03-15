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
  # has_many :waters, dependent: :destroy
  has_many :rents, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :liasses, dependent: :destroy

  # instead of deleting, indicate the user requested a delete & timestamp it
  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  # ensure user account is active
  def active_for_authentication?
    super && !deleted_at
  end

  # provide a custom message for a deleted account
  def inactive_message
    !deleted_at ? super : :deleted_account
  end


end
