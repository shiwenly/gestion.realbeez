class RemoveApartmentFromTenant < ActiveRecord::Migration[5.2]
  def change
    remove_reference :tenants, :apartment, foreign_key: true
    add_column :tenants, :company_id, :integer
    add_column :tenants, :company_name, :string
    add_column :tenants, :building_id, :integer
    add_column :tenants, :building_name, :string
    add_column :tenants, :apartment_id, :integer
    add_column :tenants, :apartment_name, :string
  end
end
