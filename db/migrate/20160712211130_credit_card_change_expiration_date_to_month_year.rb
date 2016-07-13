class CreditCardChangeExpirationDateToMonthYear < ActiveRecord::Migration
  def change
    change_table :credit_cards do |t|
      t.remove :expiration_date
      t.integer :expiration_month,  null: false
      t.integer :expiration_year,   null: false
    end
  end
end
