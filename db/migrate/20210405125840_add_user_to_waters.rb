class AddUserToWaters < ActiveRecord::Migration[5.2]
  def change
    add_reference :waters, :user, foreign_key: true
    change_column_default(:waters, :photo, "http://res.cloudinary.com/myhouze/image/upload/v1613915595/default_annonce_tj0cet.png")
  end
end
