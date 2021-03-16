class TransactionHistory < ApplicationRecord
	belongs_to :admin,optional: true
end
