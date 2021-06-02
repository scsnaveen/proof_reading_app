class Coupon < ApplicationRecord
	has_many :coupon_redemptions
	before_save :upcase_code
	def coupon_types_enum
		[ 'amount', 'percentage'  ]
	end
	def upcase_code
		self.code.upcase!
	end

	rails_admin do 
		edit do 
			field :coupon_type, :enum do
				render do
					bindings[:form].select( "coupon_type", bindings[:object].coupon_types_enum, {})
				end
			end
			include_all_fields
		end
	end
end
