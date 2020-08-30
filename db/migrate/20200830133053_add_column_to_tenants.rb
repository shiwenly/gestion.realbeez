class AddColumnToTenants < ActiveRecord::Migration[5.2]
  def change
    add_column :tenants, :current_tenant, :boolean, default: true
  end
end
