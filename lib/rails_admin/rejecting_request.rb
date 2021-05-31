module RailsAdmin
	module Config
		module Actions
			class RejectingRequest < RailsAdmin::Config::Actions::Base
				
				register_instance_option :visible? do
					true 
				end
				register_instance_option :show_in_menu do
					false 
				end
				# specific for post/Record
				register_instance_option :member do
					true
				end
				#pjax to false because we don't need pjax for this action
				register_instance_option :pjax? do
					false
				end
				register_instance_option :http_methods do
					[:get,:put,:post]
				end
				register_instance_option :controller do
					Proc.new do
						@post = Post.find(params[:id])
						@request = Request.where("post_id=? AND admin_id=?", @post.id,current_admin.id)
						# rejecting before accepting
						if request.put?
							@post = Post.find(params[:id])
							@request = Request.where("post_id=? AND admin_id=?", @post.id,current_admin.id).first
							@request.status = "rejected"
							@request.save
							flash[:alert]="The request is rejected"
							redirect_to dashboard_path
						end
						# rejecting after accepting
						if request.post?
							@post = Post.find(params[:id])
							@request = Request.where("post_id=? AND admin_id=?", @post.id,current_admin.id).first
							loop do 
								@payment_reference = ( "fine" + [*(0..9)].sample(10).join.to_s )
								break @payment_reference unless Payment.exists?(reference_id: @payment_reference)
							end
							# payment for prof reader fine
							@payment               = Payment.new()
							@payment.admin_id      = current_admin.id
							@payment.amount        = Payment.find_by(post_id:@post.id).paid_amount
							@payment.reference_id  = @payment_reference
							@payment.status        = "fined"
							@payment.post_id       = @post.id
							@payment.paid_amount   = PaymentCharge.first.fine_percentage / 100 * @payment.amount
							@rejected_admin_wallet = Wallet.find_by(admin_id: current_admin.id)
							if @rejected_admin_wallet.balance < @payment.paid_amount
								flash[:notice]= "There is no sufficient balance"
								redirect_to dashboard_path
							else
								# payment for fined amount credited amount to super admin
								@payment1               = Payment.new()
								@payment1.admin_id      = Admin.find_by(:role=>"Super Admin").id
								@payment1.amount        = @payment.amount
								@payment1.reference_id  = @payment_reference
								@payment1.status        = "fine received"
								@payment1.post_id       = @post.id
								@payment1.paid_amount   = @payment.paid_amount
								@admin_wallet          = Admin.find_by(:role=>"Super Admin").wallet
								@rejected_admin_wallet.transaction do
									@rejected_admin_wallet.with_lock do 
										@rejected_admin_wallet.balance = @rejected_admin_wallet.balance -  @payment.paid_amount
										@rejected_admin_wallet.save

										@admin_wallet.balance = @admin_wallet.balance + @payment.paid_amount
										@admin_wallet.save
									end
								end
								@request.status = "rejected"
								@request.save
								@payment.save
								@payment1.save
								# sending requests for admins who are not busy
								@admins = Admin.where("role=? AND admin_status=?","ProofReader","not busy")
								@admins.all.each do |admin|
									if !(Request.where("admin_id=? AND post_id=?",admin.id,@post.id).first.present?)
										@request = Request.new
										@request.post_id = @post.id
										@request.admin_id = admin.id
										@request.status = "pending"
										@request.save
										AdminMailer.new_post_admin_notify_email(admin.id,@request).deliver_now rescue nil
									end	
								end
								current_admin.admin_status="not busy"
								current_admin.save
								flash[:alert]="The request is rejected and collected amount of #{@payment.paid_amount}"
								redirect_to dashboard_path
							end
						end
					end#Proc.new do
				end
			end#RejectingRequest
		end#Actions
	end#Config
end#RailsAdmin