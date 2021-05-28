class ChangeColsInRequests < ActiveRecord::Migration[6.0]
  def change
  	rename_column :requests,:accepted_admin,:admin_id
  	remove_column :requests,:rejected_admin,:integer,array: true, default: []
  	remove_column :requests,:start_time,:datetime
  end
end
