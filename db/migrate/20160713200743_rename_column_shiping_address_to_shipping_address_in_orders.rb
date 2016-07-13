class RenameColumnShipingAddressToShippingAddressInOrders < ActiveRecord::Migration
  def change
    rename_column :orders, :shiping_address, :shipping_address
  end
end
