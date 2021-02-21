class ChangeDefaultPicExpenses < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:expenses, :photo, "image/upload/v1613915595/default_annonce_tj0cet.png")
    change_column_default(:waters, :photo, "image/upload/v1613915595/default_annonce_tj0cet.png")
  end
end
