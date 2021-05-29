class PaymentsController < ApplicationController
	before_action :authenticate_user!,except: [:admin_payments]
	before_action :authenticate_admin! ,only: [:admin_payments]
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
		@payment = Payment.where(post_id:@post.id,user_id:current_user.id).first
		@coupon = Coupon.find_by(code:params[:coupon_code]) 
		@coupon_redemption = CouponRedemption.where("coupon_id =? AND user_id=?", @coupon.id,current_user.id).first
		# checking if coupon is present  
		if @coupon.present?
			# if entered expired coupon it will raise an error
			if  !DateTime.now.between?(@coupon.valid_from,@coupon.valid_until) 
				redirect_to payments_new_path(:id=> @post.id),alert: "Coupon has been expired "
				return
			end
			#checking if that user redemption is present or else creating one 
			if !@coupon_redemption.present?
				@coupon_redemption = CouponRedemption.new
				@coupon_redemption.coupon_id = @coupon.id
				@coupon_redemption.user_id = current_user.id
				@coupon_redemption.coupon_redemptions_count = 0
				@coupon_redemption.save
			end
			@payment.discount_id            = @coupon.id 
			@payment.save
			@coupon_redemption.coupon_redemptions_count+=1
			@coupon_redemption.save
			redirect_to posts_show_path(:id=>@post.id),notice: "Applied coupon successful"
		else
			flash[:alert]="Enter valid coupon code"
			redirect_to payments_new_path(:id=>@post.id)	
		end
	end
	# coupon verification if coupon is present or not
	def coupon_verification
		@result = "not"
		amount = params[:tot_amount]
		if params[:code].present?
			coupon =Coupon.find_by("code = ?",params[:code])
				if coupon.present?
					if coupon.coupon_type =="percentage"
						@result = {
							:percentage=>coupon.percentage,
							:total_amount=> (amount.to_f/100 * coupon.percentage.to_f).ceil(0),
							:symbol=>"%"
						}
					else
						@result = {
						:percentage=>coupon.amount,
						:total_amount=> coupon.amount,
						:symbol=>"Rs"
					}

					end
				else
					@result = "Not a valid coupon"
				end
		end
		respond_to do |format|
			format.html
			format.json {render :json=>@result}
		end
	end

	def extra_payment
		@post = Post.find(params[:id])
		payment = Payment.find_by("user_id = ? AND post_id = ?",@post.user_id,@post.id)
		words = @post.updated_text.split(' ').size
		@user_wallet = Wallet.find_by(user_id:@post.user_id)
		amount = words * @post.per_word_amount
		@admin_wallet =Wallet.find_by(:admin_id=>1)
		if @user_wallet.balance < payment.paid_amount - amount
			redirect_to payments_new_path(:id=> @post.id),alert: "There is no sufficient money"
			return
		else
			loop do 
				@payment_reference = ( "payment" + [*(0..9)].sample(10).join.to_s )
				break @payment_reference unless Payment.exists?(reference_id: @payment_reference)
			end
			@payment                        = Payment.new
			@payment.user_id                = @post.user_id
			@payment.post_id                = @post.id
			@payment.reference_id           = @payment_reference
			@payment.amount                 =  payment.paid_amount - amount
			@payment.status                 = "pending"
			@payment.paid_amount            = @payment.amount - @payment.discount_amount
				@user_wallet.transaction do
					@user_wallet.with_lock do 
						@user_wallet.balance = @user_wallet.balance -  @payment.paid_amount 
						@user_wallet.save

						@admin_wallet.balance = @admin_wallet.balance + @payment.paid_amount 
						@admin_wallet.save
					end
				end
			@payment.status = "success"
			@payment.save
			loop do 
					@transaction_reference = ( "transaction" + [*(0..9)].sample(10).join.to_s )
					break @transaction_reference unless TransactionHistory.exists?(reference_id: @transaction_reference)
				end
			@transaction_history = TransactionHistory.new()
			@transaction_history.user_id = current_user.id
			@transaction_history.reference_id = @transaction_reference
			@transaction_history.status = "credited"
			@transaction_history.current_wallet_amount = @user_wallet.balance
			@transaction_history.save
			AdminMailer.extra_payment(@payment).deliver
		end
	end
	def show 
		@payment = Payment.find_by(post_id:params[:post_id])
	end
	def admin_payments
		@payments = Payment.where(admin_id: current_admin.id)
	end
end

	 
