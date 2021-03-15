class User < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise	:database_authenticatable, :registerable,
					:recoverable, :rememberable, :validatable,
					:confirmable,:lockable,:trackable
	validates :email, format: { :with => /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/ }
	validates :last_name, presence: true,format: { with: /\A[a-zA-Z]+\z/,message: "only allows letters" }
	validates :first_name,presence: true,format: { with: /\A[a-zA-Z]+\z/,message: "only allows letters" }
	validates :user_name,presence: true
	validates :phone_number,numericality: { only_integer: true },presence: true
	has_one :wallet
	has_many :posts
	has_many :payments
	has_many :deposits
	# sending a welcome mail after the confirmation
	def after_confirmation
		UserMailer.welcome_email(self).deliver
	end
end
