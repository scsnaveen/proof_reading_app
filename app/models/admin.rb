class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,:lockable,:timeoutable,:trackable
    has_one :wallet
  	serialize :roles, Array
    def roles_enum
        [ 'Super Admin', 'Admin'  ]
    end

    rails_admin do 
		edit do 
			field :role, :enum do
				render do
					bindings[:form].select( "role", bindings[:object].roles_enum, {})
				end
			end
			include_all_fields
		end
	end
end
