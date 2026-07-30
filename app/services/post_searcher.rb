class PostSearcher
  attr_reader :guild, :keyword

  def initialize(guild:, keyword:)
    @guild = guild
    @keyword = keyword
  end

  def search(limit: 5)
    return Post.none if guild.nil? || keyword.blank?

    guild.posts
         .search_by_keyword(keyword)
         .includes(:tags, :images)
         .order(created_at: :desc)
         .limit(limit)
  end
end
