class AddColumnsToTransactionHistories < ActiveRecord::Migration[6.0]
  def change
  	rename_column :transaction_histories,:amount,:withdraw_amount
  	add_column :transaction_histories,:current_wallet_amount,:decimal
  	add_column :transaction_histories,:reference_id,:string
  	remove_column :transaction_histories,:post_id,:integer
  	remove_column :transaction_histories,:user_id,:integer
  end
end
