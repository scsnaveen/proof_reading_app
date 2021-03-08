#custom_action for post_requests
require Rails.root.join('lib', 'rails_admin', "post_requests.rb")
RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::PostRequests)
require Rails.root.join('lib', 'rails_admin', "proof_reading.rb")
RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::ProofReading)
require Rails.root.join('lib', 'rails_admin', "send_requests.rb")
RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::SendRequests)
require Rails.root.join('lib', 'rails_admin', "accepted_requests.rb")
RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::AcceptedRequests)
RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :admin
  end
  config.current_user_method(&:current_admin)

  ## == CancanCan ==
  config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
    post_requests do 
      visible do 
        bindings[:abstract_model].model.to_s == "Post"
      end
    end
    proof_reading do 
      visible do 
        bindings[:abstract_model].model.to_s == "Post"
      end
    end
    send_requests
    accepted_requests do 
      visible do 
        bindings[:abstract_model].model.to_s == "Post"
      end
    end


    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
