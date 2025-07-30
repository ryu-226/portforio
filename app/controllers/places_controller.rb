require 'net/http'

class PlacesController < ApplicationController
  protect_from_forgery except: :search

  def search
    uri = URI("https://places.googleapis.com/v1/places:searchNearby")
    headers = {
      "Content-Type" => "application/json",
      "X-Goog-Api-Key" => ENV["GOOGLE_PLACES_API_KEY"],
      "X-Goog-FieldMask" => "places.displayName,places.location,places.formattedAddress,places.rating"
    }
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.post(uri.path, request.raw_post, headers)
    end

    body_utf8 = res.body.force_encoding("UTF-8")

    render json: JSON.parse(body_utf8), status: res.code.to_i
  end
end
