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
		coupon_redemption = CouponRedemption.find_by(coupon_id: @coupon.id) rescue nil
		@admin_wallet =Wallet.find_by(:admin_id=>1)

		# if user amount is less it will show an error
		if @user_wallet.balance < @post.words * PaymentCharge.first.per_word_amount
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
				@payment.amount                 = @post.words * PaymentCharge.first.per_word_amount
				@payment.status                 = "pending"
				@payment.reference_id           = @payment_reference
				# checking if coupon is present  
				if @coupon.present?

					# if user already use the coupon it will raise an error
					if coupon_redemption.user_id.select{ |x| x == @post.user_id }.present? 
						redirect_to payments_new_path(:id=> @post.id),alert: "Coupon has been used"
					return
					# if coupon redemption count is  exceeded t will raise an error
					elsif @coupon.redemption_limit == @coupon.coupon_redemptions_count
					redirect_to payments_new_path(:id=> @post.id),alert: "Coupon has been expired "
					return
					# if entered expired coupon it will raise an error
					elsif  !DateTime.now.between?(@coupon.valid_from,@coupon.valid_until) 
						redirect_to payments_new_path(:id=> @post.id),alert: "Coupon has been expired "
						return
					else
						@payment.discount_id            = @coupon.id rescue nil
						@payment.discount_amount        = @coupon.amount rescue nil
						@payment.paid_amount            = @payment.amount - @payment.discount_amount
					end
				else
					@payment.paid_amount = @payment.amount
				end
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
				@transaction_history.payment_id = @payment.reference_id
				@transaction_history.current_wallet_amount = @user_wallet.balance
				@transaction_history.save
				if @coupon.present?
					coupon_redemption.user_id << @post.user_id
					coupon_redemption.update(params.permit(:user_id))
					@coupon.coupon_redemptions_count+=1
					@coupon.update(params.permit(:coupon_redemptions_count))
				end
				redirect_to post_show_path(:id=>@post.id),notice: "Payment successful"
				# sending mail to admin after successful payment
				AdminMailer.admin_notify_email(@post).deliver
				
		end
	end
	# coupon verification if coupon is present or not
	def coupon_verification
		@result =nil
		if params[:code].present?
			coupon =Coupon.find_by("code = ?",params[:code])
			if coupon.present?
				@result = coupon.amount
			end
		end
		respond_to do |format|
    		format.html
    		format.json {render :json=>@result}
  		end
	end
	def tot_amount
		puts @result.inspect
		puts params[:amount].inspect
		value = params[:amount]- @result
		respond_to do |format|
    		format.html
    		format.json {render :json=>value}
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
	def admin_payment_histories
		@payments = Payment.where(admin_id: current_admin.id)
	end
end

	 
