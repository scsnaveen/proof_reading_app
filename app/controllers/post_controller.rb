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
		redirect_to post_new_path,notice: "Your post has been successfully saved"
		UserMailer.admin_notify_email(@post.user_id).deliver
		
	end
	
	def reject
		@post =Post.find(params[:id])
		@request =Request.find_by(post_id: @post.id)
	end
	def rejected_request
		@post =Post.find(params[:id])
		@request = Request.find_by(post_id: @post.id)
		@request.reason = params[:reason]
		@request.status = "not satisified"
		@request.update(params.permit(:reason,:status))
		UserMailer.post_rejected_email(@request).deliver
		redirect_to post_index_path
	end
	def show
		@post =Post.find(params[:id])
	end

	def post_params
		params.require(:post).permit(:text,:user_id,:words,:status,:updated_text,:per_word_amount,:reason)
	end
end
