class RemovePerWordAmountFromPost < ActiveRecord::Migration[6.0]
  def change
    remove_column :posts, :per_word_amount, :decimal
  end
end
