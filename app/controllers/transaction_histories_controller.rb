class TransactionHistoriesController < ApplicationController
	before_action :authenticate_admin!
end
