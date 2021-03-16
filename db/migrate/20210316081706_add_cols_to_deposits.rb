class AddColsToDeposits < ActiveRecord::Migration[6.0]
  def change
  	add_column :deposits,:deposit_reference,:string
  	add_column :requests,:start_time,:time
  end
end
