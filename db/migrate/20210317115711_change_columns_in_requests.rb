class ChangeColumnsInRequests < ActiveRecord::Migration[6.0]
  def change
  	remove_column :requests,:start_time,:time
  	add_column :requests,:start_time,:datetime
  	remove_column :requests,:time_taken,:time
  	add_column :requests,:time_taken,:integer
  end
end
