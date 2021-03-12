class ChangeColumn < ActiveRecord::Migration[6.0]
  def up
  	    change_column :posts, :per_word_amount, :decimal, {:default => 5}
    end

    def down
  	    change_column :posts, :per_word_amount, :decimal, {:default => 5}
    end
end
