class CreateGuilds < ActiveRecord::Migration[8.1]
  def change
    create_table :guilds do |t|
      t.string :discord_guild_id, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :guilds, :discord_guild_id, unique: true
  end
end
