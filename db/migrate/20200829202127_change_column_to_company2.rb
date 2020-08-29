class ChangeColumnToCompany2 < ActiveRecord::Migration[5.2]
  def change
    change_column :companies, :associe, :string
    remove_column :companies, :access
  end
end
