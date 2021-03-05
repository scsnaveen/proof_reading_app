class PostController < ApplicationController
	before_action :authenticate_user!
	def index
		puts current_user.posts.inspect
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
		UserMailer.admin_notify_mail(@post.user_id).deliver
	end
	
	def update 
		@post = Post.find(params[:id])
		@post.update_text
		@post.save
	end
	def show
		@post =Post.find(params[:id])
	end

	def post_params
		params.require(:post).permit(:text,:user_id,:words,:status)
	end
end
