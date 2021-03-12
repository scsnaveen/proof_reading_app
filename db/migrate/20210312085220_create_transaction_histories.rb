class CreateTransactionHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :transaction_histories do |t|
    	t.integer :user_id
    	t.integer :post_id
    	t.integer :admin_id
    	t.string :payment_id
    	t.string :status
    	t.decimal :amount
      t.timestamps
    end
  end
end
