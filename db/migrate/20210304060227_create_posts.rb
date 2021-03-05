class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.text :text
      t.references :user, null: false, foreign_key: true
      t.integer :words
      t.string :status, default: "pending" 

      t.timestamps
    end
  end
end
