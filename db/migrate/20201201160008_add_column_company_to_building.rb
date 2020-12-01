class AddColumnCompanyToBuilding < ActiveRecord::Migration[5.2]
  def change
    add_column :buildings, :company_name, :string
  end
end
