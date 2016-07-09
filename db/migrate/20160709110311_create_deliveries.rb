class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.string :type, null: false
      t.decimal :price
      t.timestamps null: false
    end

    add_reference :orders, :delivery, index: true, foreign_key: true
  end
end
