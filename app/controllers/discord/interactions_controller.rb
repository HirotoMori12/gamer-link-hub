module Discord
  class InteractionsController < ApplicationController
    # DiscordからのリクエストにはCSRFトークンがないため、この検証は無効化
    skip_before_action :verify_authenticity_token
    before_action :verify_discord_signature

    # Interactionタイプ
    PING = 1
    APPLICATION_COMMAND = 2
    MESSAGE_COMPONENT = 3

    # レスポンスタイプ
    PONG = 1
    CHANNEL_MESSAGE_WITH_SOURCE = 4
    DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE = 5

    def create
      case interaction_params[:type]
      when PING
        render json: { type: PONG }
      when APPLICATION_COMMAND
        # 後のIssueで実装
        render json: { type: CHANNEL_MESSAGE_WITH_SOURCE, data: { content: "コマンドを受信しました" } }
      else
        render json: { error: "Unsupported interaction type" }, status: :bad_request
      end
    end

    private

    def interaction_params
      @interaction_params ||= JSON.parse(request.raw_post, symbolize_names: true)
    rescue JSON::ParserError
      {}
    end

    def verify_discord_signature
      signature = request.headers["X-Signature-Ed25519"]
      timestamp = request.headers["X-Signature-Timestamp"]
      body = request.raw_post

      verifier = Discord::SignatureVerifier.new
      unless verifier.verify(signature: signature, timestamp: timestamp, body: body)
        head :unauthorized
      end
    end
  end
end
