class RemoveUserReferenceFromWater < ActiveRecord::Migration[5.2]
  def change
    remove_reference :waters, :user, foreign_key: true
  end
end
