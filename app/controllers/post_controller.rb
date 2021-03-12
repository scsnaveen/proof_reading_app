class PostController < ApplicationController
	before_action :authenticate_user!
	def index
		@posts = current_user.posts
	end

	def new
		@post = Post.new
	end

	def create
		@post = Post.new(post_params)
		@post.user_id = current_user.id
		@post.words = @post.text.split(' ').size
		@post.save
		redirect_to payments_new_path(:id=>@post.id),notice: "Your post has been successfully saved"		
	end

	# after user satisified with the updated_text
	def accept
		@post = Post.find(params[:id])
		@post.status ="completed"
		@request = Request.find_by(post_id: @post.id)
		@request.status="completed"
		@request.reason = params[:reason]
		@request.update(params.permit(:reason,:status))
		redirect_to post_index_path,notice: "Thank you ,Please visit again"
	end

	# if user rejected the updated text
	def reject
		@post =Post.find(params[:id])
		@request =Request.find_by(post_id: @post.id)
	end

	#  reason for the rejection of updated text
	def rejected_request
		@post =Post.find(params[:id])
		@request = Request.find_by(post_id: @post.id)
		if params[:reason].blank?
			flash[:alert]="Please provide the reason"
			redirect_to post_reject_path(id:@post.id) 
		else
			@request.reason = params[:reason]
			@request.status = "not satisified"
			@request.update(params.permit(:reason,:status))
			UserMailer.post_rejected_email(@request).deliver
			redirect_to post_index_path
		end
	end

	# displaying the post
	def show
		@post =Post.find(params[:id])
	end
	def total_amount
			result = params[:words].to_i*params[:per_word_amount].to_i
			
	end

	def post_params
		params.require(:post).permit(:text,:user_id,:words,:status,:updated_text,:per_word_amount,:reason)
	end
end
