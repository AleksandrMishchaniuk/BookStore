class RenameColumnTypeToDeliveryTypeInDeliveries < ActiveRecord::Migration
  def change
    rename_column :deliveries, :type, :delivery_type
  end
end
