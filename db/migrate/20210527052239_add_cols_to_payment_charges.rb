class AddColsToPaymentCharges < ActiveRecord::Migration[6.0]
  def change
  	add_column :payment_charges,:commission_percentage,:float
  	add_column :payment_charges,:fine_percentage,:float
  	remove_column :payment_charges,:withdraw_fee,:decimal
  	remove_column :payment_charges,:gst,:decimal
  	remove_column :payment_charges,:minimum_amount,:decimal
  end
end
