class AddAssociationAddressUser < ActiveRecord::Migration
  def change
    add_column :addresses, :shipping_for_user, :integer, index: true
    add_column :addresses, :billing_for_user, :integer, index: true
    add_foreign_key :addresses, :users, column: :shipping_for_user
    add_foreign_key :addresses, :users, column: :billing_for_user
  end
end
