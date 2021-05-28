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
				AdminMailer.admin_notify_email(@post).deliver
				redirect_to payments_new_path(:id=>@post.id),notice: "Your post has been successfully saved"
			end
		else
			redirect_to posts_new_path,alert: "Please enter text"	
		end
	end

	# after user satisified with the updated_text
	def accept
		@post = Post.find(params[:id])
		@post.status ="completed"
		@post.save
		@request = Request.find_by(post_id: @post.id)
		@request.status="completed"
		@request.reason = params[:reason]
		@request.update(params.permit(:reason,:status))
		redirect_to posts_index_path,notice: "Thank you ,Please visit again"
	end

	# if user rejected the updated text
	def reject
		@post =Post.find(params[:id])
		@request =Request.find_by(post_id: @post.id)
	end

	#  reason for the rejection of updated text
	def rejected_request
		@post =Post.find(params[:id])
		@request = Request.find_by(post_id: @post.id)
		if params[:reason].blank?
			flash[:alert]="Please provide the reason"
			redirect_to posts_reject_path(id:@post.id) 
		else
			@request.reason = params[:reason]
			@request.status = "not satisified"
			@request.update(params.permit(:reason,:status))
			UserMailer.post_rejected_email(@request).deliver
			redirect_to posts_index_path
		end
	end

	# displaying the post
	def show
		@post =Post.find(params[:id])
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
		@payment = Payment.find_by("user_id = ? AND post_id = ?",@post.user_id,@post.id)
	end

	def post_params
		params.require(:post).permit(:text,:user_id,:words,:status,:updated_text,:per_word_amount,:reason)
	end
end
