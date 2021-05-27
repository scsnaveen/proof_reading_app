class User < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise	:database_authenticatable, :registerable,
					:recoverable, :rememberable, :validatable,
					:confirmable,:lockable,:trackable
	# validation for email
	validates :email, :presence => true,format: {:with => /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/, message: "invalid format "}
	# validation for password
	validates :password, :presence => true,:confirmation => true,:length => {:within => 8..40},:on => :create,format: {:with => /\A^(?=.*[A-Z])(?=.*\d.*)(?=.*\W.*)[a-zA-Z0-9\S]{1,15}$\z/, message: "should contain an upper case letter,a number, a special symbol from [@#$%&] and an optional lower case letter "}
	# validation for first name 
	validates :first_name, presence: true,format: { with: /\A[a-zA-Z]+\z/,message: "must be in alphabets" }
	# validation for last name
	validates :last_name,presence: true,format: { with: /\A[a-zA-Z]+\z/,message: "must be in alphabets " }
	# validation for phone number
	validates :phone_number,format: { with: /\A^[6-9]\d{9}$\z/, message: " invalid" },presence: true,:length => { :minimum => 10, :maximum => 15 }
	# validation for user name
	validates :user_name,presence: true
	has_one :wallet
	has_many :posts
	has_many :payments
	has_many :deposits
	# sending a welcome mail after the confirmation
	def after_confirmation
		UserMailer.welcome_email(self).deliver
	end
end
