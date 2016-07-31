class AddColumnStateIdToOrderStates < ActiveRecord::Migration
  def change
    add_column :order_states, :id_of_state, :integer
  end
end
