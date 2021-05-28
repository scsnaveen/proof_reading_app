class ChangeColumnInCoupons < ActiveRecord::Migration[6.0]
  def change
  	rename_column :coupons,:type,:coupon_type
  	add_column :coupons,:percentage,:decimal
  	add_column :admins,:admin_status,:string,default: "not busy"
  end
end
