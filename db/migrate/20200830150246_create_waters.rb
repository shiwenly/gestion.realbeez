class CreateWaters < ActiveRecord::Migration[5.2]
  def change
    create_table :waters do |t|
      t.date :submission_date
      t.decimal :quantity, :precision => 10, :scale => 2
      t.string :photo
      t.string :statut
      t.references :user, foreign_key: true
      t.references :tenant, foreign_key: true

      t.timestamps
    end
  end
end
