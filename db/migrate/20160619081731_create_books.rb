class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.text :short_description
      t.text :full_description
      t.string :image
      t.decimal :price

      t.timestamps null: false
    end
  end
end
