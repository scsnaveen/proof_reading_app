class CreatePaymentCharges < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_charges do |t|
    	t.decimal :per_word_amount,:precision => 32, :scale => 16
    	t.decimal :minimum_amount,:precision=> 32, :scale =>16

      t.timestamps
    end
  end
end
