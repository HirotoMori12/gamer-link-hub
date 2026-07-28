class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :guild, null: false, foreign_key: true
      t.text :body
      t.string :discord_message_id

      t.timestamps
    end

    add_index :posts, :discord_message_id
  end
end
