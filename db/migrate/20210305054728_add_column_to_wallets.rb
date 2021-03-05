class AddColumnToWallets < ActiveRecord::Migration[6.0]
  def change
    add_column :wallets, :admin_id, :integer
    change_column_null :wallets, :user_id, true

  end
end
