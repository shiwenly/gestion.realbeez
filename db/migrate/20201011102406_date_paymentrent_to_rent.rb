class DatePaymentrentToRent < ActiveRecord::Migration[5.2]
  def change
    add_column :rents, :date_payment, :date
  end
end
