# payment to the completed posts for admins
module RailsAdmin
	module Config
		module Actions
			class AdminPayment < RailsAdmin::Config::Actions::Base
				
				register_instance_option :visible? do
					authorized? 
				end
				# specific for post/Record
				register_instance_option :collection do
					true
				end
				#icon for AdminPayment
				register_instance_option :link_icon do
					'fa fa-exclamation'
				end
				#pjax to false because we don't need pjax for this action
				register_instance_option :pjax? do
					false
				end
				register_instance_option :http_methods do
					[:get,:post]
				end
				register_instance_option :controller do
					Proc.new do
						@posts = Post.where(status: "completed")
						if request.post?
						@post = Post.find(params[:id])
						@request = Request.find_by(post_id: @post.id)
						@admin_wallet = Wallet.find_by(admin_id:@request.accepted_admin)
						@super_admin_wallet =Wallet.find_by(:admin_id=>1)
						loop do 
							@payment_reference = ( "adminpayment" + [*(0..9)].sample(10).join.to_s )
							break @payment_reference unless Payment.exists?(reference_id: @payment_reference)
						end
							@payment                        = Payment.new
							@payment.admin_id               = Request.find_by(post_id: @post.id).accepted_admin
							@payment.post_id                = @post.id
							@payment.reference_id           = @payment_reference
							@payment.amount                 = @post.words * @post.per_word_amount
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
								loop do 
									@transaction_reference = ( "adminpayment" + [*(0..9)].sample(10).join.to_s )
									break @transaction_reference unless TransactionHistory.exists?(reference_id: @transaction_reference)
								end
								@transaction_history = TransactionHistory.new
								@transaction_history.admin_id = current_admin.id
								@transaction_history.reference_id = @transaction_reference
								@transaction_history.status = "debited"
								@transaction_history.current_wallet_amount = @admin_wallet.balance
								@transaction_history.save
							@payment.status = "success"
							@payment.save
						AdminMailer.admin_payment_notify_email(@payment).deliver
						end
					end#Proc.new do
				end
			end#AdminPayment
		end#Actions
	end#Config
end#RailsAdmin