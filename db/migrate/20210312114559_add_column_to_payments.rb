class AddColumnToPayments < ActiveRecord::Migration[6.0]
  def change
  	add_column :payments,:admin_id ,:integer
  	change_column_null :payments,:user_id, true
  end
end
