class ApplicationController < ActionController::Base
	protect_from_forgery with: :null_session
	# after sign in path for user and admin
	def after_sign_in_path_for(resource)
		stored_location_for(resource) ||
		if resource.is_a?(User)
			root_path
		elsif resource.is_a?(Admin)
			rails_admin_path
		else
			root_path
		end
	end

end
