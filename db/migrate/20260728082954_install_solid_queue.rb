class InstallSolidQueue < ActiveRecord::Migration[8.1]
  def up
    # queue_schema.rbの内容を読み込んで実行
    load Rails.root.join("db", "queue_schema.rb")
  end

  def down
    # ロールバックは非対応
    raise ActiveRecord::IrreversibleMigration
  end
end
