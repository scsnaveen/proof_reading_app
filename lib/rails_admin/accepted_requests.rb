module RailsAdmin
	module Config
		module Actions
			class AcceptedRequests < RailsAdmin::Config::Actions::Base
				
				register_instance_option :visible? do
					authorized? 
				end
				# specific for post/Record
				register_instance_option :collection do
					true
				end
				#icon for AcceptedRequests
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
						@accepted_requests = Request.where("admin_id=? AND status=?", current_admin.id,"reserved") 
						@completed_requests = Request.where("admin_id=? AND status=?", current_admin.id,"completed") 
					end#Proc.new do
				end
			end#AcceptedRequests
		end#Actions
	end#Config
end#RailsAdmin