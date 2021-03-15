class Deposit < ApplicationRecord
	belongs_to :user
	 validate :validation
	after_update :update_balance 
	def update_balance
		@wallet = self.user.wallet
		if self.status=="approved"
			@wallet.transaction do
				@wallet.with_lock do 
					@wallet.balance = @wallet.balance+self.amount 
					@wallet.save
					self.user.wallet.balance
				end
			end
		end
	end

	private def validation
		if  status_was.eql?"approved" or status_was.eql?"rejected"
			errors.add(:status,"you have already updated") 
		end
	end
end
