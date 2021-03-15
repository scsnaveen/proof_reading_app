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
					[:get,:post]
				end
				register_instance_option :controller do
					Proc.new do
						@post = Post.find(params[:id])
						@request = Request.find_by(post_id: @post.id)
						if request.post?
						@post = Post.find(params[:id])
						@payment = Payment.new()
						@payment.admin_id = current_admin.id
						@payment.amount = 25
						@payment.status = "fined"
						@payment.post_id = @post.id
						@payment.paid_amount = 25
						@rejected_admin_wallet = Wallet.find_by(admin_id: current_admin.id)
						@admin_wallet =Wallet.find_by(:admin_id=>1)
						if @rejected_admin_wallet.balance < @payment.amount
							redirect_to payments_new_path(:id=> @post.id),alert: "There is no sufficient money"
						else
						@rejected_admin_wallet.transaction do
							@rejected_admin_wallet.with_lock do 
								@rejected_admin_wallet.balance = @rejected_admin_wallet.balance -  @payment.amount
								@rejected_admin_wallet.save

								@admin_wallet.balance = @admin_wallet.balance + @payment.amount
								@admin_wallet.save
							end
						end
						@request.accepted_admin = nil
						@request.status = nil
						@request.rejected_admin << @payment.admin_id
						@request.update(params.permit(:rejected_admin,:status))
						@post.status = "pending"
						@post.save
						@payment.save!
						UserMailer.fined_for_rejection(@post).deliver
					end
					end
					end#Proc.new do
				end
			end#RejectingRequest
		end#Actions
	end#Config
end#RailsAdmin