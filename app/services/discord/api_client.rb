require "net/http"
require "json"

module Discord
  class ApiClient
    BASE_URL = "https://discord.com/api/v10"

    def initialize(application_id: ENV["DISCORD_CLIENT_ID"], bot_token: ENV["DISCORD_BOT_TOKEN"])
      @application_id = application_id
      @bot_token = bot_token
    end

    # Deferred Response の後で送るフォローアップメッセージ
    def create_followup_message(interaction_token:, content:)
      uri = URI("#{BASE_URL}/webhooks/#{@application_id}/#{interaction_token}")
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = { content: content }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      if response.code.to_i.between?(200, 299)
        JSON.parse(response.body)
      else
        Rails.logger.error "Followup message failed: #{response.code} #{response.body}"
        nil
      end
    rescue => e
      Rails.logger.error "Error sending followup message: #{e.message}"
      nil
    end

    # フォローアップメッセージにEmbedを含める版
    def create_followup_message_with_embeds(interaction_token:, content: nil, embeds: nil)
      uri = URI("#{BASE_URL}/webhooks/#{@application_id}/#{interaction_token}")
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"

      body = {}
      body[:content] = content if content
      body[:embeds] = embeds if embeds
      request.body = body.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      if response.code.to_i.between?(200, 299)
        JSON.parse(response.body)
      else
        Rails.logger.error "Followup with embeds failed: #{response.code} #{response.body}"
        nil
      end
    rescue => e
      Rails.logger.error "Error sending followup with embeds: #{e.message}"
      nil
    end

    # 即時にEmbedを返す(Deferred Responseを使わない場合)
    # Note: このメソッドは使わない場合もあるが、参考として実装
    def create_message_with_embed(interaction_token:, embeds:)
      uri = URI("#{BASE_URL}/webhooks/#{@application_id}/#{interaction_token}")
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = { embeds: embeds }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      if response.code.to_i.between?(200, 299)
        JSON.parse(response.body)
      else
        Rails.logger.error "Embed message failed: #{response.code} #{response.body}"
        nil
      end
    rescue => e
      Rails.logger.error "Error sending embed message: #{e.message}"
      nil
    end
  end
end
