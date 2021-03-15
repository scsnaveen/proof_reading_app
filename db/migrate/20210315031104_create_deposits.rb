class CreateDeposits < ActiveRecord::Migration[6.0]
  def change
    create_table :deposits do |t|
        t.references :user, null: false, foreign_key: true
        t.decimal :amount, :precision => 32, :scale => 16 , null: false
        t.string :status
        
      t.timestamps
    end
  end
end
