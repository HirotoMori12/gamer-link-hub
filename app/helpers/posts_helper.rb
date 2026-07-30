module PostsHelper
  # 本文中のURLを自動的にリンク化
  def auto_link_urls(text)
    return "" if text.blank?

    # URLを検出して<a>タグに変換
    url_pattern = %r{(https?://[^\s]+)}
    escaped = h(text)
    linked = escaped.gsub(url_pattern) do |url|
      %(<a href="#{url}" target="_blank" rel="noopener noreferrer" class="text-indigo-600 hover:underline break-all">#{url}</a>)
    end
    linked.html_safe
  end
end
