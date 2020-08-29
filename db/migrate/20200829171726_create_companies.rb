class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :address
      t.boolean :corporate_tax
      t.boolean :vat
      t.string :associe
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
