class Post < ApplicationRecord
  belongs_to :user
  rails_admin do 
		edit do
			field :text do
				read_only true
			end
			field :updated_text
		end
	end
end
