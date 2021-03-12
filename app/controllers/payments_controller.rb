class PaymentsController < ApplicationController
	before_action :authenticate_user!
	def index
		@payments = current_user.payments
	end
	def new
		@post =Post.find(params[:id])
		@payment = Payment.new()
	end
	# payment for post 
	def create
		@post = Post.find(params[:id])
		@user_wallet = Wallet.find_by(user_id:@post.user_id)
		@coupon = Coupon.find_by(code:params[:coupon_code])
		coupon_redemption = CouponRedemption.find_by(coupon_id: @coupon.id)
		@user_wallet = Wallet.find_by(user_id:@post.user_id)
		@admin_wallet =Wallet.find_by(:admin_id=>1)

		# checking if coupon is present 
		if !@coupon.present?
			redirect_to payments_new_path(:id=> @post.id),alert: "Please give a valid coupon"
			return
		# if user already use the coupon it will raise an error
		elsif coupon_redemption.user_id.select{ |x| x == @post.user_id }.present? 
			redirect_to payments_new_path(:id=> @post.id),alert: "Coupon has been used"
			return
		# if user amount is less it will show an error
		elsif @user_wallet.balance < @post.words * @post.per_word_amount
			redirect_to payments_new_path(:id=> @post.id),alert: "There is no sufficient money"
			return
		# if entered expired coupon it will raise an error
		elsif  !DateTime.now.between?(@coupon.valid_from,@coupon.valid_until) 
			redirect_to payments_new_path(:id=> @post.id),alert: "Coupon has been expired "
			return
		# if coupon redemption count is  exceeded t will raise an error
		elsif @coupon.redemption_limit == @coupon.coupon_redemptions_count
			redirect_to payments_new_path(:id=> @post.id),alert: "Coupon has been expired "
			return
		else
			@payment                        = Payment.new
			@payment.user_id                = @post.user_id
			@payment.post_id                = @post.id
			@payment.amount                 = @post.words * @post.per_word_amount
			@payment.status                 = "pending"
			@payment.discount_id            = @coupon.id
			@payment.discount_amount        = @coupon.amount
			@payment.paid_amount            = @payment.amount - @payment.discount_amount
				@user_wallet.transaction do
					@user_wallet.with_lock do 
						@user_wallet.balance = @user_wallet.balance -  @payment.paid_amount 
						@user_wallet.save

						@admin_wallet.balance = @admin_wallet.balance + @payment.paid_amount 
						@admin_wallet.save
					end
				end
			coupon_redemption.user_id << @post.user_id
			coupon_redemption.update(params.permit(:user_id))
			@coupon.coupon_redemptions_count+=1
			@coupon.update(params.permit(:coupon_redemptions_count))
			@payment.status = "success"
			@payment.save
			redirect_to post_show_path(:id=>@post.id),notice: "Payment successful"
			# sending mail to admin after successful payment
			UserMailer.admin_notify_email(@post.user_id).deliver
		end
	end
	
	def coupon_verification
		result =nil
		if params[:code].present?
			coupon =Coupon.find_by("code = ?",params[:code])
			if coupon.present?
			result = coupon.amount
		end
		  return result
		end
	end
	def admin_payment
		@post = Post.find(params[:id])
		@request = Request.find_by(post_id: @post.id)
		@admin_wallet = Wallet.find_by(admin_id:@request.accepted_admin)
		@super_admin_wallet =Wallet.find_by(:admin_id=>1)
			@payment                        = Payment.new
			@payment.admin_id                = Request.find_by(post_id: @post.id).accepted_admin
			@payment.post_id                = @post.id
			@payment.amount                 = @post.words * @post.per_word_amount - 
			@payment.status                 = "pending"
			@payment.paid_amount            = @payment.amount - 10
				@admin_wallet.transaction do
					@admin_wallet.with_lock do 
						@super_admin_wallet.balance = @super_admin_wallet.balance -  @payment.paid_amount 
						@super_admin_wallet.save

						@admin_wallet.balance = @admin_wallet.balance + @payment.paid_amount 
						@admin_wallet.save
					end
				end
			@payment.status = "success"
			@payment.save
	end
	def show 
		@payment = current_user.payments
	end
end

	 
