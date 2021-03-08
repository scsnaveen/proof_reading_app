class CreateRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :requests do |t|
    	t.integer :post_id
    	t.integer :accepted_admin
    	t.integer :rejected_admin, array: true, default: []
    	t.time :time_taken


      t.timestamps
    end
  end
end
