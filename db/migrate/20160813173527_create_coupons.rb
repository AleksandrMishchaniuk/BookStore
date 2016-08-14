class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string      :code, null: false
      t.decimal     :discount, null: false
      t.boolean     :used, default: false
      t.belongs_to  :order, index: true
      t.timestamps null: false
    end
  end
end
