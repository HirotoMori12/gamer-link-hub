class CreateUserGuilds < ActiveRecord::Migration[8.1]
  def change
    create_table :user_guilds do |t|
      t.references :user, null: false, foreign_key: true
      t.references :guild, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_guilds, [:user_id, :guild_id], unique: true
  end
end
