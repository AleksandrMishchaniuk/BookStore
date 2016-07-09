class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :address_line, null: false
      t.string :city, null: false
      t.string :country, null: false
      t.string :zip, null: false
      t.string :phone, null: false
      t.timestamps null: false
    end

    add_column :orders, :billing_address, :integer, index: true
    add_column :orders, :shiping_address, :integer, index: true
    add_foreign_key :orders, :addresses, column: :billing_address
    add_foreign_key :orders, :addresses, column: :shiping_address
  end
end
