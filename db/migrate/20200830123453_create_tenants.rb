class CreateTenants < ActiveRecord::Migration[5.2]
  def change
    create_table :tenants do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.decimal :rent, :precision => 10, :scale => 2
      t.decimal :service_charge, :precision => 10, :scale => 2
      t.decimal :deposit, :precision => 10, :scale => 2
      t.string :contract
      t.string :inventory
      t.date :move_in_date
      t.date :move_out_date
      t.string :statut
      t.references :user, foreign_key: true
      t.references :apartment, foreign_key: true

      t.timestamps
    end
  end
end
