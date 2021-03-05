class AddColumnToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :updated_text, :text
  end
end
