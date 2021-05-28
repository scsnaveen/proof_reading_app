class AdminMailer < ApplicationMailer
	#admin notification mail after user post
	def admin_notify_email(post)
		@post= Post.find(post.id)
		@admin = Admin.find_by(:role =>"Super Admin" )
		mail(:to=> @admin.email, subject: "Post Notification")
	end
	# sending mail for completed proofreading payment amount 
	def admin_payment_notify_email(payment)
		@payment = Payment.find(payment.id)
		@admin = Admin.find(@payment.admin_id)
		mail(:from =>"railschecking@gmail.com",:to=>@admin.email,subject: "Paid for proof reading")
	end
	def fined_for_rejection(post)
		@post = Post.find(post.id)
		@admin = Admin.find_by(:role =>"Super Admin")
		mail(:from =>"railschecking@gmail.com",:to=>@admin.email,subject: "Paid for proof reading")
	end
	# sending all ProofReaders that new post request is delivered
	def new_post_admin_notify_email(admin,request)
		@request = Request.find(request.id)
		@admin =Admin.find(admin)
		mail(:from =>"railschecking@gmail.com",:to=> @admin.email, subject: "New Post request")
	end
end
