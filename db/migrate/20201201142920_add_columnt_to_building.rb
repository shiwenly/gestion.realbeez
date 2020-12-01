class AddColumntToBuilding < ActiveRecord::Migration[5.2]
  def change
    add_column :buildings, :name, :string
  end
end
