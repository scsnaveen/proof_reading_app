class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
    	t.references :user, null: false, foreign_key: true
    	t.decimal :amount, :precision => 32, :scale => 16 , null: false
    	t.decimal :paid_amount, :precision => 32, :scale => 16 , null: false
    	t.string :status
    	t.integer :post_id,null: false
    	t.integer :discount_id
    	t.decimal :discount_amount


      t.timestamps
    end
  end
end
