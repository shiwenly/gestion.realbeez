class CreateRents < ActiveRecord::Migration[5.2]
  def change
    create_table :rents do |t|
      t.date :period
      t.decimal :rent_paid, :precision => 10, :scale => 2
      t.decimal :service_charge_paid, :precision => 10, :scale => 2
      t.decimal :rent_ask, :precision => 10, :scale => 2
      t.decimal :service_charge_ask, :precision => 10, :scale => 2
      t.string :statut
      t.references :user, foreign_key: true
      t.references :tenant, foreign_key: true

      t.timestamps
    end
  end
end
