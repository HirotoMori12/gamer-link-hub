class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :discord_uid, null: false
      t.string :username, null: false
      t.string :avatar_url

      t.timestamps
    end

    add_index :users, :discord_uid, unique: true
  end
end
