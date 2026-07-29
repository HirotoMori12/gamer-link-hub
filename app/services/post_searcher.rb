class PostSearcher
  attr_reader :guild, :keyword

  def initialize(guild:, keyword:)
    @guild = guild
    @keyword = keyword
  end

  def search(limit: 5)
    return Post.none if guild.nil? || keyword.blank?

    # Ransackを使ってbodyまたはtag名で検索
    guild.posts
         .ransack(m: "or",
                  body_cont: keyword,
                  tags_name_cont: keyword)
         .result(distinct: true)
         .includes(:tags, :images)
         .order(created_at: :desc)
         .limit(limit)
  end
end
