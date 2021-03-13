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
						puts current_admin.inspect
						@accepted_requests = Request.where(accepted_admin: current_admin.id) 
						@rejected_requests = Request.where(status: "not satisified") if @accepted_requests
						@satisifed_requests = Request.where(status: "satisifed")
					end#Proc.new do
				end
			end#AcceptedRequests
		end#Actions
	end#Config
end#RailsAdmin