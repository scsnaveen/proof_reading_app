class DepositsController < ApplicationController
	def index
		@deposits = current_user.deposits
	end
	def new
		@deposit = Deposit.new
	end
	
	def create
		if current_user.deposits.where("status = ?","pending").present?
			redirect_to deposit_new_path
			flash[:alert] ="You have pending request, please wait for some time"
		else
			deposit = Deposit.new
			deposit.amount = params[:amount]
			deposit.status = "pending"
			deposit.user_id =current_user.id
			deposit.save
			redirect_to deposits_new_path
			flash[:notice] ="Successfully Requested deposit"
		end				
	end

	def update
		@deposit = Deposit.find(params[:id])
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
