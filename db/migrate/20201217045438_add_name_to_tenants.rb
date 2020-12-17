class AddNameToTenants < ActiveRecord::Migration[5.2]
  def change
    add_column :tenants, :name, :string
  end
end
