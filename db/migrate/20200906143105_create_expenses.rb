class CreateExpenses < ActiveRecord::Migration[5.2]
  def change
    create_table :expenses do |t|
      t.string :apartment_name
      t.string :expense_type
      t.date :date
      t.string :supplier
      t.decimal :amount_ttc, :precision => 10, :scale => 2
      t.decimal :amount_vat, :precision => 10, :scale => 2
      t.string :photo, default: "image/upload/v1598991055/default_annonce_k6x0wm.png"
      t.boolean :deductible
      t.string :statut
      t.references :user, foreign_key: true
      t.references :building, foreign_key: true

      t.timestamps
    end
  end
end
