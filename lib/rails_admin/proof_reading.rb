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
						if request.get?
							@post = Post.find(params[:id])
							@request = Request.where("admin_id=? AND post_id=? AND status=?",current_admin.id, @post.id,"reserved").first
						end
						if request.put?
							@post = Post.find(params[:id])
							@request = Request.where("post_id=? AND status=?", @post.id,"reserved").first
							# getting time and splitting
							time_split = params[:time1].split(":") rescue nil
							#converting the time taken to integer
							time_taken = time_split[0].to_i*3600 + time_split[1].to_i * 60 + time_split[2].to_i rescue 0
							if @request.time_taken.present?
								@request.time_taken += time_taken
							else
								@request.time_taken = time_taken rescue nil
							end
							@request.save
							@post.update_attributes(params.permit(:updated_text))
							flash[:notice]="Proof reading post is saved"
							redirect_to dashboard_path
						end
						if request.post? 
							@post = Post.find(params[:id])
							@request = Request.where("admin_id=? AND post_id=?",current_admin.id, @post.id).first
							if params[:time1].present?
								# getting time and splitting
								time_split = params[:time1].split(":") rescue nil
								#converting the time taken to integer
								time_taken = time_split[0].to_i*3600 + time_split[1].to_i * 60 + time_split[2].to_i rescue 0
								if @request.time_taken.present?
									@request.time_taken += time_taken
								else
									@request.time_taken = time_taken
								end
							end
							@request.status ="completed"
							@request.save
							@post.status = "edited"
							@post.update_attributes(params.permit(:updated_text,:status))
							current_admin.admin_status ="not busy"
							current_admin.save 
							flash[:notice]="Proof reading post is saved and completed"
							redirect_to dashboard_path
							# UserMailer.user_notify_email(@post.user_id).deliver_now rescue nil
						end
						
					end#Proc.new do
				end
			end#ProofReading
		end#Actions
	end#Config
end#RailsAdmin