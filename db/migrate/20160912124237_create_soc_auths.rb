class CreateSocAuths < ActiveRecord::Migration
  def change
    create_table :soc_auths do |t|
      t.string      :uid, index: true, null: false
      t.string      :provider, index: true, null: false
      t.text        :data
      t.belongs_to  :user, index: true, null: false
      t.timestamps null: false
    end
  end
end
