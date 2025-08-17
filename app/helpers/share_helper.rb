module ShareHelper
  def x_share_url(text:, url:, hashtags: [], via: nil)
    base = "https://twitter.com/intent/tweet"
    params = {
      text: text,
      url:  url,
      hashtags: (hashtags.presence && hashtags.join(",")),
      via: via.presence
    }.compact_blank
    "#{base}?#{params.to_query}"
  end
end