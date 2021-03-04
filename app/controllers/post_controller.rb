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
		@post.words = @post.text.scan(/[\w-]+/).size
		@post.save
		redirect_to post_new_path,notice: "Your post has been successfully saved"
		UserMailer.admin_notify_mail(@post.user_id).deliver
	end
	def post_params
		params.require(:post).permit(:text,:user_id,:words,:status)
	end
end
