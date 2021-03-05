module RailsAdmin
  module Config
    module Actions
      class PostRequests < RailsAdmin::Config::Actions::Base
        
        register_instance_option :visible? do
          authorized? 
        end
        # specific for user/Record
        register_instance_option :member do
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
        register_instance_option :controller do
          Proc.new do
            @posts = Post.where(status: "pending")   
          end#Proc.new do
        end
      end#PostRequests
    end#Actions
  end#Config
end#RailsAdmin