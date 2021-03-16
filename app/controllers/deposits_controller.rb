class DepositsController < ApplicationController
	def index
		@deposits = current_user.deposits
	end
	def new
		@deposit = Deposit.new
	end
	
	def create
		if current_user.deposits.where("status = ?","pending").present?
			redirect_to deposits_new_path
			flash[:alert] ="You have pending request, please wait for some time"
		else
			deposit = Deposit.new
			deposit.amount = params[:amount]
			deposit.status = "pending"
			deposit.user_id =current_user.id
			deposit.save
			redirect_to deposits_new_path
			flash[:notice] ="Successfully Requested deposit"
			loop do 
				@transaction_reference = ( "deposit" + [*(0..9)].sample(10).join.to_s )
				break @transaction_reference unless TransactionHistory.exists?(reference_id: @transaction_reference)
			end
			@transaction_history = TransactionHistory.new()
			@transaction_history.user_id = current_user.id
			@transaction_history.reference_id = @transaction_reference
			@transaction_history.status = "pending"
			@transaction_history.current_wallet_amount = @user_wallet.balance
			@transaction_history.save
		end
	end

	def update
		@deposit = Deposit.find(params[:id])
		# @transaction_history = TransactionHistory.find_by(reference_id:)
		if status.present?
			@deposit.status = "approved"
			@deposit.save
		end
	end
	def destroy
		@deposit = Deposit.find(params[:id])
		@deposit.destroy
		flash[:alert]= "Deposit successfully deleted"
		redirect_to deposits_new_path
	end
end
