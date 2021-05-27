class ChangeColumnInCouponRedemption < ActiveRecord::Migration[6.0]
  def change
  	remove_column :coupon_redemptions, :user_id, :integer,array: true ,default: []
  	add_column :coupon_redemptions, :user_id, :integer
  	remove_column :coupons,:coupon_redemptions_count,:integer
  	add_column :coupon_redemptions,:coupon_redemptions_count,:integer
  end
end
