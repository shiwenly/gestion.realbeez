class AddColumnToBuildings < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :statut, :string
  end
end
