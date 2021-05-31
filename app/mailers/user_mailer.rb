class UserMailer < ApplicationMailer
	#welcome mailer for the user after confirmation
	def welcome_email(user)
		@user = user
		mail(:from =>"railschecking@gmail.com",to: @user.email, subject: "Welcome!")
	end
	#user notification after proof reading completed
	def user_notify_email(user_id)
		@user = User.find(user_id)
		@admin = Admin.find_by(:role =>"Super Admin" )
		mail(:from =>"railschecking@gmail.com",:to=> @user.email, subject: "ProofReading Completed")
	end
	#after post has been rejected by user sending to admin notification
	def post_rejected_email(request)
		@request = Request.find(request.id)
		@admin = Admin.find(@request.admin_id)
		mail(:from =>"railschecking@gmail.com",:to=> @admin.email, subject: "ProofReading Rejected")
	end
	#after extra payment received
	def extra_payment(payment)
		@user = User.find(payment.user_id)
		mail(:from =>"railschecking@gmail.com",:to=> @user.email, subject: "Payment details")
	end
	
end
