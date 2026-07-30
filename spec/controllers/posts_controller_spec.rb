require "rails_helper"

RSpec.describe PostsController, type: :controller do
  let(:guild) { create(:guild) }
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:post_record) { create(:post, user: owner, guild: guild) }

  before do
    create(:user_guild, user: owner, guild: guild)
    create(:user_guild, user: other_user, guild: guild)
  end

  def login_as(user, guild:)
    session[:user_id] = user.id
    session[:current_guild_id] = guild.id
  end

  describe "認証・Guild選択のガード" do
    it "未ログインの場合はrootへリダイレクトする" do
      get :index

      expect(response).to redirect_to(root_path)
    end

    it "Guild未選択の場合はguilds_pathへリダイレクトする" do
      session[:user_id] = owner.id

      get :index

      expect(response).to redirect_to(guilds_path)
    end
  end

  describe "GET #index" do
    before { login_as(owner, guild: guild) }

    it "現在のguildの投稿一覧を取得する" do
      get :index

      expect(response).to have_http_status(:ok)
      expect(assigns(:posts)).to include(post_record)
    end

    it "他guildの投稿は含まれない" do
      other_guild_post = create(:post, guild: create(:guild))

      get :index

      expect(assigns(:posts)).not_to include(other_guild_post)
    end

    it "keywordで本文・タグを絞り込める" do
      matching = create(:post, guild: guild, user: owner, body: "VRChatワールドのリンクです")

      get :index, params: { keyword: "VRChat" }

      expect(assigns(:posts)).to include(matching)
      expect(assigns(:posts)).not_to include(post_record)
    end

    it "tag_idで絞り込める" do
      tag = create(:tag, guild: guild)
      tagged = create(:post, guild: guild, user: owner)
      tagged.tags << tag

      get :index, params: { tag_id: tag.id }

      expect(assigns(:posts)).to include(tagged)
      expect(assigns(:posts)).not_to include(post_record)
    end
  end

  describe "GET #show" do
    before { login_as(owner, guild: guild) }

    it "本人の投稿の場合is_ownerがtrueになる" do
      get :show, params: { id: post_record.id }

      expect(response).to have_http_status(:ok)
      expect(assigns(:is_owner)).to eq(true)
    end

    it "他人の投稿の場合is_ownerがfalseになる(閲覧自体は可能)" do
      other_post = create(:post, user: other_user, guild: guild)

      get :show, params: { id: other_post.id }

      expect(response).to have_http_status(:ok)
      expect(assigns(:is_owner)).to eq(false)
    end

    it "他guildの投稿にはアクセスできない" do
      other_guild_post = create(:post, guild: create(:guild))

      expect {
        get :show, params: { id: other_guild_post.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #edit" do
    before { login_as(owner, guild: guild) }

    it "本人の場合は編集画面を表示する" do
      get :edit, params: { id: post_record.id }

      expect(response).to have_http_status(:ok)
    end

    it "本人以外の場合は詳細画面へリダイレクトする(require_owner!)" do
      other_post = create(:post, user: other_user, guild: guild)

      get :edit, params: { id: other_post.id }

      expect(response).to redirect_to(post_path(other_post))
      expect(flash[:alert]).to be_present
    end
  end

  describe "PATCH #update" do
    before { login_as(owner, guild: guild) }

    it "本人の場合は本文とタグを更新できる" do
      patch :update, params: { id: post_record.id, post: { body: "更新後の本文", tag_names: "VRChat, Mod" } }

      post_record.reload
      expect(response).to redirect_to(post_path(post_record))
      expect(post_record.body).to eq("更新後の本文")
      expect(post_record.tags.pluck(:name)).to contain_exactly("VRChat", "Mod")
    end

    it "タグ名を空にすると既存のタグとの紐づけが解除される" do
      tag = create(:tag, guild: guild, name: "既存タグ")
      post_record.tags << tag

      patch :update, params: { id: post_record.id, post: { body: post_record.body, tag_names: "" } }

      expect(post_record.reload.tags).to be_empty
    end

    it "本文が空だと更新に失敗し編集画面を再表示する" do
      patch :update, params: { id: post_record.id, post: { body: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(post_record.reload.body).not_to eq("")
    end

    it "本人以外は更新できない(require_owner!)" do
      other_post = create(:post, user: other_user, guild: guild, body: "元の本文")

      patch :update, params: { id: other_post.id, post: { body: "改ざんされた本文" } }

      expect(response).to redirect_to(post_path(other_post))
      expect(other_post.reload.body).to eq("元の本文")
    end
  end

  describe "DELETE #destroy" do
    before { login_as(owner, guild: guild) }

    it "本人の場合は削除できる" do
      expect {
        delete :destroy, params: { id: post_record.id }
      }.to change(Post, :count).by(-1)

      expect(response).to redirect_to(posts_path)
    end

    it "本人以外は削除できない(require_owner!)" do
      other_post = create(:post, user: other_user, guild: guild)

      expect {
        delete :destroy, params: { id: other_post.id }
      }.not_to change(Post, :count)

      expect(response).to redirect_to(post_path(other_post))
    end
  end
end
