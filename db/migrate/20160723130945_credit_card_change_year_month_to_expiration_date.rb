class CreditCardChangeYearMonthToExpirationDate < ActiveRecord::Migration
  def change
    change_table :credit_cards do |t|
      t.remove :expiration_month
      t.remove :expiration_year
      t.date :expiration_date, null: false
    end
  end
end
