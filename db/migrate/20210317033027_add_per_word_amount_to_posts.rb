class AddPerWordAmountToPosts < ActiveRecord::Migration[6.0]
  def change
  	add_column :posts,:per_word_amount,:decimal,:precision=> 32, :scale =>16
  	add_column :payment_charges,:gst,:decimal,:precision=> 32,:scale =>16
  	add_column :payment_charges,:withdraw_fee,:decimal,:precision=> 32,:scale=>16
  end
end
