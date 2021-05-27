class AddHoldAmountToWallet < ActiveRecord::Migration[6.0]
  def change
  	add_column :wallets,:hold_amount,:decimal
  end
end
