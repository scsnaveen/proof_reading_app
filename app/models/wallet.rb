class Wallet < ApplicationRecord
	belongs_to :user, optional: true
end
