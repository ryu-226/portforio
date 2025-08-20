module MetaTagsHelper
  def set_meta_tags_for(title:, description:, image_url:, url: request.original_url, type: "website",
                        twitter_card: "summary_large_image")
    tags = []
    # Open Graph
    tags << tag.meta(property: "og:title",       content: title)
    tags << tag.meta(property: "og:description", content: description)
    tags << tag.meta(property: "og:image",       content: image_url)
    tags << tag.meta(property: "og:image:secure_url", content: image_url)
    tags << tag.meta(property: "og:image:width",  content: "1200")
    tags << tag.meta(property: "og:image:height", content: "630")
    tags << tag.meta(property: "og:url",         content: url)
    tags << tag.meta(property: "og:type",        content: type)
    tags << tag.meta(property: "og:site_name",   content: "めしガチャ")
    # Twitter
    tags << tag.meta(name: "twitter:card",        content: twitter_card)
    tags << tag.meta(name: "twitter:title",       content: title)
    tags << tag.meta(name: "twitter:description", content: description)
    tags << tag.meta(name: "twitter:image",       content: image_url)
    tags << tag.meta(name: "twitter:image:alt",   content: title)

    tags << tag.link(rel: "canonical", href: url)

    content_for(:meta, safe_join(tags, "\n"))
  end

  require "uri"
  def absolute_url(path_or_url)
    begin
      uri = URI.parse(path_or_url.to_s)
      return path_or_url if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
    end
    host  = Rails.application.routes.default_url_options[:host] || request&.host
    proto = Rails.application.routes.default_url_options[:protocol] || (request&.ssl? ? "https" : "http")
    "#{proto}://#{host}#{path_or_url}"
  end
end