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
						@requests = Request.where(admin_id:current_admin.id) 
						# @posts = Post.where(status: "pending") 
						if request.post?|| request.put?
							arr =[]
							@requests = Request.where("accepted_admin = ?",current_admin.id)
							@requests.all.each do |request|
								arr <<request.status.blank?
							end
							if arr.include?(true)
								flash[:error]= "You already have pending tasks"
								redirect_to dashboard_path
							else
								@post = Post.find(params[:id])
								@post.status = "reserved"
								@request = Request.find_by(post_id:@post.id)
								@request.accepted_admin = current_admin.id
								@request.save
								@post.save
								
							end
						end
					end#Proc.new do
				end
			end#PostRequests
		end#Actions
	end#Config
end#RailsAdmin