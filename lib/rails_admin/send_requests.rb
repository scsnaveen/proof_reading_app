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
				# specific for post/Record
				register_instance_option :member do
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
						if request.post?
							@post = Post.find(params[:id])
							@request = Request.new(params.permit(:post_id,:accepted_admin,:rejected_admin,:time_taken))
							@request.post_id = @post.id
							@request.save
							Admin.all.each do |admin|
								@admin =Admin.find(admin.id)
								UserMailer.new_post_admin_notify_email(@admin,@request).deliver
							end
						end
					end#Proc.new do
				end
			end#SendRequests
		end#Actions
	end#Config
end#RailsAdmin