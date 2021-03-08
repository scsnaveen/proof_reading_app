class AddPerWordAmountColumnToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :per_word_amount, :decimal
  end
end
