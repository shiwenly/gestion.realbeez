class RemoveCompanyFromBuilding < ActiveRecord::Migration[5.2]
  def change
    remove_reference :buildings, :company, foreign_key: true
    remove_reference :apartments, :company, foreign_key: true
    add_column :buildings, :company_id, :integer
    add_column :apartments, :company_id, :integer
    add_column :apartments, :company_name, :string
    add_column :apartments, :building_name, :string
  end
end
