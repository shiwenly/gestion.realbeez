class RemoveBuidlingFromApartment < ActiveRecord::Migration[5.2]
  def change
    remove_reference :apartments, :building, foreign_key: true
    add_reference :apartments, :company, foreign_key: true
    add_column :apartments, :building_id, :integer
  end
end
