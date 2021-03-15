class RemoveWaterReference < ActiveRecord::Migration[5.2]
  def change
    remove_reference :waters, :tenant, foreign_key: true
    add_column :waters, :company_id, :integer
    add_column :waters, :company_name, :string
    add_column :waters, :building_id, :integer
    add_column :waters, :building_name, :string
    add_column :waters, :tenant_name, :string
    change_column_default(:tenants, :contract, "image/upload/v1613915595/default_annonce_tj0cet.png")
    change_column_default(:tenants, :inventory, "image/upload/v1613915595/default_annonce_tj0cet.png")
  end
end
