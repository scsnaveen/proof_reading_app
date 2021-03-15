class UserMailer < ApplicationMailer
	#welcome mailer for the user after confirmation
	def welcome_email(user)
		@user = user
		mail(:from =>"railschecking@gmail.com",to: @user.email, subject: "Welcome!")
	end
	#admin notification mail after user post
	def admin_notify_email(post)
		@post= Post.find(post.id)
		@admin = Admin.find_by(:role =>"Super Admin" )
		mail(:from =>"railschecking@gmail.com",:to=> @admin.email, subject: "Post Notification")
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
		@admin = Admin.find(@request.accepted_admin)
		mail(:from =>"railschecking@gmail.com",:to=> @admin.email, subject: "ProofReading Rejected")
	end
	# sending all admins that new post request is delivered
	def new_post_admin_notify_email(admin,request)
		@request = Request.find(request.id)
		@admin =Admin.find(admin.id)
     	mail(:from =>"railschecking@gmail.com",:to=> @admin.email, subject: "New Post request")
	end
	# sending mail for completed proofreading payment amount 
	def admin_payment_notify_email(payment)
		@payment = Payment.find(payment.id)
		@admin = Admin.find(@payment.admin_id)
		mail(:from =>"railschecking@gmail.com",:to=>@admin.email,subject: "Paid for proof reading")
	end
	def fined_for_rejection(post)
		@post = post.find(post.id)
		@admin = Admin.find_by(:role =>"Super Admin")
		mail(:from =>"railschecking@gmail.com",:to=>@admin.email,subject: "Paid for proof reading")
	end
end
