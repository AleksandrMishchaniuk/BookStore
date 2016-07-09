class CreateBooksCategories < ActiveRecord::Migration
  def change
    create_table :books_categories, id: false do |t|
      t.belongs_to :book, index: true, foreign_key: true
      t.belongs_to :category, index: true, foreign_key: true
    end
    add_index :books_categories, [:book_id, :category_id], :unique => true
  end
end
