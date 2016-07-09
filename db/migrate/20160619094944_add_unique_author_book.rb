class AddUniqueAuthorBook < ActiveRecord::Migration
  def change
    remove_index :authors_books, [:author_id, :book_id]
    add_index :authors_books, [:author_id, :book_id], :unique => true
  end
end
