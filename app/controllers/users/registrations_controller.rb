# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
	 before_action :sign_up_params, only: [:create]
	 before_action :configure_account_update_params, only: [:update]

def new
		 @user = User.new
	end

	def create
		@user = User.new(sign_up_params)
		if @user.save
			Wallet.create :user_id => @user.id
			redirect_to new_user_session_path
		else
			render 'new'
		end
	end
	def sign_up_params
		params.require(:user).permit(:first_name, :last_name, :user_name, :email, :password, :password_confirmation,:phone_number)
	end

	# GET /resource/edit
	def edit
		super
	end

	# PUT /resource
	def update
		super
	end

	# DELETE /resource
	# def destroy
	#   super
	# end

	# GET /resource/cancel
	# Forces the session data which is usually expired after sign
	# in to be expired now. This is useful if the user wants to
	# cancel oauth signing in/up in the middle of the process,
	# removing all OAuth session data.
	# def cancel
	#   super
	# end

	# protected

	# If you have extra params to permit, append them to the sanitizer.
	# def configure_sign_up_params
	#   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
	# end

	# If you have extra params to permit, append them to the sanitizer.


	# The path used after sign up.
	def after_sign_up_path_for(resource)
		new_user_session_path
	end
	

	# The path used after sign up for inactive accounts.
	# def after_inactive_sign_up_path_for(resource)
	#   super(resource)
	# end
end
