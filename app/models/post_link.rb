class PostLink < ApplicationRecord
  belongs_to :post
  belongs_to :related_post, class_name: "Post"

  validates :related_post_id, uniqueness: { scope: :post_id }
  validate :cannot_link_to_self
  validate :must_be_same_guild

  private

  def cannot_link_to_self
    return if post_id.nil? || related_post_id.nil?

    errors.add(:related_post_id, "自分自身を関連付けることはできません") if post_id == related_post_id
  end

  def must_be_same_guild
    return if post.blank? || related_post.blank?

    errors.add(:related_post, "別サーバーの投稿とは関連付けられません") if post.guild_id != related_post.guild_id
  end
end
