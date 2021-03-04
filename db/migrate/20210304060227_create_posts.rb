class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.text :text
      t.references :user, null: false, foreign_key: true
      t.integer :words
      t.string :status

      t.timestamps
    end
  end
end
