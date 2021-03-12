class CouponsController < ApplicationController
	before_action :authenticate_admin! ,only: [:new, :create]
	before_action :authenticate_super_admin ,only: [:new, :create]
	#coupons displaying for the user
	def index

		@coupons= Coupon.all
	end
	# adding a new coupon
	def new
		@coupon =Coupon.new()
	end
	# creating a new coupon and coupon redemption
	def create
		@coupon =Coupon.new(coupon_params)
		@coupon.save
		@coupon_redemption = CouponRedemption.new
		@coupon_redemption.coupon_id = @coupon.id
		@coupon_redemption.save
	end
	def authenticate_super_admin
		if current_admin.role == "Super Admin"
		else
			redirect_to root_path,alert: "You cannot create coupon"	
		end
	end

	private
	def coupon_params
		params.require(:coupon).permit(:code,:description,:valid_from,:valid_until,:redemption_limit,:coupon_redemptions_count,:amount)
	end
end