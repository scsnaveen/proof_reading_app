class PaymentsController < ApplicationController
	before_action :authenticate_user!
	def new
		@post =Post.find(params[:id])
		puts @post.inspect 

		@request = Request.find_by(post_id: @post.id)
		@payment = Payment.new()
	end

	def create
		@post = Post.find(params[:id])
		@request = Request.find(params[:id])
		@user_wallet = Wallet.find(@post.user_id)
		if @request.amount > @user_wallet.amount
			flash[:alert] ="There was no sufficient money"
			redirect_to post_index_path
		return
		@payment                    = Payment.new
		@payment.user_id                = @post.user_id
		@payment.amount                   = @request.amount
		@payment.status                 = "pending"
		@payment.discount_amount          = @discount_amount
		@payment.paid_amount            = @amount.to_f - @discount_amount.to_f
			@user_wallet = Wallet.find(@post.user_id)
			@admin_wallet =Wallet.where(:admin_id=>1)
			@user_wallet.transaction do
				@user_wallet.with_lock do 
					@user_wallet.balance = @user_wallet.balance -  @payment.paid_amount 
					@user_wallet.save

					@admin_wallet.balance = @admin_wallet.balance + @payment.paid_amount 
					@admin_wallet.save
				end
			end
		payment.status = "success"
		payment.amount =@payment.paid_amount 
		payment.save
		flash.now[:notice] ="Payment successful"
		UserMailer.invoice(@payment,@post).deliver
	end
	end
	def fine
		@post = Post.find(params[:id])
		@payment = Payment.new
		@payment.admin_id = current_admin.id
		@payment.amount = 25
		@payment.status = "fined"
		@payment.user_id = User.find(@post.user_id)
		@user_wallet.transaction do
				@user_wallet.with_lock do 
					@user_wallet.balance = @user_wallet.balance -  @amount
					@user_wallet.save

					@admin_wallet.balance = @admin_wallet.balance + @amount
					@admin_wallet.save
				end
			end
	end
	def show 
		@payment = Payment.find(params[:id])
	end
end

	 
