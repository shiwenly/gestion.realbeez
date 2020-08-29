class ChangeColumnToCompany < ActiveRecord::Migration[5.2]
  def change
    change_column :companies, :access, :text
  end
end
