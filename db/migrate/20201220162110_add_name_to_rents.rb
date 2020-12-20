class AddNameToRents < ActiveRecord::Migration[5.2]
  def change
    add_column :rents, :name, :string
  end
end
