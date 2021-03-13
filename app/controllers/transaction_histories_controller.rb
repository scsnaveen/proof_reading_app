class TransactionHistoriesController < ApplicationController
	before_action :authenticate_admin!
	def index
		@transaction_histories = TransactionHistory.all
	end
	def new
		@transaction_history = TransactionHistory.new
	end

	# creating a withdraw for admin
	def create
		@amount =params[:amount].to_f
		@wallet = current_admin.wallet
		# amount must be greater than wallet
		if @wallet.balance <  @amount
			redirect_to root_path,flash[:error]= "No Sufficient balance " 
			return
		else
			loop do 
				@transaction_reference = ( "transaction" + [*(0..9)].sample(10).join.to_s )
				break @transaction_reference unless TransactionHistory.exists?(reference_id: @transaction_reference)
			end
			@transaction_history = TransactionHistory.new
			@transaction_history.admin_id = current_admin.id
			@transaction_history.reference_id = @transaction_reference
			@transaction_history.status = "credited"
			@transaction_history.withdraw_amount = @amount
			@transaction_history.current_wallet_amount = @wallet.balance - @amount
			@transaction_history.save
		end
	end
end
