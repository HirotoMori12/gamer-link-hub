module ApplicationHelper
  # BotをDiscordサーバーに追加するためのOAuth2インストールリンク
  # bot: Botユーザーとしてサーバーに参加させる, applications.commands: スラッシュ/メッセージコマンドを使えるようにする
  # 権限(permissions)はGateway未使用・純粋なInteractionsのみのBotのため0で十分
  def discord_bot_install_url
    "https://discord.com/api/oauth2/authorize?client_id=#{ENV['DISCORD_CLIENT_ID']}&scope=bot%20applications.commands&permissions=0"
  end
end
