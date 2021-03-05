module RailsAdmin
  module Config
    module Actions
      class ProofReading < RailsAdmin::Config::Actions::Base
        
        register_instance_option :visible? do
          authorized? 
        end
        # specific for user/Record
        register_instance_option :member do
          true
        end
        #icon for ProofReading
        register_instance_option :link_icon do
          'fa fa-exclamation'
        end
        #pjax to false because we don't need pjax for this action
        register_instance_option :pjax? do
          false
        end
        register_instance_option :controller do
          Proc.new do
            @post =Post.find(params[:id])
            @post.updated_text = params[:updated_text]
            
          end#Proc.new do
        end
      end#ProofReading
    end#Actions
  end#Config
end#RailsAdmin