require "rails_helper"

RSpec.describe HomeController, type: :controller do
  render_views

  describe "GET #index" do
    it "未ログインの場合はログインボタンを表示する" do
      get :index

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Discordでログイン")
    end

    it "ログイン済みの場合はBotインストールリンクを表示する" do
      user = create(:user)
      session[:user_id] = user.id

      get :index

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Botをサーバーに追加する")
    end
  end
end
