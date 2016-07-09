class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.belongs_to :order, index: true, null: false
      t.belongs_to :book, index: true, null: false
      t.integer :book_count, null: false
      t.timestamps null: false
    end
  end
end
