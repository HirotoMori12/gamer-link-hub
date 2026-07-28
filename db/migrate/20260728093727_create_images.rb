class CreateImages < ActiveRecord::Migration[8.1]
  def change
    create_table :images do |t|
      t.references :post, null: false, foreign_key: true
      t.string :image_url, null: false

      t.timestamps
    end
  end
end
