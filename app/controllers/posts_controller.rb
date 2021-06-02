class PostsController < ApplicationController
	before_action :authenticate_user!
	def index
		@posts = current_user.posts.order( 'id ASC' )
	end

	def new
		@post = Post.new
	end

	def create
		@post = Post.new(post_params)
		@post.user_id = current_user.id
		@post.words = @post.text.split(' ').size
		@post.per_word_amount =PaymentCharge.first.per_word_amount
		@user_wallet = current_user.wallet
		@amount = @post.words.to_f * @post.per_word_amount.to_f
		if @post.words > 1
			if @user_wallet.balance < @amount
				redirect_to posts_new_path,alert: "You don't have enough balance"
			else
				loop do 
				@payment_reference = ( "payment" + [*(0..9)].sample(10).join.to_s )
				break @payment_reference unless Payment.exists?(reference_id: @payment_reference)
				end
					@payment                        = Payment.new
					@payment.user_id                = @post.user_id
					@payment.amount                 = @amount
					@payment.status                 = "pending"
					@payment.reference_id           = @payment_reference
				@user_wallet.transaction do
					@user_wallet.with_lock do 
						@user_wallet.balance = @user_wallet.balance.to_f -  @amount 
						@user_wallet.save

						@user_wallet.hold_amount = @user_wallet.hold_amount.to_f + @amount
						@user_wallet.save
					end
				end
				# creating transaction history
				@transaction_history = TransactionHistory.new()
				@transaction_history.user_id = current_user.id
				@transaction_history.reference_id = @transaction_reference
				@transaction_history.status = "credited"
				@transaction_history.payment_id = @payment.reference_id
				@transaction_history.current_wallet_amount = @user_wallet.balance
				@transaction_history.save
				@post.save
				@payment.post_id = @post.id
				@payment.status = "success"
				@payment.paid_amount = @payment.amount
				@payment.save
				AdminMailer.admin_notify_email(@post).deliver rescue nil
				redirect_to payments_new_path(:id=>@post.id),notice: "Your post has been successfully saved"
			end
		else
			redirect_to posts_new_path,alert: "Please enter text"	
		end
	end

	# after user satisified with the updated_text
	def accept
		@post = Post.find(params[:id])
		@user_wallet = current_user.wallet
		@request = Request.where("post_id=? AND status=?",@post.id,"completed").first
		@user_payment =Payment.where("post_id=? AND user_id=?",@post.id,current_user.id).first
		# comparing two string words
		s1 = @post.text.split(' ')
		s2 = @post.updated_text.split(' ')
		diff = s2 - s1
		# getting count of different words
		@post.words =diff.count
		p @post.words.inspect
		# checking if coupon is present  
		if @user_payment.discount_id.present?
			@coupon = Coupon.find(@user_payment.discount_id) 
			@coupon_redemption = CouponRedemption.where("coupon_id =? AND user_id=?", @coupon.id,current_user.id).first
			loop do 
				@payment_reference = ( "success" + [*(0..9)].sample(10).join.to_s )
				break @payment_reference unless Payment.exists?(reference_id: @payment_reference)
			end
			# user return payment
			@payment                  = Payment.new()
			@payment.amount           = @post.words * PaymentCharge.first.per_word_amount.to_f
			@payment.reference_id     = @payment_reference
			@payment.status           = "refund"
			@payment.user_id          = current_user.id
			@payment.post_id          = @post.id
			@payment.discount_id      = @coupon.id
			@payment.payment_type     = "debited"
			# if coupon type is percentage
			if @coupon.coupon_type == "percentage"
				# if payment amount is greater than coupon amount
				if @payment.amount.to_f > @coupon.amount.to_f
					percentage_amount = @payment.amount.to_f/100.0 * @coupon.percentage.to_f
					# if coupon percentage amount is greater than coupon limit amount
					if percentage_amount > @coupon.amount.to_f
						@payment.discount_amount  = @coupon.amount.to_f
					else
						@payment.discount_amount = percentage_amount.to_f
					end
				else
					@payment.discount_amount = @payment.amount.to_f
				end
			else
				if  @payment.amount.to_f > @coupon.amount.to_f
					@payment.discount_amount  = @coupon.amount.to_f
				else
					@payment.discount_amount  = @payment.amount.to_f
				end
			end
			@user_return_amount        = @user_payment.paid_amount.to_f - @payment.amount.to_f + @payment.discount_amount.to_f
			@payment.amount            = @user_payment.paid_amount.to_f - @user_return_amount.to_f
			@payment.paid_amount       = @user_return_amount.to_f
			@balance_amount            = @user_payment.paid_amount.to_f - @user_return_amount.to_f
			@user_wallet               = User.find(@post.user_id).wallet
			@user_wallet.transaction do
				@user_wallet.with_lock do 
					@user_wallet.hold_amount = @user_wallet.hold_amount.to_f -  @user_return_amount.to_f
					@user_wallet.save

					@user_wallet.balance = @user_wallet.balance.to_f + @user_return_amount.to_f
					@user_wallet.save
				end
			end
			@payment.save

			# user paid amount
			@payment1                  = Payment.new()
			@payment1.amount           = @payment.amount
			@payment1.reference_id     = @payment_reference
			@payment1.status           = "completed"
			@payment1.user_id          = current_user.id
			@payment1.post_id          = @post.id
			@payment1.discount_id      = @coupon.id
			@payment1.payment_type     = "credited"
			@payment1.discount_amount   = @payment.discount_amount
			@payment1.paid_amount       = @payment.amount
			@payment1.save

			# payment for super admin commission to successful proof reading 
			@super_admin_payment               = Payment.new()
			@super_admin_payment.admin_id      = Admin.find_by(:role=>"Super Admin").id
			@super_admin_payment.amount        = (PaymentCharge.first.commission_percentage.to_f / 100 * @payment.amount.to_f).round(2)
			@super_admin_payment.reference_id  = @payment_reference
			@super_admin_payment.status        = "completed"
			@super_admin_payment.post_id       = @post.id
			@super_admin_payment.paid_amount   = @super_admin_payment.amount
			@super_admin_wallet                = Admin.find_by(:role=>"Super Admin").wallet
			@super_admin_wallet.transaction do
					@super_admin_wallet.with_lock do 
						@user_wallet.hold_amount = @user_wallet.hold_amount.to_f -  @super_admin_payment.paid_amount.to_f
						@user_wallet.save

						@super_admin_wallet.balance = @super_admin_wallet.balance.to_f + @super_admin_payment.paid_amount.to_f
						@super_admin_wallet.save
					end
				end
			@super_admin_payment.save
			
			# payment for proofreader amount 
			@payment2               = Payment.new()
			@payment2.admin_id      = @request.admin_id
			@payment2.amount        = @payment.amount.to_f - @super_admin_payment.paid_amount.to_f
			@payment2.reference_id  = @payment_reference
			@payment2.status        = "completed"
			@payment2.post_id       = @post.id
			@payment2.paid_amount   = @payment2.amount
			@admin_wallet          = Admin.find(@request.admin_id).wallet
			@admin_wallet.transaction do
				@admin_wallet.with_lock do 
					@user_wallet.hold_amount = @user_wallet.hold_amount.to_f -  @payment2.paid_amount.to_f
					@user_wallet.save

					@admin_wallet.balance = @admin_wallet.balance.to_f + @payment2.paid_amount.to_f
					@admin_wallet.save
				end
			end
			@payment2.save
			@post.status ="completed"
			@post.save
			@request.status="completed"
			@request.save
			redirect_to posts_index_path,notice: "Thank you ,Please visit again"
		else
			flash[:alert]="Enter valid coupon code"
			redirect_to payments_new_path(:id=>@post.id)	
		end
	end

	# if user rejected the updated text
	def reject
		@post =Post.find(params[:id])
		@request =Request.find_by(post_id: @post.id)
	end

	#  reason for the rejection of updated text
	def rejected_request
		@post =Post.find(params[:id])
		@request = Request.where("post_id=? AND status=?", @post.id,"completed").first
		if params[:reason].blank?
			flash[:alert]="Please provide the reason"
			redirect_to posts_reject_path(id:@post.id) 
		else
			@request.reason = params[:reason]
			@request.status = "reserved"
			@request.update(params.permit(:reason,:status))
			UserMailer.post_rejected_email(@request).deliver
			redirect_to posts_index_path
		end
	end

	# displaying the post
	def show
		@post =Post.find(params[:id])
		@request = Request.where("post_id=? AND status=?",@post.id,"completed").first
	end
	# using to calculate the total amount
	def total_amount
		@result = (params[:words].to_i*PaymentCharge.first.per_word_amount).to_i
		respond_to do |format|
			format.html
			format.json {render :json=>@result}
		end
	end
	# invoice for the post
	def invoice
		@post = Post.find(params[:id])
		@request= Request.find_by(post_id:@post.id)
		@payment = Payment.find_by("user_id = ? AND post_id = ? AND status = ?",@post.user_id,@post.id,"success")
		@payment1 = Payment.find_by("user_id = ? AND post_id = ? AND status = ?",@post.user_id,@post.id,"completed")
		respond_to do |format|
			format.html
            format.pdf do
               render pdf: "invoice",
                template: "posts/_form.html.erb",
                layout: "pdf.html",
                disposition: 'attachment'
            end
        end
	end

	def post_params
		params.require(:post).permit(:text,:user_id,:words,:status,:updated_text,:per_word_amount,:reason)
	end
end
