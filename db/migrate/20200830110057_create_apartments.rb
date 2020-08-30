class CreateApartments < ActiveRecord::Migration[5.2]
  def change
    create_table :apartments do |t|
      t.string :name
      t.string :water
      t.string :statut
      t.references :building, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
