require 'rails_admin/config/sections/update'
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
          [:get, :put]
        end
        register_instance_option :controller do
          Proc.new do
            if @request =Request.find_by(:accepted_admin=>current_admin)
              @post = Post.find(params[:id])
              @starting = Time.now
              if request.post? || request.put?
                @post.status = "edited"
                @ending = Time.now   
                time_taken = @ending - @starting
                # puts time_taken.inspect
                # @request.update_attributes(params.require(:request).permit(:time_taken))
                @post.update_attributes(params.require(:post).permit(:updated_text,:status))
                redirect_to dashboard_path
                UserMailer.user_notify_email(@post.user_id).deliver
              end
            end
            
          end#Proc.new do
        end
      end#ProofReading
    end#Actions
  end#Config
end#RailsAdmin