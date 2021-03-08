class AddReasonToRequests < ActiveRecord::Migration[6.0]
  def change
  	add_column :requests,:reason,:string
  	add_column :requests,:status,:string
  end
end
