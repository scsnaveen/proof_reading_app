module RailsAdmin
	module Config
		module Actions
			class PostRequests < RailsAdmin::Config::Actions::Base
				
				register_instance_option :visible? do
					authorized? 
				end
				# specific for post/Record
				register_instance_option :collection do
					true
				end
				#icon for PostRequests
				register_instance_option :link_icon do
					'fa fa-reply'
				end
				#pjax to false because we don't need pjax for this action
				register_instance_option :pjax? do
					false
				end
				register_instance_option :http_methods do
					[:get,:post,:put]
				end
				register_instance_option :controller do
					Proc.new do
						@requests = Request.where("admin_id = ? AND status=?",current_admin.id,"pending")
						# @posts = Post.where(status: "pending") 
						if request.post?|| request.put?
							@post = Post.find(params[:id])
							if !Request.where("post_id=? AND status=?",@post.id,"reserved").first.present?
								# verifying if any pending requests are present
								@requests = Request.where("admin_id = ? AND status=?",current_admin.id,"reserved")
						
								# if pending request present
								if @requests.present?
									flash[:alert]= "You already have pending tasks"
									redirect_to dashboard_path
									# if pending requests not present
								else
									@post = Post.find(params[:id])
									@request = Request.where("post_id=? AND admin_id=?",@post.id,current_admin.id).first
									@request.status = "reserved"
									current_admin.admin_status ="Busy"
									current_admin.save
									@request.save
									flash[:notice]= "You accepted the request"
									redirect_to dashboard_path
								end
							else
								flash[:alert]= "This post is already reserved"
								redirect_to dashboard_path
							end
						end
					end#Proc.new do
				end
			end#PostRequests
		end#Actions
	end#Config
end#RailsAdmin