class AddTenantIdToWater < ActiveRecord::Migration[5.2]
  def change
    add_column :waters, :tenant_id, :integer
  end
end
