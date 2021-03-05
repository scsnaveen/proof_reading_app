class UserMailer < ApplicationMailer
	#welcome mailer for the user after confirmation
	def welcome_email(user)
		@user = user
		mail(:from =>"railschecking@gmail.com",to: @user.email, subject: "Welcome!")
	end
	#admin notification mail after user post
	def admin_notify_mail(user_id)
		puts user_id.inspect
		@user = User.find(user_id)
		@admin = Admin.find_by(:role =>"Super Admin" )
		mail(:from =>"railschecking@gmail.com",:to=> @admin.email, subject: "Post Notification")
	end
end
