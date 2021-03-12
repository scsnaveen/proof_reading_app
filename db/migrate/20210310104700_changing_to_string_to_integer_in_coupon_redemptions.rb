class ChangingToStringToIntegerInCouponRedemptions < ActiveRecord::Migration[6.0]
  def change
  		remove_column :coupon_redemptions,:user_id
  	  	add_column :coupon_redemptions, :user_id, :integer,array: true ,default: []
  end
end
