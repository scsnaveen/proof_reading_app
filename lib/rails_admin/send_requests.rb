module RailsAdmin
	module Config
		module Actions
			class SendRequests < RailsAdmin::Config::Actions::Base
				
				register_instance_option :visible? do
					true 
				end
				register_instance_option :show_in_menu do
					true 
				end
				# specific for Request/Record
				register_instance_option :collection do
					true
				end
				#icon for SendRequests
				register_instance_option :link_icon do
					'fa fa-reply'
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
						@posts = Post.where(status: "pending")
						# @requests = Request.find_by()
						if request.post?
							@post = Post.find(params[:id])
							@admins = Admin.where(role:"ProofReader")
							@admins.all.each do |admin|
							@request = Request.new
							@request.post_id = @post.id
							@request.admin_id = admin.id
							@request.status = "pending"
							@request.save
							AdminMailer.new_post_admin_notify_email(admin.id,@request).deliver_now
							end
						end
					end#Proc.new do
				end
			end#SendRequests
		end#Actions
	end#Config
end#RailsAdmin