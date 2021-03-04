class CreateWallets < ActiveRecord::Migration[6.0]
  def change
    create_table :wallets do |t|
    	t.decimal :balance, {:default => 100}
     	t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
