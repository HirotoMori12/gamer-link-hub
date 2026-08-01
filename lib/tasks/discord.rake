namespace :discord do
  namespace :commands do
    COMMANDS = [
      {
        name: "この情報を保存",
        type: 3
      },
      {
        name: "search",
        description: "保存された情報を検索します",
        type: 1,
        options: [
          {
            name: "keyword",
            description: "検索キーワード",
            type: 3,
            required: true
          }
        ]
      }
    ].freeze

    def discord_require_env!(*names)
      missing = names.select { |name| ENV[name].blank? }
      return if missing.empty?

      puts "エラー: 環境変数が不足しています"
      names.each { |name| puts "  #{name}: #{ENV[name].present? ? 'OK' : 'NG'}" }
      exit 1
    end

    def discord_report_result(result, success_message)
      if result
        puts success_message
        Array(result).each { |cmd| puts "  - #{cmd['name']} (id: #{cmd['id']}, type: #{cmd['type']})" }
      else
        puts "失敗しました(ログを確認してください)"
        exit 1
      end
    end

    desc "Register application commands to the test guild only (instant, for local development)"
    task register: :environment do
      discord_require_env! "DISCORD_CLIENT_ID", "DISCORD_BOT_TOKEN", "DISCORD_TEST_GUILD_ID"

      result = Discord::ApiClient.new.register_guild_commands(ENV["DISCORD_TEST_GUILD_ID"], COMMANDS)
      discord_report_result(result, "コマンド登録成功(テストサーバーのみ、即時反映): #{Array(result).length}件")
    end

    desc "List commands registered to the test guild"
    task list: :environment do
      discord_require_env! "DISCORD_CLIENT_ID", "DISCORD_BOT_TOKEN", "DISCORD_TEST_GUILD_ID"

      result = Discord::ApiClient.new.list_guild_commands(ENV["DISCORD_TEST_GUILD_ID"])
      discord_report_result(result, "登録済みコマンド(テストサーバー): #{Array(result).length}件")
    end

    desc "Delete all commands registered to the test guild"
    task clear: :environment do
      discord_require_env! "DISCORD_CLIENT_ID", "DISCORD_BOT_TOKEN", "DISCORD_TEST_GUILD_ID"

      Discord::ApiClient.new.clear_guild_commands(ENV["DISCORD_TEST_GUILD_ID"])
      puts "テストサーバーの全コマンド削除完了"
    end

    desc "Register application commands globally (all guilds the bot is in; can take up to ~1 hour to propagate)"
    task register_global: :environment do
      discord_require_env! "DISCORD_CLIENT_ID", "DISCORD_BOT_TOKEN"

      result = Discord::ApiClient.new.register_global_commands(COMMANDS)
      discord_report_result(result, "コマンド登録成功(グローバル、反映まで最大1時間程度): #{Array(result).length}件")
    end

    desc "List globally registered commands"
    task list_global: :environment do
      discord_require_env! "DISCORD_CLIENT_ID", "DISCORD_BOT_TOKEN"

      result = Discord::ApiClient.new.list_global_commands
      discord_report_result(result, "登録済みコマンド(グローバル): #{Array(result).length}件")
    end

    desc "Delete all globally registered commands"
    task clear_global: :environment do
      discord_require_env! "DISCORD_CLIENT_ID", "DISCORD_BOT_TOKEN"

      Discord::ApiClient.new.clear_global_commands
      puts "グローバルコマンド全削除完了"
    end
  end
end
