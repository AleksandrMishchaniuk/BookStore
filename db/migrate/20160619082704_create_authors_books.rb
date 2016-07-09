class CreateAuthorsBooks < ActiveRecord::Migration
  def change
    create_table :authors_books, id: false do |t|
      t.belongs_to :author, index: true, foreign_key: true
      t.belongs_to :book, index: true, foreign_key: true
    end

    add_index :authors_books, [:author_id, :book_id]
  end
end
