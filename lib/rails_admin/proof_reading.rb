
module RailsAdmin
	module Config
		module Actions
			class ProofReading < RailsAdmin::Config::Actions::Base
				
				register_instance_option :visible? do
					authorized? 
				end
					register_instance_option :show_in_menu do
					false
				end
				# specific for post/Record
				register_instance_option :member do
					true
				end
				#icon for ProofReading
				register_instance_option :link_icon do
					'fa fa-exclamation'
				end
				#pjax to false because we don't need pjax for this action
				register_instance_option :pjax? do
					true
				end
				register_instance_option :http_methods do
					[:get,:put, :post]
				end
				register_instance_option :controller do
					Proc.new do
						if @request =Request.where("admin_id=? AND status=?",current_admin,"reserved")
							if request.get?
							@post = Post.find(params[:id])
							@request = Request.find_by(post_id: @post.id)
							@request.save
						end
							if request.post? || request.put?
								@post = Post.find(params[:id])
								@request = Request.find_by(post_id: @post.id)
								end_time =Time.now.to_formatted_s(:number)
								start_time = @request.start_time.to_formatted_s(:number)
								time = end_time.to_i - start_time.to_i
								@post.status = "edited"
								@request.time_taken += time
								@request.update_attributes(params.permit(:time_taken))
								@post.update_attributes(params.require(:post).permit(:updated_text,:status))
								redirect_to dashboard_path
								UserMailer.user_notify_email(@post.user_id).deliver_now rescue nil
							end
						end
						
					end#Proc.new do
				end
			end#ProofReading
		end#Actions
	end#Config
end#RailsAdmin