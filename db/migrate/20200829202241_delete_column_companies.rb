class DeleteColumnCompanies < ActiveRecord::Migration[5.2]
  def change
    remove_column :companies, :access
    add_column :companies, :associe, :string
  end
end
