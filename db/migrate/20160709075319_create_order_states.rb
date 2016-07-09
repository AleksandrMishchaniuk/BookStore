class CreateOrderStates < ActiveRecord::Migration
  def change
    create_table :order_states do |t|
      t.string :state
      t.timestamps null: false
    end
  end
end
