class CreateLiasses < ActiveRecord::Migration[5.2]
  def change
    create_table :liasses do |t|
      t.date :year
      t.string :statut
      t.boolean :closed, default: false
      t.references :user, foreign_key: true
      t.references :building, foreign_key: true

      t.timestamps
    end
  end
end
