class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.belongs_to :user, index: true, null: false
      t.text      :text,  null: false
      t.integer   :vote
      t.boolean   :approved, default: false, null: false
      t.belongs_to :book, index: true, foreign_key: true, null: false

      t.timestamps  null: false
    end
  end
end
