Rails.application.config.middleware.use OmniAuth::Builder do
  provider :discord,
           ENV["DISCORD_CLIENT_ID"],
           ENV["DISCORD_CLIENT_SECRET"],
           scope: "identify guilds"
end

OmniAuth.config.allowed_request_methods = [:post]
OmniAuth.config.silence_get_warning = true

# 開発環境ではCSRF検証をスキップ(本番環境では必ずtrueに)
if Rails.env.development?
  OmniAuth.config.request_validation_phase = ->(env) { true }
end
