class CreateCoupons < ActiveRecord::Migration[6.0]
  def change
    create_table :coupons do |t|
      t.string :code
      t.string :description
      t.date :valid_from
      t.date :valid_until
      t.integer :redemption_limit, default: 1
      t.integer :coupon_redemptions_count, default: 0
      t.integer :amount, default: 0
      t.string :type
      t.timestamps


    create_table :coupon_redemptions do |t|
      t.belongs_to :coupon
      t.string :user_id,array: true, default: []
      t.timestamps
    end


    end
  end
end
