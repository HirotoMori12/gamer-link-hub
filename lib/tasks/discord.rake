require "net/http"
require "json"
require "uri"

namespace :discord do
  namespace :commands do
    desc "Register application commands (guild-scoped)"
    task register: :environment do
      application_id = ENV["DISCORD_CLIENT_ID"]
      bot_token = ENV["DISCORD_BOT_TOKEN"]
      guild_id = ENV["DISCORD_TEST_GUILD_ID"]

      if application_id.blank? || bot_token.blank? || guild_id.blank?
        puts "エラー: 環境変数が不足しています"
        puts "  DISCORD_CLIENT_ID: #{application_id.present? ? 'OK' : 'NG'}"
        puts "  DISCORD_BOT_TOKEN: #{bot_token.present? ? 'OK' : 'NG'}"
        puts "  DISCORD_TEST_GUILD_ID: #{guild_id.present? ? 'OK' : 'NG'}"
        exit 1
      end

      commands = [
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
      ]

      uri = URI("https://discord.com/api/v10/applications/#{application_id}/guilds/#{guild_id}/commands")
      request = Net::HTTP::Put.new(uri)
      request["Authorization"] = "Bot #{bot_token}"
      request["Content-Type"] = "application/json"
      request.body = commands.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      if response.code == "200"
        registered_commands = JSON.parse(response.body)
        puts "コマンド登録成功: #{registered_commands.length}件"
        registered_commands.each do |cmd|
          puts "  - #{cmd['name']} (type: #{cmd['type']})"
        end
      else
        puts "コマンド登録失敗: HTTPステータス #{response.code}"
        puts response.body
        exit 1
      end
    end

    desc "List registered commands"
    task list: :environment do
      application_id = ENV["DISCORD_CLIENT_ID"]
      bot_token = ENV["DISCORD_BOT_TOKEN"]
      guild_id = ENV["DISCORD_TEST_GUILD_ID"]

      uri = URI("https://discord.com/api/v10/applications/#{application_id}/guilds/#{guild_id}/commands")
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bot #{bot_token}"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      if response.code == "200"
        commands = JSON.parse(response.body)
        puts "登録済みコマンド: #{commands.length}件"
        commands.each do |cmd|
          puts "  - #{cmd['name']} (id: #{cmd['id']}, type: #{cmd['type']})"
        end
      else
        puts "コマンド取得失敗: HTTPステータス #{response.code}"
        puts response.body
      end
    end

    desc "Delete all registered commands"
    task clear: :environment do
      application_id = ENV["DISCORD_CLIENT_ID"]
      bot_token = ENV["DISCORD_BOT_TOKEN"]
      guild_id = ENV["DISCORD_TEST_GUILD_ID"]

      uri = URI("https://discord.com/api/v10/applications/#{application_id}/guilds/#{guild_id}/commands")
      request = Net::HTTP::Put.new(uri)
      request["Authorization"] = "Bot #{bot_token}"
      request["Content-Type"] = "application/json"
      request.body = [].to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      if response.code == "200"
        puts "全コマンド削除完了"
      else
        puts "削除失敗: HTTPステータス #{response.code}"
        puts response.body
      end
    end
  end
end
