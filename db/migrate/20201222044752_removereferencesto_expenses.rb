class RemovereferencestoExpenses < ActiveRecord::Migration[5.2]
  def change
    remove_reference :expenses, :building, foreign_key: true
    add_column :expenses, :company_id, :integer
    add_column :expenses, :company_name, :string
    add_column :expenses, :building_id, :integer
    add_column :expenses, :building_name, :string
    add_column :expenses, :apartment_id, :integer
    add_column :expenses, :recuperable, :boolean, default: true
  end
end
