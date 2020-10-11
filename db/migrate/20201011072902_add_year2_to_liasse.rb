class AddYear2ToLiasse < ActiveRecord::Migration[5.2]
  def change
    add_column :liasses, :year2, :integer
  end
end
