class CreatePostLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :post_links do |t|
      t.references :post, null: false, foreign_key: { on_delete: :cascade }
      t.references :related_post, null: false, foreign_key: { to_table: :posts, on_delete: :cascade }

      t.timestamps
    end

    add_index :post_links, [:post_id, :related_post_id], unique: true
  end
end
