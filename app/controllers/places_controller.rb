require 'net/http'

class PlacesController < ApplicationController
  protect_from_forgery except: :search

  def search
    req_body = request.raw_post
    parsed   = JSON.parse(req_body) rescue {}

    # Text Search を使う条件（textQueryがある時）: 価格帯で絞るならこちらを送る設計にすると◎
    endpoint = parsed["textQuery"].present? ? "places:searchText" : "places:searchNearby"
    uri = URI("https://places.googleapis.com/v1/#{endpoint}")

    headers = {
      "Content-Type"    => "application/json",
      "X-Goog-Api-Key"  => ENV.fetch("GOOGLE_PLACES_API_KEY"),
      "X-Goog-FieldMask" => [
        "places.id",
        "places.displayName",
        "places.location",
        "places.formattedAddress",
        "places.rating",
        "places.priceLevel",
        "places.websiteUri",
        "places.nationalPhoneNumber",
      ].join(",")
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 10

    res  = http.post(uri.path, req_body, headers)
    body = res.body.to_s.force_encoding("UTF-8")

    # デバッグしやすく：エラー時はレスポンス本文をそのまま返す（必要なら削除OK）
    if res.code.to_i >= 400
      Rails.logger.error("[Places] #{res.code} #{body}")
    end

    render json: JSON.parse(body), status: res.code.to_i
  rescue JSON::ParserError
    render plain: body, status: res.code.to_i
  rescue => e
    Rails.logger.error("[Places] #{e.class}: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end
end