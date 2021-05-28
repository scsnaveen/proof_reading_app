class CouponsController < ApplicationController
	# checking if admin or not for new and create
	before_action :authenticate_admin! ,only: [:new, :create]
	# checking if its super admin or not
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
		@coupon.save!
		redirect_to new_coupon_path,notice: "Coupon has been created"
	end
	# checking if it is super admin or not
	def authenticate_super_admin
		if current_admin.role == "Super Admin"
		else
			redirect_to root_path,alert: "You cannot create coupon"	
		end
	end

	private
	def coupon_params
		params.require(:coupon).permit(:code,:description,:coupon_type,:valid_from,:valid_until,:redemption_limit,:amount,:percentage)
	end
end
