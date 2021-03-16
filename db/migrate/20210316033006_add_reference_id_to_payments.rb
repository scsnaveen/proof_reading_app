class AddReferenceIdToPayments < ActiveRecord::Migration[6.0]
  def change
  	add_column :payments,:reference_id,:string
  	add_column :payments,:payment_type,:string
  	add_column :transaction_histories,:user_id,:integer
  end
end
