require "rails_helper"

RSpec.describe GuildsController, type: :controller do
  render_views

  let(:user) { create(:user) }

  describe "GET #index" do
    it "未ログインの場合はrootへリダイレクトする" do
      get :index

      expect(response).to redirect_to(root_path)
    end

    it "ログイン済みの場合は所属サーバー一覧とBotインストールリンクを表示する" do
      guild = create(:guild)
      create(:user_guild, user: user, guild: guild)
      session[:user_id] = user.id

      get :index

      expect(response).to have_http_status(:ok)
      expect(assigns(:guilds)).to include(guild)
      expect(response.body).to include("Botをサーバーに追加する")
    end
  end

  describe "POST #select" do
    it "自分の所属するguildを選択できる" do
      guild = create(:guild)
      create(:user_guild, user: user, guild: guild)
      session[:user_id] = user.id

      post :select, params: { id: guild.id }

      expect(session[:current_guild_id]).to eq(guild.id)
      expect(response).to redirect_to(root_path)
    end

    it "所属していないguildは選択できない" do
      other_guild = create(:guild)
      session[:user_id] = user.id

      expect {
        post :select, params: { id: other_guild.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
