class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.string :number, null: false
      t.date :expiration_date
      t.string :code
      t.timestamps null: false
    end

    add_reference :orders, :credit_card, index: true, foreign_key: true
  end
end
